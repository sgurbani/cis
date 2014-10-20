%Computer Integrated Surgery, EN.600.445
%Alperen Degirmenci, Saumya Gurbani

%Copyright 2010 Johns Hopkins University.

function f = inverseFrame3D(frame)
%computes the inverse transformation of the frame transformation
%frame is of the form F = (R, p)
%inverse will be Finv = (Rinv, -Rinv*p)

Rinv = inv(frame.R);
f = frame3D(Rinv, -1 * Rinv * frame.p);

end