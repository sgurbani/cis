%Computer Integrated Surgery, EN.600.445
%Alperen Degirmenci, Saumya Gurbani

%Copyright 2010 Johns Hopkins University.

%This function performs a linear search with bounding spheres
%and a spherical separation of space (like an octree, but with concentric
%spheres). It will find the point on the mesh triangles which is closest to
%the point p.
function [c triangleIndex] = closestPointOnMeshLinearBounding(p, or, suggestedStartIndex, confidenceLevel)
global mesh;

    if(nargin == 1)
        or = zeros(3,1);
        suggestedStartIndex = 1;
        confidenceLevel = 0;
    end
    
    if(nargin == 2)
        suggestedStartIndex = 1;
        confidenceLevel = 0;
    end
    
    suggestedStartIndex = max(1,suggestedStartIndex-floor(.3*length(mesh.triangles)*sin(confidenceLevel)));
%     suggestedStartIndex = 1;
  
    array = mesh.triangles;
    
    %array is an array of triangle3D
    %p is a point3D
    %c is a point3D

    %initially, we will accept any triangle
    bound = Inf;
    
    %intially, we haven't found any triangle
    triangleIndex = -1;

    %triangles are sorted by their center's distance from origin (0,0,0)
    %we know p's distance from the origin as well.
    %once we start reaching triangles who's distance is >> p's distance
    %then let's break the loop.
    %also, let's ignore triangles at the beginning who's distances are
    %much less than p's
    %....
    %We call this a Lazy Man's Octree (LMO).
    %...
    %yeah, despite tons of hours of work and many a bottle of beer,
    %we couldn't get an Octree to be efficiently implemented in 
    %Matlab due to variable passing-by-value speeds and data structure
    %limitation.
    %The LMO does decrease our running time by an average of 60%. The
    %bounds below were chosen because they maintained 100% accuracy while
    %speeding up running time.
    
    %lower distance bound
%     lower = norm(p.vec, 2) * .7;
    lower = norm(p.vec - or, 2) * .7;

    %upper distance bound
%     upper = norm(p.vec, 2) * 1.3;
    upper = norm(p.vec - or, 2) * 1.3;
   
    for i = suggestedStartIndex:length(array)
        t = array(i);
        
        %check for bounds
%         distFromOrigin = norm(t.center, 2);
        distFromOrigin = norm(t.center - or, 2);

        if(distFromOrigin < lower)
            continue;
        elseif(distFromOrigin > upper)
            break;
        end
        
        %get distance from triangle center to p center
        len = norm(t.center - p.vec,2);
        
        %check if within 'bound' of radius
        if((len - t.radius) < bound)
            h = closestPointOnTriangle(p.vec, t.v1_vec, t.v2_vec, ...
                t.v3_vec);
            dist = norm(h - p.vec,2);
            if(dist < bound)
                c = h;
                triangleIndex = i;
                bound = dist;
            end
        end
    end
end