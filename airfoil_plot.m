function [] = airfoil_plot(toggle,x_b,y_b,plot_name)
% This function is a general function to plot the airfoil shape, if run is
% 1
%   Detailed explanation goes here

if toggle == 1
    figure();
    plot(x_b,y_b);
    title(plot_name)
    xlabel('m');
    ylabel('m');
else
end
