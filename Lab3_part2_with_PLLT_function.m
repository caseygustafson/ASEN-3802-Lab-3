clc;
clear;
close all;

%% ============================================================
%  PART 2: FINITE WING ANALYSIS USING PRANDTL LIFTING LINE THEORY
%  This script:
%  1) Verifies the PLLT function using known test cases
%  2) Reproduces Anderson Fig. 5.20 (induced drag factor vs taper ratio)
% ============================================================

%% -------------------------
%  SECTION 1: FUNCTION CHECK
%  (Sanity check using instructor-provided cases)
% --------------------------

% Common parameters
b = 100;           % span [ft]
N_test = 5;        % small number of modes for quick validation

% Case definitions (each row = one test case)
cases = [
    2*pi, 2*pi, 10, 10, 0, 0, 5, 5;   % Case 1
    2*pi, 2*pi, 8, 10, 0, 0, 5, 5;    % Case 2
    6.3 , 6.5 , 8, 10, 0, -2, 5, 7     % Case 3
];

% Preallocate
numCases = size(cases,1);
CL_check  = zeros(1,numCases);
CDi_check = zeros(1,numCases);
e_check   = zeros(1,numCases);

for k = 1:numCases
    
    % Extract parameters for current case
    a0_t = cases(k,1);
    a0_r = cases(k,2);
    c_t  = cases(k,3);
    c_r  = cases(k,4);
    aero_t = cases(k,5);
    aero_r = cases(k,6);
    geo_t  = deg2rad(cases(k,7));
    geo_r  = deg2rad(cases(k,8));
    
    % Run PLLT
    [e_check(k), CL_check(k), CDi_check(k)] = ...
        PLLT(b,a0_t,a0_r,c_t,c_r,aero_t,aero_r,geo_t,geo_r,N_test);
end

% Store + display
results_check.CL  = CL_check;
results_check.CDi = CDi_check;
results_check.e   = e_check;

disp('--- PLLT Function Check ---');
disp(results_check);


%% -------------------------
%  SECTION 2: ANDERSON FIG 5.20 REPRODUCTION
%  Induced drag factor δ vs taper ratio
% --------------------------

% Analysis parameters
AR_list = [4 6 8 10];          % Aspect ratios
taper   = linspace(0,1,100);   % ct/cr range
N = 50;                        % (matches Anderson)

% Airfoil / angle assumptions (uniform across span)
a0_t = 2*pi;
a0_r = 2*pi;
aero_t = 0;
aero_r = 0;
geo_t  = deg2rad(5);
geo_r  = deg2rad(5);

b = 100; % fixed span

% Preallocate results
delta = zeros(length(taper), length(AR_list));

for i = 1:length(AR_list)
    
    AR = AR_list(i);
    
    for j = 1:length(taper)
        
        lambda = taper(j); % taper ratio
        
        % Enforce desired AR by solving for chord geometry
        c_r = (2*b) / (AR * (1 + lambda));
        c_t = lambda * c_r;
        
        % Run PLLT
        [e, CL, CDi] = PLLT(b,a0_t,a0_r,c_t,c_r,...
                            aero_t,aero_r,geo_t,geo_r,N);
        
        % Induced drag factor (delta)
        delta(j,i) = (1 / e) - 1;
        
    end
end


%% -------------------------
%  SECTION 3: PLOTTING
% --------------------------

figure;
plot(taper, delta, 'LineWidth',1.5);

xlabel('$c_t/c_r$','Interpreter','latex');
ylabel('$\delta$','Interpreter','latex');
title('Induced Drag Factor vs. Taper Ratio');

legend('AR = 4','AR = 6','AR = 8','AR = 10',...
       'Location','best');

ylim([0 0.2]);
grid on;


%% PLLT function

function [e,c_L,c_Di] = PLLT(b,a0_t,a0_r,c_t,c_r,aero_t,aero_r,geo_t,geo_r,N)
%% Variables:
% Outputs:
% e : span efficiency factor (to be computed and returned)
% c_L : coefficient of lift (to be computed and returned)
% c_Di : induced coefficient of drag (to be computed and returned)

% Inputs:
% b: span [ft]
% a0_t : cross-sectional lift slope at tips [/rad]
% a0_r : cross-sectional lift slope at root [/rad]
% c_t : chord at tips [ft]
% c_r : chord at root [ft]
% aero_t : zero-lift angle of attack at tips [deg]
% aero_r : zero-lift angle of attack at root [deg]
% geo_t : geometric angle of attack at tips [deg]
% geo_r : geometric angle of attack at root [deg]
% N : number of odd terms to include in the series expansion for
% circulation

%% Task 1:

e = 0;
% Initialize output variables
c_L = zeros(N, 1);
c_Di = zeros(N, 1);

theta = (1:N)' * pi / (2*N); % spanwise angular coordinate used in lifting-line transformation [rad]
y = -(b/2) .* cos(theta); % spanwise location along wind [ft] from -b/2 to b/2

c_theta = c_r + (abs(y) / (b/2)) * (c_t - c_r); % local chord length distribution along the span [ft]
aero0 = deg2rad(aero_r + (abs(y) / (b/2)) * (aero_t - aero_r)); % local zero-lift AoA distribution [rad]
a0_theta = a0_r + (abs(y) / (b/2)) * (a0_t - a0_r); % local lift curve slope distribution [rad]
aero_geo = deg2rad(geo_r + (abs(y) / (b/2)) * (geo_t-geo_r)); % local geometric AoA distribution [rad]

% Aspect ratio (using trapezoidal wing approximation)
AR = (2*b) / (c_r + c_t);

% Coefficient term in PLLT fundamental equation:
% coeff: term from Prandtl equation relating circulation to geometry
coeff = (4*b) ./ (a0_theta .* c_theta);

% [M]{A}={D}
% M: System matrix for Fourier coefficients
% RHS: effective angle of attack (alpha - alpha_L=0) at each spanwise
% station [rad]

M = zeros(N, N);
RHS = (aero_geo - aero0);

% Fill the M matrix based on the coefficients and spanwise positions
for i = 1:N
    for j = 1:N
        n = 2*j - 1;
        % n: odd Fourier mode index (1,3,5...etc)
        M(i,j) = coeff(i) * sin(n * theta(i)) + (n * sin(n * theta(i))) / sin(theta(i));
        % 1st term: geometric/aerodynamic contribution
        % 2nd term: induced angle contribution from downwash
    end
end

% Solve for Fourier coefficients:
% A Fourier coefficients describing circulation distribution
A = M \ RHS;

% efficiency factor
% n_index: vector of odd integers corresponding to Fourier modes
% denom: denominator of span efficiency expression
% e: span efficiency factor (measure of how close lift distribution is to
% elliptical)
n_index = 2 * (1:N) - 1;
denom = sum(n_index(:) .* (A(:).^2));
e = A(1)^2 / denom;

% CL and CDi calculations:
% c_L: total lift coefficient (depends only on first Fourier coefficient)
% C_Di: induced drag coefficient
c_L = pi * AR * A(1);
c_Di = c_L^2 / (pi * AR * e);

end