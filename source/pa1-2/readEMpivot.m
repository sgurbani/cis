
%Computer Integrated Surgery, EN.600.445
%Alperen Degirmenci, Saumya Gurbani

%Copyright 2010 Johns Hopkins University.

function [G frames] = readEMpivot(filename)
%Reads the empivot.txt and returns the corresponding G point3D structs
%and the number of frames

fid = fopen(filename);
line1 = fgetl(fid);
[num_g, line1] = strtok(line1, ',');
num_repeat = strtok(line1, ',');

num_G = str2num(num_g);
frames = str2num(num_repeat);

for i = 1:frames
    offset = i - 1;
    for k = offset*num_G + 1 : i*num_G
        line = fgetl(fid);
        [x, line] = strtok(line, ',');
        [y, line] = strtok(line, ',');
        z = strtok(line, ',');
        point = point3D(str2double(x), str2double(y), str2double(z));
        G(k) = point;
    end
end

fclose(fid);

end