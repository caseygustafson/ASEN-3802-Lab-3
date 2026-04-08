function [cl] = Vortex_Panel(XB,YB,Vinf,alpha)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input:                           %
% XB    = Boundary Points x-location
% YB    = Boundary Points y-location
% Vinf  = Free-stream velocity
% alpha = Angle of attack in degrees
%
% Output:
% cl    = Sectional Lift Coefficient
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

alpha = alpha*pi/180;   % convert to radians
chord = max(XB)-min(XB);

M = length(XB)-1;       % number of panels
MP1 = M+1;

% -------------------- Panel Geometry --------------------
X = zeros(1,M);
Y = zeros(1,M);
S = zeros(1,M);
theta = zeros(1,M);
sine = zeros(1,M);
cosine = zeros(1,M);
RHS = zeros(1,M);

for i = 1:M
    ip1 = i+1;
    X(i) = 0.5*(XB(i)+XB(ip1));
    Y(i) = 0.5*(YB(i)+YB(ip1));
    S(i) = sqrt((XB(ip1)-XB(i))^2 + (YB(ip1)-YB(i))^2);
    theta(i) = atan2(YB(ip1)-YB(i), XB(ip1)-XB(i));
    sine(i) = sin(theta(i));
    cosine(i) = cos(theta(i));
    RHS(i) = sin(theta(i)-alpha);
end

% -------------------- Influence Coefficients --------------------
CN1 = zeros(M,M); CN2 = zeros(M,M);
CT1 = zeros(M,M); CT2 = zeros(M,M);

for i = 1:M
    for j = 1:M
        if i == j
            CN1(i,j) = -1; CN2(i,j) = 1;
            CT1(i,j) = 0.5*pi; CT2(i,j) = 0.5*pi;
        else
            A = -(X(i)-XB(j))*cosine(j) - (Y(i)-YB(j))*sine(j);
            B = (X(i)-XB(j))^2 + (Y(i)-YB(j))^2;
            C = sin(theta(i)-theta(j));
            D = cos(theta(i)-theta(j));
            E = (X(i)-XB(j))*sine(j) - (Y(i)-YB(j))*cosine(j);
            F = log(1 + S(j)*(S(j)+2*A)/B);
            G = atan2(E*S(j), B+A*S(j));
            P = (X(i)-XB(j))*sin(theta(i)-2*theta(j)) + (Y(i)-YB(j))*cos(theta(i)-2*theta(j));
            Q = (X(i)-XB(j))*cos(theta(i)-2*theta(j)) - (Y(i)-YB(j))*sin(theta(i)-2*theta(j));
            CN2(i,j) = D + 0.5*Q*F/S(j) - (A*C+D*E)*G/S(j);
            CN1(i,j) = 0.5*D*F + C*G - CN2(i,j);
            CT2(i,j) = C + 0.5*P*F/S(j) + (A*D-C*E)*G/S(j);
            CT1(i,j) = 0.5*C*F - D*G - CT2(i,j);
        end
    end
end

AN = zeros(MP1,MP1); AT = zeros(M,MP1);

for i = 1:M
    AN(i,1) = CN1(i,1);
    AN(i,MP1) = CN2(i,M);
    AT(i,1) = CT1(i,1);
    AT(i,MP1) = CT2(i,M);
    for j = 2:M
        AN(i,j) = CN1(i,j)+CN2(i,j-1);
        AT(i,j) = CT1(i,j)+CT2(i,j-1);
    end
end

AN(MP1,1) = 1; AN(MP1,MP1) = 1;
AN(MP1,2:M) = 0;
RHS(MP1) = 0;

% -------------------- Solve for circulation --------------------
GAMA = AN\RHS';

% -------------------- Tangential velocity & CP --------------------
V = zeros(1,M);
CP = zeros(1,M);
for i = 1:M
    V(i) = cos(theta(i)-alpha);
    for j = 1:MP1
        V(i) = V(i) + AT(i,j)*GAMA(j);
    end
    CP(i) = 1 - V(i)^2;
end

% -------------------- Sectional Lift Coefficient --------------------
cl = 2*sum(S.*V)/chord;

end