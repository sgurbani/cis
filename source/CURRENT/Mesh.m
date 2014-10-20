% Computer Integrated Surgery, EN.600.445
% Alperen Degirmenci, Saumya Gurbani

classdef Mesh
%Defines a mesh class, consisting of a series of triangles, vertices,
%and an internal octree.

    properties
        vertices = point3D(0,0,0);
        triangles = triangle3D(0,0,0,0,0,0);
        origin = point3D(0,0,0);
%         octree = Octree
    end
    
    methods
        
        function this = Mesh(filename, sort)
            if nargin == 1
                sort = true;
            end
            
            disp('loading mesh...');
            disp('reading from file...');
             %open file
            fid = fopen(filename);
            
            %create vertices vector; 1st line contains num Vertices
            num_vertices = str2double(fgetl(fid));
            this.vertices(num_vertices) = point3D(0,0,0);
            
            %add each vertex to the mesh
            for i = 1:1:num_vertices
                line = fgetl(fid);
                [x, line] = strtok(line, ', ');
                [y, line] = strtok(line, ', ');
                z = strtok(line, ', ');
                this.vertices(i) = point3D(str2double(x), str2double(y), str2double(z));
            end
            
            %next line will contain number of triangles
            num_triangles = str2double(fgetl(fid));
            this.triangles(num_triangles) = triangle3D(0,0,0,0,0,0);
            
            for i = 1:1:num_triangles
                line = fgetl(fid);

                %vertex indices of triangle
                [v1, line] = strtok(line, ', ');
                [v2, line] = strtok(line, ', ');
                [v3, line] = strtok(line, ', ');
                
                %for now, ignore the neighbors
                this.triangles(i) = triangle3D(str2double(v1)+1,...
                    str2double(v2)+1, str2double(v3)+1, ...
                    this.vertices(str2double(v1)+1).vec, ...
                    this.vertices(str2double(v2)+1).vec, ...
                    this.vertices(str2double(v3)+1).vec);                
            
            end

            if(sort)
                disp('sorting triangles...');

                %get median of all triangles for origin
                origin3D = point3D(sum([this.triangles.center],2) / length([this.triangles.center]));

                %sort triangles
                this.triangles = sortTrianglesByDistance(this.triangles, origin3D);
            end
            disp('mesh load complete.');
        end
        
%         function t = triangle(mesh, v_one, v_two, v_three)
%             %defines a triangle t with vertices given by the indices v_one, v_two,
%             %and v_three in the vertex array
% 
%             if nargin < 3
%                 disp('ERROR - TRIANGLE NEEDS THREE VERTICES');
%                 return;
%             end
% 
%             %store the indices locally
%             t.v1 = v_one;
%             t.v2 = v_two;
%             t.v3 = v_three;
% 
%             %also store the actual vertex coordinates temporarily for calculations
%             t.v1_vec = mesh.vertices(t.v1).vec;
%             t.v2_vec = mesh.vertices(t.v2).vec;
%             t.v3_vec = mesh.vertices(t.v3).vec;
% 
%             %calculate triangle center
% %             t.center = t.v1_vec.*(t.v2_vec.^2 + t.v3_vec.^2 - t.v1_vec.^2);
%               t.center = 1/3 * (t.v1_vec + t.v2_vec + t.v3_vec);
%               
%             %calculate bounding sphere radius
%             t.radius = max(norm(t.v1_vec-t.center,2), ...
%                 max(norm(t.v2_vec-t.center,2), norm(t.v3_vec-t.center,2)));
%         end
%         
%         function mesh = addTriangle(mesh, v1, v2, v3)
%             t = mesh.triangle(v1, v2, v3);
%             mesh.triangles = [mesh.triangles; t];
%             mesh.octree = mesh.octree.addTriangle(t);
%         end
%         
%         function mesh = addVertex(mesh, p1, p2, p3)
%             mesh.vertices = [mesh.vertices; point3D(p1, p2, p3)];
%         end
        
        %----findClosestPointOnMeshLinear
%         function c = findClosestPointOnMeshLinear(mesh,p)
%             %does a linear search through the 
%             %p is a point3D
%             %c is a point3D
% 
%             bound = Inf;
%             index = NaN;
% 
%             for i = 1:length(mesh.triangles)
%                 t = mesh.triangles(i);
%                 h = closestPointOnTriangle(p.vec, t.v1_vec, t.v2_vec, ...
%                     t.v3_vec);
%                 dist = norm(h - p.vec,2);
%                 if(dist < bound)
%                     c = h;
%                     index = i;
%                     bound = dist;
%                 end
%             end
%             disp('Triangle Number: ')
%             disp(index)
%         end
        %----findClosestPointOnMeshLinear
        
    end %methods
    
end %classdef