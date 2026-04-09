function [yc,x,XB, YB, aL0] = NACA_Airfoils(digits, N)
   % Convert numeric input to 4-digit string
   if isnumeric(digits)
       digits = num2str(digits, '%04d');
   end
   % Validate input
   if length(digits) ~= 4 || any(~isstrprop(digits, 'digit'))
       error('Input must be a 4-digit NACA code (e.g., 0012, 2412, 4415).');
   end
   % Airfoil parameters
   c = 1;  % chord length
   m = str2double(digits(1)) / 100;   % max camber
   p = str2double(digits(2)) / 10;    % position of max camber
   t = str2double(digits(3:4)) / 100; % thickness
   % Cosine spacing along chord
   beta = linspace(0, pi, N);
   x = 0.5 * c * (1 - cos(beta));   % 0→c
   % Thickness distribution (lab formula)
   yt = 5 * t * c * ( ...
       0.2969 * sqrt(x / c) ...
       - 0.1260 * (x / c) ...
       - 0.3516 * (x / c).^2 ...
       + 0.2843 * (x / c).^3 ...
       - 0.1036 * (x / c).^4 );
   % Mean camber line (yc) and slope (dyc/dx)
   yc = zeros(size(x));
   dyc_dx = zeros(size(x));
   if p ~= 0 && m ~= 0
       % Front portion: 0 ≤ x < p*c
       idx1 = x < p * c;
       xc1 = x(idx1) / c;
       yc(idx1) = (m / p^2) * (2 * p * xc1 - xc1.^2) * c;
       dyc_dx(idx1) = (2 * m / p^2) .* (p - xc1);
       % Rear portion: p*c ≤ x ≤ c
       idx2 = ~idx1;
       xc2 = x(idx2) / c;
       yc(idx2) = (m / (1 - p)^2) * ((1 - 2 * p) + 2 * p * xc2 - xc2.^2) * c;
       dyc_dx(idx2) = (2 * m / (1 - p)^2) .* (p - xc2);
   end
   % Camberline angle
   theta = atan(dyc_dx);
   % Upper and lower surfaces
   xu = x - yt .* sin(theta);
   yu = yc + yt .* cos(theta);
   xl = x + yt .* sin(theta);
   yl = yc - yt .* cos(theta);
   % Combine into single clockwise boundary (TE→LE→TE)
   XB = [fliplr(xl), xu(2:end)];
   YB = [fliplr(yl), yu(2:end)];
   % Calculating zero lift angle of attack by switching variables for x to
   % theta
   if m ~= 0 && p ~= 0
       Nint = 1000;
       theta_int = linspace(0, pi, Nint);
       x_c = 0.5 * (1 - cos(theta_int));
       % Slope of mean camber line
       dzdx = zeros(size(x_c));
       for i = 1:Nint
           if x_c(i) < p
               dzdx(i) = (2*m/p^2)*(p - x_c(i));
           else
               dzdx(i) = (2*m/(1-p)^2)*(p - x_c(i));
           end
       end
      
       % gives zero lift aoa for 2412 and 4412 of -2.07 and -4.15
         integrand = dzdx .* (cos(theta_int) - 1);
       % gives zero lift aoa for 2412 and 4412 of -1.12 and -2.5
       %  integrand = dzdx .* (cos(theta_int - 1));
       aL0 = -(1/pi) * trapz(theta_int, integrand); % radians
       aL0 = aL0 * 180/pi; % convert to degrees
   else
       aL0 = 0;
   end
end
