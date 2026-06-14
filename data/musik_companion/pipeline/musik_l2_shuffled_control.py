#!/usr/bin/env python3
"""
Shuffled-Control für Musik-Substrat: prüft ob â-Hierarchie
Vocabulary-Größen-Artefakt ist oder echte Sequenz-Geometrie.

Permutiert pro Stück die Note-Reihenfolge (Multimenge bleibt gleich),
re-fittet Sigmoid, vergleicht Genre-Trennung mit echtem Run.

Erwartung (falls Sequenz-Geometrie):
  - â-Verteilung degeneriert zu engem Gauß um 0.5
  - Genre-Trennung verschwindet (Cohen-d → 0, p_holm → n.s.)

Falsifikations-Bedingung:
  - Wenn Genre-Trennung im Shuffled-Run BLEIBT → Vocabulary-Effekt, nicht Sigmoid-Geometrie

Konstrukt-Anker: Musik-L2-Praeregistrierung (intern, 2026-05-16)
"""

import argparse
import json
import os
import random
import sys
from collections import defaultdict
from pathlib import Path

import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parent))
from musik_l2_ahat_run import fit_sigmoid_ahat, extract_note_sequence
from musik_l2_lakh_cross_genre import parse_tagtraum, extract_tr_id, collect_lakh_per_genre


def compute_ahat_shuffled(path: Path, rng: random.Random, min_notes: int = 20) -> dict:
    """Wie compute_ahat_for_piece, aber mit gemischter Note-Reihenfolge."""
    notes = extract_note_sequence(path)
    if notes is None:
        return {"path": str(path), "status": "parse_failed"}
    if len(notes) < min_notes:
        return {"path": str(path), "status": "too_short", "n_notes": len(notes)}

    notes = list(notes)
    rng.shuffle(notes)  # Permutation auf gleicher Multimenge

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
    return {"path": str(path), "status": "ok", "n_notes": len(notes), **fit}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--lakh-root", type=Path, default=Path("./data/lakh/lmd_matched"))
    ap.add_argument("--tagtraum", type=Path, default=Path("./data/lakh/msd_tagtraum_cd2c.cls"))
    ap.add_argument("--n-per-genre", type=int, default=200)
    ap.add_argument("--targets", nargs="+", default=["Rock", "Pop", "Electronic", "Jazz", "Rap"])
    ap.add_argument("--output", type=Path, default=Path("./logs/musik_l2_shuffled_control.json"))
    ap.add_argument("--seed", type=int, default=42)
    args = ap.parse_args()

    print(f"SHUFFLED-CONTROL: loading tagtraum...", flush=True)
    tagtraum = parse_tagtraum(args.tagtraum)
    targets = set(args.targets)

    by_genre = collect_lakh_per_genre(args.lakh_root, tagtraum, targets, max_per_genre=args.n_per_genre)
    for g in sorted(targets):
        print(f"  {g:12s}: {len(by_genre[g])} MIDIs", flush=True)

    rng = random.Random(args.seed)
    all_results = []
    for genre, paths in by_genre.items():
        random.Random(args.seed).shuffle(paths)
        for p in paths[:args.n_per_genre]:
            try:
                r = compute_ahat_shuffled(p, rng)
            except Exception as exc:
                r = {"path": str(p), "status": "exception", "error": repr(exc)[:80]}
            r["genre"] = genre
            all_results.append(r)
            if len(all_results) % 50 == 0:
                ok = sum(1 for x in all_results if x.get("status") == "ok")
                valid = sum(1 for x in all_results if x.get("valid"))
                print(f"  [{len(all_results)}] last={genre} ok={ok} valid={valid}", flush=True)

    per_genre = defaultdict(list)
    for r in all_results:
        if r.get("valid"):
            per_genre[r["genre"]].append(r["a_hat"])

    summary = {}
    for g, ahats in per_genre.items():
        summary[g] = {
            "n": len(ahats),
            "median_ahat": float(np.median(ahats)),
            "P25": float(np.percentile(ahats, 25)),
            "P75": float(np.percentile(ahats, 75)),
            "std": float(np.std(ahats)),
        }

    r2s = [r["R2"] for r in all_results if r.get("valid")]
    out = {
        "label": "lakh_shuffled_control",
        "n_total": len(all_results),
        "n_valid": sum(1 for r in all_results if r.get("valid")),
        "median_R2": float(np.median(r2s)) if r2s else None,
        "per_genre": summary,
    }
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(out, indent=2))

    print()
    print("=== SHUFFLED-CONTROL SUMMARY (Negativkontroll-Erwartung: ã alle ~0.5, Genre-Trennung verschwindet) ===")
    print(f'n_total={out["n_total"]}, n_valid={out["n_valid"]}, median R²={out["median_R2"]:.3f}')
    for g, s in sorted(summary.items(), key=lambda kv: kv[1]["median_ahat"]):
        print(f'  {g:12s} n={s["n"]:4d} ã={s["median_ahat"]:.3f} IQR=[{s["P25"]:.3f}, {s["P75"]:.3f}] σ={s["std"]:.3f}')


if __name__ == "__main__":
    main()
