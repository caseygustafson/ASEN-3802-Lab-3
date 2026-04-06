%Name: 3802-Lab3 Main
%Authors: Harroop Sooch, Kyan Mathysen-Gerst
%Date: 4/6/2026

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
    x = zeros(1,N);
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

% Part 1
c = 1;
alpha = 12; % degrees
Vinf = 1;
m = 0;
p = 0;
t = 0.12;
N = 100; 

r = c/2;
    x = zeros(1,N);
    dtheta = 180/(N-1);
    angle = 180;

    for i = 1:N
        x(i) = r*cosd(angle) + r;
        angle = angle - dtheta;
    end

[x_b, y_b] = NACA_Airfoils(m,p,t,c,N,x,2);
cl = Vortex_Panel(x_b, y_b, Vinf, alpha);

fprintf('CL for NACA 0012 at alpha = 12 deg: %f\n', cl);


% Part 2
    N_exact = 1000;
    
    x_exact = zeros(1,N_exact);
    dtheta = 180/(N_exact-1);
    angle = 180;

    for i = 1:N_exact
        x_exact(i) = r*cosd(angle) + r;
        angle = angle - dtheta;
    end

    [x_b_exact, y_b_exact] = NACA_Airfoils(m,p,t,c,N_exact,x_exact,2);
    cl_exact = Vortex_Panel(x_b_exact, y_b_exact, Vinf, alpha);

    % different panel numbers
    N_values = 10:10:200;
    cl_values = zeros(size(N_values));
    error_values = zeros(size(N_values));

    for k = 1:length(N_values)

        N = N_values(k);

        x = zeros(1,N);
        dtheta = 180/(N-1);
        angle = 180;

        for i = 1:N
            x(i) = r*cosd(angle) + r;
            angle = angle - dtheta;
        end

        [x_b, y_b] = NACA_Airfoils(m,p,t,c,N,x,2);
        cl_values(k) = Vortex_Panel(x_b, y_b, Vinf, alpha);

        error_values(k) = abs((cl_values(k) - cl_exact)/cl_exact)*100;
    end

    % minimum N with less 1% error
    N_min = 0;
    cl_min = 0;

    for k = 1:length(N_values)
        if error_values(k) < 1
            N_min = N_values(k);
            cl_min = cl_values(k);
            break
        end
    end

    fprintf('Exact cl = %f\n', cl_exact);
    fprintf('Minimum number of panels for less than 1 percent error = %d\n', N_min);
    fprintf('cl at minimum number of panels = %f\n', cl_min);
    
    figure
    plot(N_values, cl_values, 'bo-')
    hold on
    xline(N_min, 'r--')
    yline(cl_exact, 'k--')
    xlabel('Number of Panels, N')
    ylabel('Sectional Lift Coefficient, c_l')
    title('Convergence of c_l with Number of Panels')
    hold off

end
