# ⚛️ Sodium Cooled Reactor Vessel Radiation Shielding Model

A simplified **1D slab attenuation model** in MATLAB for visualising how neutron and gamma dose rates fall off through layered shielding on a sodium cooled fast reactor.

![MATLAB](https://img.shields.io/badge/MATLAB-R2020b%2B-orange)
![Model](https://img.shields.io/badge/model-1D%20analytical-blue)
![Status](https://img.shields.io/badge/status-visualisation%20aid-lightgrey)

---

## ⚠️ Scope and Limitations

This is a **first-order analytical model**, not a transport simulation. It assumes straight-line attenuation with no buildup factors, scattering, streaming paths, or geometry effects.

> It is **not** a substitute for the MCNP transport analysis. Treat the numbers as directional, useful for comparing shield configurations and prepping panels, not for demonstrating regulatory compliance.

The unshielded dose rate and the neutron/gamma split are placeholder baselines. Swap in real MCNP values before drawing any conclusions.

---

## 🔬 Physics

Two mechanisms, modelled independently then summed.

**Fast neutron removal** through borated polyethylene:

$$\phi(t) = \phi_0 \, e^{-\Sigma_r \, t}$$

**Gamma attenuation** through lead:

$$I(t) = I_0 \, e^{-\mu \, t}, \qquad \mu = \left(\frac{\mu}{\rho}\right)\rho$$

**Combined dose rate** at the working position:

$$D(t) = D_n \, e^{-\Sigma_r \, t_{\text{poly}}} + D_\gamma \, e^{-\mu \, t_{\text{Pb}}}$$

The 2 MeV fission gamma is the design driver, since it has the lowest mass attenuation coefficient of the energies considered.

---

## 🧱 Materials and Key Parameters

| Parameter | Value | Notes |
|---|---|---|
| 🟦 Neutron shield | 5% borated polyethylene | $\Sigma_r = 0.12\ \text{cm}^{-1}$ |
| ⬛ Gamma shield | Lead | $\rho = 11.34\ \text{g/cm}^3$ |
| ☢️ Gamma energies | 478 keV, 1 MeV, 2 MeV | 478 keV from B-10(n,α)Li-7 capture |
| 🎯 Design point | 6" poly + 6" lead | 12" total, 50/50 split |
| 📏 Regulatory band | 5 to 100 mrem/hr | DOE-STD-1098-2017 envelope |

---

## 📊 What It Generates

Running the script produces three figures:

1. **📉 Gamma attenuation through lead** — normalised gamma flux vs lead thickness on a log axis, one curve per energy, with the design thickness marked.
2. **📈 Dose rate vs total shield thickness** — total, neutron, and gamma components vs combined thickness, with the DOE regulatory band shaded and the 12" design point flagged.
3. **🌐 3D trade space** — dose rate surface over the full poly/lead thickness grid, with regulatory contours and the as-built design point called out.

---

## 🚀 Running It

```bash
# Open MATLAB, then from the Command Window:
Neutron_plots
```

Or open `Neutron_plots.m` in the editor and press **Run**. No additional toolboxes required, base MATLAB only.

**Requirements:** MATLAB R2020b or newer (uses the `turbo` colormap).

---

## 📚 Data Sources

- **Gamma mass attenuation coefficients:** NIST XCOM
- **Neutron removal cross sections:** Lamarsh, *Introduction to Nuclear Engineering*; Shultis & Faw, *Fundamentals of Nuclear Science and Engineering*
- **Dose rate envelope:** DOE-STD-1098-2017

---

## 📝 Notes

To adapt this for a different configuration, edit the constants block at the top: material coefficients, thickness envelope, design point, and the baseline dose assumptions. Everything downstream recomputes from those values.
