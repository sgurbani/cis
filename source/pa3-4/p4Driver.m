% Computer Integrated Surgery, EN.600.445
% Alperen Degirmenci, Saumya Gurbani
% 
% 
% Driver for Programming Assignment 4
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
% Output: creates one file named "PA4-X-Output.txt" in the /OUTPUT/ 
%         directory for every input data set, where X is the letter 
%         of the data set


%%%%%%%%%%%%%%
% SCRIPT
%%%%%%%%%%%%%%

%prepare Matlab window
clc;
tstart = tic;

global mesh;

%load mesh and body values one time only
tstart = tic;
if(~exist('meshBuilt', 'var'))
    mesh=readMesh('..\input\Problem4MeshFile.sur');
    meshBuilt = 1;
end
disp('Time to read mesh:');
disp(toc(tstart));

[markersA tipA] = readBody('..\input\Problem4-BodyA.txt');
[markersB tipB] = readBody('..\input\Problem4-BodyB.txt');

num_A = length(markersA);
num_B = length(markersB);
    
%run through each set of test data
num_datasets = 10;
filelet = 'A';

for cur_file = 1:1:num_datasets
    if(filelet == 'I')
        filelet='J';
    end
    
    fprintf('on data set: %s\n', filelet);
    %if there is an Output.txt file, then the file starter is -debug
    %else it is -unknown
    file_starter = strcat('..\input\PA4-', filelet, '-Debug-');
    ftest = fopen(strcat(file_starter, 'Output.txt'));
    if (ftest == -1)  
        file_starter = strcat('..\input\PA4-', filelet, '-Unknown-');
    end
    if (ftest ~= -1)
        fclose(ftest);
    end
       
    %load sample readings
    sampreadings = strcat(file_starter, 'SampleReadingsTest.txt');
    [a b samps] = readSampleReadings(sampreadings, num_A, num_B);
    
    %prepare output file
    outputfilename = strcat('pa4-',filelet,'-Output.txt');
    outputfile = strcat('..\output\', outputfilename);
    
    outputfilename2 = strcat('pa3-',filelet,'-Output.txt');
    outputfile2 = strcat('..\output\', outputfilename2);
    
    %write output file header
    f_out = fopen(outputfile, 'wt');
    fprintf(f_out, '%d %s 0\n', samps, outputfilename);
    
    %write output file header
    f_out2 = fopen(outputfile2, 'wt');
    fprintf(f_out2, '%d %s 0\n', samps, outputfilename2);

    %clear dk variable each time, since it is causing errors if not reset
    clear dk;
    
    %run through k samples to calculate dk for each sample
    for k=1:samps 
        a_k = a(((k-1)*num_A +1):(k*num_A));
        b_k = b(((k-1)*num_B +1):(k*num_B));

        Fak = getTransformation(markersA, a_k);
        Fbk = getTransformation(markersB, b_k);

        dk(k) = register3D(tipA, [inverseFrame3D(Fbk), Fak]); 
    end
 
    %Problem 3 - used for debugging
    for k=1:samps
        ck(k) = point3D(closestPointOnMeshLinearBounding(dk(k)));
        fprintf(f_out2, '%8.4f,%8.4f,%8.4f\t%8.4f,%8.4f,%8.4f\t%8.4f\n', dk(k).x, dk(k).y, dk(k).z, ck(k).x, ck(k).y, ck(k).z, norm(dk(k).vec-ck(k).vec,2)); 
    end      
    fclose(f_out2);
    
    %Implementing better Freg transformation
    %set variables
    
    %Threshold is the difference needed between iterative Fregs
    %algorithm can terminate if all frame transformation variables <
    %threshold value. We selected .0001 since it offers a good balance
    %between computing time and producing an answer within acceptable
    %limits.
    threshold = .0001;
    
    %Distance threshold (called nu) is used for removing certain points
    %from consideration. If the distance from sk(i) to ck(i) is > nu, then
    %exclude that point from consideration.
    nu = 100;
    
    %Initial guess for Freg is identity transformation
    F(1) = frame3D();
    
    %initialize variables
    A = [];
    B = [];
    pointsLeft = length(dk);
 
    %100 iterations takes ~30minutes to run a data site with 200 points
    %use that as max, since most terminate in < 60 iterations
    maxIter = 100;
    
    for i=1:maxIter;
        fprintf('iteration: %1.0f nu=%1.4f triangles=%3.0f\n', i, nu, pointsLeft);
        
        %closest point on mesh
        z = 1;
        
        %Apply the latest Freg to dk
        % sk = Freg(i) * dk;
        sk = register3D(dk, F(i));
        
        %initialize variables
        keepIndex = 1;
        A = [];
        B = [];
        %e = zeros(1, trianglesLeft);
        
        tic;
        %go through each point and find the closest point on mesh
        for z=1:samps
            %using linear search with bounding spheres
            %octree implementation in Matlab was slower than this method
            %possibly because of lack of passing variables by reference
            ck(z) = point3D(closestPointOnMeshLinearBounding(sk(z)));
            
            %calculate distance between sk and ck points
            d(z) = norm(ck(z).vec - sk(z).vec, 2);
            
            %if distance < nu, then include in calculations
            if(d(z) < nu)
                A = [A dk(z)];
                B = [B ck(z)];
                e(keepIndex) = d(z);
                keepIndex = keepIndex + 1;
            end
        end
        toc;
        
        %If for some reason we have no points left (because nu is too
        %small), then lets terminate our iterations.
        if(isempty(A))
            break;
        end
        
        %calculate new Freg
        FregNew = getTransformation(A, B);
        
        %calculate difference between new and old Fregs
        dFreg = abs(FregNew.quad - F(i).quad);
        disp(dFreg);
%         disp(FregNew.quad);
        
        %check for Freg convergence. If we've converged to within the set
        %threshold, terminate the loop.
        if(dFreg < threshold * ones(4,4))
            %we're done; update sk and end
            sk = register3D(dk, FregNew);
            break;
        end
        
        %store the latest iteration; we're only storing all Fregs found for
        %debugging purposes
        F(i+1) = FregNew;
        
        %check to see how many points we lost from last iteration
        %If we ever lose more than 10% of the triangles, then we're likely
        %stuck in a local minimum; do not tighten nu and within a few
        %iterations we should "pop out" of the local minimum.
        %If we only lose < 10% of triangles, then let's go ahead and
        %tighten nu, using the formula given in lecture slide:
        %nu = 3*mean(distance of all points still being considered)
        if(length(A)/pointsLeft >= .9)
            %update nu
            nu = 3 * mean(e);
            pointsLeft = length(A);
        end
    end
    
    fprintf('Number of iterations: %1f\n',i);
    
    %output to file
    for k=1:samps
        fprintf(f_out, '%8.4f,%8.4f,%8.4f\t%8.4f,%8.4f,%8.4f\t%8.4f\n', sk(k).x, sk(k).y, sk(k).z, ck(k).x, ck(k).y, ck(k).z, norm(sk(k).vec-ck(k).vec,2));   
    end    

    fclose(f_out);
    
    %increment the file letter
    filelet = cast(filelet+1, 'char');   
end

toc(tstart);