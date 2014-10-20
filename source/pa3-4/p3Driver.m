% Computer Integrated Surgery, EN.600.445
% Alperen Degirmenci, Saumya Gurbani
% 
% 
% Driver for Programming Assignment 3
% Required files (listed alphabetically):
%
% closestPointOnMeshLinear.m - calculates closest point using a simple search
% closestPointOnMeshLinearBounding.m - like above, but with a bounding sphere
% closestPointOnMeshOctree.m - uses an octree to calculate closest point
% closestPointOnTriangle.m - calculates the closest point on triangle
% frame3D.m - defines a frame transformation (rotate + translate)
% getCenterOfQuadrant - calculates the centroid of a mesh of triangles
% getQuadrant - calculates which of the 8 3D quadrants a point falls within
% getTransformation.m - calculates the transformation between 2 point clouds
% inverseFrame3D.m - calculates the inverse transformation of a given one
% Mesh.m - defines the Mesh class
% Octree.m - defines the Octree class
% p3Driver.m - this file
% point3D.m - struct defining a 3-dim point
% projectOnSegment.m - projects a point onto a line segment
% readBody.m - reads the '-BodyA.txt' and '-BodyB.txt' files
% readMesh.m - reads the 'Mesh.sur' files and produces a Mesh
% readSampleReadings.m - reads the sample readings text files
% register3D.m - performs a series of frame transformations
% transform3D.m - performs a frame transformation between 2 points
% 
% Total files: 19
% 
% Output: creates one file named "PA3-X-Output.txt" in the /OUTPUT/ 
%         directory for every input data set, where X is the letter 
%         of the data set


%%%%%%%%%%%%%%
% SCRIPT
%%%%%%%%%%%%%%

%prepare Matlab window
clc;

%load mesh and body values one time only
tstart = tic;
if(~exist('meshBuilt', 'var'))
    mesh=readMesh('..\input\Problem3Mesh.sur');
    meshBuilt = 1;
end
disp('Time to read mesh:');
disp(toc(tstart));

[markersA tipA] = readBody('..\input\Problem3-BodyA.txt');
[markersB tipB] = readBody('..\input\Problem3-BodyB.txt');

num_A = length(markersA);
num_B = length(markersB);
    
%run through each set of test data
num_datasets = 9;
filelet = 'A';

for cur_file = 1:1:num_datasets
    if(filelet == 'I')
        filelet='J';
    end
    
    fprintf('on data set: %s\n', filelet);
    %if there is an Output.txt file, then the file starter is -debug
    %else it is -unknown
    file_starter = strcat('..\input\PA3-', filelet, '-Debug-');
    ftest = fopen(strcat(file_starter, 'Output.txt'));
    if (ftest == -1)  
        file_starter = strcat('..\input\PA3-', filelet, '-Unknown-');
    end
    if (ftest ~= -1)
        fclose(ftest);
    end
       
    %load sample readings
    sampreadings = strcat(file_starter, 'SampleReadingsTest.txt');
    [a b samps] = readSampleReadings(sampreadings, num_A, num_B);
    
    %prepare output file
    outputfilename = strcat('pa3-',filelet,'-Output.txt');
    outputfile = strcat('..\output\', outputfilename);
    
    %write output file header
    f_out = fopen(outputfile, 'wt');
    fprintf(f_out, '%d %s 0\n', samps, outputfilename);

    %run through k samples
    for k=1:samps
        a_k = a(((k-1)*num_A +1):(k*num_A));
        b_k = b(((k-1)*num_B +1):(k*num_B));

        Fak = getTransformation(markersA, a_k);
        Fbk = getTransformation(markersB, b_k);

        dk = register3D(tipA, [inverseFrame3D(Fbk), Fak]);

        %for this problem, sk = dk
        sk = dk;
  
        %closest point on mesh
        ck = closestPointOnMeshLinearBounding(mesh.triangles, dk);

        fprintf(f_out, '%8.2f,%8.2f,%8.2f\t%8.2f,%8.2f,%8.2f\t%8.2f\n', dk.x, dk.y, dk.z, ck(1), ck(2), ck(3), norm(dk.vec-ck,2));
    end

    fclose(f_out);
    
    %increment the file letter
    filelet = cast(filelet+1, 'char');   
end