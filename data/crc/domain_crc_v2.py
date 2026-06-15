#!/usr/bin/env python3
"""
SRDS Domain C (v2): Colorectal Cancer — cBioPortal TCGA-COAD/READ
Uses MANTIS score + SUBTYPE for MSI classification.
"""
import sys, os, json
import numpy as np
import pandas as pd
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from scipy.stats import spearmanr, mannwhitneyu, ks_2samp
from scipy.optimize import curve_fit

sys.path.insert(0, os.path.dirname(__file__))
from srds_core import fit_sigmoid, null_model_test, sigmoid

# Self-contained companion copy: read inputs and write outputs next to this script.
OUT_DIR = os.path.dirname(os.path.abspath(__file__))
FIG_DIR = os.path.dirname(os.path.abspath(__file__))

def run():
    print("=" * 60)
    print("DOMAIN C (v2): COLORECTAL CANCER")
    print("=" * 60)
    
    df = pd.read_csv(os.path.join(OUT_DIR, 'tcga_crc_combined.csv'))
    
    # Parse columns
    df['stage_num'] = df['AJCC_PATHOLOGIC_TUMOR_STAGE'].apply(lambda s: 
        4 if 'IV' in str(s).upper() else 3 if 'III' in str(s).upper() else 
        2 if 'II' in str(s).upper() else 1 if ('I' in str(s).upper() and 'II' not in str(s).upper() and 'IV' not in str(s).upper()) else None)
    
    df['mutation_count'] = pd.to_numeric(df['MUTATION_COUNT'], errors='coerce')
    df['fga'] = pd.to_numeric(df['FRACTION_GENOME_ALTERED'], errors='coerce')
    df['mantis'] = pd.to_numeric(df['MSI_SCORE_MANTIS'], errors='coerce')
    df['sensor'] = pd.to_numeric(df['MSI_SENSOR_SCORE'], errors='coerce')
    df['os_months'] = pd.to_numeric(df['OS_MONTHS'], errors='coerce')
    df['os_event'] = df['OS_STATUS'].astype(str).str.contains('DECEASED|1:', na=False).astype(int)
    
    # MSI classification: Use SUBTYPE (gold standard from TCGA consortium)
    df['is_msi'] = df['SUBTYPE'].astype(str).str.contains('MSI', na=False).astype(int)
    
    # Also use MANTIS > 0.4 for patients without subtype
    mantis_msi = (df['mantis'] > 0.4).astype(int)
    df.loc[df['SUBTYPE'].isna(), 'is_msi'] = mantis_msi[df['SUBTYPE'].isna()]
    
    n_msi = df['is_msi'].sum()
    n_mss = (df['is_msi'] == 0).sum()
    print(f"\nPatients: {len(df)} total, {n_msi} MSI, {n_mss} MSS")
    
    # Filter
    df_clean = df[df['stage_num'].notna() & (df['fga'].notna() | df['mutation_count'].notna())].copy()
    print(f"Clean (stage + genomic): {len(df_clean)} ({df_clean['is_msi'].sum()} MSI)")
    
    # ================================================================
    # ANALYSIS 1: Population-level sigmoid per MSI group
    # Sort patients by stage → mutation count, fit sigmoid to cumulative FGA
    # ================================================================
    print("\n--- Analysis 1: Population-level sigmoid per group ---")
    
    group_results = {}
    for label, mask in [('MSI', df_clean['is_msi'] == 1), ('MSS', df_clean['is_msi'] == 0)]:
        grp = df_clean[mask].sort_values(['stage_num', 'mutation_count']).reset_index(drop=True)
        if len(grp) < 15:
            print(f"  {label}: too few ({len(grp)})")
            continue
        
        # Cumulative FGA
        cum_fga = np.cumsum(grp['fga'].fillna(0).values)
        result = fit_sigmoid(np.arange(len(grp)), cum_fga)
        if result:
            group_results[label] = {**result, 'n': len(grp)}
            print(f"  {label} (cumFGA): n={len(grp)}, â={result['a_hat']:.3f}, k={result['k']:.1f}, R²={result['R2']:.3f}")
        
        # Cumulative mutation count
        cum_mut = np.cumsum(grp['mutation_count'].fillna(0).values)
        result_mut = fit_sigmoid(np.arange(len(grp)), cum_mut)
        if result_mut:
            group_results[f'{label}_mut'] = {**result_mut, 'n': len(grp)}
            print(f"  {label} (cumMut): n={len(grp)}, â={result_mut['a_hat']:.3f}, k={result_mut['k']:.1f}, R²={result_mut['R2']:.3f}")
    
    # ================================================================
    # ANALYSIS 2: Per-stage cumulative FGA — sigmoid across 4 stages
    # For each patient, their (stage, FGA) contributes to per-stage means
    # ================================================================
    print("\n--- Analysis 2: Stage-aggregated sigmoid ---")
    
    for label, mask in [('MSI', df_clean['is_msi'] == 1), ('MSS', df_clean['is_msi'] == 0), ('ALL', df_clean['is_msi'].notna())]:
        grp = df_clean[mask]
        stage_means = grp.groupby('stage_num').agg(
            fga_mean=('fga', 'mean'),
            mut_mean=('mutation_count', 'mean'),
            n=('fga', 'count')
        ).reset_index()
        
        if len(stage_means) >= 3:
            cum_fga = np.cumsum(stage_means['fga_mean'].values * stage_means['n'].values)
            result = fit_sigmoid(stage_means['stage_num'].values, cum_fga)
            if result:
                print(f"  {label} stage-agg (cumFGA): â={result['a_hat']:.3f}, R²={result['R2']:.3f}")
    
    # ================================================================
    # ANALYSIS 3: Bootstrap â comparison MSI vs MSS
    # ================================================================
    print("\n--- Analysis 3: Bootstrap â comparison ---")
    rng = np.random.default_rng(42)
    
    boot_a_msi = []
    boot_a_mss = []
    
    msi_patients = df_clean[df_clean['is_msi'] == 1].reset_index(drop=True)
    mss_patients = df_clean[df_clean['is_msi'] == 0].reset_index(drop=True)
    
    for i in range(500):
        # MSI bootstrap
        if len(msi_patients) >= 15:
            sample = msi_patients.sample(n=min(40, len(msi_patients)), replace=True, 
                                         random_state=rng.integers(0, 1000000))
            sample = sample.sort_values(['stage_num', 'mutation_count']).reset_index(drop=True)
            cum_fga = np.cumsum(sample['fga'].fillna(0).values)
            result = fit_sigmoid(np.arange(len(sample)), cum_fga)
            if result:
                boot_a_msi.append(result['a_hat'])
        
        # MSS bootstrap
        if len(mss_patients) >= 15:
            sample = mss_patients.sample(n=min(40, len(mss_patients)), replace=True,
                                         random_state=rng.integers(0, 1000000))
            sample = sample.sort_values(['stage_num', 'mutation_count']).reset_index(drop=True)
            cum_fga = np.cumsum(sample['fga'].fillna(0).values)
            result = fit_sigmoid(np.arange(len(sample)), cum_fga)
            if result:
                boot_a_mss.append(result['a_hat'])
    
    boot_a_msi = np.array(boot_a_msi)
    boot_a_mss = np.array(boot_a_mss)
    
    print(f"  MSI bootstraps: {len(boot_a_msi)}, â = {boot_a_msi.mean():.3f} ± {boot_a_msi.std():.3f}")
    print(f"  MSS bootstraps: {len(boot_a_mss)}, â = {boot_a_mss.mean():.3f} ± {boot_a_mss.std():.3f}")
    
    if len(boot_a_msi) > 10 and len(boot_a_mss) > 10:
        u_stat, u_p = mannwhitneyu(boot_a_msi, boot_a_mss, alternative='two-sided')
        print(f"  Mann-Whitney U: U={u_stat:.0f}, p={u_p:.6f}")
        
        ks_stat_groups, ks_p_groups = ks_2samp(boot_a_msi, boot_a_mss)
        print(f"  KS (MSI vs MSS): D={ks_stat_groups:.3f}, p={ks_p_groups:.6f}")
        
        delta_a = boot_a_msi.mean() - boot_a_mss.mean()
        direction = "früher" if delta_a < 0 else "später"
        print(f"  Δâ = {delta_a:+.3f} → MSI transitions {direction} than MSS")
    
    # ================================================================
    # ANALYSIS 4: â vs Survival (using individual patient sigmoid within mutation quartile)
    # ================================================================
    print("\n--- Analysis 4: â vs Survival ---")
    
    # Aggregate: group patients by mutation count decile, compute cumulative FGA
    df_clean['mut_decile'] = pd.qcut(df_clean['mutation_count'], q=10, labels=False, duplicates='drop')
    
    survival_results = []
    for msi_val in [0, 1]:
        grp = df_clean[df_clean['is_msi'] == msi_val]
        for _, patient in grp.iterrows():
            survival_results.append({
                'patient_id': patient['patient_id'],
                'is_msi': msi_val,
                'fga': patient['fga'],
                'mutation_count': patient['mutation_count'],
                'stage': patient['stage_num'],
                'os_months': patient['os_months'],
                'os_event': patient['os_event'],
            })
    
    df_surv = pd.DataFrame(survival_results)
    
    # Correlate FGA and mutation_count with survival within groups
    for label, mask in [('MSI', df_surv['is_msi'] == 1), ('MSS', df_surv['is_msi'] == 0)]:
        grp = df_surv[mask].dropna(subset=['os_months', 'fga'])
        if len(grp) > 10:
            rho, p = spearmanr(grp['fga'], grp['os_months'])
            print(f"  {label}: FGA vs OS_months ρ={rho:.3f}, p={p:.4f}, n={len(grp)}")
    
    # ================================================================
    # ANALYSIS 5: Null model
    # ================================================================
    print("\n--- Analysis 5: Null model ---")
    all_boot_a = np.concatenate([boot_a_msi, boot_a_mss]) if len(boot_a_msi) > 0 and len(boot_a_mss) > 0 else boot_a_mss
    ks_stat, ks_p, synth_a_hats = null_model_test(all_boot_a, len(all_boot_a), 40)
    print(f"  KS (all bootstrap vs null): D={ks_stat:.3f}, p={ks_p:.6f}")
    
    # ================================================================
    # FIGURES
    # ================================================================
    print("\n--- Generating figures ---")
    
    # Fig 1: Bootstrap â distribution MSI vs MSS
    fig, ax = plt.subplots(1, 1, figsize=(8, 5))
    if len(boot_a_msi) > 0:
        ax.hist(boot_a_msi, bins=25, alpha=0.6, label=f'MSI (n={len(boot_a_msi)}, μ={boot_a_msi.mean():.3f})', color='red')
    if len(boot_a_mss) > 0:
        ax.hist(boot_a_mss, bins=25, alpha=0.6, label=f'MSS (n={len(boot_a_mss)}, μ={boot_a_mss.mean():.3f})', color='blue')
    ax.set_xlabel('â (Transition Point)')
    ax.set_ylabel('Count')
    ax.set_title('CRC: Bootstrap â Distribution — MSI vs MSS')
    ax.legend()
    if len(boot_a_msi) > 10 and len(boot_a_mss) > 10:
        ax.text(0.02, 0.95, f'Mann-Whitney p={u_p:.4f}\nΔâ={delta_a:+.3f}', transform=ax.transAxes, va='top', fontsize=9)
    plt.tight_layout()
    plt.savefig(os.path.join(FIG_DIR, 'crc_a_hat_distribution.png'), dpi=150)
    plt.close()
    
    # Fig 2: MSI vs MSS cumulative trajectories
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    
    for msi_val, label, color, ax in [(1, 'MSI', 'red', axes[0]), (0, 'MSS', 'blue', axes[1])]:
        grp = df_clean[df_clean['is_msi'] == msi_val].sort_values(['stage_num', 'mutation_count']).reset_index(drop=True)
        if len(grp) < 10:
            continue
        cum_fga = np.cumsum(grp['fga'].fillna(0).values)
        x = np.arange(len(grp))
        x_n = x / (x.max() + 1e-12)
        y_n = (cum_fga - cum_fga.min()) / (cum_fga.max() - cum_fga.min() + 1e-12)
        
        ax.scatter(x_n, y_n, s=8, alpha=0.4, c=color)
        
        try:
            popt, _ = curve_fit(sigmoid, x_n, y_n, p0=[0.95, 5.0, 0.5],
                               bounds=([0.01, 0.1, 0.01], [0.99, 100.0, 0.99]), maxfev=10000)
            x_fit = np.linspace(0, 1, 200)
            y_fit = sigmoid(x_fit, *popt)
            ax.plot(x_fit, y_fit, 'k-', lw=2, label=f'Sigmoid (â={popt[2]:.3f}, R²=...)')
            ax.axvline(popt[2], color='red', ls='--', alpha=0.5)
        except:
            pass
        
        ax.set_xlabel('Sorted Patient Index (norm)')
        ax.set_ylabel('Cumulative FGA (norm)')
        ax.set_title(f'{label} (n={len(grp)})')
        ax.legend()
        ax.grid(True, alpha=0.3)
    
    plt.suptitle('CRC: Cumulative Genomic Instability — MSI vs MSS')
    plt.tight_layout()
    plt.savefig(os.path.join(FIG_DIR, 'crc_msi_comparison.png'), dpi=150)
    plt.close()
    
    # Fig 3: Null model
    fig, ax = plt.subplots(1, 1, figsize=(8, 5))
    ax.hist(all_boot_a, bins=25, alpha=0.7, label=f'Empirical bootstrap (n={len(all_boot_a)})', color='forestgreen')
    if len(synth_a_hats) > 0:
        ax.hist(synth_a_hats, bins=25, alpha=0.4, label=f'Null model (n={len(synth_a_hats)})', color='gray')
    ax.set_xlabel('â (Transition Point)')
    ax.set_ylabel('Count')
    ax.set_title('CRC: â Distribution — Empirical vs Null Model')
    ax.legend()
    ax.text(0.02, 0.95, f'KS={ks_stat:.3f}, p={ks_p:.4f}', transform=ax.transAxes, va='top', fontsize=9)
    plt.tight_layout()
    plt.savefig(os.path.join(FIG_DIR, 'crc_null_model.png'), dpi=150)
    plt.close()
    
    print("  Figures saved.")
    
    # Save results
    result_summary = {
        'n_patients': len(df_clean),
        'n_msi': int(df_clean['is_msi'].sum()),
        'n_mss': int((df_clean['is_msi'] == 0).sum()),
        'group_results': {},
        'bootstrap': {},
    }
    
    for k, v in group_results.items():
        result_summary['group_results'][k] = {kk: float(vv) if isinstance(vv, (np.floating, np.integer)) else vv for kk, vv in v.items()}
    
    if len(boot_a_msi) > 0 and len(boot_a_mss) > 0:
        result_summary['bootstrap'] = {
            'msi_mean_a': float(boot_a_msi.mean()),
            'msi_std_a': float(boot_a_msi.std()),
            'mss_mean_a': float(boot_a_mss.mean()),
            'mss_std_a': float(boot_a_mss.std()),
            'delta_a': float(delta_a),
            'mann_whitney_p': float(u_p),
            'ks_d': float(ks_stat_groups),
            'ks_p': float(ks_p_groups),
        }
    
    result_summary['null_model'] = {
        'ks_stat': float(ks_stat),
        'ks_p': float(ks_p),
    }
    
    with open(os.path.join(OUT_DIR, 'crc_results_v2.json'), 'w') as f:
        json.dump(result_summary, f, indent=2)
    
    return result_summary

if __name__ == '__main__':
    summary = run()
    print(f"\n{'='*60}")
    print(json.dumps(summary, indent=2, default=str))
