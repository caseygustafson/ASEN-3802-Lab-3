%Name: 3802-Lab3 Main
%Authors: Harroop Sooch,
%Date: 3/27/2026

clear;
clc;
close all;

%--------------------------------------------------------------------
%toggles
p1_task1 = 0;

% airfoil number input
airfoil = '4415';

m = str2num(airfoil(1))/100;
p = str2num(airfoil(2))/10;
t = str2num(airfoil(3:4))/100;


c = 1;
N = 10;
r = c/2;
x = zeros(1,10);
dtheta = 180/(N-1);
angle = 180;
for i=1:N

x(i) = r*cosd(angle) + r;

angle = angle - dtheta;
end



