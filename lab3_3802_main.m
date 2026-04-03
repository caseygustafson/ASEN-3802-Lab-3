%Name: 3802-Lab3 Main
%Authors: Harroop Sooch,
%Date: 3/27/2026

clear;
clc;
close all;

%--------------------------------------------------------------------
%toggles
gen_plots = 1;

p1_task1 = 1;
p1_task2 = 1;
%--------------------------------------------------------------------


if(p1_task1)
    %get data from airfoil name
    airfoil = '2421';
    
    m = str2num(airfoil(1))/100;
    p = str2num(airfoil(2))/10;
    t = str2num(airfoil(3:4))/100;
    
    %get x coordinates based on circle method
        
    c = 1;
    N = 50;
    r = c/2;
    x = zeros(1,10);
    dtheta = 180/(N-1);
    angle = 180;
    for i=1:N
    
    x(i) = r*cosd(angle) + r;
    
    angle = angle - dtheta;
    end
    
    %generate the airfoil
    %pass 1 for clockwise 2 for counterclockwise
    [x_a, y_a] = NACA_Airfoils(m, p, t, c, N, x, 2);

    if(gen_plots)
        airfoil_plot(x_a, y_a, airfoil, c);
    end
end

if(p1_task2)


end