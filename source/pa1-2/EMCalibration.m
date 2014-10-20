%Computer Integrated Surgery, EN.600.445
%Alperen Degirmenci, Saumya Gurbani

%Copyright 2010 Johns Hopkins University.

function P_dimple = EMCalibration(G, frames)

%perform a pivot calibration for the EM probe and determine the
%position of the dimple in the calibration post relative to the 
%EM tracker base coordinate system
%P_dimple is a point3D

%step 1 - use the first frame to define a local probe coordinate
num_readings = length(G) / frames;

%1a - find the midpoint of observed points in first frame
G1 = G(1:num_readings); %first frame
sum_g = zeros(3,1);
for i=1:1:length(G1)
    sum_g = sum_g + G1(i).vec;
end
Go = sum_g / length(G1);

%translate observations relative to Go
for i=1:1:length(G1)
    g1(i) = point3D(G1(i).x - Go(1), G1(i).y - Go(2), G1(i).z - Go(3));    
end

%step 2 - for each frame k, compute FG(k) such that G = FG(k)*g
for k=1:frames %go through each frame
    Gk = G(num_readings*(k-1)+1:num_readings*k);
    FG(k) = getTransformation(g1, Gk);
end

%Lorsakul, Auranuch et al
%step 3 - P_dimple = FG[k]*t_g can be written as 
%P_dimple = R_G[k]*t_g + p_G[k]
%rearrange: R_G[k]*t_g - P_dimple = -p_G[k]
%setting up the least square problem, we get:
% [  :    |  : ] [   t_g    ]   [   :    ]
% [R_G[k] | -I ]*[ P_dimple ] = [-p_G[k] ]
% [  :    |  : ]                [   :    ]
%This can be represented as A`*b`=p`
%Thus b` = inv(A`'*A`)*A`'*p`
%Furthermore b` = pinv(A`)*p` (where pinv() is pseudoinverse)
for k = 1:frames
   a = [FG(k).R, -eye(3)];
   A((k-1)*size(a,1)+1:k*size(a,1),1:size(a,2)) = a;
   p = -FG(k).p;
   P((k-1)*length(p)+1:k*length(p),1) = p;
end
B = pinv(A)*P;
%t_g = B(1:3,1);
P_dimple = point3D(B(4,1), B(5,1), B(6,1));

end