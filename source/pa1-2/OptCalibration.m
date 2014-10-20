%Computer Integrated Surgery, EN.600.445
%Alperen Degirmenci, Saumya Gurbani

%Copyright 2010 Johns Hopkins University.

function P_dimple = OptCalibration(D, H, d, frames)

%perform a pivot calibration for the opt probe and determine the
%position of the dimple in the calibration post relative to the 
%opt tracker base coordinate system
%d: points in calibration body d: used to find F_D
%P_dimple is a point3D

%step 1 - use the first frame to define a local probe coordinate

H_readings = length(H) / frames;

%transform the optical tracker beacon positions into EM tracker coordinates
dstart = 1;
for i=1:frames
    %calculate the FD transformation
    FD = getTransformation(D(dstart:dstart+length(d)-1), d);
    %transform H to EM tracker coordinate system
    H_em((i-1)*H_readings+1:i*H_readings) = register3D(H((i-1)*H_readings+1:i*H_readings), FD);
    
    dstart = dstart + length(d);
end

%1a - find the midpoint of observed points in first frame
H1 = H_em(1:H_readings); %first frame
sum_h = zeros(3,1);
for i=1:1:length(H1)
    sum_h = sum_h + H1(i).vec;
end
Ho = sum_h / length(H1);

%translate observations relative to Ho
for i=1:1:length(H1)
    h1(i) = point3D(H1(i).x - Ho(1), H1(i).y - Ho(2), H1(i).z - Ho(3));    
end

%step 2 - for each frame k, compute FG(k) such that G = FG(k)*g
for k=1:frames %go through each frame
    Hk = H_em(H_readings*(k-1)+1:H_readings*k);
    FH(k) = getTransformation(h1, Hk);
end

%Lorsakul, Auranuch et al
%step 3 - P_dimple = FH[k]*t_h can be written as 
%P_dimple = R_H[k]*t_h + p_H[k]
%rearrange: R_H[k]*t_h - P_dimple = -p_H[k]
%setting up the least square problem, we get:
% [  :    |  : ] [   t_h    ]   [   M    ]
% [R_H[k] | -I ]*[ P_dimple ] = [-p_H[k] ]
% [  :    |  : ]                [   M    ]
%This can be represented as A`*b`=p`
%Thus b` = inv(A`'*A`)*A`'*p`
%Furthermore b` = pinv(A`)*p` (where pinv() is pseudoinverse)
for k = 1:frames
   a = [FH(k).R, -eye(3)];
   A((k-1)*size(a,1)+1:k*size(a,1),1:size(a,2)) = a;
   p = -FH(k).p;
   P((k-1)*length(p)+1:k*length(p),1) = p;
end
B = pinv(A)*P;
%t_g = B(1:3,1);
P_dimple = point3D(B(4,1), B(5,1), B(6,1));

end