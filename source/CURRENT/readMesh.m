%Computer Integrated Surgery, EN.600.445
%Alperen Degirmenci, Saumya Gurbani

%Copyright 2010 Johns Hopkins University.

function mesh = readMesh(filename)
%Reads the Mesh.sur file and returns an object of type Mesh
    
    %create new Mesh object
    mesh = Mesh;
    
    %open file, get number vertices
    fid = fopen(filename);
    num_vertices = str2num(fgetl(fid));
    
    %add each vertex to the mesh
    for i = 1:1:num_vertices
        line = fgetl(fid);
        [x, line] = strtok(line, ', ');
        [y, line] = strtok(line, ', ');
        z = strtok(line, ', ');
        mesh = mesh.addVertex(str2double(x), str2double(y), str2double(z));
    end

    %next line will contain number of triangles
    num_triangles = str2num(fgetl(fid));
    
    h=waitbar(0, 'Loading Mesh...0%');
    for i = 1:1:num_triangles
        line = fgetl(fid);
        
        %vertex indices of triangle
        [v1, line] = strtok(line, ', ');
        [v2, line] = strtok(line, ', ');
        [v3, line] = strtok(line, ', ');

        %neighbor triangles
        [n1, line] = strtok(line, ',');
        [n2, line] = strtok(line, ',');
        n3 = strtok(line, ',');
        
        %for now, ignore the neighbors
        mesh = mesh.addTriangle(str2double(v1)+1, str2double(v2)+1, str2double(v3)+1);
        waitbar(i/num_triangles, h,sprintf('Loading Mesh...%2.0f%%',i/num_triangles * 100));
    end
    delete(h);
    
    %close file
    fclose(fid);

end