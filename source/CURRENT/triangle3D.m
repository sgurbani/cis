%Computer Integrated Surgery, EN.600.445
%Alperen Degirmenci, Saumya Gurbani

%Copyright 2010 Johns Hopkins University.

function t = triangle3D(v1, v2, v3, v1vec, v2vec, v3vec)
    %defines a triangle t with vertices given by the indices v1, v2,
    %and v3 in the vertex array
    
    global mesh;


    if nargin == 0
        t = triangle3D(0,0,0,0,0,0);
        return;
    end
    
    %store the indices locally
    t.v1 = v1;
    t.v2 = v2;
    t.v3 = v3;
    
    %if only indices are given, find the vectors from the mesh
    if nargin == 3
        t.v1_vec = mesh.vertices(v1).vec;
        t.v2_vec = mesh.vertices(v2).vec;
        t.v3_vec = mesh.vertices(v3).vec;
    else
        t.v1_vec = v1vec;
        t.v2_vec = v2vec;
        t.v3_vec = v3vec;
    end
    
    %calculate triangle center
%             t.center = t.v1_vec.*(t.v2_vec.^2 + t.v3_vec.^2 - t.v1_vec.^2);
     t.center = 1/3 * (t.v1_vec + t.v2_vec + t.v3_vec);
%      temp_center = (v1vec + v2vec)/2;
%      v = v3vec - temp_center;
%      u = v1vec - temp_center;
%      if (dot(v, v) <= dot(u, u))
%          t.center = temp_center;
%      else
%          d = cross(cross(u,v),u);
%          gamma = norm(v.^2 - u.^2,2)/dot(2*d, v-u);
%          if(gamma <= 0)
%              lambda = 0;
%          else
%              lambda = gamma;
%          end
%          t.center = temp_center + lambda*d;
%      end
    %calculate bounding sphere radius
    t.radius = max(norm(t.v1_vec-t.center,2), ...
        max(norm(t.v2_vec-t.center,2), norm(t.v3_vec-t.center,2)));
    
end