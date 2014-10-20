clear
clc

syms cx cy px py qx qy rx ry lambda mu

%cx - px = lambda*(qx - px) + mu*(rx - px)
%cy - py = lambda*(qy - py) + mu*(ry - py)

soln = solve(px - cx + lambda*(qx - px) + mu*(rx - px), ...
    py - cy + lambda*(qy - py) + mu*(ry - py), lambda, mu);

disp('lambda')
pretty(simple(soln.lambda))
disp('mu')
pretty(simple(soln.mu))