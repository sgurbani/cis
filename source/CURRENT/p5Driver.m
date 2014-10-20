% Computer Integrated Surgery, EN.600.445
% Alperen Degirmenci, Saumya Gurbani
% 
% 
% Driver for Programming Assignment 5
% Required files (listed alphabetically):
%
% closestPointOnMeshLinearBounding.m - calculates the closest point on a 
%       mesh using bounding spheres as well as some heuristic properties
%       to speed up a search
% closestPointOnTriangle.m - calculates the closest point on triangle
% deformableRegistration.m - calculates the mode weights of a deformation
% frame3D.m - defines a frame transformation (rotate + translate)
% getTransformation.m - calculates the transformation between 2 point clouds
% inverseFrame3D.m - calculates the inverse transformation of a given one
% iterativeClosestPoint.m - calculates an ICP of a rigid body
% Mesh.m - defines the Mesh class (located in the @Mesh folder for Matlab
%          versions older than R2009a
% p5Driver.m - this file
% point3D.m - struct defining a 3-dim point
% projectOnSegment.m - projects a point onto a line segment
% readBody.m - reads the '-BodyA.txt' and '-BodyB.txt' files
% readSampleReadings.m - reads the sample readings text files
% register3D.m - performs a series of frame transformations
% transform3D.m - performs a frame transformation between 2 points
% triangle3D.m - represents a triangle composed of 3 vertices (point3Ds)
% 
% Total files: 16
% 
% Output: creates one file named "pa5-X-Output.txt" in the /OUTPUT/ 
%         directory for every input data set, where X is the letter 
%         of the data set


%%%%%%%%%%%%%%
% SCRIPT
%%%%%%%%%%%%%%

%prepare Matlab window
clc;
tstart = tic;

%due to the nature of PA5, need to load mesh every time
tic;
global mesh;
mesh = Mesh('..\input\Problem5Mesh.sur', true);
meshOrigin = mesh.origin.vec;
disp('Time to process mesh:');
toc;

numTriangles = size(mesh.triangles, 2);
    
if(~exist('modes', 'var'))
    global modes;
    disp('loading modes...');
    tic;
    modes = readModes('..\input\Problem5Modes.txt');  
    numModes = size(modes, 1);
    disp('Time to process modes: ');disp(toc);
end

%load sample reading data
[markersA tipA] = readBody('..\input\Problem5-BodyA.txt');
[markersB tipB] = readBody('..\input\Problem5-BodyB.txt');
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
    file_starter = strcat('..\input\PA5-', filelet, '-Debug-');
    ftest = fopen(strcat(file_starter, 'Output.txt'));
    if (ftest == -1)  
        file_starter = strcat('..\input\PA5-', filelet, '-Unknown-');
    end
    if (ftest ~= -1)
        fclose(ftest);
    end
       
    %load sample readings
    sampreadings = strcat(file_starter, 'SampleReadingsTest.txt');
    [a b samps] = readSampleReadings(sampreadings, num_A, num_B);
    
    %prepare output file
    outputfilename = strcat('pa5-',filelet,'-Output.txt');
    outputfile = strcat('..\output\', outputfilename);
    
    outputfilename2 = strcat('pa3-',filelet,'-Output.txt');
    outputfile2 = strcat('..\output\', outputfilename2);
    
    outputfilename3 = strcat('pa4-',filelet,'-Output.txt');
    outputfile3 = strcat('..\output\', outputfilename3);
    
    %write output file header
    f_out = fopen(outputfile, 'wt');
    fprintf(f_out, '%d %s 0\n', samps, outputfilename);
    
    %write output file header
    f_out2 = fopen(outputfile2, 'wt');
    fprintf(f_out2, '%d %s 0\n', samps, outputfilename2);
    
    %write output file header
    f_out3 = fopen(outputfile3, 'wt');
    fprintf(f_out3, '%d %s 0\n', samps, outputfilename3);
        
    %clear dk variable each time, since it is causing errors if not reset
    %then, preallocate space for dk
    clear dk;
    dk(samps) = point3D;
    
    %run through k samples to calculate dk for each sample
    for k=1:samps 
        a_k = a(((k-1)*num_A +1):(k*num_A));
        b_k = b(((k-1)*num_B +1):(k*num_B));

        Fak = getTransformation(markersA, a_k);
        Fbk = getTransformation(markersB, b_k);

        dk(k) = register3D(tipA, [inverseFrame3D(Fbk), Fak]); 
    end
 
%     sk = dk;
%     for z=1:length(sk)
%             [tempck ckInd(z)] = closestPointOnMeshLinearBounding(sk(z), meshOrigin);
%             ck(z) = point3D(tempck);
%         end

    %Problem 3 - used for debugging
    %preallocate ck for speed
    ck(samps) = point3D;
    for k=1:samps
        ck(k) = point3D(closestPointOnMeshLinearBounding(dk(k)));
        fprintf(f_out2, '%8.4f,%8.4f,%8.4f\t%8.4f,%8.4f,%8.4f\t%8.4f\n', dk(k).x, dk(k).y, dk(k).z, ck(k).x, ck(k).y, ck(k).z, norm(dk(k).vec-ck(k).vec,2)); 
    end      
    fclose(f_out2);

    %%%PROBLEM 4%%%
    %Implementing better Freg transformation

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
    Freg = frame3D();
    
    %100 iterations takes ~30minutes to run a data site with 200 points
    %use that as max, since most terminate in < 60 iterations
    maxIterICP = 100;
    maxIterDeform = 50;
    
    %run ICP algorithm to get latest Freg
    [Freg ck ckInd] = iterativeClosestPoint(dk, Freg, threshold, nu, maxIterICP, meshOrigin);

    %apply Freg to dk to get sk
    sk = register3D(dk, Freg);
    
    %output to file
    for k=1:samps
        fprintf(f_out3, '%8.4f,%8.4f,%8.4f\t%8.4f,%8.4f,%8.4f\t%8.4f\n', sk(k).x, sk(k).y, sk(k).z, ck(k).x, ck(k).y, ck(k).z, norm(sk(k).vec-ck(k).vec,2));   
    end    
    fclose(f_out3);
    
    %%%PROBLEM 5%%%

    converged = false;
    maxIter = 20;
    
    %run a deformable registration, using 
    [lambda converged] = deformableRegistration(sk, ck, ckInd, maxIterDeform, threshold*10);
    
    for i=1:maxIter
        %first, run an ICP to calculate ck, ckInd, and Freg
        [Freg ck ckInd] = iterativeClosestPoint(dk, Freg, threshold, nu, maxIterICP, meshOrigin);

        %apply Freg to dk to get sk
        sk = register3D(dk, Freg);

        %run a deformable registration, using 
        [lambda converged] = deformableRegistration(sk, ck, ckInd, maxIterDeform, threshold*10);
        
        if(converged == true)
            %we're done
            break;
        end
    end
    
    %run one last ICP
    [Freg ck ckInd] = iterativeClosestPoint(dk, Freg, threshold, nu, maxIterICP, meshOrigin);
    sk = register3D(dk, Freg);
    
    %output to file
    fprintf(f_out, '%6.4f\t', lambda);
    for k=1:samps
        fprintf(f_out, '\n%8.4f,%8.4f,%8.4f\t%8.4f,%8.4f,%8.4f\t%8.4f', sk(k).x, sk(k).y, sk(k).z, ck(k).x, ck(k).y, ck(k).z, norm(sk(k).vec-ck(k).vec,2));   
    end    
    fclose(f_out);
    %increment the file letter
    filelet = cast(filelet+1, 'char');   
end

toc(tstart);