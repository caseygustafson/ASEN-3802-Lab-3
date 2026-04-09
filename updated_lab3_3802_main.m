%% ---------------- User Input ----------------
clear;
clc;
close all;

ALPHA = 12;         % Angle of attack in degrees

%% ---------------- Task 1: Airfoil Plots for 2421 and 0012 ----------------
airfoils = {'2421','0012'};   % List of airfoils to plot
N_plot = 50;                  % Panels for plotting

for k = 1:length(airfoils)
    airfoil = airfoils{k};
    
    % Generate airfoil coordinates
    [YC3, X3, XB3, YB3, aL03] = Airfoil_Generator(str2double(airfoil), N_plot);
    
    % Plot airfoil with panel points
    figure;
    hold on;
    plot(XB3, YB3, 'b', 'LineWidth', 1.5);       % Airfoil surface
    scatter(XB3, YB3, 10, 'filled');             % Panel points
    if any(YC3)  % if camber exists
        plot(X3, YC3, 'r--', 'LineWidth', 2);   % Camber line
    end
    title(['NACA ', airfoil])
    xlabel('x/c')
    ylabel('y/c')
    axis equal
    grid on
    hold off;
end

%% ---------------- Task 2: Convergence Study ----------------
ALPHA = 12;   % Angle of attack

% Step 1: High-resolution panel numbers
N = round(linspace(10, 300,300));   % increase number of panels
CL1 = zeros(size(N));

for i = 1:length(N)
    Ni = N(i);
    [~, ~, XB3, YB3, ~] = Airfoil_Generator(12, Ni);  % NACA 0012
    CL1(i) = Vortex_Panel(XB3, YB3, ALPHA);
end

CL_exact = CL1(end);  % take largest N as "exact"

% Step 2: Find minimum number of panels for 1% error
rel_error = abs(CL1 - CL_exact)/CL_exact;
N_min_idx = find(rel_error <= 0.01, 1, 'first');
N_min_guess = N(N_min_idx);

% Step 3: Refine around that guess
N_refine = N_min_guess-50 : N_min_guess+50;  
N_refine(N_refine < 1) = 1;                 
CL_refine = zeros(size(N_refine));

for i = 1:length(N_refine)
    Ni = N_refine(i);
    [~, ~, XB3, YB3, ~] = Airfoil_Generator(12, Ni);
    CL_refine(i) = Vortex_Panel(XB3, YB3, ALPHA);
end

% Find actual minimum number of panels
rel_error_refine = abs(CL_refine - CL_exact)/CL_exact;
N_min_actual = N_refine(find(rel_error_refine <= 0.01, 1, 'first'));

% Print results
fprintf('Sectional lift coefficient CL for NACA 0012 at alpha = %.1f deg: %.4f\n', ALPHA, CL_exact);
fprintf('Minimum number of panels for 1%% relative error: %d\n', N_min_actual);

% Step 4: Plot convergence
figure;
hold on; grid on;
plot(N, CL1, 'b-', 'LineWidth', 1.5);           
xline(N_min_actual, 'r--', 'LineWidth', 2);     
xlabel('Number of Panels');
ylabel('Sectional Coefficient of Lift CL');
title('NACA 0012 Convergence Study');
legend('CL vs N', sprintf('1%% Error Threshold at N = %d', N_min_actual));
hold off;

saveas(gcf, 'convergenceStudyPanels_highres', 'png');
