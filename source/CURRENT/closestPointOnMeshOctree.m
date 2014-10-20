% Computer Integrated Surgery, EN.600.445
% Alperen Degirmenci, Saumya Gurbani

function closestPoint = closestPointOnMeshOctree(mesh, p)
%This function finds the closest point on the mesh, using an
%Octree method. p is the point we're trying to place on mesh

%initially, set the current Octree to the mesh's Octree,
curOctree = mesh.octree;
triangleLimit = max(length(mesh.triangles) * .1, 3);
trianglesInQuad = mesh.triangles;

while(curOctree.numTriangles > triangleLimit)
%     disp('number of triangles in current octree:');
%     disp(curOctree.numTriangles);
    
%     disp(curOctree.center);
    
    %find which quadrant of Octree the point falls in
    pQuad = getQuadrant(p.vec, curOctree.center.vec);
%     disp('selected quadrant:');
%     disp(pQuad);
    
    
    if(isempty(curOctree.quadrants{pQuad}))
%         disp('NO MORE TRIANGLES');
        break;
    end
    
    %create an octree from that quadrant
    trianglesInQuad = curOctree.quadrants{pQuad};
    
    curOctree = Octree(getCenterOfQuadrant(trianglesInQuad)); %make new Octree

    for i=1:length(trianglesInQuad)
        curOctree = curOctree.addTriangle(trianglesInQuad(i));
    end    
    
end

%now, do a linear search through these triangles for closest point
% closestPoint = closestPointOnMeshLinear(curOctree.allTriangles, p);
% closestPoint = closestPointOnMeshLinearBounding(curOctree.allTriangles, p);
closestPoint = closestPointOnMeshLinearBounding(trianglesInQuad, p);

end