% Computer Integrated Surgery, EN.600.445
% Alperen Degirmenci, Saumya Gurbani

function [Freg ck ckInd] = iterativeClosestPoint(dk, Freg0, threshold, bound, maxIter, meshOrigin)

    %if maxIter and meshOrigin not specified, use defaults
    if(nargin == 4)
        maxIter = 100;
        meshOrigin = point3D.vec;
    end
    
    if(nargin == 5)
        meshOrigin = point3D.vec;
    end
    
    %initialize other variables
    ck = point3D;
    ckInd = -1;
    samps = length(dk);
    
    %store every Freg found, starting with Freg0
    %this is for debugging purposes
    F(1) = Freg0;
    
    %set number of points left being considered
    %used for convergence / end case testing
    pointsLeft = length(dk);
    
    ckInd = zeros(1, samps);

    for i=1:maxIter;
        fprintf('ICP iteration: %1.0f bound=%1.4f points=%3.0f\n', i, bound, pointsLeft);
        
        %Apply the latest Freg to dk
        sk = register3D(dk, F(i));
        
        %initialize variables
        keepIndex = 1;
        A = [];
        B = [];
        ck(samps) = point3D;
        d = zeros(1, samps);
        %e = zeros(1, trianglesLeft);
        
        tic;
        %go through each point and find the closest point on mesh
        
        for z=1:samps
            %using linear search with bounding spheres
            %octree implementation in Matlab was slower than this method
            %possibly because of lack of passing variables by reference
            [tempck ckInd(z)] = closestPointOnMeshLinearBounding(sk(z), meshOrigin, ckInd(z), min(1,max(0, 1-(bound/maxIter))));
%             [tempck ckInd(z)] = closestPointOnMeshLinearBounding(sk(z), meshOrigin);

            ck(z) = point3D(tempck);
            
            %calculate distance between sk and ck points
            d(z) = norm(ck(z).vec - sk(z).vec, 2);
            
            %if distance < bound, then include in calculations
            if(d(z) < bound)
                A = [A dk(z)];
                B = [B ck(z)];
                e(keepIndex) = d(z);
                keepIndex = keepIndex + 1;
            end
        end
        toc;
        
        %If for some reason we have no points left (because bound is too
        %small), then lets terminate our iterations.
        if(isempty(A))
            break;
        end
        
        %rotation will converge faster. if we do have a converged rotation,
        %lets not calculate a new transformation; rather, just calculate a
        %new translation.
        
        FregNew = getTransformation(A, B);
        
        %calculate difference between new and old Fregs
        dFreg = abs(FregNew.quad - F(i).quad);
        disp(dFreg);
%         disp(FregNew.quad);
        
        %check for Freg convergence. If we've converged to within the set
        %threshold, terminate the loop.
        if(dFreg < threshold * ones(4,4))
%         if(dFreg([2:4],1) < thresholdTrans*ones(3,1))
%                if(dFreg([2:4],[2:4]) < thresholdRot*ones(3,3))
            %we're done; update sk and end
            sk = register3D(dk, FregNew);
            break;
%                end
        end
        
%         if(dFreg([2:4],[2:4]) < thresholdRot*ones(3,3))
%             rotConverged = 1;
%             disp('rotation converged.');
%         end
        
        %store the latest iteration; we're only storing all Fregs found for
        %debugging purposes
        F(i+1) = FregNew;
        
        %check to see how many points we lost from last iteration
        %If we ever lose more than 10% of the triangles, then we're likely
        %stuck in a local minimum; do not tighten bound and within a few
        %iterations we should "pop out" of the local minimum.
        %If we only lose < 10% of triangles, then let's go ahead and
        %tighten bound, using the formula given in lecture slide:
        %bound = 3*mean(distance of all points still being considered)
        if(length(A)/pointsLeft >= .9)
            %update bound
            bound = 3 * mean(e);
            pointsLeft = length(A);
        end
    end
    
    Freg = F(i);
    fprintf('Number of iterations: %1f\n',i);
end
    