function [] = airfoil_plot(x,y,plot_name, c)
% This function is a general function to plot the airfoil shape, if run is
% 1
%   Detailed explanation goes here

figure();
hold on;

ylim([-c/2, c/2]);
plot(x,y);
title("Airfoil: NACA " + plot_name)
xlabel('m');
ylabel('m');

hold off;

end
