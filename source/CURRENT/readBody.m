%Computer Integrated Surgery, EN.600.445
%Alperen Degirmenci, Saumya Gurbani

%Copyright 2010 Johns Hopkins University.

function [markers tip] = readBody(filename)
%Reads the -BodyY.txt file and return two values
%markers - an array of point3Ds of the LE markers
%tip - a point3D of the body's tip
    
    %open file, get number vertices
    fid = fopen(filename);
    line = fgetl(fid);
    [num_markers, line] = strtok(line, ', ');
    num_markers = str2num(num_markers);
    
    %read in LED coordinates
    for i = 1:1:num_markers
        line = fgetl(fid);
        [x, line] = strtok(line, ', ');
        [y, line] = strtok(line, ', ');
        z = strtok(line, ', ');
        markers(i) = point3D(str2double(x), str2double(y), str2double(z));
    end
    
    %next line will contain tip coordinates
    line = fgetl(fid);
    [x, line] = strtok(line, ', ');
    [y, line] = strtok(line, ', ');
    z = strtok(line, ', ');
    tip = point3D(str2double(x), str2double(y), str2double(z));
    
    %close file
    fclose(fid);

end