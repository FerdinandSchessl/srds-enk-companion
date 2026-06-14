#!/usr/bin/env python3
"""
Sigma-Operationalisierung: Unabhaengige Lastmessung fuer Hooke-Diagramm.

Operative Spezifikation der Sigma_c-Konjektur (Paper §9.2, Programm C).
Ziel: sigma (User-seitig) x epsilon (NC2) → R² das nach Detrending ueberlebt.

Hinweis: Setzt den ENK-Gold-Korpus voraus (privat / unter DUA, NICHT in diesem
Companion enthalten). Pfade ueber Umgebungsvariablen ENK_REPO / ENK_VENV setzen.

Phase 1: S1-S3 (Embedding), S6-S7 (Token) — ~10min
Phase 2: S4-S5 (GPT-2 User Surprisal) — ~60min, --phase2 Flag
"""

import json, csv, sys, os, math, argparse
from pathlib import Path
from collections import Counter
import numpy as np
from scipy.stats import spearmanr, mannwhitneyu, linregress
from scipy.signal import butter, filtfilt

# ─── Paths (ENK-Gold-Korpus privat/DUA, nicht im Companion) ───
REPO = Path(os.environ.get("ENK_REPO", "."))
INPUT_DIR = REPO / "input"
OUTPUT_DIR = REPO / "output"
VENV = Path(os.environ.get("ENK_VENV", ".venv"))

# ─── Config ───
NC2_WINDOW = 20
SIGMA_WINDOW = 5
MIN_TURNS = 15  # minimum turn-pairs for Hooke analysis
HP_LAMBDA = 100  # Hodrick-Prescott filter


# ═══ Chat Discovery ═══

def discover_chats():
    """Find all chats with gold CSVs."""
    golds = sorted(OUTPUT_DIR.glob("*_gold.csv"))
    chats = []
    for g in golds:
        stem = g.stem.replace("_gold", "")
        # Find matching JSON
        candidates = list(INPUT_DIR.glob(f"{stem}*.json")) + list(INPUT_DIR.glob(f"*{stem}*.json"))
        if not candidates:
            # Try common prefixes
            for prefix in ["chat_", "julia_", ""]:
                candidates = list(INPUT_DIR.glob(f"{prefix}{stem}*.json"))
                if candidates:
                    break
        if candidates:
            chats.append({"json": candidates[0], "gold": g, "stem": stem})
    return chats


def load_chat_turns(json_path):
    """Load chat turns from JSON, return list of (role, text) tuples."""
    with open(json_path, encoding="utf-8") as f:
        data = json.load(f)

    turns = []
    # Handle different JSON formats
    if isinstance(data, list):
        msgs = data
    elif "mapping" in data:
        # ChatGPT export format
        msgs = []
        for node_id, node in data["mapping"].items():
            msg = node.get("message")
            if msg and msg.get("content", {}).get("parts"):
                role = msg.get("author", {}).get("role", "unknown")
                text = " ".join(str(p) for p in msg["content"]["parts"] if isinstance(p, str))
                if text.strip() and role in ("user", "assistant"):
                    msgs.append({"role": role, "text": text,
                                 "create_time": msg.get("create_time", 0) or 0})
        msgs.sort(key=lambda x: x["create_time"])
    elif "messages" in data:
        msgs = data["messages"]
    else:
        msgs = []

    for m in msgs:
        if isinstance(m, dict):
            role = m.get("role", m.get("author", {}).get("role", "unknown"))
            text = m.get("text", "")
            if not text and "content" in m:
                c = m["content"]
                if isinstance(c, str):
                    text = c
                elif isinstance(c, dict) and "parts" in c:
                    text = " ".join(str(p) for p in c["parts"] if isinstance(p, str))
            if text.strip() and role in ("user", "assistant"):
                turns.append((role, text.strip()))

    return turns


def get_turn_pairs(turns):
    """Extract (user_text, ai_text) pairs."""
    pairs = []
    i = 0
    while i < len(turns) - 1:
        if turns[i][0] == "user" and turns[i + 1][0] == "assistant":
            pairs.append((turns[i][1], turns[i + 1][1]))
            i += 2
        else:
            i += 1
    return pairs


def load_mal_frac(gold_path):
    """Load malicious fraction from gold CSV."""
    mal, total = 0, 0
    with open(gold_path, newline="", encoding="utf-8") as f:
        for row in csv.DictReader(f):
            if row.get("speaker", "").lower() == "assistant":
                v = row.get("malicious_typx_nik", "NA")
                if v in ("0", "1"):
                    total += 1
                    if v == "1":
                        mal += 1
    return mal / total if total > 0 else 0.0


# ═══ Embedding ═══

_model_cache = {}

def get_embedder(model_name="all-MiniLM-L6-v2"):
    if model_name not in _model_cache:
        from sentence_transformers import SentenceTransformer
        _model_cache[model_name] = SentenceTransformer(model_name)
    return _model_cache[model_name]


def embed_turns(texts, model_name="all-MiniLM-L6-v2"):
    model = get_embedder(model_name)
    return model.encode(texts, show_progress_bar=False, batch_size=64)


# ═══ NC2 (Epsilon) ═══

def compute_nc2_series(embeddings, window=NC2_WINDOW):
    """NC2 = Effective Rank via SVD Participation Ratio, per window."""
    n = len(embeddings)
    nc2 = []
    for i in range(window, n + 1):
        chunk = embeddings[i - window:i]
        try:
            U, S, Vt = np.linalg.svd(chunk - chunk.mean(axis=0), full_matrices=False)
            S = S[S > 1e-10]
            p = S / S.sum()
            nc2.append(float(np.exp(-np.sum(p * np.log(p + 1e-15)))))
        except Exception:
            nc2.append(np.nan)
    return np.array(nc2)


# ═══ Sigma Candidates ═══

def compute_s1_user_topic_shift(user_embeddings):
    """S1: Cosine distance between consecutive user embeddings."""
    if len(user_embeddings) < 2:
        return np.array([])
    from sklearn.metrics.pairwise import cosine_distances
    shifts = []
    for i in range(1, len(user_embeddings)):
        d = cosine_distances([user_embeddings[i - 1]], [user_embeddings[i]])[0][0]
        shifts.append(d)
    return np.array(shifts)


def compute_s2_user_dispersion(user_embeddings, window=SIGMA_WINDOW):
    """S2: Std of user embeddings in rolling window."""
    n = len(user_embeddings)
    if n < window:
        return np.array([])
    disps = []
    for i in range(window, n + 1):
        chunk = user_embeddings[i - window:i]
        disps.append(float(np.std(np.linalg.norm(chunk - chunk.mean(axis=0), axis=1))))
    return np.array(disps)


def compute_s3_user_ai_divergence(user_embeddings, ai_embeddings, window=SIGMA_WINDOW):
    """S3: Cosine distance between mean user and mean AI embeddings per window."""
    n = min(len(user_embeddings), len(ai_embeddings))
    if n < window:
        return np.array([])
    from sklearn.metrics.pairwise import cosine_distances
    divs = []
    for i in range(window, n + 1):
        u_mean = user_embeddings[i - window:i].mean(axis=0)
        a_mean = ai_embeddings[i - window:i].mean(axis=0)
        d = cosine_distances([u_mean], [a_mean])[0][0]
        divs.append(d)
    return np.array(divs)


def compute_s6_user_vocab_entropy(user_texts, window=SIGMA_WINDOW):
    """S6: Token entropy of user messages per window."""
    # Tokenize simply by whitespace + lowercase
    token_lists = []
    for text in user_texts:
        tokens = text.lower().split()
        token_lists.append(tokens)

    n = len(token_lists)
    if n < window:
        return np.array([])
    entropies = []
    for i in range(window, n + 1):
        all_tokens = []
        for tl in token_lists[i - window:i]:
            all_tokens.extend(tl)
        if not all_tokens:
            entropies.append(0.0)
            continue
        counts = Counter(all_tokens)
        total = sum(counts.values())
        probs = np.array([c / total for c in counts.values()])
        h = -np.sum(probs * np.log2(probs + 1e-15))
        entropies.append(h)
    return np.array(entropies)


def compute_s7_rolling_gini_sv_user(user_embeddings, window=SIGMA_WINDOW):
    """S7: Rolling Gini coefficient of user-only sem_velocity."""
    n = len(user_embeddings)
    if n < 2:
        return np.array([])
    # Compute user sem_velocity
    from sklearn.metrics.pairwise import cosine_distances
    sv = []
    for i in range(1, n):
        d = cosine_distances([user_embeddings[i - 1]], [user_embeddings[i]])[0][0]
        sv.append(d)
    sv = np.array(sv)

    if len(sv) < window:
        return np.array([])
    ginis = []
    for i in range(window, len(sv) + 1):
        chunk = np.sort(sv[i - window:i])
        n_w = len(chunk)
        if n_w == 0 or chunk.sum() == 0:
            ginis.append(0.0)
            continue
        idx = np.arange(1, n_w + 1)
        gini = (2 * np.sum(idx * chunk) - (n_w + 1) * np.sum(chunk)) / (n_w * np.sum(chunk))
        ginis.append(gini)
    return np.array(ginis)


# ═══ GPT-2 User Surprisal (Phase 2) ═══

_gpt2_cache = {}

def get_gpt2():
    if "model" not in _gpt2_cache:
        from transformers import GPT2LMHeadModel, GPT2Tokenizer
        import torch
        tokenizer = GPT2Tokenizer.from_pretrained("gpt2")
        model = GPT2LMHeadModel.from_pretrained("gpt2")
        model.eval()
        _gpt2_cache["model"] = model
        _gpt2_cache["tokenizer"] = tokenizer
        _gpt2_cache["torch"] = torch
    return _gpt2_cache["model"], _gpt2_cache["tokenizer"], _gpt2_cache["torch"]


def compute_turn_surprisal(text, max_tokens=512):
    model, tokenizer, torch = get_gpt2()
    inputs = tokenizer(text, return_tensors="pt", truncation=True, max_length=max_tokens)
    input_ids = inputs["input_ids"]
    if input_ids.shape[1] < 2:
        return None
    with torch.no_grad():
        outputs = model(input_ids, labels=input_ids)
        logits = outputs.logits
    shift_logits = logits[0, :-1, :]
    shift_labels = input_ids[0, 1:]
    log_probs = torch.nn.functional.log_softmax(shift_logits, dim=-1)
    token_log_probs = log_probs.gather(1, shift_labels.unsqueeze(1)).squeeze(1)
    surprisal = -token_log_probs.numpy()
    return {"mean": float(np.mean(surprisal)), "std": float(np.std(surprisal)),
            "max": float(np.max(surprisal))}


def compute_s4_user_surprisal(user_texts):
    """S4: Per-turn mean surprisal of user messages via GPT-2."""
    vals = []
    for text in user_texts:
        r = compute_turn_surprisal(text)
        vals.append(r["mean"] if r else np.nan)
    return np.array(vals)


def compute_s5_user_surprisal_gradient(user_texts):
    """S5: Delta of per-turn surprisal."""
    s4 = compute_s4_user_surprisal(user_texts)
    if len(s4) < 2:
        return np.array([])
    return np.diff(s4)


# ═══ Hooke Analysis ═══

def hp_filter(y, lamb=HP_LAMBDA):
    """Hodrick-Prescott filter: return cycle component."""
    n = len(y)
    if n < 4:
        return y
    I = np.eye(n)
    D2 = np.zeros((n - 2, n))
    for i in range(n - 2):
        D2[i, i] = 1
        D2[i, i + 1] = -2
        D2[i, i + 2] = 1
    trend = np.linalg.solve(I + lamb * D2.T @ D2, y)
    return y - trend  # cycle component


def align_series(sigma, epsilon):
    """Align two time series to same length (trim from start)."""
    n = min(len(sigma), len(epsilon))
    if n < MIN_TURNS:
        return None, None
    return sigma[-n:], epsilon[-n:]


def hooke_analysis(sigma, epsilon, mal_frac):
    """Compute R² level and detrended, return dict."""
    sigma_a, epsilon_a = align_series(sigma, epsilon)
    if sigma_a is None:
        return None

    # Remove NaN
    mask = ~(np.isnan(sigma_a) | np.isnan(epsilon_a))
    if mask.sum() < MIN_TURNS:
        return None
    s, e = sigma_a[mask], epsilon_a[mask]

    # Level R²
    try:
        slope, intercept, r, p, se = linregress(e, s)
        r2_level = r ** 2
    except Exception:
        return None

    # Independence check: correlation between sigma and epsilon
    rho_indep, p_indep = spearmanr(s, e)

    # Detrended R² (HP filter)
    try:
        s_dt = hp_filter(s, HP_LAMBDA)
        e_dt = hp_filter(e, HP_LAMBDA)
        slope_dt, intercept_dt, r_dt, p_dt, se_dt = linregress(e_dt, s_dt)
        r2_detrended = r_dt ** 2
    except Exception:
        r2_detrended = np.nan

    return {
        "r2_level": r2_level,
        "r2_detrended": r2_detrended,
        "rho_independence": rho_indep,
        "n_points": int(mask.sum()),
        "mal_frac": mal_frac,
    }


# ═══ Main ═══

def process_chat(chat_info, model_name="all-MiniLM-L6-v2", phase2=False):
    """Process one chat: compute all sigma candidates + Hooke analysis."""
    turns = load_chat_turns(chat_info["json"])
    pairs = get_turn_pairs(turns)
    mal_frac = load_mal_frac(chat_info["gold"])
    is_mal = 1 if mal_frac > 0.05 else 0

    if len(pairs) < MIN_TURNS:
        return None

    user_texts = [p[0] for p in pairs]
    ai_texts = [p[1] for p in pairs]
    all_texts = []
    for u, a in pairs:
        all_texts.extend([u, a])

    # Embed
    all_emb = embed_turns(all_texts, model_name)
    user_emb = all_emb[0::2]  # even indices = user
    ai_emb = all_emb[1::2]    # odd indices = AI

    # Epsilon: NC2
    nc2 = compute_nc2_series(all_emb, NC2_WINDOW)

    # Sigma candidates (Phase 1)
    sigmas = {}
    sigmas["S1_topic_shift"] = compute_s1_user_topic_shift(user_emb)
    sigmas["S2_dispersion"] = compute_s2_user_dispersion(user_emb, SIGMA_WINDOW)
    sigmas["S3_divergence"] = compute_s3_user_ai_divergence(user_emb, ai_emb, SIGMA_WINDOW)
    sigmas["S6_vocab_entropy"] = compute_s6_user_vocab_entropy(user_texts, SIGMA_WINDOW)
    sigmas["S7_gini_sv_user"] = compute_s7_rolling_gini_sv_user(user_emb, SIGMA_WINDOW)

    # Phase 2: GPT-2 User Surprisal
    if phase2:
        sigmas["S4_user_surprisal"] = compute_s4_user_surprisal(user_texts)
        sigmas["S5_surprisal_grad"] = compute_s5_user_surprisal_gradient(user_texts)

    # Hooke analysis for each sigma
    results = {
        "chat_id": chat_info["stem"],
        "n_pairs": len(pairs),
        "mal_frac": mal_frac,
        "is_mal": is_mal,
        "hooke": {},
    }

    for name, sigma in sigmas.items():
        if len(sigma) == 0:
            continue
        h = hooke_analysis(sigma, nc2, mal_frac)
        if h:
            results["hooke"][name] = h

    return results


def aggregate_results(all_results):
    """Aggregate per-chat results into summary statistics."""
    summary = {}

    # Collect all sigma names
    sigma_names = set()
    for r in all_results:
        sigma_names.update(r["hooke"].keys())

    for sname in sorted(sigma_names):
        chats = [(r["hooke"][sname], r["is_mal"], r["mal_frac"])
                 for r in all_results if sname in r["hooke"]]
        if not chats:
            continue

        r2_level = [c[0]["r2_level"] for c in chats]
        r2_detr = [c[0]["r2_detrended"] for c in chats if not np.isnan(c[0]["r2_detrended"])]
        rho_indep = [c[0]["rho_independence"] for c in chats]
        mal_flags = [c[1] for c in chats]
        mal_fracs = [c[2] for c in chats]

        r2_detr_arr = np.array([c[0]["r2_detrended"] for c in chats
                                if not np.isnan(c[0]["r2_detrended"])])
        mf_arr = np.array([c[2] for c in chats
                           if not np.isnan(c[0]["r2_detrended"])])
        is_mal_arr = np.array([c[1] for c in chats
                               if not np.isnan(c[0]["r2_detrended"])])

        # Mann-Whitney: R²_detrended mal vs base
        mal_r2 = r2_detr_arr[is_mal_arr == 1]
        base_r2 = r2_detr_arr[is_mal_arr == 0]
        if len(mal_r2) > 5 and len(base_r2) > 5:
            u_stat, mw_p = mannwhitneyu(mal_r2, base_r2, alternative="greater")
        else:
            u_stat, mw_p = np.nan, np.nan

        # Spearman: R²_detrended vs mal_frac
        if len(r2_detr_arr) > 10:
            rho_mal, p_mal = spearmanr(r2_detr_arr, mf_arr)
        else:
            rho_mal, p_mal = np.nan, np.nan

        # Independence: mean |cor(sigma, NC2)|
        mean_indep = np.mean(np.abs(rho_indep))

        summary[sname] = {
            "n_chats": len(chats),
            "r2_level_mean": float(np.mean(r2_level)),
            "r2_level_median": float(np.median(r2_level)),
            "r2_detrended_mean": float(np.mean(r2_detr)) if r2_detr else np.nan,
            "r2_detrended_median": float(np.median(r2_detr)) if r2_detr else np.nan,
            "mean_abs_independence": float(mean_indep),
            "rho_vs_mal": float(rho_mal),
            "p_vs_mal": float(p_mal),
            "mw_p": float(mw_p),
            "mal_r2_mean": float(np.mean(mal_r2)) if len(mal_r2) > 0 else np.nan,
            "base_r2_mean": float(np.mean(base_r2)) if len(base_r2) > 0 else np.nan,
        }

    return summary


def grade_candidate(stats):
    """Grade a sigma candidate: GOLD / SILBER / BRONZE / FAIL."""
    r2 = stats.get("r2_detrended_mean", 0)
    rho = stats.get("rho_vs_mal", 0)
    p = stats.get("p_vs_mal", 1)
    indep = stats.get("mean_abs_independence", 1)

    if indep > 0.5:
        return "FAIL (nicht unabhaengig: |cor|={:.2f})".format(indep)
    if r2 > 0.20 and rho > 0.20 and p < 0.05:
        return "GOLD"
    if r2 > 0.10 and rho > 0 and p < 0.05:
        return "SILBER"
    if r2 > 0.07:
        return "BRONZE"
    return "FAIL"


def write_report(summary, all_results, output_path):
    """Write markdown report."""
    lines = ["# Sigma-Operationalisierung — Ergebnisse\n"]
    lines.append(f"**Datum:** {__import__('datetime').date.today()}")
    lines.append(f"**n:** {len(all_results)} Chats")
    lines.append(f"**Referenz:** delta_NC2~NC2 R²_detrended=0.07, rho=-0.160 (n.s.)")
    lines.append(f"**Spec:** ~/archive/spec_sigma_operationalisierung.md\n")
    lines.append("---\n")
    lines.append("## Ergebnis-Tabelle\n")
    lines.append("| Kandidat | n | R²_level | R²_detr | |cor(σ,ε)| | ρ(R²,mal) | p | MW p | Grade |")
    lines.append("|----------|---|----------|---------|-----------|-----------|---|------|-------|")

    for sname in sorted(summary.keys()):
        s = summary[sname]
        grade = grade_candidate(s)
        lines.append(
            f"| {sname} | {s['n_chats']} "
            f"| {s['r2_level_mean']:.3f} "
            f"| {s['r2_detrended_mean']:.3f} "
            f"| {s['mean_abs_independence']:.3f} "
            f"| {s['rho_vs_mal']:+.3f} "
            f"| {s['p_vs_mal']:.4f} "
            f"| {s['mw_p']:.4f} "
            f"| **{grade}** |"
        )

    lines.append("\n---\n")
    lines.append("## Referenz: delta_NC2 ~ NC2 (Baseline)\n")
    lines.append("| R²_level | R²_detrended | ρ vs mal | p |")
    lines.append("|----------|-------------|----------|---|")
    lines.append("| 0.460 | 0.072 | -0.160 | 0.088 |\n")

    # Mal vs Base detail
    lines.append("## Mal vs Base Detail\n")
    lines.append("| Kandidat | mal R²_detr | base R²_detr | Δ |")
    lines.append("|----------|------------|-------------|---|")
    for sname in sorted(summary.keys()):
        s = summary[sname]
        delta = s["mal_r2_mean"] - s["base_r2_mean"] if not (np.isnan(s["mal_r2_mean"]) or np.isnan(s["base_r2_mean"])) else np.nan
        lines.append(
            f"| {sname} | {s['mal_r2_mean']:.3f} | {s['base_r2_mean']:.3f} | {delta:+.3f} |"
        )

    # Best candidate
    lines.append("\n---\n")
    best = None
    best_score = -1
    for sname, s in summary.items():
        score = s["r2_detrended_mean"] * (1 if s["rho_vs_mal"] > 0 else -1)
        if score > best_score and s["mean_abs_independence"] < 0.5:
            best_score = score
            best = sname
    if best:
        lines.append(f"## Bester Kandidat: **{best}**\n")
        s = summary[best]
        lines.append(f"- R²_detrended = {s['r2_detrended_mean']:.3f}")
        lines.append(f"- ρ(R², mal_frac) = {s['rho_vs_mal']:+.3f} (p={s['p_vs_mal']:.4f})")
        lines.append(f"- Kanalunabhaengigkeit: |cor| = {s['mean_abs_independence']:.3f}")
        lines.append(f"- Grade: **{grade_candidate(s)}**")

    lines.append("\n\n---\n")
    lines.append("RESULT: " + ("PASS" if best and "FAIL" not in grade_candidate(summary[best]) else "FAIL")
                 + f" — {best}: R²_dt={summary[best]['r2_detrended_mean']:.3f}, "
                   f"ρ={summary[best]['rho_vs_mal']:+.3f}" if best else " — Kein Kandidat besser als Baseline")

    with open(output_path, "w") as f:
        f.write("\n".join(lines))
    print(f"Report: {output_path}")


def main():
    parser = argparse.ArgumentParser(description="Sigma-Operationalisierung")
    parser.add_argument("--phase2", action="store_true", help="Include GPT-2 user surprisal (S4/S5)")
    parser.add_argument("--model", default="all-MiniLM-L6-v2", help="Embedding model")
    parser.add_argument("--limit", type=int, default=0, help="Limit chats (0=all)")
    args = parser.parse_args()

    print(f"=== Sigma-Operationalisierung ===")
    print(f"Model: {args.model}, Phase2: {args.phase2}")

    os.chdir(REPO)

    chats = discover_chats()
    print(f"Discovered {len(chats)} chats")

    if args.limit > 0:
        chats = chats[:args.limit]
        print(f"Limited to {len(chats)}")

    all_results = []
    for i, chat in enumerate(chats):
        sys.stdout.write(f"\r[{i + 1}/{len(chats)}] {chat['stem'][:50]}...")
        sys.stdout.flush()
        try:
            r = process_chat(chat, args.model, args.phase2)
            if r:
                all_results.append(r)
        except Exception as e:
            print(f"\n  ERROR {chat['stem']}: {e}")

    print(f"\n\nProcessed {len(all_results)} chats successfully")

    summary = aggregate_results(all_results)

    # Print quick overview
    print("\n=== Quick Results ===")
    print(f"{'Kandidat':<25} {'R²_dt':>8} {'ρ_mal':>8} {'p':>8} {'|cor|':>8} {'Grade'}")
    print("-" * 75)
    for sname in sorted(summary.keys()):
        s = summary[sname]
        grade = grade_candidate(s)
        print(f"{sname:<25} {s['r2_detrended_mean']:>8.3f} {s['rho_vs_mal']:>+8.3f} "
              f"{s['p_vs_mal']:>8.4f} {s['mean_abs_independence']:>8.3f} {grade}")

    # Save results
    out_json = REPO / "analysis" / "sigma_candidates_results.json"
    with open(out_json, "w") as f:
        json.dump({"summary": summary, "per_chat": all_results}, f, indent=2, default=str)
    print(f"\nData: {out_json}")

    # Write report
    report_path = REPO / "analysis" / "sigma_operationalisierung_report.md"
    write_report(summary, all_results, report_path)


if __name__ == "__main__":
    main()
