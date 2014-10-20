%Computer Integrated Surgery, EN.600.445
%Alperen Degirmenci, Saumya Gurbani

%Copyright 2010 Johns Hopkins University.

function [boundbox c] = getCorrection(EMreadings, EMExpected, ndeg)
%This function calculates an ndeg-degree Bernstein polynomial
%to represent the distortion between EMReadings and EMExpected values
%
%Returns three parameters:
%boundbox - a 1x2 array of point3D representing the maximal and minimal
%           values to be used for ScaleToBox in the future
%c - a matrix representing the coefficiants of the ndeg-degree polynomial
%ndeg - the degree of polynomial to use
%
%Two input parameters:
%EMreadings: EM readings (multiple frames). Should be an array of point3D
%EMExpected: Expected EM values, calculated using getTranformation.m

% disp('Calculating distortion function');
%check - lengths of a and be must be the same
if(length(EMreadings) ~= length(EMExpected))
    disp('ERROR - same number of points in each cloud required');
    return;
end

len = length(EMExpected);
x=1; y=2; z=3;

%"known truth" -- expectedEM
p = zeros(len, 3);

%"distorted" / observed values
q = zeros(len, 3);

for i = 1:len
    q(i,x) = EMreadings(i).x;
    q(i,y) = EMreadings(i).y;
    q(i,z) = EMreadings(i).z;
    
    p(i,x) = EMExpected(i).x;
    p(i,y) = EMExpected(i).y;
    p(i,z) = EMExpected(i).z;
end

%scale to box
max_x = max(q(:,x));
max_y = max(q(:,y));
max_z = max(q(:,z));

min_x = min(q(:,x));
min_y = min(q(:,y));
min_z = min(q(:,z));

max_q = point3D(max_x, max_y, max_z);
min_q = point3D(min_x, min_y, min_z);

boundbox = [max_q min_q];

q(:,x) = (q(:,x)-min_x)./(max_x-min_x);
q(:,y) = (q(:,y)-min_y)./(max_y-min_y);
q(:,z) = (q(:,z)-min_z)./(max_z-min_z);
%end of scale to box

%Bernstein polynomial degree set to ndeg
n = ndeg;

%precalculate binomial coefficients - increases speed ~20x
binom = zeros(1,n+1);
for i=0:n
    binom(i+1) = gamma(n+1) / gamma(i+1) / gamma(n-i+1);    
end

%calculate the len-by-(n+1)^3 matrix F which consists of 
%all Bernstein polynomials such that
%F = [F000 F001 ... F555 (for data point 1)
%     F000 F001 ... F555 (for data point 2)
%           ....
%     F000 F001 ... F555] (for data point n)
%
%   where Fijk = Bin(x)*Bjn(y)*Bkn(z)
    
% disp('creating matrix F');
F = zeros(len,(n+1)^3);
for l = 1:len
    for i = 0:n
        for j = 0:n
            for k = 0:n
                colIndex = i*(n+1)^2 + j*(n+1) + k + 1;
                F(l,colIndex) = binom(i+1) * q(l,x)^i * (1-q(l,x))^(n-i)*...
                                binom(j+1) * q(l,y)^j * (1-q(l,y))^(n-j)*...
                                binom(k+1) * q(l,z)^k * (1-q(l,z))^(n-k);
            end    
        end
    end
end

% disp('now doing least squares');
c = pinv(F)*p;
% disp('distortion function found');
end