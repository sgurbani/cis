%Computer Integrated Surgery, EN.600.445
%Alperen Degirmenci, Saumya Gurbani

%Copyright 2010 Johns Hopkins University.

function v = rotate3D(point, frameTrans)
%applies the rotation of frameTrans to point.
%requires both parameters to be present
%we assume that "point" is of the point3D struct
%frameTrans is either a 3x3 matrix or of type frame3D

    if nargin < 2
        disp('Two parameters needed, a point and a frame transform');
        return;
    end
    
    if(class(frameTrans) == 'struct') %frameTrans is a frame3D struct
        vec = frameTrans.R * point.vec; 
    else %frameTrans is a 3x3 rotation matrix
        vec = frameTrans * point.vec;
    end
    
    v = point3D(vec(1), vec(2), vec(3));        
end