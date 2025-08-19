# Hybrid Seasonal–Trend + LSTM Residual (Wolfram Language)

## 🎯 Context & Motivation
This project was developed as part of my Wolfram Student Ambassador application.  
My academic and professional background spans **Computer Engineering (UNIR)**, **International Business & Data Science (ESIC)**, and hands-on roles in **AI software development (Kincode)** and **Big Data analytics (incoming NielsenIQ internship)**.  

My vision is to stand at the frontier of computational science—connecting **classical modeling, modern deep learning, and interactive visualization**. This notebook demonstrates how Wolfram Language can unify those worlds in a compact, reproducible way.

**Why it matters**  
Hybrid forecasting frameworks are increasingly relevant for both academia and industry. By combining **harmonic seasonal–trend decomposition** with **LSTM residual learning**, this project shows how WL can serve not only as a mathematical engine but also as a bridge between interpretability and predictive power.  

The interactive spatiotemporal visualization makes the results tangible, echoing my broader goal: to use computational tools to **turn complex data into accessible, actionable insights**.

---

## ✨ Features
- Seasonal–trend linear model (harmonics) per region  
- LSTM trained on residual sequences (12-step window)  
- 12-step ahead multi-region forecast  
- Uncertainty bands (≈80% and ≈95%) from residual dispersion  
- Interactive `Manipulate`: regional network + time-series panel  

---

## 🚀 Quickstart
1. Open `HybridSeasonalLSTM.wl` in Mathematica / Wolfram Desktop (v13+ recommended) and evaluate all cells,  
   or paste the code into a new notebook and run.  
2. Use the slider to move through forecast months and the drop-down to switch region.  

To publish to Wolfram Cloud:
```wolfram
nb = CreateDocument[Get["HybridSeasonalLSTM.wl"]];
CloudDeploy[nb, Permissions -> "Public"]
