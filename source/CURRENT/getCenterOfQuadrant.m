% Computer Integrated Surgery, EN.600.445
% Alperen Degirmenci, Saumya Gurbani

function c = getCenterOfQuadrant(quad)
%quad is an array of triangles; find the center of all triangles

% sum = zeros(3,1);

xmin = Inf;
xmax = -Inf;
ymin = Inf;
ymax = -Inf;
zmin = Inf;
zmax = -Inf;

for i = 1:length(quad)
%     sum = sum + quad(i).center;
    tri = quad(i).center;
    if(tri(1) > xmax)
        xmax = tri(1);
    elseif(tri(1) < xmin)
        xmin = tri(1);
    end
    
    if(tri(2) > ymax)
        ymax = tri(2);
    elseif(tri(2) < ymin)
        ymin = tri(2);
    end
    
    if(tri(3) > zmax)
        zmax = tri(3);
    elseif(tri(3) < zmin)
        zmin = tri(3);
    end
    
end

c = point3D( (xmax+xmin)/2, (ymax+ymin)/2, (zmax+zmin)/2);
% 
% c = sum / length(quad);
end