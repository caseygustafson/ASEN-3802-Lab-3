function [e,c_L,c_Di] = PLLT(b,a0_t,a0_r,c_t,c_r,aero_t,aero_r,geo_t,geo_r,N, AR)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here



% Pre-allocate theta
theta = zeros(N);
for i=1:N
    theta(i) = i * pi / (2*N);
end

% make variables functions of distance along span, y
y = -b/2 * cos(theta);
a0 = a0_r + (a0_t-a0_r).*(y./(b/2));
c = c_r + (c_t-c_r).*(y./(b/2));
aero = aero_r + (aero_t-aero_r).*(y./(b/2));
geo = geo_r + (geo_t-geo_r).*(y./(b/2));

aero = deg2rad(aero);
geo = deg2rad(geo);

An = zeros(N,N);
geo_aero = zeros(N,1);

for i=1:N
    
    for j=1:N
        n = j*2-1;
        An(i,j) = ((4*b)/(a0(i)*c(i)))*sin(n*theta(i)) + n*((sin(n*theta(i)))/(sin(theta(i))));
        
    end
    geo_aero(i) = geo(i) - aero(i);

end


x = An/geo_aero;

% cl calculation
c_L = pi * AR * x(1);

%zeta calculation
zeta=0
for i=2:N
    n = i*2-1;
    zeta = zeta + n*(x(i)/x(1))^2;

end

c_Di = (c_L^2/(pi*AR))*(1+zeta);

%e calculation

e = (1+zeta)^(-1);

end

