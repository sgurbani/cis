%Computer Integrated Surgery, EN.600.445
%Alperen Degirmenci, Saumya Gurbani

%Copyright 2010 Johns Hopkins University.

function modes = readModes(filename)
%Reads the -Modes.txt file and returns a 2D array of modes

%open file, get header data
fid = fopen(filename);
line = fgetl(fid);
numModes = ...
    str2num(substring(regexp(line, 'Nmodes=[0-9]*', 'match', 'once'), 7));
numVertices = ...
    str2num(substring(regexp(line, 'Nvertices=[0-9]*', 'match', 'once'), 10));

%preallocate modes matrix
% modes = zeros(numModes, numVertices);
modes(numModes+1, numVertices) = point3D;

%read in vertex coordinates
for j=1:numModes+1
    %first line is just a header
    line = fgetl(fid);
    for i=1:numVertices
        line = fgetl(fid);
        [x, line] = strtok(line, ', ');
        [y, line] = strtok(line, ', ');
        z = strtok(line, ', \n\t');
        modes(j, i) = point3D(str2double(x), str2double(y), str2double(z));
    end
end

fclose(fid);

end