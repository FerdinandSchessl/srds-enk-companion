#!/usr/bin/env python3
"""
Pisot inflation eigenvalues (aperiodic order) -- companion check for SRDS+ENK Sec. 2.5.

Structure -> value: within a structured family the characteristic scale value is the
Perron-Frobenius eigenvalue of the symmetry-specific substitution matrix -- algebraically
DETERMINED, not fitted. In aperiodic order it is a Pisot number of degree phi_Eul(n)/2
(Euler totient): quadratic for 5-/8-/12-fold, cubic from 7-fold on. The value 1/phi = 0.618
is the golden (5-fold) Galois conjugate -- one of a spectrum, NOT a universal constant.
This is the constructive complement of the no-go theorem (no universal value, no
cross-disjoint law; only the form is universal).

Pre-registered before the literature dive and before this computation, then triangulated
against the aperiodic-order literature (Nakakura et al. 2019, Nat. Commun. 10:4235;
Pautze 2017, Symmetry 9(2):19; Hare, Masakova & Vavra 2016, arXiv:1612.09285). The exact
Pisot/Galois-conjugate verification was additionally carried out with python-flint.
See paper Sec. 2.5.

Self-contained: Python standard library only.   Run:  python3 pisot_eigenvalues.py
"""
import sys

_P = [0]
_F = []


def chk(label, got, ref, ok):
    if ok:
        _P[0] += 1
    else:
        _F.append(label)
    print(f"  {label:46s} got={got:<26} ref={ref}  {'PASS' if ok else '*** FAIL ***'}")


def pf2(tr, det):
    """Largest eigenvalue of a 2x2 non-negative substitution matrix [[tr-d, .],[.,d]]."""
    return (tr + (tr * tr - 4 * det) ** 0.5) / 2


def gcd(a, b):
    while b:
        a, b = b, a % b
    return a


def phi_eul(n):
    return sum(1 for k in range(1, n) if gcd(k, n) == 1)


def main():
    print("=" * 64)
    print("Pisot inflation eigenvalues (aperiodic order) -- SRDS+ENK Sec. 2.5")
    print("=" * 64)
    phi = (1 + 5 ** 0.5) / 2
    chk("5-fold golden  lambda  (x^2-x-1)",  f"{pf2(1, -1):.6f}", "1.618034 (phi)",
        abs(pf2(1, -1) - phi) < 1e-6)
    chk("8-fold silver  lambda  (x^2-2x-1)", f"{pf2(2, -1):.6f}", "2.414214 (1+sqrt2)",
        abs(pf2(2, -1) - (1 + 2 ** 0.5)) < 1e-6)
    chk("12-fold        lambda  (x^2-2x-2)", f"{pf2(2, -2):.6f}", "2.732051 (1+sqrt3)",
        abs(pf2(2, -2) - (1 + 3 ** 0.5)) < 1e-6)
    l7 = 2.246979604  # 7-fold: irreducibly cubic -> breaks the quadratic case
    res7 = l7 ** 3 - 2 * l7 ** 2 - l7 + 1
    chk("7-fold cubic   lambda  (x^3-2x^2-x+1)", f"{l7:.6f} (res {res7:+.0e})",
        "2.246980 (deg 3)", abs(res7) < 1e-5)
    chk("1/phi golden conjugate (cited as Sigma_c)", f"{1 / phi:.6f}",
        "0.618034 (one of a spectrum)", abs(1 / phi - 0.618034) < 1e-5)
    chk("degree law phi_Eul(n)/2, n=5,8,12 -> 2",
        str([phi_eul(n) // 2 for n in (5, 8, 12)]), "[2, 2, 2]",
        [phi_eul(n) // 2 for n in (5, 8, 12)] == [2, 2, 2])
    chk("degree law phi_Eul(n)/2, n=7,9 -> 3",
        str([phi_eul(n) // 2 for n in (7, 9)]), "[3, 3]",
        [phi_eul(n) // 2 for n in (7, 9)] == [3, 3])
    print("=" * 64)
    if _F:
        print(f"RESULT: {_P[0]} PASSED, {len(_F)} FAILED -> {', '.join(_F)}")
        sys.exit(1)
    print(f"RESULT: all {_P[0]} checks PASSED.")


if __name__ == "__main__":
    main()
