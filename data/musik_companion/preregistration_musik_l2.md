# Pre-Registration: Musik als SRDS-Substrat auf ℓ₂ (Stück-Skala)

**Datum:** 2026-05-16
**Status:** Pre-registered, Implementierung ausstehend
**Konstrukt-Anker:** §2.2 (Axiome A0-A4), §6.1 (Skalen-Hierarchie ℓ₀-ℓ₄), §4 (ENK als ℓ₂-Substrat als Analogie)
**Datenquelle:** MetaMIDI Dataset (Ens & Pasquier 2021, Zenodo 10.5281/ZENODO.5142664), gefiltert nach Di Marco et al. 2026 (Sci Rep 16:11121)

---

## 0. Konstrukt-Anker

Ein MIDI-Stück ist die Prozess-Aufzeichnung des kompositorischen Vorgangs, **strukturell analog zu einem ENK-Chat als Prozess-Aufzeichnung eines Dialog-Vorgangs**. Daraus folgen die fünf Axiome auf ℓ₂:

| Axiom | Operationalisierung auf MIDI-Stück |
|---|---|
| **A0 Self-Reference** | Note N hängt vom Note-Verlauf 1…N-1 ab im kompositorischen Prozess (genauso wie Turn N vom Turn-Verlauf abhängt im Dialog) |
| **A1 Dissipation** | Konsumption kreativer Freiheitsgrade durch zunehmend constraint-haftere Wahlen (etabliertes Vocabulary einengt zukünftige Wahlen) |
| **A2 Akkumulation** | cum_unique_edges(i) monoton wachsend per Konstruktion über die Note-Sequenz |
| **A3 Transition** | Sigmoid-Inflektion = Wahl-Sättigungs-Punkt, an dem das Note-Vocabulary "ausgeschöpft" ist |
| **A4 Irreversibilität** | Einmal etabliertes Vocabulary wird innerhalb des Stücks nicht "vergessen" |

**Die Frage "ist Musik ein gültiges SRDS-Substrat?" ist nicht offen** — der Frame ist universell (§3). Die Frage ist nur welche Skala. Diese Pre-Reg fixiert ℓ₂ (Stück-Skala).

## 1. Operationalisierung

| Element | Wert |
|---|---|
| **1 Prüfkörper** | 1 MIDI-Stück (analog 1 ENK-Chat / 1 Erdbeben-Sequenz / 1 Holzprobe / 1 V-Dem-Episode) |
| **n** | ≈21.480 (MetaMIDI nach Spotify-Match, Di Marcos final dataset) |
| **X-Achse** | i / n_notes ∈ [0,1] (relative Note-Position im Stück) |
| **Y-Achse (primär)** | cum_unique_edges(i) / max_possible_edges (Network-Density-Aufbau, analog Note-Adjacency wie Di Marco) |
| **Y-Achse (Robustness)** | cum_unique_pitches(i) / final_unique_pitches (Vocabulary-Aufbau) |
| **Normierung** | beide Y-Achsen auf [0,1] |
| **Sigmoid-Fit** | logistisch `f(x) = 1 / (1 + exp(-k(x - â)))`, pro Stück, via `scipy.optimize.curve_fit` |
| **â** | Inflektionspunkt = relative Position der Network-Sättigung |

## 2. Externe Bezugsgrößen

Pro Stück verfügbar aus MetaMIDI + Spotify-Match (Di Marco Methodik):
- **Genre** (Rock, Pop, Electronic, Classical, Jazz, Hip Hop)
- **Decade** (Spotify Release-Year, LLM-Heuristik für 72% des Datasets)
- **Artist/Composer** (für ℓ₃-Sub-Aggregation)

## 3. Hypothesen (pre-registriert)

**H1 (Genre-Trennung):** Die â-Verteilung trennt mindestens ein Genre-Paar mit Cohen-d > 0.5, Mann-Whitney p < 0.01 Bonferroni-korrigiert über alle 15 Genre-Paare. Konsistenz-Erwartung: Classical/Jazz höhere ã als Hip-Hop/Pop/Rock/Electronic (analog Di-Marco Efficiency-Hierarchie).

**H2 (Fatigue-Memory über Dekaden):** Pro Genre verschiebt sich ã systematisch über Dekaden (Mann-Kendall |τ| > 0.2, p < 0.01 Bonferroni über 6 Genres). Konsistenz-Erwartung: monoton sinkendes ã (frühere Sättigung) über jüngere Dekaden = Komplexitäts-Erosion analog V-Dem Fatigue-Memory (§5.5).

**H3 (Sigmoid-Konformität):** Median R² ≥ 0.85 über alle gefitteten Stücke (analog Erdbeben R²=0.918, V-Dem R²=0.980, Holz konformant).

## 4. Stop-Kriterien

- **Sigmoid-Fit-Quality Floor:** Wenn median R² < 0.5 über alle Stücke → methodisches Failure, Re-Operationalisierung der Y-Achse erforderlich (z.B. cum_entropy oder cum_weighted_efficiency statt cum_unique_edges).
- **Sample-Size pro Genre:** ≥ 200 Stücke pro Genre nach Filter. Hip Hop hat in MetaMIDI minimal ~500 (Di Marco Fig 6), sollte ausreichen.
- **Außreißer-Filter:** â ∈ [0.05, 0.95]; Stücke mit n_notes < 20 ausgeschlossen.
- **Compute-Stop:** wenn Pipeline > 4h ohne Fortschritt pro Genre-Subset → Hung-Detection-Exit.

## 5. Shuffled-Control (Negativkontrolle-Bias, §7.4)

Pro Stück: Note-Reihenfolge randomisieren (Permutation auf gleicher Note-Multimenge), Sigmoid neu fitten. Erwartung: â-Verteilung degeneriert zu engem Gauß um 0.5 (cum_unique_edges wird quasi-linear), Genre-Trennung verschwindet.

**Falsifikations-Bedingung:** Wenn Genre-Trennung im Shuffled-Run BLEIBT → Effekt ist nicht sequenzielle Geometrie, sondern Vocabulary-Größen-Aggregations-Artefakt → Befund auf "Vocabulary-Effekt, kein Sigmoid-Geometrie-Effekt" reduzieren.

## 6. Erwarteter Skala-Anschluss

Diese Pre-Reg betrifft **nur ℓ₂** (Stück-Skala). Anschluss-Skalen sind explizit nicht-Teil dieser Pre-Reg, aber Folge-Pre-Reg-Kandidaten:

- **ℓ₃ (Komponist/Künstler-Karriere):** â-Verteilung pro Artist als Karriere-Trajektorie, Sub-Aggregation auf chronologische Werk-Sequenz. Analog Multi-Material Fatigue §5.2 (per-Material).
- **ℓ₄ (Genre-Episoden):** "Komplexitäts-Erosions-Episode" pro Genre × Region × Period als Sample, analog V-Dem-Autokratisierungs-Episode. Erwartung: trägt Fatigue-Memory + Hysterese über Streaming-Era-Übergang.

## 7. Datenpfad

```
MetaMIDI Dataset (Zenodo 10.5281/ZENODO.5142664)
  → Filter: Genre ∈ {rock, pop, electronic, classical, jazz, hip hop}
            ∧ Spotify-Match
            ∧ Länge > 60s
            ∧ parsbar via music21 (oder pretty_midi als Fallback)
  → ≈21.480 Stücke
  → pro Stück: Note-Stream extrahieren, Drums ignorieren
  → Sliding über Note-Indizes 1...n_notes
  → cum_unique_edges(i), cum_unique_pitches(i)
  → Sigmoid-Fit
  → â pro Stück
  → Aggregation pro Genre × Decade
```

## 8. Output-Format

```json
{
  "run_id": "musik_l2_pre_reg_<timestamp>",
  "dataset": "MetaMIDI subset n=<actual>",
  "y_axis_primary": "cum_unique_edges",
  "y_axis_robustness": "cum_unique_pitches",
  "n_pieces_total": <int>,
  "n_pieces_fitted": <int>,
  "median_r2": <float>,
  "per_genre": {
    "Classical": {"n": ..., "median_ahat": ..., "P25": ..., "P75": ..., "std": ...},
    ...
  },
  "cross_genre_cohen_d_pairs": [...],
  "per_decade_per_genre_ahat": {...},
  "mann_kendall_per_genre": {...},
  "shuffled_control": {
    "median_ahat": ..., "std": ...,
    "genre_trennung_residual": <0 oder Wert>
  },
  "verdict_h1_genre_separation": "PASS" | "FAIL" | "INCONCLUSIVE",
  "verdict_h2_fatigue_memory": "PASS" | "FAIL" | "INCONCLUSIVE",
  "verdict_h3_sigmoid_konformitaet": "PASS" | "FAIL"
}
```

## 9. Bezug zum Paper

Falls H1+H2+H3 PASS: **§5.11 Musik (Companion-Studie zu Di Marco 2026)** in der V2/V3-Iteration des Papers, parallel zu §5.7 Erdbeben und §5.8 Batterie als drittes nicht-mechanisches, nicht-medizinisches, nicht-finanzielles Cross-Domain-Substrat.

Falls H1+H2 FAIL aber H3 PASS: Vierter §5.10-Negativkontroll-Befund (Sigmoid-Form trägt, Genre-Trennung leer). Auch interpretationsfähig im Rahmen.

Falls H3 FAIL: Y-Achse re-operationalisieren (cum_entropy oder cum_weighted_efficiency); falls erneut FAIL: Substrat-Hinweis als Operating-Range-Marker (analog duktile Metalle §5.10).

## 10. Genealogie-Anker

Konstrukt-Konvergenz mit Di Marco et al. 2026 (Sci Rep 16:11121): identischer Datensatz (MetaMIDI), identische Network-Konstruktion (directed weighted, Note-Adjacency). **Unterschied:** Di Marco extrahiert statische Network-Properties (Density, Efficiency, Reciprocity, Entropy) und vergleicht Genre-Mittel. Diese Pre-Reg ergänzt: kumulative Trajektorie-Auswertung pro Stück, Sigmoid-Inflektionspunkt-Extraktion, SRDS-â-Vokabular auf Note-Sequenz.

**Attaguile (Zenodo 19633018, April 2026):** strukturell paralleles theoretisches Framework (constraint-weighted state selection mit non-Markovian memory + threshold transitions). Diese Pre-Reg dokumentiert empirische ENK-Triangulation mit MetaMIDI-Substrat, die Attaguile's Frame ohne Daten klassen-konvergent stützt.

---

**Signatur Pre-Reg:** 2026-05-16, Konstrukt-Anker aus SRDS v2 §2.2 + §4 + §6.1 + §6.3. Implementierung folgt in eigenständigem Pipeline-Schritt (music21 + scipy + Pandas), Voll-Sample auf MetaMIDI-Subset oder Stratified-Sample bei Compute-Limits.
