% Computer Integrated Surgery, EN.600.445
% Alperen Degirmenci, Saumya Gurbani

classdef Octree
%Defines an Octree class, which stores triangles by separating them
%into the 8 3D-space quadrants they fall in to. The "origin" of the
%quadrants can be defined by passing the 'center' parameter upon
%construction. If no center parameter is passed, the standard origin
%(0,0,0) is assumed.

%no properties should be editable outside of this class
properties (SetAccess=private)
    center = point3D(0,0,0);
    quadrants = cell(8);
%     allTriangles = [];
    numTriangles = 0;
end

%numTriangles should be dynamically calculated every time
% properties(Dependent=true, SetAccess=private)
%     numTriangles;
% end

methods
    %constructor
    function oct = Octree(center)
        if nargin > 0
            if(class(center) == 'struct') %center is a point3D
                oct.center = center;
            else %center is a vector
                oct.center = point3D(center);
            end
        end
    end

    %add a triangle to octree
    function oct = addTriangle(oct, triangle)
        %a triangle may be added to multiple quadrants, depending
        %on its vertex locations. Each vertex will be in exactly 1
        %quadrant, so each triangle will be in 1,2, or 3 quadrants.

        %So, let's find which quadrant each vertex is in
        triQuads(1) = getQuadrant(triangle.v1_vec, oct.center);
        triQuads(2) = getQuadrant(triangle.v2_vec, oct.center);
        triQuads(3) = getQuadrant(triangle.v3_vec, oct.center);

        %take only unique quadrants
        triQuads = unique(triQuads);

        %add to every quadrant in triQuads
        for i = 1:length(triQuads)
            oct.quadrants{triQuads(i)} = [oct.quadrants{triQuads(i)}; triangle];
        end

        %add triangle to allTriangles
%         oct.allTriangles = [oct.allTriangles; triangle];
        %increment numTriangles
        oct.numTriangles = oct.numTriangles + 1;
    end
    
    %return how many triangles are in the Octree
%     function numTri = get.numTriangles(oct)
%         numTri = length(oct.allTriangles);
%     end
end

end