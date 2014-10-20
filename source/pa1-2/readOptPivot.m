%Computer Integrated Surgery, EN.600.445
%Alperen Degirmenci, Saumya Gurbani

%Copyright 2010 Johns Hopkins University.

function [D H frames] = readOptPivot(filename)

%Reads the optpivot.txt and returns the corresponding D, H point3D structs
%and the number of frames

fid = fopen(filename);
line1 = fgetl(fid);
[num_d, line1] = strtok(line1, ',');
[num_h, line1] = strtok(line1, ',');
num_repeat = strtok(line1, ',');

num_D = str2num(num_d);
num_H = str2num(num_h);
frames = str2num(num_repeat);

for i = 1:frames
    offset = i - 1;
    for k = offset*num_D + 1 : i*num_D
        line = fgetl(fid);
        [x, line] = strtok(line, ',');
        [y, line] = strtok(line, ',');
        z = strtok(line, ',');
        point = point3D(str2double(x), str2double(y), str2double(z));
        D(k) = point;
    end
    
    for k = offset*num_H + 1 : i*num_H
        line = fgetl(fid);
        [x, line] = strtok(line, ',');
        [y, line] = strtok(line, ',');
        z = strtok(line, ',');
        point = point3D(str2double(x), str2double(y), str2double(z));
        H(k) = point;
    end
end

fclose(fid);

end