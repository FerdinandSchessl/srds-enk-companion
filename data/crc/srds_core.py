"""
SRDS Core — Sigmoid fitting and null model utilities.
"""
import numpy as np
from scipy.optimize import curve_fit
from scipy.stats import spearmanr, ks_2samp

def sigmoid(x, L, k, a_hat):
    """Logistic sigmoid: y = L / (1 + exp(-k * (x - a_hat)))"""
    return L / (1.0 + np.exp(-k * (x - a_hat)))

def fit_sigmoid(x, y, L_bounds=(0.01, 0.99), k_bounds=(0.1, 100.0)):
    """
    Fit sigmoid to normalized cumulative trajectory.
    Returns dict with a_hat, k, L, R2 or None on failure.
    """
    try:
        # Normalize x to [0, 1]
        x = np.asarray(x, dtype=float)
        y = np.asarray(y, dtype=float)
        if len(x) < 4:
            return None
        x_norm = (x - x.min()) / (x.max() - x.min() + 1e-12)
        y_norm = (y - y.min()) / (y.max() - y.min() + 1e-12)
        
        # Initial guess
        p0 = [0.95, 5.0, 0.5]
        bounds_lower = [L_bounds[0], k_bounds[0], 0.01]
        bounds_upper = [L_bounds[1], k_bounds[1], 0.99]
        
        popt, _ = curve_fit(sigmoid, x_norm, y_norm, p0=p0,
                           bounds=(bounds_lower, bounds_upper),
                           maxfev=10000)
        L, k, a_hat = popt
        y_pred = sigmoid(x_norm, *popt)
        ss_res = np.sum((y_norm - y_pred) ** 2)
        ss_tot = np.sum((y_norm - y_norm.mean()) ** 2)
        R2 = 1 - ss_res / (ss_tot + 1e-12)
        
        return {'a_hat': a_hat, 'k': k, 'L': L, 'R2': R2}
    except Exception:
        return None

def generate_synthetic_baselines(n_series, length, n_synth=1000):
    """
    Generate 1000 synthetic baselines (AR(1), Random Walk, White Noise)
    and fit sigmoid to each. Returns array of â values.
    """
    a_hats = []
    rng = np.random.default_rng(42)
    
    for i in range(n_synth):
        kind = i % 3
        if kind == 0:  # AR(1)
            phi = rng.uniform(0.5, 0.99)
            series = np.zeros(length)
            for t in range(1, length):
                series[t] = phi * series[t-1] + rng.normal(0, 0.1)
            series = np.cumsum(np.abs(series))
        elif kind == 1:  # Random Walk
            series = np.cumsum(rng.normal(0, 1, length))
            series = series - series.min()
        else:  # White Noise cumsum
            series = np.cumsum(np.abs(rng.normal(0, 1, length)))
        
        x = np.linspace(0, 1, length)
        result = fit_sigmoid(x, series)
        if result is not None:
            a_hats.append(result['a_hat'])
    
    return np.array(a_hats)

def null_model_test(empirical_a_hats, n_series, avg_length, n_synth=1000):
    """Run null model and KS test."""
    synth_a_hats = generate_synthetic_baselines(n_series, avg_length, n_synth)
    if len(synth_a_hats) < 10:
        return None, None, synth_a_hats
    stat, pval = ks_2samp(empirical_a_hats, synth_a_hats)
    return stat, pval, synth_a_hats
