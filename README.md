# ⚛️ Sodium Cooled Reactor Vessel Radiation Shielding Model

A simplified **1D slab attenuation model** in MATLAB, SciLab, and GNU Octave for visualising how neutron and gamma dose rates fall off through layered shielding on a sodium cooled fast reactor.
---

## ⚠️ Scope and Limitations

This is a **first-order analytical model**, not a transport simulation. It assumes straight-line attenuation with no buildup factors, scattering, streaming paths, or geometry effects. It is **not** a substitute for the MCNP transport analysis. Treat the numbers as directional, useful for comparing shield configurations and prepping panels, not for demonstrating regulatory compliance.

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
