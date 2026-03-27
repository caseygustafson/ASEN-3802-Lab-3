function [x_b,y_b] = NACA_Airfoils(m,p,t,c,N)
% _b is a vector containing the x-location of the boundary points, y_b is a vector containing the
%y-location of the boundary points, m is the maximum camber, p is the location of maximum camber, t is
% the thickness, c is the chord length, and N is the number of employed panels.


% EXAMPLE INPUT NACA 2415
m= 2/100;
p = 4/10;
t = 0.15;
c = 3;
N=500;
%----------------------------
x = linspace(0,c,N);
pc= p*c;

y_t = t/0.2*c * (0.2969.*sqrt(x./c) - 0.1260.*(x./c).^2 + 0.2843*(x./c).^3- 0.1036.*(x./c).^4); %Thickness distribution (vector)
[~, pc_idx] = min(abs(x - pc)); % finds the index of closest value to pc in the x vector

% first part of piecewise function
for i=1:pc_idx
y_c(i) = m*x(i)/p^2.*(2*p-x(i)/c); % From 0 < x < p*c
end

% second part of peicewise function
for i = pc_idx:length(x)
y_c(i) = m*((c-x(i))/(1-p)^2) * (1+x(i)/c-2*p); % from pc < x < c
end

% Zeta function for upper and lower
zeta_U = @(x) atan(m/p^2 * (2*(p-x/c)));
zeta_L = @(x) atan(m/(1-p)^2 * (p-(x/c)));

% Compute upper and lower points
x_U = x - y_t.* sin(zeta_U(x));
x_L = x + y_t.* sin(zeta_L(x));

y_U = y_c + y_t.*cos(zeta_U(x));
y_L = y_c - y_t.*cos(zeta_L(x));

%% TEST PLOT

figure;
plot(x_U,y_U);
hold on
plot(x_L,y_L);





