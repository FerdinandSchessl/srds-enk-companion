#!/usr/bin/env python3
"""
Musik-Substrat auf ℓ₂ (Stück-Skala) — Pro-Stück-â auf MIDI/MusicXML.

Konstrukt-Anker: Musik-L2-Praeregistrierung (intern, 2026-05-16)
Strain-Achse: cumsum(|interval|/12) — Pitch-Bewegungs-Energie
Stress-Achse: cumsum(neue_edge) — Vocabulary-Aufbau

Sigmoid-Funktion identisch zu the SRDS sigmoid utility (srds_sigmoid_utils.py).
"""

import argparse
import json
import sys
import traceback
from pathlib import Path
from typing import Optional

import numpy as np
from scipy.optimize import curve_fit


def _sigmoid(x, a, k):
    return 1.0 / (1.0 + np.exp(np.clip(-k * (x - a), -500, 500)))


def fit_sigmoid_ahat(stress_series, strain_series, min_points=15):
    """SRDS-â auf kumulativen Strain (paper-isomorph cumsum-Variante)."""
    stress = np.asarray(stress_series, dtype=float)
    strain = np.asarray(strain_series, dtype=float)
    clean = ~(np.isnan(stress) | np.isnan(strain))
    stress, strain = stress[clean], strain[clean]
    n = len(stress)
    if n < min_points:
        return {"a_hat": np.nan, "k": np.nan, "R2": np.nan, "valid": False, "method": "insufficient_data", "n": n}

    cum_stress = np.cumsum(np.abs(stress))
    cs_min, cs_max = cum_stress.min(), cum_stress.max()
    if cs_max - cs_min < 1e-8:
        return {"a_hat": np.nan, "k": np.nan, "R2": np.nan, "valid": False, "method": "no_stress_variance", "n": n}
    y = (cum_stress - cs_min) / (cs_max - cs_min)

    cum_strain = np.cumsum(np.abs(strain))
    es_min, es_max = cum_strain.min(), cum_strain.max()
    if es_max - es_min < 1e-8:
        x = np.linspace(0, 1, n)
        method = "time_fallback_no_strain_variance"
    else:
        x = (cum_strain - es_min) / (es_max - es_min)
        method = "strain"

    try:
        popt, _ = curve_fit(_sigmoid, x, y, p0=[0.5, 5.0],
                            bounds=([0.01, 0.1], [0.99, 50.0]), maxfev=5000)
        a_hat, k_hat = popt
        y_pred = _sigmoid(x, a_hat, k_hat)
        ss_res = np.sum((y - y_pred) ** 2)
        ss_tot = np.sum((y - y.mean()) ** 2)
        R2 = 1 - ss_res / ss_tot if ss_tot > 1e-10 else 0.0
        return {"a_hat": float(a_hat), "k": float(k_hat), "R2": float(R2),
                "valid": bool(R2 > 0.3), "method": method, "n": n}
    except Exception:
        return {"a_hat": np.nan, "k": np.nan, "R2": np.nan, "valid": False,
                "method": f"{method}_fit_failed", "n": n}


def extract_note_sequence(path: Path) -> Optional[list[int]]:
    """Extract chronological MIDI pitch sequence from a music file."""
    try:
        from music21 import converter
        score = converter.parse(str(path))
    except Exception:
        return None

    notes = []
    try:
        flat = score.flatten().notes
    except Exception:
        flat = score.flat.notes
    for n in flat:
        if hasattr(n, "pitch"):
            notes.append(int(n.pitch.midi))
        elif hasattr(n, "pitches"):
            for p in n.pitches:
                notes.append(int(p.midi))
    return notes if notes else None


def compute_ahat_for_piece(path: Path, min_notes: int = 20) -> dict:
    """Compute â for a single piece. Returns dict with metadata + fit results."""
    notes = extract_note_sequence(path)
    if notes is None:
        return {"path": str(path), "status": "parse_failed"}
    if len(notes) < min_notes:
        return {"path": str(path), "status": "too_short", "n_notes": len(notes)}

    pitches = np.array(notes, dtype=int)
    intervals = np.abs(np.diff(pitches)).astype(float) / 12.0
    seen = set()
    novel = np.zeros(len(intervals), dtype=float)
    for i in range(len(intervals)):
        edge = (int(pitches[i]), int(pitches[i + 1]))
        if edge not in seen:
            novel[i] = 1.0
            seen.add(edge)

    fit = fit_sigmoid_ahat(stress_series=novel, strain_series=intervals)
    return {"path": str(path), "status": "ok", "n_notes": len(notes),
            "n_unique_edges": len(seen), **fit}


def run_batch(paths: list[Path], output_path: Path, label: str = "batch"):
    results = []
    for i, p in enumerate(paths):
        try:
            res = compute_ahat_for_piece(p)
        except Exception as exc:
            res = {"path": str(p), "status": "exception", "error": repr(exc)}
        results.append(res)
        if (i + 1) % 25 == 0 or i == len(paths) - 1:
            print(f"  [{i+1}/{len(paths)}] last: {Path(p).name[:40]} -> {res.get('status')}", flush=True)
    summary = summarize(results, label=label)
    out = {"label": label, "n_input": len(paths), "summary": summary, "results": results}
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(json.dumps(out, indent=2))
    return summary


def summarize(results: list[dict], label: str = "") -> dict:
    ok = [r for r in results if r.get("status") == "ok"]
    valid = [r for r in ok if r.get("valid")]
    ahats = [r["a_hat"] for r in valid if not np.isnan(r["a_hat"])]
    r2s = [r["R2"] for r in valid if not np.isnan(r["R2"])]
    return {
        "label": label,
        "n_total": len(results),
        "n_ok": len(ok),
        "n_valid_fit": len(valid),
        "median_ahat": float(np.median(ahats)) if ahats else None,
        "P25_ahat": float(np.percentile(ahats, 25)) if ahats else None,
        "P75_ahat": float(np.percentile(ahats, 75)) if ahats else None,
        "median_R2": float(np.median(r2s)) if r2s else None,
        "P25_R2": float(np.percentile(r2s, 25)) if r2s else None,
    }


def collect_music21_bach(n_max: int = 50) -> list[Path]:
    """Sanity-Subset aus music21 core corpus (Bach BWV)."""
    from music21 import corpus
    bach_paths = [Path(str(p)) for p in corpus.getCorePaths() if "bwv" in str(p).lower()]
    return bach_paths[:n_max]


def collect_lakh(root: Path, n_max: int = 0) -> list[Path]:
    """Lakh MIDI files unter root sammeln."""
    paths = list(root.rglob("*.mid")) + list(root.rglob("*.midi"))
    if n_max > 0:
        paths = paths[:n_max]
    return paths


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--mode", choices=["sanity", "lakh", "custom"], default="sanity")
    ap.add_argument("--lakh-root", type=Path, default=Path.home() / "data/lakh")
    ap.add_argument("--custom-paths", type=Path, nargs="*")
    ap.add_argument("--n-max", type=int, default=50)
    ap.add_argument("--output", type=Path, default=Path.home() / f"logs/musik_l2_ahat.json")
    args = ap.parse_args()

    if args.mode == "sanity":
        paths = collect_music21_bach(args.n_max)
        label = f"sanity_bach_n{len(paths)}"
    elif args.mode == "lakh":
        paths = collect_lakh(args.lakh_root, args.n_max)
        label = f"lakh_n{len(paths)}"
    else:
        paths = args.custom_paths or []
        label = f"custom_n{len(paths)}"

    if not paths:
        print(f"No paths found for mode={args.mode}", file=sys.stderr)
        sys.exit(2)

    print(f"Running {label}, {len(paths)} pieces, output -> {args.output}", flush=True)
    summary = run_batch(paths, args.output, label=label)
    print()
    print("SUMMARY:")
    print(json.dumps(summary, indent=2))


if __name__ == "__main__":
    main()
