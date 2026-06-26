# Sigma-Operationalisierung — Ergebnisse

**Datum:** 2026-03-29
**n:** 176 Chats
**Referenz:** delta_NC2~NC2 R²_detrended=0.07, rho=-0.160 (n.s.)
**Spec:** operative Spezifikation der Σ_c-Konjektur (§9.2 Programm C)

---

## Ergebnis-Tabelle

| Kandidat | n | R²_level | R²_detr | |cor(σ,ε)| | ρ(R²,mal) | p | MW p | Grade |
|----------|---|----------|---------|-----------|-----------|---|------|-------|
| S1_topic_shift | 165 | 0.043 | 0.029 | 0.162 | -0.144 | 0.0654 | 0.9796 | **FAIL** |
| S2_dispersion | 154 | 0.070 | 0.041 | 0.195 | -0.155 | 0.0544 | 0.9676 | **FAIL** |
| S3_divergence | 154 | 0.161 | 0.062 | 0.319 | -0.128 | 0.1125 | 0.9610 | **FAIL** |
| S4_user_surprisal | 165 | 0.040 | 0.035 | 0.154 | -0.063 | 0.4242 | 0.7929 | **FAIL** |
| S5_surprisal_grad | 164 | 0.007 | 0.019 | 0.070 | -0.152 | 0.0523 | 0.9915 | **FAIL** |
| S6_vocab_entropy | 154 | 0.151 | 0.067 | 0.309 | -0.109 | 0.1779 | 0.9531 | **FAIL** |
| S7_gini_sv_user | 144 | 0.113 | 0.057 | 0.237 | -0.186 | 0.0254 | 0.9920 | **FAIL** |

---

## Referenz: delta_NC2 ~ NC2 (Baseline)

| R²_level | R²_detrended | ρ vs mal | p |
|----------|-------------|----------|---|
| 0.460 | 0.072 | -0.160 | 0.088 |

## Mal vs Base Detail

| Kandidat | mal R²_detr | base R²_detr | Δ |
|----------|------------|-------------|---|
| S1_topic_shift | 0.026 | 0.031 | -0.005 |
| S2_dispersion | 0.032 | 0.048 | -0.017 |
| S3_divergence | 0.059 | 0.065 | -0.007 |
| S4_user_surprisal | 0.032 | 0.038 | -0.005 |
| S5_surprisal_grad | 0.013 | 0.023 | -0.010 |
| S6_vocab_entropy | 0.052 | 0.079 | -0.027 |
| S7_gini_sv_user | 0.040 | 0.073 | -0.033 |

---

## Bester Kandidat: **S5_surprisal_grad**

- R²_detrended = 0.019
- ρ(R², mal_frac) = -0.152 (p=0.0523)
- Kanalunabhaengigkeit: |cor| = 0.070
- Grade: **FAIL**


---

RESULT: FAIL — S5_surprisal_grad: R²_dt=0.019, ρ=-0.152