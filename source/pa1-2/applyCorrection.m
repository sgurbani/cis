%Computer Integrated Surgery, EN.600.445
%Alperen Degirmenci, Saumya Gurbani

%Copyright 2010 Johns Hopkins University.

function corrected_ = applyCorrection(coeff, boundbox, raw_data)
%This function applies a given distortion function to the point3Ds in
%raw_data
%
%Returns the distortion-corrected point3Ds
%
%Requires three input parameters:
%coeff - a matrix representing the Bernstein coefficients
%boundbox - a vector of point3D representing the bounds for the
%           ScaleToBox algorithm
%raw_data - the vector of point3D representing the distorted data space

% disp('Applying distortion function');
len = length(raw_data);
x=1; y=2; z=3;

%"distorted" / observed values
q = zeros(len, 3);

for i = 1:len
    q(i,x) = raw_data(i).x;
    q(i,y) = raw_data(i).y;
    q(i,z) = raw_data(i).z;
end

%scale to box using boundbox
max_x = boundbox(1).x;
max_y = boundbox(1).y;
max_z = boundbox(1).z;

min_x = boundbox(2).x;
min_y = boundbox(2).y;
min_z = boundbox(2).z;

q(:,x) = (q(:,x)-min_x)./(max_x-min_x);
q(:,y) = (q(:,y)-min_y)./(max_y-min_y);
q(:,z) = (q(:,z)-min_z)./(max_z-min_z);
%end of scale to box

%Bernstein polynomial degree set to rhe cube root of the rows in coeff  -1
n = length(coeff) ^ (1/3) - 1;

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
% F = zeros(len, 3);

for l = 1:len
    for i = 0:n
        for j = 0:n
            for k = 0:n
                colIndex = i*(n+1)^2 + j*(n+1) + k + 1;
                F(l, colIndex) =binom(i+1) * q(l,x)^i * (1-q(l,x))^(n-i)*...
                                binom(j+1) * q(l,y)^j * (1-q(l,y))^(n-j)*...
                                binom(k+1) * q(l,z)^k * (1-q(l,z))^(n-k); 
            end    
        end
    end
end

%apply correction by doing p = F*coeff;
% disp('multiplying F by c');
p = F*coeff;

% disp('making point3Ds');
for l=1:len
   corrected_(l) =  point3D(p(l,x),p(l,y),p(l,z));
end
end