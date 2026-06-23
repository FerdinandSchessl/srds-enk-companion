# Reproduktion des No-Go-Numerik-Zertifikats (Arb, Intervall-Arithmetik).
# Voraussetzung: pip install -r requirements.txt   (python-flint, mpmath, numpy, scipy)
#
# 'make verify' reproduziert das im Paper zertifizierte Intervall
#   Q̇(1/2) ∈ [1.8412, 1.8963]  (K_SUBBOX=4000, 199×4000 = 796000 Sub-Boxen;
#   Beleg: certificate.json + arb_run_K4000.log). Voller Lauf, rechenintensiv.
# 'make verify-fast' nutzt K_SUBBOX=500 (deutlich schneller, breiteres aber
#   ebenfalls 0-ausschliessendes Enclosure ~[1.75, 1.99]).
verify:
	K_SUBBOX=4000 python3 verified_computation.py

verify-fast:
	K_SUBBOX=500 python3 verified_computation.py

.PHONY: verify verify-fast
