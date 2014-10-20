%Computer Integrated Surgery, EN.600.445
%Alperen Degirmenci, Saumya Gurbani

%Copyright 2010 Johns Hopkins University.
function sortedTriangles = sortTrianglesByDistance(triangles, origin)

if(nargin == 1)
    origin = point3D(0,0,0);
end

% sortedTriangles(length(unsortedTriangles)) = triangle3D;

%Insertion Sort
% unsortedTriangles = triangles;
% for i=2:length(unsortedTriangles)
% %     disp(i);
%     curTriangle = unsortedTriangles(i);
%     dist = norm(curTriangle.center - origin.vec,2);
%     done = false;
%     j = i - 1;
%     
%     while(~done)
%         tempTriangle = unsortedTriangles(j);
%         nextDist = norm(tempTriangle.center - origin.vec, 2);
%         if(nextDist > dist)
%             unsortedTriangles(j+1) = unsortedTriangles(j);
%             j = j-1;
%             if(j < 1)
%                 done = true;
%             end
%         else
%             done = true;
%         end
%     end
%     
%     unsortedTriangles(j+1) = curTriangle;
% end
% 
% sortedTriangles = unsortedTriangles;

%Merge Sort

n = length(triangles);

if n < 2
    sortedTriangles = triangles;
else
    %split array of triangles in half, then call sort function on each half
    m = floor(n/2);
%     disp('m:');
%     disp(m);
    y1 = sortTrianglesByDistance(triangles(1:m), origin);
    y2 = sortTrianglesByDistance(triangles(m+1:n), origin);

    %merge y1 and y2 together
    len1 = size(y1,2);
    len2 = size(y2,2);

%     disp('y1 and y2 lengths:');
%     disp([len1, len2]);

    %preallocate sortedTriangles
    sortedTriangles(len1+len2) = triangle3D;

    %indices for each array
    ind1 = 1;
    ind2 = 1;

    %merge
    for i=1:(len1+len2)
%         disp(ind1);    disp(ind2);
    %     disp(y1(ind1));

        if ind1 > len1  %no more values in y1
            sortedTriangles(i) = y2(ind2);
            ind2 = ind2+1;
        elseif ind2 > len2  %no more values in y2
            sortedTriangles(i) = y1(ind1);
            ind1 = ind1+1;
        elseif norm(y1(ind1).center-origin.vec,2) ...
                <= norm(y2(ind2).center-origin.vec,2)
            %if the dist to triangle in y1 <= triangle in y2, add the one in y1
            sortedTriangles(i) = y1(ind1);
            ind1 = ind1+1;
        else
            %add the triangle from y2
            sortedTriangles(i) = y2(ind2);
            ind2 = ind2+1;
        end
    end
end


end
