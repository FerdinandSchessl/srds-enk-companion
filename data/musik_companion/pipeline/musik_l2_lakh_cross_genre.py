#!/usr/bin/env python3
"""
Lakh + Tagtraum Cross-Genre Run für SRDS-â auf ℓ₂.

Pipeline:
  Tagtraum CD2C parse → MSD-TR-ID → Genre
  → Lakh LMD-matched MIDIs sammeln pro Genre
  → Stratified Sample (default 200 pro Genre)
  → compute_ahat_for_piece (aus musik_l2_ahat_run.py)
  → Aggregation pro Genre
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
from musik_l2_ahat_run import compute_ahat_for_piece


def parse_tagtraum(path: Path) -> dict[str, str]:
    """TR-ID → Genre dict from tagtraum cls."""
    mapping = {}
    with path.open() as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            parts = line.split("\t")
            if len(parts) >= 2:
                mapping[parts[0]] = parts[1]
    return mapping


def extract_tr_id(path_str: str) -> str | None:
    for p in path_str.split(os.sep):
        if p.startswith("TR") and len(p) >= 18:
            return p
    return None


def collect_lakh_per_genre(lakh_root: Path, tagtraum: dict, targets: set[str],
                            max_per_genre: int = 1000) -> dict[str, list[Path]]:
    """Walk Lakh tree, group MIDIs by genre via Tagtraum-Match (TR-ID-level)."""
    by_genre = {g: [] for g in targets}
    seen_tr = set()  # nur ein MIDI pro TR-ID
    for root, _, files in os.walk(lakh_root):
        tr = extract_tr_id(root)
        if tr is None or tr in seen_tr:
            continue
        if tr not in tagtraum:
            continue
        genre = tagtraum[tr]
        if genre not in targets:
            continue
        if len(by_genre[genre]) >= max_per_genre:
            continue
        mids = [f for f in files if f.endswith(".mid")]
        if not mids:
            continue
        # Take first MIDI for this TR-ID
        by_genre[genre].append(Path(root) / mids[0])
        seen_tr.add(tr)
    return by_genre


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--lakh-root", type=Path, default=Path("./data/lakh/lmd_matched"))
    ap.add_argument("--tagtraum", type=Path, default=Path("./data/lakh/msd_tagtraum_cd2c.cls"))
    ap.add_argument("--n-per-genre", type=int, default=200)
    ap.add_argument("--targets", nargs="+",
                    default=["Rock", "Pop", "Electronic", "Jazz", "Rap"])
    ap.add_argument("--output", type=Path,
                    default=Path("./logs/musik_l2_lakh_cross_genre.json"))
    ap.add_argument("--seed", type=int, default=42)
    args = ap.parse_args()

    print(f"Loading tagtraum from {args.tagtraum}", flush=True)
    tagtraum = parse_tagtraum(args.tagtraum)
    print(f"  -> {len(tagtraum):,} TR-IDs labeled", flush=True)

    targets = set(args.targets)
    print(f"Targets: {sorted(targets)} (n_per_genre={args.n_per_genre})", flush=True)

    print(f"Walking {args.lakh_root}...", flush=True)
    by_genre = collect_lakh_per_genre(args.lakh_root, tagtraum, targets,
                                       max_per_genre=args.n_per_genre)
    for g in sorted(targets):
        print(f"  {g:12s}: {len(by_genre[g])} MIDIs collected", flush=True)

    # Stratified Run
    random.seed(args.seed)
    all_results = []
    for genre, paths in by_genre.items():
        random.shuffle(paths)
        for i, p in enumerate(paths[:args.n_per_genre]):
            try:
                r = compute_ahat_for_piece(p)
            except Exception as exc:
                r = {"path": str(p), "status": "exception", "error": repr(exc)[:80]}
            r["genre"] = genre
            all_results.append(r)
            if (len(all_results)) % 50 == 0:
                ok = sum(1 for x in all_results if x.get("status") == "ok")
                valid = sum(1 for x in all_results if x.get("valid"))
                print(f"  [{len(all_results)}] last={genre}, ok={ok}, valid={valid}", flush=True)

    # Summary per genre
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
        "label": "lakh_cross_genre",
        "n_total": len(all_results),
        "n_valid": sum(1 for r in all_results if r.get("valid")),
        "median_R2": float(np.median(r2s)) if r2s else None,
        "P25_R2": float(np.percentile(r2s, 25)) if r2s else None,
        "per_genre": summary,
        "results": all_results,
    }
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(out, indent=2))

    print()
    print("=== LAKH CROSS-GENRE SUMMARY ===")
    print(f'Total: {out["n_total"]}, Valid: {out["n_valid"]}, '
          f'median R²={out["median_R2"]}')
    sorted_g = sorted(summary.items(), key=lambda kv: kv[1]["median_ahat"])
    for g, s in sorted_g:
        print(f'  {g:12s} n={s["n"]:4d}  ã={s["median_ahat"]:.3f}  '
              f'P25={s["P25"]:.3f}  P75={s["P75"]:.3f}  std={s["std"]:.3f}')


if __name__ == "__main__":
    main()
