%Computer Integrated Surgery, EN.600.445
%Alperen Degirmenci, Saumya Gurbani

%Copyright 2010 Johns Hopkins University.

function F = getTransformation(a, b)
%a is a vector of struct point3D
%b is a vector of struct point3D
%calculate the transformation F such that b = F*a

%Debug mode: enables/disables some disp() commands for debugging
%enabled(true) or disabled(false)
debug = false;

%check - lengths of a and be must be the same
if(length(a) ~= length(b))
    disp('ERROR - same number of points in each cloud required');
    return;
end

%step 1 - calculate mean point of each point cloud
sum_a = zeros(3,1);
sum_b = zeros(3,1);
for i=1:1:length(a)
    sum_a = sum_a + a(i).vec;
    sum_b = sum_b + b(i).vec;
end

mean_a = sum_a / length(a);
mean_b = sum_b / length(b);

%step 2 - compute H
H = zeros(3); %H will be a 3x3 matrix

for i=1:1:length(a)
    ai = a(i);
    bi = b(i);
    
    ai.x = ai.x - mean_a(1);
    ai.y = ai.y - mean_a(2);
    ai.z = ai.z - mean_a(3);
    
    bi.x = bi.x - mean_b(1);
    bi.y = bi.y - mean_b(2);
    bi.z = bi.z - mean_b(3);
    
    dH = [ai.x*bi.x ai.x*bi.y ai.x*bi.z
          ai.y*bi.x ai.y*bi.y ai.y*bi.z
          ai.z*bi.x ai.z*bi.y ai.z*bi.z];
    
    H = H + dH;
end

if(debug)
    disp('H')
    disp(H)
end

% step 3 - compute G
delta = [H(2,3) - H(3,2)
         H(3,1) - H(1,3)
         H(1,2) - H(2,1)];
     
 G = [trace(H), delta'
      delta, H+H' - trace(H)*eye(3)];
  
  if(debug)
       disp('G')
       disp(G)
  end

%step 4 - eigenvalue decomposition of G
[V, D] = eig(G);
%D contains the eigenvalues (as a diagonal matrix)
%V contains the correspondng eigenvectors
%we need to find the largest eigenvalue
%to produce a col vector with the eigenvalues, sum over each row

eigvals = sum(D, 2);
[largest index] = max(eigvals);

if(debug)
    disp('eigenvalues:')
    disp(eigvals)
    disp('largest eigenvalue:')
    disp(largest)
    disp('index of the lareges eigenvalue:')
    disp(index)
end

%we want the "index" column of the eigenvector matrix
Qk = (V(:,index))'; %quaternion corresponding to the rotation

%step 5 - convert quaternion into rotation matrix
%from %http://ieeexplore.ieee.org/stamp/stamp.jsp?arnumber=05542910
w = Qk(1);
x = Qk(2);
y = Qk(3);
z = Qk(4);

R = [1-2*(y^2+z^2) , 2*(x*y-w*z) , 2*(x*z+w*y)
     2*(x*y+w*z) , 1-2*(x^2+z^2) , 2*(y*z-w*x)
     2*(x*z-w*y) , 2*(y*z+w*x) , 1-2*(x^2+y^2)];

%step 6 - calculate the translation component
%we know that R*a + p = b, so p = b - R*a
p = mean_b - R * mean_a;

if(debug)
    disp('det(R):')
    disp(det(R))
end

%step 7 - place into a frame transformation
F = frame3D(R, p);
end