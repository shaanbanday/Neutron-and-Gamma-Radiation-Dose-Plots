// Aalo-X Reactor Vessel Radiation Shielding: Analytical Attenuation Model
// Simplified 1D slab model for panel prep visualisation
// NOT a substitute for the MCNP transport analysis done at Aalo
// Physics: fast neutron removal + gamma mass attenuation
// Data sources: NIST XCOM (gamma), Lamarsh/Shultis (neutron)
// Converted from MATLAB to Scilab

clear; clc;
xdel(winsid());                    // close all open graphics windows

// ---- Constants ----
rho_Pb = 11.34;                    // lead density, g/cm^3
Sigma_r_boratedpoly = 0.12;        // 5% borated poly fast neutron removal, cm^-1

// Gamma mass attenuation coefficients for lead, cm^2/g (NIST XCOM)
E_gamma = [478, 1000, 2000];       // keV: 478 from B-10(n,a)Li-7, 1-2 MeV fission
mu_over_rho_Pb = [0.150, 0.0707, 0.0457];
mu_Pb = mu_over_rho_Pb * rho_Pb;   // linear atten coeff, cm^-1

// Thickness envelope
in_to_cm = 2.54;
t_poly_max = 6 * in_to_cm;         // 15.24 cm
t_Pb_max   = 6 * in_to_cm;         // 15.24 cm

// Design point (as-built)
poly_design = 6;                   // inches
lead_design = 6;                   // inches

// Baseline assumptions (replace with real MCNP values if available)
unshielded_dose = 600;             // mrem/hr at working position, unshielded
neutron_frac = 0.5;                // assumed split of unshielded dose
gamma_frac   = 0.5;
mu_driver = 0.0457 * rho_Pb;       // 2 MeV gamma is the design driver

// ============================================================
// Plot 1: Gamma flux attenuation through lead
// ============================================================
x_Pb = linspace(0, t_Pb_max, 200);
phi_gamma = zeros(length(E_gamma), length(x_Pb));
for i = 1:length(E_gamma)
    phi_gamma(i,:) = exp(-mu_Pb(i) * x_Pb);
end

f1 = scf(0);
f1.figure_position = [100 100];
f1.figure_size     = [700 500];

// custom RGB colours -> colour-map indices (Scilab needs an index, not an RGB triple)
col1 = addcolor([0.85 0.33 0.10]);
col2 = addcolor([0.47 0.67 0.19]);
col3 = addcolor([0.49 0.18 0.56]);
cols = [col1 col2 col3];

for i = 1:length(E_gamma)
    plot(x_Pb/in_to_cm, phi_gamma(i,:));
    e = gce();
    e.children.thickness  = 2;
    e.children.foreground = cols(i);
end

a = gca();
a.log_flags = "nln";               // semilogy: x normal, y log (no semilogy() in Scilab)
a.data_bounds = [0 1e-12; 6 1];    // replaces ylim/xlim
a.tight_limits = ["on" "on"];
xgrid();                           // replaces grid on

// design point marker (vertical dashed line at 6")
plot([6 6], [1e-12 1]);
e = gce(); e.children.line_style = 2; e.children.foreground = color("white");
xstring(5.8, 1e-10, "Design: 6""");
t = gce(); t.font_foreground = color("white"); t.font_size = 2;

xlabel("Lead thickness (inches)", "fontsize", 2);
ylabel("Normalised gamma flux", "fontsize", 2);
title("Gamma attenuation through lead", "fontsize", 3);
legend(["478 keV (secondary from B-10 capture)"; ..
        "1 MeV (fission product)"; ..
        "2 MeV (fission product, design driver)"], "in_lower_left");

// ============================================================
// Plot 2: Total dose rate vs total shield thickness
// ============================================================
t_total_in = linspace(0, 12, 200);
t_poly = t_total_in * in_to_cm / 2;
t_Pb   = t_total_in * in_to_cm / 2;

dose_neutron = unshielded_dose * neutron_frac * exp(-Sigma_r_boratedpoly * t_poly);
dose_gamma   = unshielded_dose * gamma_frac   * exp(-mu_driver * t_Pb);
dose_total   = dose_neutron + dose_gamma;

f2 = scf(1);
f2.figure_position = [150 150];
f2.figure_size     = [700 500];

// DOE envelope band: drawn FIRST so the curves sit on top.
// Draw order replaces MATLAB's uistack(...,'bottom'). No face-alpha in xfpoly,
// so this is a solid light-green fill rather than a translucent one.
xfpoly([0 12 12 0], [5 5 100 100], addcolor([0.85 1.0 0.85]));

plot(t_total_in, dose_total);
h1 = gce().children; h1.thickness = 3; h1.foreground = color("black");
plot(t_total_in, dose_neutron);
h2 = gce().children; h2.thickness = 2; h2.line_style = 2; h2.foreground = addcolor([0 0.4 0.7]);
plot(t_total_in, dose_gamma);
h3 = gce().children; h3.thickness = 2; h3.line_style = 2; h3.foreground = addcolor([0.85 0.33 0.10]);

a = gca();
a.log_flags = "nln";
a.data_bounds = [0 1e-1; 12 1e3];
a.tight_limits = ["on" "on"];
xgrid();

// regulatory band reference lines (replaces yline)
plot([0 12], [100 100]); e = gce(); e.children.line_style = 3; e.children.foreground = color("black");
plot([0 12], [5 5]);     e = gce(); e.children.line_style = 3; e.children.foreground = color("black");
xstring(1, 30, "DOE-STD-1098-2017 envelope (5-100 mrem/hr)");

// design point line at 12" (replaces xline)
plot([12 12], [1e-1 1e3]); e = gce(); e.children.line_style = 2; e.children.foreground = color("red");
xstring(11.85, 5e2, "Design point: 12""");
t = gce(); t.font_foreground = color("red");

xlabel("Total shield thickness (inches, 50/50 poly/lead)", "fontsize", 2);
ylabel("Dose rate at working position (mrem/hr)", "fontsize", 2);
title("Dose rate vs shield thickness (simplified model)", "fontsize", 3);
// Legend bound to explicit handles so labels match the right curves.
// The shaded envelope is labelled by the text above rather than in the legend.
legend([h1 h2 h3], ["Total dose"; "Neutron component"; "Gamma component"], "in_upper_right");

// ============================================================
// Plot 3: 3D trade space, dose rate vs poly and lead thickness
// ============================================================
[X, Y] = meshgrid(linspace(0.5, 12, 80), linspace(0.5, 12, 80));
X_cm = X * in_to_cm;
Y_cm = Y * in_to_cm;

dose_n_surf = unshielded_dose * neutron_frac * exp(-Sigma_r_boratedpoly * X_cm);
dose_g_surf = unshielded_dose * gamma_frac   * exp(-mu_driver * Y_cm);
Z  = dose_n_surf + dose_g_surf;
Zl = log10(Z);

f3 = scf(2);
f3.figure_position = [200 200];
f3.figure_size     = [900 650];
f3.color_map = jetcolormap(128);   // Scilab has no 'turbo'; jet is the closest built-in

surf(X, Y, Zl);
e = gce();
e.color_flag = 3;                  // interpolated shading (replaces shading interp)
// Note: hiding the mesh edges on a Scilab surf is not a clean one-liner like
// EdgeColor 'none'. If edge lines show, that is the known surf difference.

colorbar(min(Zl), max(Zl));        // label text cannot be set the way MATLAB does it

// design point marker
dose_at_design = unshielded_dose * neutron_frac * exp(-Sigma_r_boratedpoly * poly_design * in_to_cm) + ..
                 unshielded_dose * gamma_frac   * exp(-mu_driver * lead_design * in_to_cm);
param3d(poly_design, lead_design, log10(dose_at_design));
e = gce();
e.line_mode   = "off";
e.mark_mode   = "on";
e.mark_style  = 9;                 // filled circle-ish marker
e.mark_size   = 3;
e.mark_foreground = color("red");

a = gca();
a.rotation_angles = [60 225];      // approx of MATLAB view(-135,30); adjust to taste
xlabel("Borated poly thickness (inches)", "fontsize", 2);
ylabel("Lead thickness (inches)", "fontsize", 2);
zlabel("log10(Dose rate) [mrem/hr]", "fontsize", 2);
title("Shield design trade space: dose rate vs material split", "fontsize", 3);
xgrid();

disp(msprintf("Design point (6"", 6""): %.2f mrem/hr", dose_at_design));
