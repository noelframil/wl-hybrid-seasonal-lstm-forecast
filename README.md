# Hybrid Seasonal–Trend + LSTM Residual (Wolfram Language)

A compact Wolfram Language demo that combines a harmonic seasonal–trend fit with an LSTM residual learner to produce spatiotemporal forecasts with interactive visualization.

**Why it matters**  
It showcases a practical hybrid idea (classical decomposition + deep residuals) with a clean, reproducible WL implementation and an interactive graph of regions whose node sizes/colors reflect forecasted demand.

## ✨ Features
- Seasonal–trend linear model (harmonics) per region
- LSTM trained on residual sequences (12-step window)
- 12-step ahead multi-region forecast
- Uncertainty bands (≈80% and ≈95%) from residual dispersion
- Interactive `Manipulate`: regional network + time-series panel

## 🚀 Quickstart
1. Open `HybridSeasonalLSTM.wl` in Mathematica / Wolfram Desktop (v13+ recommended) and evaluate all cells,  
   or paste the code into a new notebook and run.
2. Use the slider to move through forecast months and the drop-down to switch region.

To publish to Wolfram Cloud:
```wolfram
nb = CreateDocument[Get["HybridSeasonalLSTM.wl"]];
CloudDeploy[nb, Permissions -> "Public"]
## 🌐 Demo
Public Cloud notebook and repo link available.