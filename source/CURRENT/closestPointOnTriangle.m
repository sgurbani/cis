% Computer Integrated Surgery, EN.600.445
% Alperen Degirmenci, Saumya Gurbani

function c_ = closestPointOnTriangle(a_, p_, q_, r_)
%all four parameters are point3Ds

% tic;

if(isstruct(p_))
    p = p_.vec;
else
    p = p_;
end

if(isstruct(q_))
    q = q_.vec;
else
    q = q_;
end

if(isstruct(r_))
    r = r_.vec;
else
    r = r_;
end

if(isstruct(a_))
    a = a_.vec;
else
    a = a_;
end

%following code has been adapted from an example on gamedev.net
%http://www.gamedev.net/community/forums/topic.asp?topic_id=552906
triangle0 = p;
triangle1 = q;
triangle2 = r;
sourcePos = a;

edge0 = triangle1-triangle0;
edge1 = triangle2-triangle0;
v0 = triangle0 - sourcePos;

a = dot(edge0, edge0);
b = dot(edge0, edge1);
c = dot(edge1, edge1);
d = dot(edge0, v0);
e = dot(edge1, v0);

det = a*c - b*b;
s = b*e - c*d;
t = b*d - a*e;

if( s+t < det)
    if( s < 0)
        if (t<0)
            if(d<0)
                s = max(0, min(1, -d/a));
                t=0;
            else
                s=0;
                t= max(0, min(1, -e/c));
            end
        else
            s=0;
            t = max(0, min(1, -e/c));
        end
    elseif (t < 0)
        s = max(0, min(1, -d/a));
        t = 0;
    else
        invDet = 1 / det;
        s = s * invDet;
        t = t * invDet;
    end
else
    if (s<0)
        tmp0 = b+d;
        tmp1 = c+e;
        
        if(tmp1 > tmp0)
            numer = tmp1 - tmp0;
            denom = a-2*b+c;
            s = max(0, min(1, numer/denom));
            t = 1-s;
        else
            t = max(0, min(1, -e/c));
            s = 0;
        end
    elseif (t < 0)
        if(a+d > b+e)
            numer = c+e-b-d;
            denom = a-2*b+c;
            s = max(0, min(1, numer/denom));
            t = 1-s;
        else
            s = max(0, min(1, -e/c));
            t = 0;
        end
    else
        numer = c+e-b-d;
        denom = a-2*b+c;
        s = max(0, min(1, numer/denom));
        t= 1 -s;
    end
end

c_ = triangle0 + s*edge0 + t*edge1;
        
% disp('closest pt to triangle time:');
% toc;

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% %find c
% %c = proj(a, (q-p)x(r-p)) (cross product)
% %let b = (q-p)x(r-p)
% b = cross(q - p, r - p);
% %http://www.euclideanspace.com/maths/geometry/elements/plane/lineOnPlane/in
% %dex.htm
% %A || B = proj(A,B) = B x (A x B) / |B|^2
% c = cross(b, cross(a,b))/norm(b,2)^2;
% 
% %c-p = lambda(q-p) + mu(r-p)
% %calculate lambda and mu
% cx = c(1); cy = c(2);
% rx = r(1); ry = r(2); rz = r(3);
% qx = q(1); qy = q(2); qz = q(3);
% px = p(1); py = r(2); pz = p(3);
% 
% % mu = ((cx-px)*((qx-qy)-(px-py))-((cx-cy)-(px-py))*(qx-px))/...
% %     (ry*qx-py*qx-px*ry-rx*qy+py*rx+px*qy);
% % lambda = ((cx-cy)-(px-py)-mu*((cx-cy)-(px-py)))/...
% %     ((qx-qy)-(px-py));
% 
% lambda = -(cx * py - cy * px - cx * ry + cy * rx + px * ry - py * rx) / ...
%     (px * qy - py * qx - px * ry + py * rx + qx *ry - qy *rx);
% mu = (cx * py - cy * px - cx * qy + cy * qx + px * qy - py * qx) / ...
%     (px * qy - py * qx - px * ry + py * rx + qx * ry - qy * rx);
%    
% if((lambda >= 0) && (mu >= 0) && ((lambda + mu) <= 1))
%     c_ = c;
% elseif((lambda + mu) > 1)
%     c_ = projectOnSegment(c, q, r);
% elseif(lambda < 0)
%     c_ = projectOnSegment(c, r, p);
% elseif(mu < 0)
%     c_ = projectOnSegment(c, p, q);
% end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


end