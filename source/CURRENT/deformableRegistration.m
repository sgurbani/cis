   
function [lambda converged] = deformableRegistration(sk, ck, ckInd, maxIter, threshold)
    global mesh;
    global modes;
    
    numModes = size(modes, 1);
    numTriangles = length(mesh.triangles);
    converged = false;
    
    for iteration=1:maxIter   
        fprintf('Deformable Registration iteration: %1.0f\n', iteration);
        tic;
        
        disp('Vertex 1 before iteration:');
        disp(mesh.vertices(1).vec');

        for k=1:length(ck)
            %first, compute barycentric coordinates of each ck such that
            %ck = psi(1,k)*mk1 + psi(2,k)*mk2 + psi(3,k)*mk3, where m1:m3 are the
            %coordinates of the triangle that ck falls on. Use least squares for
            %the equation ck = M*psi(:,k); solve for psi
            
            ckTriangle = mesh.triangles(ckInd(k));
            v1 = ckTriangle.v1;
            v2 = ckTriangle.v2;
            v3 = ckTriangle.v3;
            
            m1 = ckTriangle.v1_vec;
            m2 = ckTriangle.v2_vec;
            m3 = ckTriangle.v3_vec;
            M = [m1 m2 m3];
            psi=lscov(M, ck(k).vec);

            %next, update q's by applying psi to the modes
            for j=1:numModes
                m1 = modes(j,v1).vec;
                m2 = modes(j,v2).vec;
                m3 = modes(j,v3).vec;
                M = [m1 m2 m3];
                q(j,k) = point3D( M*psi);
            end
        end

        %define Phi(k) = Freg*dk - q0k
        %define Q = [q(1,1).x q(2,1).x ... q(m,1).x
    %                q(1,1).y q(2,1).y ... q(m,1).y
    %                q(1,1).z q(2,1).z ... q(m,1).z
    %                ------------------------------
    %                q(1,2).x q(2,2).x ... q(m,2).x
    %                q(1,2).y q(2,2).y ... q(m,2).y
    %                q(1,2).z q(2,2).z ... q(m,2).z
    %                ------------------------------
    %                                  ...
    %                                  ...
    %                                  ...
    %                ------------------------------
    %                q(1,k).x q(2,k).x ... q(m,k).x
    %                q(1,k).y q(2,k).y ... q(m,k).y
    %                q(1,k).z q(2,k).z ... q(m,k).z]
    %               
    %     where m=numModes and k=numSamps

        %To find lambdas, let's solve the least squares problem:
        %Q*lambda = Phi
        %create Phi
        numSamps = length(ck);
        Phi = zeros(numSamps*3,1);
        for k=1:numSamps
            Phi(( (k-1)*3+1):(k*3) ) = sk(k).vec - q(1,k).vec;
        end

        %create Q
        Q = zeros(numSamps*3, numModes-1);
        for k=1:length(ck)
            Qblock = zeros(3, numModes-1);
            for m=2:numModes
                %do Q in 3x7 blocks
                Qblock(:,m-1) = q(m,k).vec;
            end
            Q( ((k-1)*3+1):(k*3), :) = Qblock;
        end

        tic;
        %find lambda using least squares
        if(iteration > 1)
            lambdaOld = lambda;
            lambda = lscov(Q, Phi);
            dLambda = abs(lambda-lambdaOld);
        else
            lambda = lscov(Q, Phi);
        end
        disp('least squares time:');
        toc;

        %update model
        
        tic;
        %go through every vertex, update it using the equation
        %v = mode(0) + lambdas * other_modes
        for k=1:length(mesh.vertices)
            v = modes(1,k).vec;  %m0
            for j=2:numModes
                v = v + lambda(j-1)*modes(j,k).vec;
            end
            mesh.vertices(k) = point3D(v);
        end
        disp('updating vertices time');
        toc;
        
        tic;
        %now, update each triangle
        for k=1:numTriangles
            tri = mesh.triangles(k);
            mesh.triangles(k) = triangle3D(tri.v1, tri.v2, tri.v3);
%                 mesh.vertices(tri.v1).vec, mesh.vertices(tri.v2).vec, ...
%                 mesh.vertices(tri.v3).vec);
        end

%         updated=zeros(1,numTriangles);
%         for k=1:length(ck)
%             lowerBound = max(1,ckInd(k) - 25);
%             upperBound = min(numTriangles, ckInd(k) + 25);
%             
%             for k2=lowerBound:upperBound
%                 if(updated(1,k2)==0)
%                     tri = mesh.triangles(k2);
%                     mesh.triangles(k2) = triangle3D(tri.v1, tri.v2, tri.v3);
%                     updated(1,k2) = 1;
%                 end
%             end
%         end
        
            
        disp('updating triangle time');
        toc;
        
        tic;
        %re-sort triangles
        mesh.origin = point3D(sum([mesh.triangles.center],2) / numTriangles);
        meshOrigin = mesh.origin.vec;
        mesh.triangles = sortTrianglesByDistance(mesh.triangles, mesh.origin);
        disp('sorting triangle time');
        toc;
        
        tic;
        %update ck
        for z=1:length(sk)
            [tempck ckInd(z)] = closestPointOnMeshLinearBounding(sk(z), meshOrigin);
            ck(z) = point3D(tempck);
        end
        disp('updating ck time');
        toc;
        
        %display debugging information
        disp('Vertex 1 after iteration:');
        disp(mesh.vertices(1).vec');
        disp('lambda:');
        disp(lambda');
        disp('ck(1):');
        disp(ck(1).vec');
        toc;
        
        %check for convergence
        if(iteration > 1)
            if(dLambda < threshold * 100 * ones(length(lambda),1))
                %we're converged
                disp('converged');
                converged = true;
                break;
            end
        end
    end
end