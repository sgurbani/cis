%Computer Integrated Surgery, EN.600.445
%Alperen Degirmenci, Saumya Gurbani

%Copyright 2010 Johns Hopkins University.
function c = closestPointOnMeshLinear(mesh, p)
    %does a linear search through the
    %array is a mesh of triangles
    %p is a point3D
    %c is a point3D

    array = mesh.triangles;
    bound = Inf;
    for i = 1:size(array,1)
        t = array(i);
        h = closestPointOnTriangle(p.vec, t.v1_vec, t.v2_vec, ...
            t.v3_vec);
        dist = norm(h - p.vec,2);
        if(dist < bound)
            c = h;
            bound = dist;
        end
    end
end