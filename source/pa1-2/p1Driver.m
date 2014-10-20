% Computer Integrated Surgery, EN.600.445
% Alperen Degirmenci, Saumya Gurbani
% 
% Copyright 2010 Johns Hopkins University.
% This code may be found online at http://code.sgurbani.com/cis/source
% after submission of PA2 (November 2, 2010)
%
% For more help, please view the html page at
% http://code.sgurbani.com/cis/pa1.html
% 
% Driver for Programming Assignment 1
% Required files:
% point3D.m - struct defining a 3-dim point
% rotate3D.m - applies a frame rotation in space to a point
% frame3D.m - defines a frame transformation (rotate + translate)
% inverseFrame3D.m - calculates the inverse transformation of a given one
% transform3D.m - performs a frame transformation between 2 points
% register3D.m - performs a series of frame transformations
% getTransformation.m - calculates the transformation between 2 point clouds
% EMCalibration.m - determine the position of dimple relative to EM tracker
% OptCalibration.m - determine the position of dimple rel. to Opt tracker
% readCalBody.m - reads in the CalBody.txt files
% readCalReadings.m - reads in the CalReadings.txt files
% readEMpivot.m - read in the empivot.txt files
% readOptPivot.m - read in the optpivot.txt files
% p1Driver.m - this file
% 
% Total files: 14
% 
% Output: creates one file named "pa1-x-output1.txt" in the source directory
%        for every input data set, where x is the letter of the data set

%prepare Matlab window
clear;
clc;

%run through each set of test data
num_datasets = 9;
filelet = 'a';

for cur_file = 1:1:num_datasets
    
    %if there is an output1.txt file, then the file starter is -debug
    %else it is -unknown
    file_starter = '..\input\pa1-debug-';
    ftest = fopen(strcat(file_starter, filelet, '-output1.txt'));
    if (ftest == -1)
        file_starter = '..\input\pa1-unknown-';
    end
    if (ftest ~= -1)
        fclose(ftest);
    end
       
    %input data for calibration
    calreadings = strcat(file_starter, filelet, '-calreadings.txt');
    calbody = strcat(file_starter, filelet, '-calbody.txt');
    empivot = strcat(file_starter, filelet, '-empivot.txt');
    optpivot = strcat(file_starter, filelet, '-optpivot.txt');
    
    
    [D A C frames] = readCalReadings(calreadings);
    [d a c] = readCalBody(calbody);
    [G framesG] = readEMpivot(empivot);
    [D H framesH] = readOptPivot(optpivot);
    
    %prepare output file
    outputfile = strcat('..\output\pa1-',filelet,'-output1.txt');
    outputfilename = strcat('pa1-',filelet,'-output1.txt');
    f_out = fopen(outputfile,'wt');
    fprintf(f_out, '%d, %d, %s\n', length(c), frames, outputfilename);


    %get P_dimple for EM
    P_dimple = EMCalibration(G, framesG);
    %write P_dimple coordinates to file
    fprintf(f_out, '%8.2f, %8.2f, %8.2f\n', P_dimple.x, P_dimple.y, P_dimple.z);

    %get P_dimple for Opt
    P_dimple_OPT = OptCalibration(D, H, d, framesH);
    %write P_dimple coordinates to file
    fprintf(f_out, '%8.2f, %8.2f, %8.2f\n', P_dimple_OPT.x, P_dimple_OPT.y, P_dimple_OPT.z);

    %set initial offsets for registration data
    dstart = 1;
    astart = 1;
    %go through each frame and write positions to file
    for i=1:1:frames
        %calculate the FD transformation
        FD = getTransformation(D(dstart:dstart+length(d)-1), d);
        %calculate the FA transformation
        FA = getTransformation(A(astart:astart+length(a)-1), a);
        %calculate the expected values for C
        Cexp = register3D(c, [FD inverseFrame3D(FA)]);

        %write to file
        for k = 1:length(Cexp)
            fprintf(f_out,'%8.2f, %8.2f, %8.2f\n',Cexp(k).x, Cexp(k).y, Cexp(k).z);
        end

        %increase offsets
        dstart = dstart + length(d);
        astart = astart + length(a);
    end

    %close the file
    fclose(f_out); 
    %increment the file letter
    filelet = cast(filelet+1, 'char');   
end