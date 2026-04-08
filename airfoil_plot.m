function [] = airfoil_plot(x,y,plot_name, c, x_c, y_c)
% This function is a general function to plot the airfoil shape, if run is
% 1
%   Detailed explanation goes here

figure();
hold on;

ylim([-c/2, c/2]);
plot(x,y,'b','LineWidth',1.5);
scatter(x,y,15,'filled');

if ~isempty(x_c)
    plot(x_c,y_c,'r--','LineWidth',1.5);
end

title("Airfoil: NACA " + plot_name)
xlabel('m');
ylabel('m');
axis equal;

hold off;

end