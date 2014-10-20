%Computer Integrated Surgery, EN.600.445
%Alperen Degirmenci, Saumya Gurbani

%Copyright 2010 Johns Hopkins University.

function [d a c] = readCalBody(filename)

    %Reads the calbody.txt and returns the corresponding d, a, and c sets of
    %point3D structs

    fid = fopen(filename);
    line1 = fgetl(fid);
    [num_d, line1] = strtok(line1, ',');
    [num_a, line1] = strtok(line1, ',');
    num_c = strtok(line1, ',');
    
    num_d = str2num(num_d);
    num_a = str2num(num_a);
    num_c = str2num(num_c);

    %d = zeros(num_d, 1);
    %a = zeros(num_a, 1);
    %c = zeros(num_c, 1);

    for i = 1:1:num_d
        line = fgetl(fid);
        [x, line] = strtok(line, ',');
        [y, line] = strtok(line, ',');
        z = strtok(line, ',');
        point = point3D(str2double(x), str2double(y), str2double(z));
        d(i) = point;
    end

    for i = 1:1:num_a
        line = fgetl(fid);
        [x, line] = strtok(line, ',');
        [y, line] = strtok(line, ',');
        z = strtok(line, ',');
        point = point3D(str2double(x), str2double(y), str2double(z));
        a(i) = point;
    end

    for i = 1:1:num_c
        line = fgetl(fid);
        [x, line] = strtok(line, ',');
        [y, line] = strtok(line, ',');
        z = strtok(line, ',');
        point = point3D(str2double(x), str2double(y), str2double(z));
        c(i) = point;
    end

    fclose(fid);

end