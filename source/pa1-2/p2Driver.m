% Computer Integrated Surgery, EN.600.445
% Alperen Degirmenci, Saumya Gurbani
% 
% Copyright 2010 Johns Hopkins University.
% This code may be found online at http://code.sgurbani.com/cis/source
% after submission of PA2 (November 4, 2010)
%
% For more help, please view the html page at
% http://code.sgurbani.com/cis/pa2.html
% 
% Driver for Programming Assignment 2
% Required files (listed alphabetically):
%
% applyCorrection.m - applies a given distortion function
% EMCalibration.m - determine the position of dimple relative to EM tracker
% frame3D.m - defines a frame transformation (rotate + translate)
% getCorrection.m - calculates a distortion function
% getTransformation.m - calculates the transformation between 2 point clouds
% inverseFrame3D.m - calculates the inverse transformation of a given one
% OptCalibration.m - determine the position of dimple rel. to Opt tracker
% p2Driver.m - this file
% point3D.m - struct defining a 3-dim point
% readCalBody.m - reads in the CalBody.txt files
% readCalReadings.m - reads in the CalReadings.txt files
% readCTFiducials.m - reads in the ct-fiducials.txt files
% readEMpivot.m - read in the empivot.txt files
% readOptPivot.m - read in the optpivot.txt files
% register3D.m - performs a series of frame transformations
% rotate3D.m - applies a frame rotation in space to a point
% transform3D.m - performs a frame transformation between 2 points
% 
% Total files: 17
% 
% Output: creates two files named "pa2-x-output1.txt" and
%         "pa2-x-output2.txt" in the /OUTPUT/ directory
%         for every input data set, where x is the letter of the data set


%prepare Matlab window
clear;
clc;
tic

%FLAG FOR WHETHER TO USE DISTORTION FUNCTION OR NOT
use_distortion = 1;

%run through each set of test data
num_datasets = 8;
filelet = 'a';

for cur_file = 1:1:num_datasets
    
    fprintf('on data set: %s\n', filelet);
    %if there is an output1.txt file, then the file starter is -debug
    %else it is -unknown
    file_starter = '..\input\pa2-debug-';
    ftest = fopen(strcat(file_starter, filelet, '-output1.txt'));
    if (ftest == -1)
        file_starter = '..\input\pa2-unknown-';
    end
    if (ftest ~= -1)
        fclose(ftest);
    end
       
    %input data for calibration
    calreadings = strcat(file_starter, filelet, '-calreadings.txt');
    calbody = strcat(file_starter, filelet, '-calbody.txt');
    empivot = strcat(file_starter, filelet, '-empivot.txt');
    optpivot = strcat(file_starter, filelet, '-optpivot.txt');
    fiducial = strcat(file_starter, filelet, '-em-fiducialss.txt');
    ct_fiducial = strcat(file_starter, filelet, '-ct-fiducials.txt');
    em_nav = strcat(file_starter, filelet, '-EM-nav.txt');
    
    [D A C frames] = readCalReadings(calreadings);
    [d a c] = readCalBody(calbody);
    [G framesG] = readEMpivot(empivot);
    [D_opt H framesH] = readOptPivot(optpivot);
    [Fid framesFid] = readEMpivot(fiducial);
    CTFid = readCTFiducials(ct_fiducial);
    [EMNav framesEMNav] = readEMpivot(em_nav);
    
    %prepare output files
    
    %output file 1 contains distorted EM Ptip, Opt Ptip, and Cexp values
    outputfile1 = strcat('..\output\pa2-',filelet,'-output1.txt');
    outputfilename1 = strcat('pa2-',filelet,'-output1.txt');
    
    %output file 2 contains the positions of test data wrt CT
    outputfile2 = strcat('..\output\pa2-',filelet,'-output2.txt');
    outputfilename2 = strcat('pa2-',filelet,'-output2.txt');
    
    
    %%%END OF VARIABLES%%%
    
    %%%PART 1%%%
    
    %output to outputfile1 for first part
    f_out = fopen(outputfile1,'wt');
    fprintf(f_out, '%d, %d, %s\n', length(c), frames, outputfilename1);
    
    %get P_dimple for EM (with distortion)
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
    Cexp = [];
    
    %go through each frame and write positions to file
    for i=1:1:frames
        %calculate the FD transformation
        FD = getTransformation(D(dstart:dstart+length(d)-1), d);
        %calculate the FA transformation
        FA = getTransformation(A(astart:astart+length(a)-1), a);
        %calculate the expected values for C
        Cexp = [Cexp register3D(c, [FD inverseFrame3D(FA)])];
                
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
    
    %%%PART 2%%%
    
    %output to outputfile2 for second part
    f_out = fopen(outputfile2,'wt');
    
    %calculate distortion function using a 5-th degree Bernstein polynomial
    [boundbox c_values] = getCorrection(C, Cexp, 5);
    
%     %double check that C_ == Cexp
%     C_ = applyCorrection(c_values, boundbox, C);
%     
%     %write to file
%         for k = 1:length(Cexp)
%             fprintf(f_out,'%8.2f  %8.2f, %8.2f  %8.2f, %8.2f  %8.2f\n',Cexp(k).x, C_(k).x, Cexp(k).y, C_(k).y, Cexp(k).z, C_(k).z);
%         end

    %get corrected P_dimple for EM
    G_ = applyCorrection(c_values, boundbox, G);
    
    if(use_distortion == 0)
        G_ = G;
    end
    
    P_dimple = EMCalibration(G_, framesG);
    
%     %write P_dimple coordinates to file
%     fprintf(f_out, '%8.2f, %8.2f, %8.2f\n', P_dimple.x, P_dimple.y, P_dimple.z);
%     
%     fprintf(f_out, 'FIDUCIALS (wrt EM Tracker):\n');
    
    %calculate Fiducial locations
    %go through each Fiducial frame, and do a point cloud registration
    %with the values of G on the calibration object, then apply the
    %transformation to Pdimple
    numpoints_Fid = length(Fid) / framesFid;
    
    for i=1:framesFid
        FidData = Fid((i-1)*numpoints_Fid+1:i*numpoints_Fid);
        FFid = getTransformation(G_((i-1)*numpoints_Fid+1:i*numpoints_Fid),FidData);
        P_Fid(i) = register3D(P_dimple, FFid);
        
        %write to file
%         fprintf(f_out, '%8.2f, %8.2f, %8.2f\n', P_Fid(i).x, P_Fid(i).y, P_Fid(i).z);
    end

    %compute Freg, the transformation from EM coord to CT coord
    Freg = getTransformation(P_Fid, CTFid);
    
    %now, calculate EM-Nav locations
    %first, apply the distortion
    EMNav_ = applyCorrection(c_values, boundbox, EMNav);
    
    if(use_distortion == 0)
        EMNav_ = EMNav;
    end
    
    %then, do as we did with the EM fiducials to get loc wrt EM Tracker
    %then apply Freg to get wrt CT
    numpoints_EMNav = length(EMNav) / framesEMNav;
%     fprintf(f_out, 'EM_NAV POINTS wrt CT:\n');
    
    fprintf(f_out, '%d, %s\n', framesEMNav, outputfilename2);
    
    for i=1:framesEMNav
        EMNavData = EMNav_((i-1)*numpoints_EMNav+1:i*numpoints_EMNav);
        FEMNav = getTransformation(G_((i-1)*numpoints_EMNav+1:i*numpoints_EMNav),EMNavData);
        P_EMNav(i) = register3D(P_dimple, FEMNav);
        P_EMNav_CT(i) = register3D(P_EMNav(i), Freg);
        
        %write to file
        fprintf(f_out, '%8.2f, %8.2f, %8.2f\n', P_EMNav_CT(i).x, P_EMNav_CT(i).y, P_EMNav_CT(i).z);
    end
    
    %close the file
    fclose(f_out); 
    
    %increment the file letter
    filelet = cast(filelet+1, 'char');   
end
toc