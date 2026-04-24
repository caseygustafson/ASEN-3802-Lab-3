clc;
clear;
close all;


%% Part 1

%% Task 1 Airfoil Plots for 2421 and 0012

airfoils = {'2421','0021'}; 
N_plot = 50; % Panels

for k = 1:length(airfoils)
    airfoil = airfoils{k};

    % Generate airfoil coordinates
    [YC3, X3, XB3, YB3, aL03] = NACA_Airfoils(str2double(airfoil), N_plot);

    % Plot airfoil with panel points
    figure;
    hold on;
    plot(XB3, YB3, 'b', 'LineWidth', 1.5); % Airfoil surface
    scatter(XB3, YB3, 10, 'filled'); % Panel points
    if any(YC3) % if camber exists
        plot(X3, YC3, 'r--', 'LineWidth', 2); % Camber line
    end
    title(['NACA ', airfoil])
    xlabel('x/c')
    ylabel('y/c')
    axis equal
    grid on
    hold off;
end

%% Task 2 Convergence Study
ALPHA = 12; % Angle of attack

% Step 1 High-resolution panel numbers
N = round(linspace(10, 300,300)); % increase number of panels
CL1 = zeros(size(N));

for i = 1:length(N)
    Ni = N(i);
    [~, ~, XB3, YB3, ~] = NACA_Airfoils(12, Ni); % NACA 0012
    CL1(i) = Vortex_Panel(XB3, YB3, ALPHA);
end

CL_exact = CL1(end); % take largest N as "exact"

% Step 2 Finding minimum number of panels for 1% error
rel_error = abs(CL1 - CL_exact)/CL_exact;
N_min_idx = find(rel_error <= 0.01, 1, 'first');
N_min_guess = N(N_min_idx);

% Step 3 Refining around that guess
N_refine = N_min_guess-50 : N_min_guess+50;
N_refine(N_refine < 1) = 1;
CL_refine = zeros(size(N_refine));

for i = 1:length(N_refine)
    Ni = N_refine(i);
    [~, ~, XB3, YB3, ~] = NACA_Airfoils(12, Ni);
    CL_refine(i) = Vortex_Panel(XB3, YB3, ALPHA);
end

% Finding actual minimum number of panels
rel_error_refine = abs(CL_refine - CL_exact)/CL_exact;
N_min_actual = N_refine(find(rel_error_refine <= 0.01, 1, 'first'));

% print results
fprintf('Sectional lift coefficient CL for NACA 0012 at alpha = %.1f deg: %.4f\n', ALPHA, CL_exact);
fprintf('Minimum number of panels for 1%% relative error: %d\n', N_min_actual);

% Step 4 plot convergence
N_total = 2*N;
N_min_total = 2*N_min_actual;

figure;
hold on; grid on;
plot(N_total, CL1, 'b-', 'LineWidth', 1.5);
xline(N_min_total, 'r--', 'LineWidth', 2);
xlabel('Number of Panels');
ylabel('Sectional Coefficient of Lift CL');
title('NACA 0012 Convergence Study');
legend('CL vs N', sprintf('1%% Error Threshold at N = %d', N_min_total));
hold off;

saveas(gcf, 'convergenceStudyPanels_highres', 'png');

%% Task 3 & 4 Airfoil Thickness and Camber Effects

Panels = 35;% Number of panels for Vortex Panel
ALPHA = linspace(-8, 8, 100); % Range of angles of attack

Panels = 50; % Number of panels for Vortex Panel
ALPHA = linspace(-8, 8, 100); % Range of angles of attack


%% Part A, Effect of Thickness (0006, 0012, 0018)

thick_airfoils = {'0006','0012','0018'};
CL.Thick = struct(); % Struct to hold sectional lift
LiftSlope.Thick = struct(); % Struct to hold a0
ZeroLift.Thick = struct(); % Struct to hold zero-lift AoA

for k = 1:length(thick_airfoils)
    airfoil = str2double(thick_airfoils{k});
    [YC, Xc, XB, YB, aL0] = NACA_Airfoils(airfoil, Panels);

    ZeroLift.Thick.(sprintf('NACA%s', thick_airfoils{k})) = aL0; % zero-lift AoA

    % Compute sectional lift for all alpha
    CL.Thick.(sprintf('NACA%s', thick_airfoils{k})) = zeros(1,length(ALPHA));
    for j = 1:length(ALPHA)
        CL.Thick.(sprintf('NACA%s', thick_airfoils{k}))(j) = Vortex_Panel(XB, YB, ALPHA(j));
    end

    % Compute lift slope a0 using 0 and 5 AoA
    CL0 = Vortex_Panel(XB, YB, 0);
    CL5 = Vortex_Panel(XB, YB, 5);
    LiftSlope.Thick.(sprintf('NACA%s', thick_airfoils{k})) = (CL5 - CL0)/5;
end

% Plot thickness study
figure;
hold on; grid on;
for k = 1:length(thick_airfoils)
    plot(ALPHA, CL.Thick.(sprintf('NACA%s', thick_airfoils{k})), 'DisplayName', ['NACA ', thick_airfoils{k}]);
end
xlabel('Angle of Attack (deg)');
ylabel('Coefficient of Lift, CL');
title('Effect of Airfoil Thickness on Lift');
legend show Location best;

% NACA 0006 - symmetric, thin. Lift slope ~0.105/deg, aL0 = 0 deg
ExperimentalAoA_0006 = [-8, -6, -4, -2, 0, 2, 4, 6, 8];
cl_experimental_0006 = [-0.76, -0.58, -0.39, -0.20, 0.00, 0.20, 0.39, 0.58, 0.76];

% NACA 0012 - symmetric. Lift slope ~0.110/deg, aL0 = 0 deg
ExperimentalAoA_0012 = [-8, -6, -4, -2, 0, 2, 4, 6, 8];
cl_experimental_0012 = [-0.80, -0.61, -0.41, -0.20, 0.00, 0.20, 0.41, 0.61, 0.80];

plot(ExperimentalAoA_0006, cl_experimental_0006);
plot(ExperimentalAoA_0012, cl_experimental_0012);
legend('NACA 0006','NACA 0012','NACA 0018','Exp. NACA 0006','Exp. NACA 0012')

xlim([-8 8]);
ylim([-1 1]);

hold off;
saveas(gcf, 'thicknessImpact','png');

%% Part B, Effect of Camber (0012, 2412, 4412)

camber_airfoils = {'0012','2412','4412'};
CL.Camber = struct();
LiftSlope.Camber = struct();
ZeroLift.Camber = struct();

for k = 1:length(camber_airfoils)
    airfoil = str2double(camber_airfoils{k});
    [YC, Xc, XB, YB, aL0] = NACA_Airfoils(airfoil, Panels);

    ZeroLift.Camber.(sprintf('NACA%s', camber_airfoils{k})) = aL0;

    CL.Camber.(sprintf('NACA%s', camber_airfoils{k})) = zeros(1,length(ALPHA));
    for j = 1:length(ALPHA)
        CL.Camber.(sprintf('NACA%s', camber_airfoils{k}))(j) = Vortex_Panel(XB, YB, ALPHA(j));
    end

    CL0 = Vortex_Panel(XB, YB, 0);
    CL5 = Vortex_Panel(XB, YB, 5);
    LiftSlope.Camber.(sprintf('NACA%s', camber_airfoils{k})) = (CL5 - CL0)/5;
end

% Plot camber study
figure;
hold on;
grid on;
for k = 1:length(camber_airfoils)
    plot(ALPHA, CL.Camber.(sprintf('NACA%s', camber_airfoils{k})), 'DisplayName', ['NACA ', camber_airfoils{k}]);
end
xlabel('Angle of Attack (deg)');
ylabel('Coefficient of Lift, CL');
title('Effect of Airfoil Camber on Lift');
legend show Location best;

% Plot experimental

plot(ExperimentalAoA_0012, cl_experimental_0012);

% NACA 2412 - 2% camber. Lift slope ~0.108/deg, aL0 = -2.07 deg
ExperimentalAoA_2412 = [-8, -6, -4, -2, 0, 2, 4, 6, 8];
cl_experimental_2412 = [-0.58, -0.38, -0.17, 0.04, 0.25, 0.45, 0.65, 0.85, 1.04];
plot(ExperimentalAoA_2412, cl_experimental_2412);

% NACA 4412 - 4% camber. Lift slope ~0.108/deg, aL0 = -4.15 deg
ExperimentalAoA_4412 = [-8, -6, -4, -2, 0, 2, 4, 6, 8];
cl_experimental_4412 = [-0.36, -0.15, 0.07, 0.28, 0.50, 0.71, 0.91, 1.11, 1.30];
plot(ExperimentalAoA_4412, cl_experimental_4412);

legend('NACA 0012','NACA 2412','NACA 4412','Exp. NACA 0012','Exp. NACA 2412','Exp. NACA 4412')

xlim([-8 8]);
ylim([-1 1.5]);

hold off;
saveas(gcf, 'camberImpact','png');

%% Part C, Print results

fprintf('Thickness Study\n');
for k = 1:length(thick_airfoils)
    af = thick_airfoils{k};
    fprintf('NACA %s: a0 = %.4f per deg, alpha_L0 = %.4f deg\n', af, LiftSlope.Thick.(sprintf('NACA%s',af)), ZeroLift.Thick.(sprintf('NACA%s',af)));
end

fprintf('Camber Study\n');
for k = 1:length(camber_airfoils)
    af = camber_airfoils{k};
    fprintf('NACA %s: a0 = %.4f per deg, alpha_L0 = %.4f deg\n', af, LiftSlope.Camber.(sprintf('NACA%s',af)), ZeroLift.Camber.(sprintf('NACA%s',af)));
end


%% PART 2

b = 100; % span [ft]
N_test = 5; % small number of modes for quick validation

% [a0_t, a0_r, c_t, c_r, aero_t, aero_r, geo_t, geo_r]
cases = [
    2*pi, 2*pi, 10, 10, 0,  0,  5, 5; % Case 1
    2*pi, 2*pi,  8, 10, 0,  0,  5, 5; % Case 2
    6.3 , 6.5 ,  8, 10, 0, -2,  5, 7 % Case 3
];

numCases  = size(cases, 1);
CL_check  = zeros(1, numCases);
CDi_check = zeros(1, numCases);
e_check   = zeros(1, numCases);

for k = 1:numCases
    a0_t = cases(k,1);
    a0_r = cases(k,2);
    c_t = cases(k,3);
    c_r = cases(k,4);
    aero_t = cases(k,5);
    aero_r = cases(k,6);
    geo_t = deg2rad(cases(k,7));
    geo_r = deg2rad(cases(k,8));

    [e_check(k), CL_check(k), CDi_check(k)] = PLLT(b, a0_t, a0_r, c_t, c_r, aero_t, aero_r, geo_t, geo_r, N_test);
end

results_check.CL = CL_check;
results_check.CDi = CDi_check;
results_check.e = e_check;

disp('PART 2: PLLT Function Check');
disp(results_check);

AR_list = [4 6 8 10]; % Aspect ratios to sweep
taper = linspace(0, 1, 100); % taper ratio ct/cr range
N_fig = 50; % number of modes (matches Anderson)

% Uniform airfoil + geometric AoA assumptions
a0_t_fig = 2*pi;
a0_r_fig = 2*pi;
aero_t_fig = 0;
aero_r_fig = 0;
geo_t_fig = deg2rad(5);
geo_r_fig = deg2rad(5);
b_fig = 100; % ft

delta = zeros(length(taper), length(AR_list));

for i = 1:length(AR_list)
    AR = AR_list(i);
    for j = 1:length(taper)
        lambda = taper(j);
        c_r_fig = (2 * b_fig) / (AR * (1 + lambda));
        c_t_fig = lambda * c_r_fig;
        [e, ~, ~] = PLLT(b_fig, a0_t_fig, a0_r_fig, c_t_fig, c_r_fig, aero_t_fig, aero_r_fig, geo_t_fig, geo_r_fig, N_fig);
        delta(j, i) = (1 / e) - 1;
    end
end

figure;
plot(taper, delta, 'LineWidth', 1.5);
xlabel('$c_t / c_r$', 'Interpreter', 'latex', 'FontSize', 13);
ylabel('$\delta$', 'Interpreter', 'latex', 'FontSize', 13);
title('Induced Drag Factor vs. Taper Ratio (Anderson Fig. 5.20)');
legend('AR = 4', 'AR = 6', 'AR = 8', 'AR = 10', 'Location', 'best');
ylim([0 0.2]);
grid on;





%% PART 3

% wing goemetry
b = 33 + 4/12;
c_r = 5 + 4/12;
c_t = 3 + 8.5/12;
AR = (2*b)/(c_r + c_t);
S = (b/2)*(c_r + c_t);

% lift slope and zero-lift angle of attack from vortex panel method
[~,~,XB_r,YB_r,aero_r] = NACA_Airfoils(2412, N_min_actual);
[~,~,XB_t,YB_t,aero_t] = NACA_Airfoils(12, N_min_actual);
a0_r = (Vortex_Panel(XB_r,YB_r,5) - Vortex_Panel(XB_r,YB_r,0))/deg2rad(5);
a0_t = (Vortex_Panel(XB_t,YB_t,5) - Vortex_Panel(XB_t,YB_t,0))/deg2rad(5);

fprintf('NACA 2412 (root): a0=%.4f /rad, aL0=%.4f deg\n', a0_r, aero_r);
fprintf('NACA 0012 (tip): a0=%.4f /rad, aL0=%.4f deg\n', a0_t, aero_t);

%% deliverables 1 and 2
N_vals = 1:2:301;
gR = deg2rad(4+1);
gT = deg2rad(4);

CL_c = zeros(1,length(N_vals));
CDi_c = zeros(1,length(N_vals));

for i = 1:length(N_vals)
    [~, CL_c(i), CDi_c(i)] = PLLT(b,a0_t,a0_r,c_t,c_r,aero_t,aero_r,gT,gR,N_vals(i));
end

% relative errors
err_CL = abs((CL_c - CL_c(end))/CL_c(end))*100;
err_CDi = abs((CDi_c - CDi_c(end))/CDi_c(end))*100;

% Find first N within each threshold
thresholds = [10, 1, 0.1];
N_CL = zeros(1,3);
N_CDi = zeros(1,3);
CL_t = zeros(1,3);
CDi_t = zeros(1,3);
for t = 1:3
    i1 = find(err_CL <= thresholds(t), 1); N_CL(t) = N_vals(i1); CL_t(t) = CL_c(i1);
    i2 = find(err_CDi <= thresholds(t), 1); N_CDi(t) = N_vals(i2); CDi_t(t) = CDi_c(i2);
end


%% deliverable 1 table
fprintf('\nCONVERGENCE TABLE\n')
fprintf('Error Level     N for CL     CL Value      N for CDi    CDi Value\n')
fprintf('10 percent      %d            %.6f      %d            %.6f\n', N_CL(1), CL_t(1), N_CDi(1), CDi_t(1))
fprintf('1 percent       %d            %.6f      %d            %.6f\n', N_CL(2), CL_t(2), N_CDi(2), CDi_t(2))
fprintf('0.1 percent     %d           %.6f      %d           %.6f\n', N_CL(3), CL_t(3), N_CDi(3), CDi_t(3))


%% deliverable 2 CL plot

figure
plot(N_vals, CL_c, 'b-', 'lineWidth', 2)
hold on
grid on
xline(N_CL(1), 'r--', '10% error')
xline(N_CL(2), 'm--', '1% error')
xline(N_CL(3), 'k--', '0.1% error')
xlabel('number of odd terms')
ylabel('C_L')
title('C_L convergence with number of odd terms')
legend('C_L', '10% error', '1% error', '0.1% error', 'location', 'best')
xlim([0 100])

%% deliverable 2 CDi plot

figure
plot(N_vals, CDi_c, 'b-', 'lineWidth', 2)
hold on
grid on
xline(N_CDi(1), 'r--', '10% error')
xline(N_CDi(2), 'm--', '1% error')
xline(N_CDi(3), 'k--', '0.1% error')
xlabel('number of odd terms')
ylabel('C_{D,i}')
title('C_{D,i} Convergence with number of odd terms')
legend('C_{D,i}', '10% error', '1% error', '0.1% error', 'location', 'best')
xlim([0 100])

%% deliverable 3

N_use = max(N_CL(3), N_CDi(3));  % most restrictive N for 0.1% error
rho = 0.001756; % density at 10,000 ft [slug/ft^3]
V = 100*1.68781; % 100 knots in ft/s
q = 0.5*rho*V^2; % dynamic pressure [lb/ft^2]

[e_cr, CL_cr, CDi_cr] = PLLT(b,a0_t,a0_r,c_t,c_r,aero_t,aero_r,gT,gR,N_use);

cd_profile = 0.5*(0.007 + 0.006); % avg of root (NACA 2412) and tip (NACA 0012) cd
CD_cr = cd_profile + CDi_cr;
L  = q*S*CL_cr;
Di = q*S*CDi_cr;
D = q*S*CD_cr;

fprintf('\nCRUISE RESULTS\n')
fprintf('Number of terms used: %d\n', N_use)
fprintf('CL = %.4f\n', CL_cr)
fprintf('CDi = %.4f\n', CDi_cr)
fprintf('cd = %.4f\n', cd_profile)
fprintf('CD = %.4f\n', CD_cr)
fprintf('L = %.2f lb\n', L)
fprintf('Di = %.2f lb\n', Di)
fprintf('D = %.2f lb\n', D)
fprintf('L/D = %.4f\n', L/D)


%% AoA Sweep
alpha_deg = -10:0.5:20;
CL_s=zeros(1,length(alpha_deg));
CDi_s=CL_s;
CD_s=CL_s;
LD_s=CL_s;

for a = 1:length(alpha_deg)
    gR_a = deg2rad(alpha_deg(a) + 1); % root: AoA + 1 deg twist
    gT_a = deg2rad(alpha_deg(a) + 0); % tip: AoA + 0 deg twist
    [~, CL_s(a), CDi_s(a)] = PLLT(b,a0_t,a0_r,c_t,c_r,aero_t,aero_r,gT_a,gR_a,N_use);
    CD_s(a) = cd_profile + CDi_s(a);
    LD_s(a) = CL_s(a)/CD_s(a);
end

%% Deliverable 4
figure; hold on;
plot(alpha_deg, CD_s,'k-','LineWidth',2,'DisplayName','C_D total');
plot(alpha_deg, CDi_s,'b--', 'LineWidth',1.8, 'DisplayName','C_{D,i} induced');
plot(alpha_deg, CD_s - CDi_s,'r:','LineWidth',1.8, 'DisplayName','c_d profile');
xlabel('\alpha [deg]');
ylabel('Drag Coefficient');
title('Total Drag Coefficient vs. \alpha');
legend('Location','northwest');
grid on;

%% Deliverable 5
[maxLD, imax] = max(LD_s);
figure; plot(alpha_deg, LD_s, 'k-', 'LineWidth',2);
hold on;
plot(alpha_deg(imax), maxLD, 'r*', 'MarkerSize',12,'DisplayName', sprintf('(L/D)_{max}=%.2f at %.1f°', maxLD, alpha_deg(imax)));
xlabel('\alpha [deg]');
ylabel('L/D');
title('L/D vs. \alpha');
legend('Location','best');
grid on;
fprintf('\n(L/D)_max = %.4f at alpha = %.2f deg\n', maxLD, alpha_deg(imax));






%%  LOCAL FUNCTIONS  

function airfoil_plot(x, y, plot_name, c, x_c, y_c)
% General function to plot airfoil shape with optional camber line.
% Inputs:
%  x, y - boundary point coordinates
%  plot_name - string label for title
%  c - chord length (used for y-axis limits)
%  x_c, y_c - camber line coordinates

figure();
hold on;
ylim([-c/2, c/2]);
plot(x, y, 'b', 'LineWidth', 1.5);
scatter(x, y, 15, 'filled');
if ~isempty(x_c)
    plot(x_c, y_c, 'r--', 'LineWidth', 1.5);
end
title("Airfoil: NACA " + plot_name)
xlabel('m');
ylabel('m');
axis equal;
hold off;
end


function [yc, x, XB, YB, aL0] = NACA_Airfoils(digits, N)
% Generates NACA 4-digit airfoil geometry and computes zero-lift AoA.
% Inputs:
%  digits - 4-digit NACA code (numeric or string, e.g. 2412 or '2412')
%  N - number of panels (cosine-spaced)
% Outputs:
%  yc - camber line y-coordinates
%  x - chordwise x-coordinates
%  XB - boundary point x-coordinates (clockwise, TE->LE->TE)
%  YB - boundary point y-coordinates
%  aL0 - zero-lift angle of attack [deg]

% Convert numeric input to 4-digit string
if isnumeric(digits)
    digits = num2str(digits, '%04d');
end
% Validate input
if length(digits) ~= 4 || any(~isstrprop(digits, 'digit'))
    error('Input must be a 4-digit NACA code (e.g., 0012, 2412, 4415).');
end

% Airfoil parameters
c = 1; % chord length
m = str2double(digits(1)) / 100; % max camber
p = str2double(digits(2)) / 10; % position of max camber
t = str2double(digits(3:4)) / 100; % thickness

% Cosine spacing along chord
beta = linspace(0, pi, N);
x = 0.5 * c * (1 - cos(beta));  % 0 -> c

% Thickness distribution
yt = 5 * t * c * ( 0.2969 * sqrt(x / c) - 0.1260 * (x / c) - 0.3516 * (x / c).^2 + 0.2843 * (x / c).^3 - 0.1036 * (x / c).^4 );

% Mean camber line and slope
yc = zeros(size(x));
dyc_dx = zeros(size(x));

if p ~= 0 && m ~= 0
    % Front portion: 0 <= x < p*c
    idx1 = x < p * c;
    xc1 = x(idx1) / c;
    yc(idx1) = (m / p^2) * (2 * p * xc1 - xc1.^2) * c;
    dyc_dx(idx1) = (2 * m / p^2) .* (p - xc1);

    % Rear portion: p*c <= x <= c
    idx2 = ~idx1;
    xc2 = x(idx2) / c;
    yc(idx2) = (m / (1 - p)^2) * ((1 - 2 * p) + 2 * p * xc2 - xc2.^2) * c;
    dyc_dx(idx2) = (2 * m / (1 - p)^2) .* (p - xc2);
end

% Camberline angle
theta = atan(dyc_dx);

% Upper and lower surfaces
xu = x - yt .* sin(theta);
yu = yc + yt .* cos(theta);
xl = x + yt .* sin(theta);
yl = yc - yt .* cos(theta);

% Combine into clockwise boundary (TE->LE->TE)
XB = [fliplr(xl), xu(2:end)];
YB = [fliplr(yl), yu(2:end)];

% Zero-lift angle of attack via thin airfoil theory integration
if m ~= 0 && p ~= 0
    Nint = 1000;
    theta_int = linspace(0, pi, Nint);
    x_c = 0.5 * (1 - cos(theta_int));

    % Slope of mean camber line
    dzdx = zeros(size(x_c));
    for i = 1:Nint
        if x_c(i) < p
            dzdx(i) = (2*m/p^2)*(p - x_c(i));
        else
            dzdx(i) = (2*m/(1-p)^2)*(p - x_c(i));
        end
    end

    % gives zero lift aoa for 2412 and 4412 of -2.07 and -4.15
    integrand = dzdx .* (cos(theta_int) - 1);
    % gives zero lift aoa for 2412 and 4412 of -1.12 and -2.5
    %  integrand = dzdx .* (cos(theta_int - 1));
    aL0 = -(1/pi) * trapz(theta_int, integrand); % radians
    aL0 = aL0 * 180/pi; % convert to degrees
else
    aL0 = 0;
end
end

%----------------------------------------------------------------------------
function [CL] = Vortex_Panel(XB, YB, ALPHA)
% Vortex panel method for 2D sectional lift coefficient
% Inputs:
%  XB - boundary point x-coordinates
%  YB- boundary point y-coordinates
%  ALPHA - angle of attack [deg]
% Output:
%  CL - sectional lift coefficient

ALPHA = ALPHA * pi/180;
CHORD = max(XB) - min(XB);
M = max(size(XB,1), size(XB,2)) - 1;
MP1 = M + 1;

X = zeros(1,M);
Y = zeros(1,M);
S = zeros(1,M);
THETA = zeros(1,M);
SINE = zeros(1,M);
COSINE = zeros(1,M);
RHS = zeros(1,M);
CN1 = zeros(M);
CN2 = zeros(M);
CT1 = zeros(M);
CT2 = zeros(M);
AN = zeros(M);
AT = zeros(M);
V = zeros(1,M);
CP = zeros(1,M);

% Control points, panel sizes, and angles
for I = 1:M
    IP1 = I + 1;
    X(I) = 0.5*(XB(I)+XB(IP1));
    Y(I) = 0.5*(YB(I)+YB(IP1));
    S(I) = sqrt((XB(IP1)-XB(I))^2 + (YB(IP1)-YB(I))^2);
    THETA(I) = atan2(YB(IP1)-YB(I), XB(IP1)-XB(I));
    SINE(I) = sin(THETA(I));
    COSINE(I) = cos(THETA(I)); 
    RHS(I) = sin(THETA(I) - ALPHA);
end

% Between panels
for I = 1:M
    for J = 1:M
        if I == J
            CN1(I,J) = -1.0;
            CN2(I,J) = 1.0;
            CT1(I,J) = 0.5*pi;
            CT2(I,J) = 0.5*pi;
        else
            A = -(X(I)-XB(J))*COSINE(J) - (Y(I)-YB(J))*SINE(J);
            B = (X(I)-XB(J))^2 + (Y(I)-YB(J))^2;
            C = sin(THETA(I)-THETA(J));
            D = cos(THETA(I)-THETA(J));
            E = (X(I)-XB(J))*SINE(J) - (Y(I)-YB(J))*COSINE(J); 
            F = log(1.0 + S(J)*(S(J)+2*A)/B);
            G = atan2(E*S(J), B+A*S(J));
            P = (X(I)-XB(J))*sin(THETA(I)-2*THETA(J)) + (Y(I)-YB(J))*cos(THETA(I)-2*THETA(J));
            Q = (X(I)-XB(J))*cos(THETA(I)-2*THETA(J)) - (Y(I)-YB(J))*sin(THETA(I)-2*THETA(J));
            CN2(I,J) = D + 0.5*Q*F/S(J) - (A*C+D*E)*G/S(J);
            CN1(I,J) = 0.5*D*F + C*G - CN2(I,J);
            CT2(I,J) = C + 0.5*P*F/S(J) + (A*D-C*E)*G/S(J);
            CT1(I,J) = 0.5*C*F - D*G - CT2(I,J);
        end
    end
end

% Coefficients
for I = 1:M
    AN(I,1) = CN1(I,1);
    AN(I,MP1) = CN2(I,M);
    AT(I,1) = CT1(I,1);
    AT(I,MP1) = CT2(I,M);
    for J = 2:M
        AN(I,J) = CN1(I,J) + CN2(I,J-1);
        AT(I,J) = CT1(I,J) + CT2(I,J-1);
    end
end
AN(MP1,1) = 1.0;
AN(MP1,MP1) = 1.0;
for J = 2:M
    AN(MP1,J) = 0.0;
end
RHS(MP1) = 0.0;

% Vortex strengths
GAMA = AN \ RHS';

% Tangential velocity and lift
for I = 1:M
    V(I) = cos(THETA(I) - ALPHA);
    for J = 1:MP1
        V(I) = V(I) + AT(I,J)*GAMA(J);
    end
end

CIRCULATION = sum(S .* V);
CL = 2 * CIRCULATION / CHORD;
end



function [e, c_L, c_Di] = PLLT(b, a0_t, a0_r, c_t, c_r, aero_t, aero_r, geo_t, geo_r, N)
% PLLT - Prandtl Lifting Line Theory
%
% Computes span efficiency, lift coefficient, and induced drag coefficient
% for a finite wing using a Fourier series for spanwise circulation.
%
% INPUTS:
%  b - wing span [ft]
%  a0_t - sectional lift slope at tip [/rad]
%  a0_r - sectional lift slope at root [/rad]
%  c_t - chord at tip [ft]
%  c_r - chord at root [ft]
%  aero_t - zero-lift AoA at tip [deg]
%  aero_r - zero-lift AoA at root [deg]
%  geo_t - geometric AoA at tip [rad]
%  geo_r - geometric AoA at root [rad]
%  N - number of odd Fourier modes
%
% OUTPUTS:
%  e - span efficiency factor
%  c_L - wing lift coefficient
%  c_Di - wing induced drag coefficient

% Spanwise collocation points (theta: 0=tip, pi/2=root)
theta = (1:N)' * pi / (2*N);
y = -(b/2) .* cos(theta);

% Spanwise distributions (linear root-to-tip)
c_theta= c_r + (abs(y)/(b/2)) * (c_t - c_r);
aero0 = deg2rad(aero_r + (abs(y)/(b/2)) * (aero_t - aero_r));
a0_theta = a0_r + (abs(y)/(b/2)) * (a0_t - a0_r);
aero_geo = geo_r + (abs(y)/(b/2)) * (geo_t - geo_r);

% Aspect ratio (trapezoidal)
AR = (2 * b) / (c_r + c_t);

% PLLT coefficient term
coeff = (4 * b) ./ (a0_theta .* c_theta);

% Build linear system
M_mat = zeros(N, N);
RHS = aero_geo - aero0;

for i = 1:N
    for j = 1:N
        n = 2*j - 1;
        M_mat(i,j) = (coeff(i) + n/sin(theta(i))) * sin(n*theta(i));
    end
end

% Solve for Fourier coefficients
A = M_mat \ RHS;

% Span efficiency factor
n_index = 2*(1:N) - 1;
denom = sum(n_index(:) .* (A(:).^2));
e = A(1)^2 / denom;

% Lift and induced drag coefficients
c_L = pi * AR * A(1);
c_Di = c_L^2 / (pi * AR * e);
end
