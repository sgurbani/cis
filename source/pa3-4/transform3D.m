%Computer Integrated Surgery, EN.600.445
%Alperen Degirmenci, Saumya Gurbani

%Copyright 2010 Johns Hopkins University.

function v = transform3D(point, frameTrans)
%applies the frame transformation frameTrans to a point.
%requires both parameters to be present
%we assume that "point" is of the point3D struct
%and frameTrans is of the frame3D struct
% the returned variable v is a point3D struct

    if nargin < 2
        disp('Two parameters needed, a point and a frame transform');
        return;
    end
    
    vec = frameTrans.quad * point.q; 
    %v = point3D(vec(1), vec(2), vec(3));
    v = point3D(vec(2), vec(3), vec(4));
end