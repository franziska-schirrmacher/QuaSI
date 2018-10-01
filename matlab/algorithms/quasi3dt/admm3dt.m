% Implemented by Tobias Lindenberger
% Implements the basic structure of 'Algorithm 1' of the QuaSI paper, extended to 3D
% inputs:
%   g -> the noisy input volumes (cell of volumes)
%   mu -> weight, controlling the influnce of the total variation (TV) term for x,y and z direction
%   omega -> weight, controlling the influence of the total variation (TV) term for t direction
%   lambda -> weight, controlling the influence of the QuaSI (here, the median) term
%   alpha -> lagragian multiplier for the QuaSI term
%   beta -> lagragian multiplier for the TV term in t direction
%   gamma -> lagragian multiplier for the TV term in t direction
%   tol -> threshold to end the iterations if the change between iterations has become small
%   maxOuterIter -> the number of iterations for the outer loop
%   maxInnerIter -> the number of iterations for the inner loop
%   patchsize -> the size of the patch for the median search (full patch size! must be an odd number!)
% outputs:
%   f -> the denoised image
%   E -> the energy function of the formula

function [ f, E ] = admm3dt( g,lambda,mu,omega,alpha,beta,gamma,tol,maxOuterIter,maxInnerIter,patchsize,p)

% store the number of volumes
numberOfVolumes = numel(g);
%numberOfVolumes = numberOfVolumes(2);
% store the size of the volumes
[R,C,Z] = size(g{1});
% convert the input volumes into a vector 
g = volumeStreamToVector(g);
% initialize the denoised image with the average of all input images
f_new = g;

% number of directions for the gradient
directions = 3;
% define the gradient directions and compute its transposes
numberPixel = C*R*Z*numberOfVolumes;
gradX = getGradientMatrix(numberPixel,1);       % gradient in x direction (right to left)
gradY = getGradientMatrix(numberPixel,C);       % gradient in y direction (bottom to top)
gradZ = getGradientMatrix(numberPixel, R*C);    % gradient in z direction ()
gradT = getGradientMatrix(numberPixel, R*C*Z);  % gradient in t direction
gradXT = gradX';    % transposed gradient in x direction (left to right)
gradYT = gradY';    % transposed gradient in y direction (top to bottom)
gradZT = gradZ';    % transposed gradient in z direction
gradTT = gradT';    % transposed gradient in t direction

grad_XYZ = {gradX, gradY, gradZ};
clearvars gradX;
clearvars gradY;
clearvars gradZ;
gradT_XYZ = {gradXT, gradYT, gradZT};
clearvars gradXT;
clearvars gradYT;
clearvars gradZT;
grad_T = {gradT};
gradT_T = {gradTT};
clearvars gradT;
clearvars gradTT;


% iniitalize the auxiliary variable and the bregman variable related to the total variation term 
% in x, y and z direction
v_vec = cell(1,directions);     % auxilary variable     d_{x,y,z}
bv_vec = cell(1,directions);    % bregman variable      b_{x,y,z}
for pos = 1:directions
    v_vec{pos} = zeros(R*C*Z*numberOfVolumes, 1);
    bv_vec{pos} = zeros(R*C*Z*numberOfVolumes, 1);
end

% initialize the auxilary variables and the bregman variable related to the total variation term
% in t direction
d_t_vec = zeros(R*C*Z*numberOfVolumes,1);
b_t_vec = zeros(R*C*Z*numberOfVolumes,1);

% iniitalize the auxiliary variable and the bregman variable related to the quasi prior
u_vec = zeros(R*C*Z*numberOfVolumes,1);     % auxilary variable     u
bu_vec = zeros(R*C*Z*numberOfVolumes,1);    % bregman variable      b_{u}

% compute Laplacian, create a matrix that computes the laplacian when multiplied 
% to a volume stream in vector form
[Rgrad, Cgrad, Zgrad] = size(grad_XYZ{1});
L_XYZ = sparse(Rgrad,Cgrad,Zgrad);
% laplacian from gradients in x,y,z direction
for pos  = 1:length(grad_XYZ)    
    L_XYZ = L_XYZ + gradT_XYZ{pos}*grad_XYZ{pos};    
end
% laplacian from gradients in t direction
L_T = sparse(Rgrad,Cgrad,Zgrad);
L_T = L_T + gradT_T{1}*grad_T{1};

% vectorize the volume
f_new_vec = f_new;
flag = 0;
% store the value of the energy function in each iteration step (equation (1))
% this is only used to show the convergence of the algorithm
E = [];



% start the optimization, this implements basically algorithm 1 of the paper
for outerIter = 1:maxOuterIter
    
    % Compute look up table for quantile regularization (M = Id - Q)
    if lambda > 0
        lookUpRow = zeros(C*R*Z*numberOfVolumes,1);
        lookUpColumn = zeros(C*R*Z*numberOfVolumes,1);
        currentVolumes = vectorToVolumeStream(f_new_vec,numberOfVolumes,C,R,Z);
        %for current=1:size(currentVolumes)
        for current=1:numberOfVolumes
            [currentLookUpRow,currentLookUpColumn] = compute_Q3dt(currentVolumes{current}, patchsize,p);
            startPos = (current-1)*C*R*Z + 1;
            endPos = current*C*R*Z;
            currentLookUpRow = currentLookUpRow + (startPos-1);
            currentLookUpColumn = currentLookUpColumn + (startPos-1);
            lookUpRow(startPos:endPos) = currentLookUpRow;
            lookUpColumn(startPos:endPos) = currentLookUpColumn;
        end
        M = speye(numberPixel, numberPixel) - sparse(lookUpRow,lookUpColumn,1,numberPixel,numberPixel);
        MT = speye(numberPixel, numberPixel) - sparse(lookUpColumn,lookUpRow,1,numberPixel,numberPixel);
    else
        M = speye(numberPixel, numberPixel);
        MT = speye(numberPixel, numberPixel);
    end
    
    f_old_vec = f_new_vec;   
    
    for innerIter = 1:maxInnerIter
         %update the intermediate image f
        [f_new_vec, sigma] = update_f3dt( f_new_vec,g,alpha,beta,gamma,v_vec,bv_vec,...
            b_t_vec,d_t_vec,bu_vec,u_vec,M,MT,grad_XYZ,gradT_XYZ,grad_T,gradT_T,L_XYZ,L_T,tol);
       
        if(find(isnan(f_new_vec(:)) == 1))
            flag = 1;
            f_new_vec = zeros(R,C);
            error('Optimize_f returned NaN')
        end
        
        % update the auxilary (v_vec) and bregman (bv_vec) variables for the total variation in x,y,z direction
        % Gradient for TV denoising in x,y,z direction
        gradient = cell(1,directions);
        %Anisotropic TV denoising
        for pos = 1:directions
            % compute gradient of the new image in x,y,z direction
            gradient{pos} = getGradient(f_new_vec,grad_XYZ,gradT_XYZ,pos);
            % update v_vec according to formula (6) v_new = shrink(grad(f_new) + b_old, mu/beta)
            v_vec{pos} = updateAux(gradient{pos},bv_vec{pos},mu,beta);
            % update bv_vec according to formula (8) bv_new = bv_old + (grad(f_new)-v_new)
            bv_vec{pos} = updateBreg(bv_vec{pos},gradient{pos}, v_vec{pos});
        end
        
        % update the auxilary (d_t_vec) and bregman (b_t_vec) variables for the total variation in t direction
        % Gradient for TV denoising in t direction
        % compute gradient of the new image in t direction
        gradient_t = getGradient(f_new_vec,grad_T,gradT_T,1);
        % update d_t_vec according to formula (6) d_t_vec = shrink(grad(f_new) + b_t_vec, omega/gamma)
        d_t_vec = updateAux(gradient_t,b_t_vec,omega,gamma);
        % update b_t_vec according to formula (8) b_t_vec = b_t_vec + (grad(f_new)-d_t_vec_new)
        b_t_vec = updateBreg(b_t_vec,gradient_t,d_t_vec);
        
        % update the auxilary (u_vec) and bregman (bu_vec) variables for the quasi prior
        if lambda > 0
            % update u_vec according to formula (5) u_new = shrink(f_new - Q*f_new + bu_old, lambda/alpha)
            u_vec = updateAux( M*f_new_vec,bu_vec,lambda,alpha);
            % update bu_vec according to formula (7) bu_new = bu_old + (f_new - Q*f_new - u_new)
            bu_vec = updateBreg( bu_vec,M*f_new_vec,u_vec);
        end
    
         if nargout > 1
            % Compute energy function            
            E = [E; calculateEnergyFunction3dt(f_new_vec, g, gradient, gradient_t, 1.345*sigma, mu, lambda, omega, patchsize,p, C, R, Z, numberOfVolumes)];
         end
            
    end
        
    if(flag == 1)
        break;
    end
    
    %compute the difference between the intermediate image and the
    %image from the previous iteration step 
    %return is difference is small
    if norm(f_old_vec - f_new_vec) / norm(f_old_vec) < tol 
       f = vectorToVolumeStream(f_new_vec,numberOfVolumes,C,R,Z);
       return;
    end
    
end

f = vectorToVolumeStream(f_new_vec,numberOfVolumes,C,R,Z);