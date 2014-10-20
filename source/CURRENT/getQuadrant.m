% Computer Integrated Surgery, EN.600.445
% Alperen Degirmenci, Saumya Gurbani

function i = getQuadrant(point, center)
%determine which 3D quadrant point is located in, given that the "origin"
%of the 3D space is given by center. Both are point3Ds or vectors

    if(class(point) == 'struct') %point is a point3D
        point = point.vec;
    end
    if(class(center) == 'struct')
        center = center.vec;
    end
    
    dist = point - center;

    %truth table
    x = dist(1);
    y = dist(2);
    z = dist(3);

    i = 4*(x>=0)+2*(y>=0)+(z>=0)+1;
end