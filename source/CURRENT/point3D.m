%Computer Integrated Surgery, EN.600.445
%Alperen Degirmenci, Saumya Gurbani

%Copyright 2010 Johns Hopkins University.

function p = point3D(x, y, z)
%defines a point p with 3D coordinates given by x,y,z

    %if no parameters, p will be the origin
    if nargin == 0
        p.x = 0;
        p.y = 0;
        p.z = 0;

    %if 1 parameter, it will be a point on the number line
    %OR, it might be a vector, which we can now convert into
    %a point3D
    elseif nargin == 1
        if(length(x) == 3) %a vector
            p.x = x(1);
            p.y = x(2);
            p.z = x(3);
        else %just a single argument was given, use point on numline
            p.x = x;
            p.y = 0;
            p.z = 0;
        end
    %if 2 parameters, the point will be the real plane
    elseif nargin == 2
        p.x = x;
        p.y = y;
        p.z = 0;
    
    %all three parameters, point in 3D space
    else
        p.x = x;
        p.y = y;
        p.z = z;
    end

    %additionally store a column vector with the coordinates
    p.vec = [p.x; p.y; p.z];
    
    %and store as a quaternion for easy computation
    %p.q = [p.vec; 1];
    p.q = [1; p.vec];
    
end