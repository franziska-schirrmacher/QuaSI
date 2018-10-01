
% functions computes the gradient of the vectorized volume f 
% the variable grad stores all the gradient matrices computed in admm.m
% the variable gradT stores the transposed matrices
% pos is the current gradient direction 
% dir determines whether grad or gradT is used
% inputs:
%   f_vec -> the vectorized volume
%   grad -> list storing the matrices for gradient computation
%   gradT -> list storing the matrices for gradient computation, transposed
%   pos -> the position of the current gradient matrix in the list
%   dir -> the direction for the gradient computation ('forward', 'backward')
% outputs:
%   g -> the gradient of the volume in vector form

function [g] = getGradient(f_vec,grad,gradT,pos, dir)

    if nargin < 5
        dir = 'forward';
    end

    if strcmp(dir, 'forward')  
        
    g = grad{pos}*f_vec;   
    
    elseif strcmp(dir, 'backward')      
        
        g = gradT{pos}*f_vec;  
    
    end
