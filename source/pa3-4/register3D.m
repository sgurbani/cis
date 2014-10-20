%Computer Integrated Surgery, EN.600.445
%Alperen Degirmenci, Saumya Gurbani

%Copyright 2010 Johns Hopkins University.

function b = register3D(a, frames)
%Registers the array of points a to the corresponding points b,
%given a series of frame transformations defined by frames

%a is a vector of structs of type point3D
%frames is a vector of structs of type frame3D

i = 1;
while(i <= length(a))
    pointA = a(i);
    
    for j = length(frames):-1:1
        pointA = transform3D(pointA, frames(j));
    end
    
    b(i) = pointA;
    i = i+1;
end

end