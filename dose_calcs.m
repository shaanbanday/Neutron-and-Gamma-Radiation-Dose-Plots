%% Aalo-X Reactor Vessel Radiation Shielding: Analytical Attenuation Model
% Simplified 1D slab model for panel prep visualisation
% NOT a substitute for the MCNP transport analysis done at Aalo
% Physics: fast neutron removal + gamma mass attenuation
% Data sources: NIST XCOM (gamma), Lamarsh/Shultis (neutron)

clear; clc; close all;

%% Constants
rho_Pb = 11.34;                    % lead density, g/cm^3
Sigma_r_boratedpoly = 0.12;        % 5% borated poly fast neutron removal, cm^-1

% Gamma mass attenuation coefficients for lead, cm^2/g (NIST XCOM)
E_gamma = [478, 1000, 2000];       % keV: 478 from B-10(n,a)Li-7, 1-2 MeV fission
mu_over_rho_Pb = [0.150, 0.0707, 0.0457];
mu_Pb = mu_over_rho_Pb * rho_Pb;   % linear atten coeff, cm^-1

% Thickness envelope
in_to_cm = 2.54;
t_poly_max = 6 * in_to_cm;         % 15.24 cm
t_Pb_max   = 6 * in_to_cm;         % 15.24 cm

% Design point (as-built)
poly_design = 6;                   % inches
lead_design = 6;                   % inches

% Baseline assumptions (replace with real MCNP values if available)
unshielded_dose = 600;             % mrem/hr at working position, unshielded
neutron_frac = 0.5;                % assumed split of unshielded dose
gamma_frac = 0.5;
mu_driver = 0.0457 * rho_Pb;       % 2 MeV gamma is the design driver

%% Plot 1: Gamma flux attenuation through lead
x_Pb = linspace(0, t_Pb_max, 200);
phi_gamma = zeros(length(E_gamma), length(x_Pb));
for i = 1:length(E_gamma)
    phi_gamma(i,:) = exp(-mu_Pb(i) * x_Pb);
end

figure('Position',[100 100 700 500]);
colours = [0.85 0.33 0.10; 0.47 0.67 0.19; 0.49 0.18 0.56];
for i = 1:length(E_gamma)
    semilogy(x_Pb/in_to_cm, phi_gamma(i,:), 'LineWidth', 2, 'Color', colours(i,:));
    hold on;
end
grid on;

% Design point marker
xline(6, '--w', 'LineWidth', 1.5);
text(5.8, 1e-10, 'Design: 6"', 'Color', 'w', ...
     'HorizontalAlignment', 'right', 'FontSize', 10, 'FontWeight', 'bold');

xlabel('Lead thickness (inches)', 'FontSize', 12);
ylabel('Normalised gamma flux', 'FontSize', 12);
title('Gamma attenuation through lead', 'FontSize', 13);
legend({'478 keV (secondary from B-10 capture)', ...
        '1 MeV (fission product)', ...
        '2 MeV (fission product, design driver)'}, ...
       'Location', 'southwest');
set(gca, 'FontSize', 11);
ylim([1e-12 1]);

%% Plot 2: Total dose rate vs total shield thickness
t_total_in = linspace(0, 12, 200);
t_poly = t_total_in * in_to_cm / 2;
t_Pb   = t_total_in * in_to_cm / 2;

dose_neutron = unshielded_dose * neutron_frac * exp(-Sigma_r_boratedpoly * t_poly);
dose_gamma   = unshielded_dose * gamma_frac   * exp(-mu_driver * t_Pb);
dose_total   = dose_neutron + dose_gamma;

figure('Position',[150 150 700 500]);

% Plot lines FIRST, forcing log scale from the start
h1 = semilogy(t_total_in, dose_total, 'LineWidth', 2.5, 'Color', [0 0 0]);
hold on;
h2 = semilogy(t_total_in, dose_neutron, '--', 'LineWidth', 1.5, 'Color', [0 0.4 0.7]);
h3 = semilogy(t_total_in, dose_gamma, '--', 'LineWidth', 1.5, 'Color', [0.85 0.33 0.10]);

set(gca, 'YScale', 'log');
ylim([1e-1 1e3]);
xlim([0 12]);

% Add the shaded DOE envelope, push it behind the lines
x_shade = [0 12 12 0];
y_shade = [5 5 100 100];
h_fill = fill(x_shade, y_shade, [0.85 1.0 0.85], 'FaceAlpha', 0.3, 'EdgeColor', 'none');
uistack(h_fill, 'bottom');

yline(100, ':k', 'LineWidth', 1);
yline(5,   ':k', 'LineWidth', 1);
text(1, 30, 'DOE-STD-1098-2017 envelope (5-100 mrem/hr)', ...
     'HorizontalAlignment', 'left', 'FontSize', 10);

xline(12, '--r', 'LineWidth', 1.5);
text(11.85, 5e2, 'Design point: 12"', 'Color', 'r', ...
     'HorizontalAlignment', 'right', 'FontSize', 10, 'FontWeight', 'bold');

grid on;
xlabel('Total shield thickness (inches, 50/50 poly/lead)', 'FontSize', 12);
ylabel('Dose rate at working position (mrem/hr)', 'FontSize', 12);
title('Dose rate vs shield thickness (simplified model)', 'FontSize', 13);
legend([h1 h2 h3 h_fill], {'Total dose', 'Neutron component', 'Gamma component', 'DOE envelope'}, ...
       'Location', 'northeast');
set(gca, 'FontSize', 11);

%% Plot 3: 3D Trade Space, Dose Rate vs Poly and Lead Thickness
[X, Y] = meshgrid(linspace(0.5, 12, 80), linspace(0.5, 12, 80));
X_cm = X * in_to_cm;
Y_cm = Y * in_to_cm;

dose_n_surf = unshielded_dose * neutron_frac * exp(-Sigma_r_boratedpoly * X_cm);
dose_g_surf = unshielded_dose * gamma_frac   * exp(-mu_driver * Y_cm);
Z = dose_n_surf + dose_g_surf;

figure('Position',[200 200 900 650]);
surf(X, Y, log10(Z), 'EdgeColor', 'none', 'FaceAlpha', 0.95);
shading interp;
colormap(turbo);
c = colorbar;
c.Label.String = 'log_{10}(Dose rate) [mrem/hr]';
c.Label.FontSize = 11;
hold on;

% Contour projection on the surface
contour3(X, Y, log10(Z), 15, 'k', 'LineWidth', 0.5);

% Regulatory band contours
contour3(X, Y, log10(Z), [log10(100) log10(100)], 'w', 'LineWidth', 3);
contour3(X, Y, log10(Z), [log10(5) log10(5)], '--w', 'LineWidth', 2);

% Design point marker (repositioned to avoid overlap with surface)
dose_at_design = unshielded_dose * neutron_frac * exp(-Sigma_r_boratedpoly * poly_design * in_to_cm) + ...
                 unshielded_dose * gamma_frac   * exp(-mu_driver * lead_design * in_to_cm);
plot3(poly_design, lead_design, log10(dose_at_design), 'ro', ...
      'MarkerSize', 14, 'MarkerFaceColor', 'r', 'LineWidth', 2);
text(poly_design - 1.5, lead_design + 2.5, log10(dose_at_design) + 1.0, ...
     sprintf('Design point\n(6", 6")\n%.2f mrem/hr', dose_at_design), ...
     'FontSize', 11, 'FontWeight', 'bold', 'BackgroundColor', 'w', 'Margin', 3);

xlabel('Borated poly thickness (inches)', 'FontSize', 12);
ylabel('Lead thickness (inches)', 'FontSize', 12);
zlabel('log_{10}(Dose rate) [mrem/hr]', 'FontSize', 12);
title('Shield design trade space: dose rate vs material split', 'FontSize', 13);
view(-135, 30);
grid on;
set(gca, 'FontSize', 11);
