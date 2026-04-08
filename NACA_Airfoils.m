function [x_b,y_b,x_c,y_c] = NACA_Airfoils(m,p,t,c,N, x, order)
% _b is a vector containing the x-location of the boundary points, y_b is a vector containing the
%y-location of the boundary points, m is the maximum camber, p is the location of maximum camber, t is
% the thickness, c is the chord length, and N is the number of employed panels.

%----------------------------
pc= p*c;
y_c = zeros(size(x));
zeta = zeros(size(x));

y_t = ((t/0.2)*c)*(0.2969*sqrt(x/c) - 0.1260*(x/c) - 0.3516*((x/c).^2) + 0.2843*((x/c).^3) - 0.1036*((x/c).^4)); %Thickness distribution (vector)

y_c1 = @(x) (m/(p^2)) * (x) .* (2*p - x/c); 

zeta_c1 = @(x) atan((m/(p^2)) * (2*(p - x/c)));

for(i=1:length(x))
    if(x(i) <= pc && p ~= 0)
        y_c(i) = y_c1(x(i));
        zeta(i) = zeta_c1(x(i));
    end
end

y_c2 = @(x) (m/((1-p)^2)) * (c - x) .* (1 + x/c - 2*p); 

zeta_c2 = @(x) atan((m/((1-p)^2)) * (p - x/c));

for(i=1:length(x))
    if(x(i) > pc && p ~= 0)
        y_c(i) = y_c2(x(i));
        zeta(i) = zeta_c2(x(i));
    end
end

x_U = x - y_t.*sin(zeta);
x_L = x + y_t.*sin(zeta);

y_U = y_c + y_t.*cos(zeta);
y_L = y_c - y_t.*cos(zeta);

if(order == 1)
    x_b = [x_U, flip(x_L)];
    y_b = [y_U, flip(y_L)];
else
    x_b = [flip(x_U), x_L];
    y_b = [flip(y_U), y_L];
end

x_c = x;
end