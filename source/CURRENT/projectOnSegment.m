% Computer Integrated Surgery, EN.600.445
% Alperen Degirmenci, Saumya Gurbani

function c_ = projectOnSegment(c,p,q)
%Projects the point c onto the segment formed by points
%p and q. Returns the projected point, c_.

lambda = dot((c-p), (q-p)) / dot((q-p),(q-p));

lambda_ = max(0,min(lambda,1));

c_ = p + lambda_ * (q-p);

end

