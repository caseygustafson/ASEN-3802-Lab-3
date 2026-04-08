%% ---------------- User Input ----------------
clear;
clc;
close all;

airfoil = '0021';  % <-- Change to any NACA 4-digit airfoil
alpha = 12;        % Angle of attack in degrees
Vinf = 1;          % Free-stream velocity
c = 1;             % Chord length
epsilon = 1e-6;    % Small offset to avoid singular matrices

%% ---------------- Task 1: Airfoil Plot ----------------
N_plot = 50;       % Panels for plotting

% Equiangular spacing
r = c/2;
x = zeros(1,N_plot);
dtheta = 180/(N_plot-1);
angle = 180;
for i = 1:N_plot
    x(i) = r*cosd(angle) + r;
    angle = angle - dtheta;
end
x(1) = epsilon;
x(end) = c - epsilon;

% Convert airfoil string to numeric parameters
airfoil_char = char(airfoil);
m = str2double(airfoil_char(1))/100;
p = str2double(airfoil_char(2))/10;
t = str2double(airfoil_char(3:4))/100;

% Generate airfoil coordinates
[x_a, y_a, x_c, y_c] = NACA_Airfoils(m, p, t, c, N_plot, x, 2);

% Remove camber line for symmetric airfoils
if p == 0
    x_c = [];
    y_c = [];
end

% Plot airfoil with panel points
figure;
hold on;
plot(x_a, y_a, 'b','LineWidth',1.5);       % Airfoil surface
scatter(x_a, y_a, 10, 'filled');          % Panel points
if ~isempty(x_c)
    plot(x_c, y_c,'r--','LineWidth',2);   % Camber line
end
title(['NACA ', airfoil])
xlabel('x/c')
ylabel('y/c')
axis equal
grid on
hold off;

%% ---------------- Task 2: Convergence Study ----------------

% Exact solution with large number of panels
N_exact = 200; % [can change this to test]
x_exact = zeros(1,N_exact);
dtheta = 180/(N_exact-1);
angle = 180;
for i = 1:N_exact
    x_exact(i) = r*cosd(angle) + r;
    angle = angle - dtheta;
end
x_exact(1) = epsilon;
x_exact(end) = c - epsilon;

[x_b_exact, y_b_exact, ~, ~] = NACA_Airfoils(m, p, t, c, N_exact, x_exact, 2);
cl_exact = Vortex_Panel(x_b_exact, y_b_exact, Vinf, alpha);

% Test different panel numbers
N_values = 10:10:300; % <---- [start:step:end] [change these to test]
cl_values = zeros(size(N_values));
error_values = zeros(size(N_values));

for k = 1:length(N_values)
    N = N_values(k);
    x_temp = zeros(1,N);
    dtheta = 180/(N-1);
    angle = 180;
    for i = 1:N
        x_temp(i) = r*cosd(angle) + r;
        angle = angle - dtheta;
    end
    x_temp(1) = epsilon;
    x_temp(end) = c - epsilon;
    
    [x_b, y_b, ~, ~] = NACA_Airfoils(m, p, t, c, N, x_temp, 2);
    cl_values(k) = Vortex_Panel(x_b, y_b, Vinf, alpha);
    
    % Avoid NaN errors for very small cl_exact
    if abs(cl_exact) > 1e-6
        error_values(k) = abs((cl_values(k) - cl_exact)/cl_exact)*100;
    else
        error_values(k) = abs(cl_values(k) - cl_exact);
    end
end

% Minimum N for <1% relative error (or absolute 1e-3 for near-zero cl)
% Threshold for convergence
if abs(cl_exact) < 1e-3
    % Use absolute error for near-zero lift
    threshold_error = 1e-4;  % try 0.0001
    idx = find(abs(cl_values - cl_exact) < threshold_error, 1, 'first');
else
    % Use 1% relative error
    threshold_error = 1; % percent
    idx = find(abs((cl_values - cl_exact)/cl_exact)*100 < threshold_error, 1, 'first');
end

if isempty(idx)
    N_min = NaN;
    cl_min = NaN;
    fprintf('No panels achieved the desired convergence.\n');
else
    N_min = N_values(idx);
    cl_min = cl_values(idx);
    fprintf('Minimum number of panels for < threshold error = %d\n', N_min);
    fprintf('cl at minimum number of panels = %f\n', cl_min);
end

% Print results
fprintf('Airfoil: NACA %s\n', airfoil);
fprintf('Exact cl (N = %d) = %f\n', N_exact, cl_exact);
if isnan(N_min)
    fprintf('No panels achieved the desired convergence.\n');
else
    fprintf('Minimum number of panels for < threshold error = %d\n', N_min);
    fprintf('cl at minimum number of panels = %f\n', cl_min);
end

% Plot convergence
figure;
plot(N_values, cl_values, 'bo-','LineWidth',1.5)   % cl vs N
hold on
grid on
if ~isnan(N_min)
    plot([N_min N_min], [min(cl_values) max(cl_values)], 'r--', 'LineWidth',2)
end
plot([min(N_values) max(N_values)], [cl_exact cl_exact], 'k--', 'LineWidth',1.5)
xlabel('Number of Panels, N')
ylabel('Sectional Lift Coefficient, c_l')
title(['Convergence of c_l for NACA ', airfoil])
legend('c_l','Minimum N (< threshold)','Exact c_l','Location','best')
hold off;