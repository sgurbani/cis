%Computer Integrated Surgery, EN.600.445
%Alperen Degirmenci, Saumya Gurbani

%Copyright 2010 Johns Hopkins University.

function correctionF = getDifference(EMreadings, expectedEM)

%EMreadings: EM readings (multiple frames).
%expectedEM: Expected EM values, calculated using getTranformation.m
%frames: number of frames in EMreadings and expectedEM
%correctionF: Distortion correction function.
%Given a distorted EM marker value, we can compute the corresponding
%accurate EM marker position relative to the EM tracker.

%check - lengths of a and be must be the same
if(length(EMreadings) ~= length(expectedEM))
    disp('ERROR - same number of points in each cloud required');
    return;
end

%get the difference between each point
diff = cell(1,3);
for i = 1:length(expectedEM)
    diff{1}(i) = EMreadings(i).x - expectedEM(i).x;
    diff{2}(i) = EMreadings(i).y - expectedEM(i).y;
    diff{3}(i) = EMreadings(i).z - expectedEM(i).z;
end

%fit a 5th degree Bernstein Polynomial

%set alpha to be the error bound of difference
% alpha = 0.001;  %0.1 percent

%Bernstein polynomial degree set to 5
n = 5;

%-------------------------
% %normalize so that all values are [0,1];
% max_val = max(diff_error);
% diff_error = diff_error ./ max_val;
%-------------------------

%use a 5th-degree Bernstein polynomial
%bern(x) = binom_coeff(n,v)*x^v*(1-x)^(n-v) for v=0:n
binom_coeff = zeros(1, n+1);
for v=0:1:n
    binom_coeff(v+1) = gamma(n+1) / gamma(v+1) / gamma(n-v+1);
end

C = cell(1,3); %Cx, Cy, and Cz are stored in this cell
for i = 1:length(expectedEM)
    for j = 1:n+1
        C{1}(i, j) = binom_coeff(j) * (diff{1}(i))^(j-1) * (1 - diff{1}(i))^(n-j+1);
        C{2}(i, j) = binom_coeff(j) * (diff{2}(i))^(j-1) * (1 - diff{2}(i))^(n-j+1);
        C{3}(i, j) = binom_coeff(j) * (diff{3}(i))^(j-1) * (1 - diff{3}(i))^(n-j+1);
    end
end

a = cell(1,3);

a{1} = pinv(C{1})*diff{1}';
a{2} = pinv(C{2})*diff{2}';
a{3} = pinv(C{3})*diff{3}';

%-------------------------
% %multiply by max value to unnormalize
% diff_error = diff_error .* max_val;
%-------------------------

% %check if every value in difference is less than alpha
% %if so, break out of this loop
% if(sum(abs(diff_error)<alpha) == length(diff_error))
%    break;
% end

correctionF = cell(1,3);
correctionF{1} = C{1}*a{1};
correctionF{2} = C{2}*a{2};
correctionF{3} = C{3}*a{3};

end