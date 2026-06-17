import csv, os, numpy as np
from scipy.optimize import curve_fit
rows=[r for r in csv.DictReader(open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "lignin", "sp_lcc_data_master.csv"))) if r.get("b-O-4","").strip() and r.get("p-factor","").strip()]
P=np.array([float(r["p-factor"]) for r in rows]); B=np.array([float(r["b-O-4"]) for r in rows])
Sig=(P-P.min())/(P.max()-P.min()); Q=(B.max()-B)/(B.max()-B.min())
def wb(x,lam,m): xc=np.clip(x,1e-12,None); return 1.0-np.exp(-np.power(xc/lam,m))   # L=1 fix
def infl(lam,m): return 0.0 if m<=1 else lam*((m-1)/m)**(1/m)
def fit(x,y,lbl):
    p,_=curve_fit(wb,x,y,p0=[0.4,2.0],bounds=([0.05,0.3],[3.0,12.0]),maxfev=200000)
    lam,m=p; yh=wb(x,*p); r2=1-np.sum((y-yh)**2)/np.sum((y-y.mean())**2)
    print(f"  {lbl:16s} â={infl(lam,m):.3f}  m(k)={m:.2f}  λ={lam:.3f}  R²={r2:.3f}")
print("Weibull-CDF, L=1 fix (korrekte Sättigung). β-O-4-Degradation vs linear-P.")
o=np.argsort(Sig); fit(Sig[o],Q[o],"roh")
for nb in (6,8,10):
    e=np.linspace(0,1,nb+1); xc=[];yc=[]
    for i in range(nb):
        msk=(Sig>=e[i])&(Sig<=e[i+1] if i==nb-1 else Sig<e[i+1])
        if msk.sum()>0: xc.append(Sig[msk].mean()); yc.append(Q[msk].mean())
    fit(np.array(xc),np.array(yc),f"gebinnt {nb}")
# Gegenprobe: ist die Kurve konkav (frühe Sättigung)? Q bei niedrigem vs hohem Σ:
lo=Q[Sig<0.33].mean(); mid=Q[(Sig>=0.33)&(Sig<0.66)].mean(); hi=Q[Sig>=0.66].mean()
print(f"  Q-Verlauf: niedrig-Σ={lo:.2f}  mittel={mid:.2f}  hoch={hi:.2f}  (konkav wenn früh schon hoch)")
