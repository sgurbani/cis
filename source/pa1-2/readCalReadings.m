%Computer Integrated Surgery, EN.600.445
%Alperen Degirmenci, Saumya Gurbani

%Copyright 2010 Johns Hopkins University.

function [D A C frames] = readCalReadings(filename)

%Reads the calbody.txt and returns the corresponding D, A, and C sets of
%point3D structs and the number of frames

fid = fopen(filename);
line1 = fgetl(fid);
[num_D, line1] = strtok(line1, ',');
[num_A, line1] = strtok(line1, ',');
[num_C, line1] = strtok(line1, ',');
num_repeat = strtok(line1, ',');

num_D = str2num(num_D);
num_A = str2num(num_A);
num_C = str2num(num_C);
num_repeat = str2num(num_repeat);
frames = num_repeat;
 
for k =1:1:num_repeat
    
    start_offset = k - 1;
    
    for i = (start_offset*num_D + 1):1:k*num_D
        line = fgetl(fid);
        [x, line] = strtok(line, ',');
        [y, line] = strtok(line, ',');
        z = strtok(line, ',');
        point = point3D(str2double(x), str2double(y), str2double(z));
        D(i) = point;
    end

    for i = (start_offset*num_A + 1):1:k*num_A
        line = fgetl(fid);
        [x, line] = strtok(line, ',');
        [y, line] = strtok(line, ',');
        z = strtok(line, ',');
        point = point3D(str2double(x), str2double(y), str2double(z));
        A(i) = point;
    end

    for i = (start_offset*num_C + 1):1:k*num_C
        line = fgetl(fid);
        [x, line] = strtok(line, ',');
        [y, line] = strtok(line, ',');
        z = strtok(line, ',');
        point = point3D(str2double(x), str2double(y), str2double(z));
        C(i) = point;
    end
end

fclose(fid);

end