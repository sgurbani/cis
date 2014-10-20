
%Computer Integrated Surgery, EN.600.445
%Alperen Degirmenci, Saumya Gurbani

%Copyright 2010 Johns Hopkins University.

function [a b samples] = readSampleReadings(filename, numA, numB)
%Reads the SampleReadings.txt and returns the corresponding G point3D structs
%and the number of frames

fid = fopen(filename);
line1 = fgetl(fid);
[num_s, line1] = strtok(line1, ' ,');
[samples, line1] = strtok(line1, ', ');

num_s = str2num(num_s);
samples = str2num(samples);

a = [];
b = [];

for i = 1:samples
    offset = i - 1;
    for k = 1:numA
        line = fgetl(fid);
        [x, line] = strtok(line, ',');
        [y, line] = strtok(line, ',');
        z = strtok(line, ',');
        point = point3D(str2double(x), str2double(y), str2double(z));
        a = [a; point];
    end
    
    for k = 1:numA
        line = fgetl(fid);
        [x, line] = strtok(line, ',');
        [y, line] = strtok(line, ',');
        z = strtok(line, ',');
        point = point3D(str2double(x), str2double(y), str2double(z));
        b = [b; point];
    end
    
    
    for k = 1:(num_s-numA-numB)
        line = fgetl(fid);
    end
end

fclose(fid);

end