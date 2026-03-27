function [x_b,y_b] = NACA_Airfoils(m,p,t,c,N)
% _b is a vector containing the x-location of the boundary points, y_b is a vector containing the
%y-location of the boundary points, m is the maximum camber, p is the location of maximum camber, t is
% the thickness, c is the chord length, and N is the number of employed panels.

y_t = t/0.2;
