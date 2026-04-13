function [e,c_L,c_Di] = PLLT(b,a0_t,a0_r,c_t,c_r,aero_t,aero_r,geo_t,geo_r,N)
%

theta = zeros(N,1);
for i = 1:N
    theta(i) = i * pi / (2*N);
end

% spanwise coordinate
y = -(b/2) * cos(theta);

% spanwise distributions
a0 = a0_r + (abs(y)/(b/2)) * (a0_t - a0_r);

c = c_r + (abs(y)/(b/2)) * (c_t - c_r);

aero = deg2rad(aero_r + (abs(y)/(b/2)) * (aero_t - aero_r));

geo_aero = deg2rad(geo_r + (abs(y)/(b/2)) * (geo_t - geo_r));

% System matrix setup
An = zeros(N,N);

AR = (2*b) / (c_r + c_t); % trapezoidal aspect ratio

for i = 1:N
    for j = 1:N
        
        n = 2*j - 1;
        
        An(i,j) = ((4*b)/(a0(i)*c(i))) * sin(n*theta(i)) + n * (sin(n*theta(i)) / sin(theta(i)));
    end
end

% Right-hand side and solve system
RHS = geo_aero - aero;

x = An \ RHS;

% cl calculation
c_L = pi * AR * x(1);

%delta (previously zeta) calculation
delta=0;
for i=2:N
    n = i*2-1;
    delta = delta + n*(x(i)/x(1))^2;

end


c_Di = (c_L^2/(pi*AR))*(1+delta);

%e calculation

e = (1+delta)^(-1);



end