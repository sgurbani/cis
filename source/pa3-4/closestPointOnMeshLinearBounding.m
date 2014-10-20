%Computer Integrated Surgery, EN.600.445
%Alperen Degirmenci, Saumya Gurbani

%Copyright 2010 Johns Hopkins University.
function c = closestPointOnMeshLinearBounding(p, array)

global mesh;
if(nargin == 1)
    array = mesh.triangles;
end

    %does a linear search through the
    %array is an array of triangles
    %p is a point3D
    %c is a point3D

    bound = Inf;

%     array = mesh.triangles;
    for i = 1:length(array)
        t = array(i);
        len = norm(t.center - p.vec,2);
        if((len - t.radius) < bound)
            h = closestPointOnTriangle(p.vec, t.v1_vec, t.v2_vec, ...
                t.v3_vec);
            dist = norm(h - p.vec,2);
            if(dist < bound)
                c = h;
                bound = dist;
            end
        end
    end
end