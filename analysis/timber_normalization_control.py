#!/usr/bin/env python3
"""Normalization-coupling control for the timber anchor (OBJECTIONS_AND_TESTS.md, row 2).

Objection under test: the inflection location a_hat lives on an axis normalized
by sigma_max, so sigma_max sits in the denominator of the predictor and the
correlation r(a_hat, sigma_max) could be a construction artifact.

Data: data/holz_master/wood_data_all.csv (n = 230, public).

Three readings, standard library only, seed fixed:
  [A] Reproduction: r and Spearman rho of (a_hat, sigma_max), overall and
      within each DIN 4074 grading class (classes are assigned visually
      before the test and are independent of the normalization).
  [B] Onset reading: sigma_onset := a_hat * sigma_max, the absolute stress at
      the inflection. A pure construction artifact requires an onset that is
      unrelated to strength; measured spread and coupling say otherwise.
  [C] Permutation baseline: permute sigma_onset against sigma_max (onset
      independent of strength, marginals preserved), form
      a_perm = onset_perm / sigma_max, and record r(a_perm, sigma_max) over
      2000 permutations. This answers only the narrower question of whether
      the onset is independent of strength; it is not a test of the
      deterministic decomposition in [D].
  [D] Deterministic decomposition (the strongest opposing null): fit the
      affine onset-strength line sigma_onset = b0 + b1*sigma_max by least
      squares. With that line, a_hat = sigma_onset/sigma_max is, up to
      residuals, b1 + b0/sigma_max, a strictly decreasing function of
      strength; the line alone forces Spearman rho(a_line, sigma_max) = -1,
      so the near-perfect measured rank order follows arithmetically from
      the established onset-strength relation.

Expected output (checked values):
  [A] r = -0.829, Spearman = -0.994; within-class r = -0.83 / -0.86 / -0.95;
      class means 0.574 (S7) > 0.557 (S10) > 0.539 (S13), monotone with grade.
  [B] onset CV = 0.228 (not constant), r(onset, sigma_max) = +0.996.
  [C] baseline mean r = -0.738, 99% band [-0.787, -0.659]; measured r = -0.829
      lies outside the band (z = -3.85; 0 of 2000 permutations reach it).
  [D] sigma_onset = 5.273 + 0.4329*sigma_max, R^2 = 0.9925; implied
      a_line = 0.4329 + 5.273/sigma_max: Spearman rho(a_line, sigma_max)
      = -1.000, Pearson r(a_line, a_hat) = +0.846.

Revision 2026-08-18: reading [D] added. The v6 reading of [C] ("the measured
r lies outside the construction baseline") overstated what the permutation
answers: [D] shows the rank order is carried by the established affine
onset-strength line itself. Readings [A]-[C] and their values are unchanged.
"""
import csv, math, os, random

PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                    "..", "data", "holz_master", "wood_data_all.csv")

def pearson(x, y):
    n = len(x); mx = sum(x)/n; my = sum(y)/n
    sx = math.sqrt(sum((a-mx)**2 for a in x)); sy = math.sqrt(sum((b-my)**2 for b in y))
    return sum((a-mx)*(b-my) for a, b in zip(x, y)) / (sx*sy)

def rank(v):
    order = sorted(range(len(v)), key=lambda i: v[i])
    r = [0.0]*len(v); i = 0
    while i < len(order):
        j = i
        while j+1 < len(order) and v[order[j+1]] == v[order[i]]:
            j += 1
        avg = (i + j)/2.0 + 1
        for k in range(i, j+1):
            r[order[k]] = avg
        i = j+1
    return r

def spearman(x, y):
    return pearson(rank(x), rank(y))

rows = list(csv.DictReader(open(PATH)))
a  = [float(r["a_hat"]) for r in rows]
s  = [float(r["sigma_max"]) for r in rows]
kl = [r["grade"].strip() for r in rows]
n = len(rows)
print(f"n = {n}")

print(f"[A] Pearson r(a_hat, sigma_max)  = {pearson(a, s):+.4f}")
print(f"[A] Spearman rho(a_hat, sigma_max) = {spearman(a, s):+.4f}")
for g in sorted(set(kl)):
    ia  = [x for x, k in zip(a, kl) if k == g]
    isx = [x for x, k in zip(s, kl) if k == g]
    if len(ia) >= 5:
        print(f"[A] class {g}: n={len(ia):3d}  r={pearson(ia, isx):+.4f}  "
              f"Spearman={spearman(ia, isx):+.4f}  mean_a={sum(ia)/len(ia):.4f}")

onset = [ai*si for ai, si in zip(a, s)]
mo = sum(onset)/n
sdo = math.sqrt(sum((o-mo)**2 for o in onset)/(n-1))
print(f"[B] sigma_onset = a_hat*sigma_max: mean={mo:.2f}, SD={sdo:.2f}, CV={sdo/mo:.3f}")
print(f"[B] Pearson r(sigma_onset, sigma_max)  = {pearson(onset, s):+.4f}")
print(f"[B] Spearman rho(sigma_onset, sigma_max) = {spearman(onset, s):+.4f}")

random.seed(0)
rs = []
for _ in range(2000):
    perm = onset[:]
    random.shuffle(perm)
    a_perm = [o/si for o, si in zip(perm, s)]
    rs.append(pearson(a_perm, s))
rs.sort()
mean_r = sum(rs)/len(rs)
sd_r = math.sqrt(sum((x-mean_r)**2 for x in rs)/(len(rs)-1))
lo = rs[int(0.005*len(rs))]; hi = rs[int(0.995*len(rs))-1]
real = pearson(a, s)
print("[C] construction baseline (onset independent of sigma_max, 2000 permutations):")
print(f"[C]   r_perm mean={mean_r:+.4f}, SD={sd_r:.4f}, 99% band=[{lo:+.4f}, {hi:+.4f}]")
print(f"[C]   measured r={real:+.4f}  ->  z = {(real-mean_r)/sd_r:+.2f} against the baseline")
below = sum(1 for x in rs if x <= real)
print(f"[C]   permutation p (one-sided, r <= measured): {below}/{len(rs)}")

ms = sum(s)/n
b1 = sum((si-ms)*(oi-mo) for si, oi in zip(s, onset)) / sum((si-ms)**2 for si in s)
b0 = mo - b1*ms
ss_res = sum((oi - (b0 + b1*si))**2 for si, oi in zip(s, onset))
ss_tot = sum((oi - mo)**2 for oi in onset)
r2 = 1.0 - ss_res/ss_tot
a_line = [b1 + b0/si for si in s]
print("[D] deterministic decomposition (affine onset-strength line):")
print(f"[D]   sigma_onset = {b0:.3f} + {b1:.4f}*sigma_max, R^2 = {r2:.4f}")
print(f"[D]   implied a_line = {b1:.4f} + {b0:.3f}/sigma_max")
print(f"[D]   Spearman rho(a_line, sigma_max) = {spearman(a_line, s):+.4f} (line alone forces -1)")
print(f"[D]   Pearson r(a_line, a_hat) = {pearson(a_line, a):+.4f}")
