%Computer Integrated Surgery, EN.600.445
%Alperen Degirmenci, Saumya Gurbani

function f = frame3D(rot, trans)
%defines a frame transformation with the given rotation and translation
%components. the rotation parameter is a 3x3 matrix and the translation
%parameter is a 3x1 column vector;


    %if no parameters given, return an "identity" frame transformation
    if nargin == 0
        f.R = eye(3);
        f.p = zeros(3,1);
        
    %if only 1 parameter, determine if its a rotation or translation
    %and make the other one the default value
    elseif nargin == 1
        
        if(size(rot) == [3 3]) %3x3 matrix
            f.R = rot;
            f.p = zeros(3,1);
        else
            f.R = eye(3);
            f.p = rot;
        end
     
    %both are given, we're happy and go get a beer.
    else
        f.R = rot;
        f.p = trans;
    end
    
    %we can make it into a convenient 4x4 matrix for use with quaternions
    %f.quad = [f.R, f.p; zeros(1,3), 1];
    f.quad = [1, zeros(1,3); f.p, f.R];
end