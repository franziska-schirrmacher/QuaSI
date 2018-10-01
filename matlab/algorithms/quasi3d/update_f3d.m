
% Update the denoised image f by solving the linear system of equations (see equation (4))
% inputs:
%   f_old_vec -> the vectorized volume from the previous iteration step
%   g -> the noisy volume
%   alpha -> lagragian multiplier for the QuaSI term
%   beta -> lagragian multiplier for the TV term in x,y,z direction
%   gamma -> lagragian multiplier for the TV term in t direction
%   v_vec -> auxiliary variable related to the total variation term in x,y,z direction
%   bv_vec -> bregman variable related to the total variation term in x,y,z direction
%   b_t_vec -> bregman variable related to the total variation term in t direction
%   d_t_vec -> auxilary variable related to the total variation term in t direction
%   bu_vec -> bregman variable related to the QuaSI term
%   u_vec -> auxiliary variable related to the QuaSI term
%   M -> I*Q identity matrix times median positions in matrix form
%   MT -> (I*Q)^T identity matrix times median positions in matrix form, transposed
%   grad_XYZ -> list storing the matrices for gradient computation in x,y,z direction
%   gradT_XYZ -> list storing the matrices for gradient computation, transposed in x,y,z direction
%   grad_T -> the matrix for gradient computation in t direction
%   gradT_T -> the matrix for gradient computation, transposed in t direction
%   L_XYZ -> matrix for laplacian computation in x,y,z direction
%   L_T -> matrix for laplacian computation in t direction
%   tol -> threshold to end the iterations if the change between iterations has become small
% outputs:
%   f_new_vec -> the result of the current iteration step
%   sigma -> something, related to the Huber Loss (not used in toplevel function...)

function [f_new_vec, sigma] = update_f3d( f_old_vec,g,alpha,beta,v_vec,bv_vec,bu_vec,u_vec,...
    M,MT,grad_XYZ,gradT_XYZ,L_XYZ,numberOfVolumes,tol)

% Assemble right hand side of the equation system.
% (without beta and gamma) ... grad^T(v-bv) + grad^t(b_{t}-d_{t})
% Part for TV denoising in x,y,z direction
[~,directions] = size(v_vec);
[R,C,Z] = size(v_vec{1});
TVpart_XYZ = zeros(R*C*Z,1);
% calculate the gradient part for x,y,z direction -> grad^T(v-bv)
for pos = 1: directions
    TVpart_XYZ = TVpart_XYZ + getGradient((bv_vec{pos} - v_vec{pos}), grad_XYZ, gradT_XYZ, pos, 'backward');
end
% Part for TV denoising in t direction
% add the gradient part for t direction -> grad^t(b_{t}-d_{t})
b =  beta * TVpart_XYZ - alpha * MT * (bu_vec - u_vec);

w_res = zeros(size(f_old_vec,1),numberOfVolumes);
for vol = 1:numberOfVolumes
    startPos = (vol-1)*C*R*Z + 1;
    endPos = vol*C*R*Z;
    % Determine residual error. f-g
    r = f_old_vec - g(startPos:endPos);
    % build the weight matrix W^k according to the Huber loss
    if (all(r(:) == 0))
        % No adaptive noise estimation.
        sigma = Inf;
        w = ones(size(r));
    else
        % Adpative noise estimation.
        sigma = 1.4826 * mad(r(:), 1);      % mad() -> returns the mean absolute deviation
        % Compute confidence weights according to the Huber loss.
        % Set threshold to 95-percent efficiency
        w = (1.345*sigma) ./ abs(r);
        w(abs(r) <= 1.345*sigma) = 1;
    end
    w_res(:,vol) = w;
    b = b + 2*w.*g(startPos:endPos);   
    
end

% Put both parts together to get the right hand side of the equation.
% sum(W*g) + alpha*(I-Q)*(u-bu) + beta*grad^T(v-bv)
% !!!BEWARE!!! signs in the paper and implementation are not consistent but lead to the essentialy same equation

% Assemble matrix (implemented via imfilter)
% build up the left side of the equation
Af = @(f_new_vec)cgCall3d( f_new_vec, w_res, alpha, beta, M, MT, L_XYZ);

% Solve A * f_new = b
[f_new_vec, ~, ~, ~, E] = cgs(Af, b, ...
    tol, 5, [], [],...
    f_old_vec);

end






















