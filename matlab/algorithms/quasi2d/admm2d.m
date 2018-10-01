function [ f, E ] = admm2d(g,lambda,mu,omega,alpha,beta,gamma,tol,maxOuterIter,maxInnerIter,patchsize,p)


%store the size of the image
[R,C,K] = size(g);

%initialize the denoised image with the average of all input images
f_new = mean(g, 3);

%number of directions for the gradient
directions = 2;
%define the gradient directions and compute its transposes
numberPixel = R*C;
gradX = getGradientMatrix(numberPixel,1);
gradY = getGradientMatrix(numberPixel,C);
gradXT = gradX';
gradYT = gradY';
grad = {gradX, gradY};
gradT = {gradXT, gradYT};

%iniitalize the auxiliary variable and the bregman variable related to the 
%total variation term
v_vec = cell(1,directions);
bv_vec = cell(1,directions);

for pos = 1:directions
    v_vec{pos} = matrixToVector(zeros(R,C));
    bv_vec{pos} = matrixToVector(zeros(R,C));
end

%iniitalize the auxiliary variable and the bregman variable related to the
%quasi prior
u_vec = zeros(R*C,1);
bu_vec = zeros(R*C,1);

%compute Laplacian
[Rgrad, Cgrad] = size(grad{1});
L = sparse(Rgrad,Cgrad);
for pos  = 1:length(grad)    
    L = L + gradT{pos}*grad{pos};    
end

%vectorize the image
f_new_vec = matrixToVector(f_new);
flag = 0;
% store the value of the energy function in each iteration step (equation (3))
E = [];


for outerIter = 1:maxOuterIter
    
    if lambda > 0
        % Compute look up table for quantile regularization (M = Id - Q)(equation (8))
        [LookUpRow, LookUpColumn] = compute_Q2d(vectorToMatrix(f_new_vec,R,C),patchsize,p);
        M = speye(numberPixel, numberPixel) - sparse(LookUpRow,LookUpColumn,1,numberPixel,numberPixel);
        MT = speye(numberPixel, numberPixel) - sparse(LookUpColumn,LookUpRow,1,numberPixel,numberPixel);
    else
        M = speye(numberPixel, numberPixel);
        MT = speye(numberPixel, numberPixel);
    end
    
    f_old_vec = f_new_vec;   
    
    for innerIter = 1:maxInnerIter
         %update the intermediate image f(equation (12)-(14))
        [f_new_vec, sigma] = update_f2d( f_new_vec,g,alpha,beta,v_vec,bv_vec,...
            bu_vec,u_vec,M,MT,grad,gradT,L,tol);

       
        if(find(isnan(f_new_vec(:)) == 1))
            flag = 1;
            f_new_vec = zeros(R,C);
            error('Optimize_f returned NaN')            
        end
        
        % Gradient for TV denoising
        gradient = cell(1,directions);
        %Anisotropic TV denoising
        for pos = 1:directions        
            gradient{pos} = getGradient(f_new_vec,grad,gradT,pos);
            % equation (17)
            v_vec{pos} = updateAux(gradient{pos},bv_vec{pos},mu,beta);
            % update bregman variable bv of the TV (equation (19) )
            bv_vec{pos} = updateBreg(bv_vec{pos},gradient{pos},v_vec{pos});
        end
          
        %part for the quasi prior
        if lambda > 0
            %update the auxiliary variable u (equation (16)) and the
            
            u_vec = updateAux( M*f_new_vec,bu_vec,lambda,alpha);
            %bregman variable bu (equation (18))
            bu_vec = updateBreg( bu_vec,M*f_new_vec,u_vec);
        end
    
        if nargout > 1
            % Compute energy function            
            E = [E; calculateEnergyFunction2d(f_new_vec, g, gradient, 1.345*sigma, mu, lambda, patchsize, p)];
        end
            
    end
        
    if(flag == 1)
        break;
    end
    
    %compute the difference between the intermediate image and the
    %image from the previous iteration step 
    %return is difference is small
    if norm(f_old_vec - f_new_vec) / norm(f_old_vec) < tol 
        f = vectorToMatrix(f_new_vec,R,C);
        return;
    end
    
end

f = vectorToMatrix(f_new_vec,R,C);