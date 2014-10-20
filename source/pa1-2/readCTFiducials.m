
%Computer Integrated Surgery, EN.600.445
%Alperen Degirmenci, Saumya Gurbani

%Copyright 2010 Johns Hopkins University.

function fiducials = readCTFiducials(filename)
%Reads the -ct-fiducials.txt and returns the corresponding point3D structs

fid = fopen(filename);
line1 = fgetl(fid);
num_pts = strtok(line1, ',');

num_Pts = str2num(num_pts);

for i = 1:num_Pts
    line = fgetl(fid);
    [x, line] = strtok(line, ',');
    [y, line] = strtok(line, ',');
    z = strtok(line, ',');
    point = point3D(str2double(x), str2double(y), str2double(z));
    fiducials(i) = point;
end

fclose(fid);

end