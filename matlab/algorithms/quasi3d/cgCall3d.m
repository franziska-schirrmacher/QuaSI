
% builds the system of equations for the MATLAB solver
% inputs:
%   f_new -> the volume in vector from
%   w -> weight matrix calculated according to the Huber Loss
%   alpha -> lagragian multiplier for the QuaSI term
%   beta -> lagragian multiplier for the TV term
%   M -> I*Q identity matrix times median positions in matrix form
%   MT -> (I*Q)^T identity matrix times median positions in matrix form, transposed
%   L_XYZ -> matrix for laplacian computation in x,y,z direction
%   L_T -> matrix for laplacian computation in t direction

function [ result ] = cgCall3d( f_new_vec, w, alpha, beta, M, MT, L_XYZ)

    result = beta .* getLaplacian(f_new_vec,L_XYZ) ... % Total variation in x,y,z direction
        + alpha .* MT * M * f_new_vec;              % Dark channel

    numberOfVolumes = size(w,2);
    for vol = 1:numberOfVolumes    
        result = result + 2*w(:,vol).*f_new_vec;        
    end


