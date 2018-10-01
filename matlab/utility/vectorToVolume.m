
% transforms the input volume into a vector.
% inputs:
%   volume -> the volume to write into a vector
% outputs:
%   vector -> the volume as vector
function [ volume ] = vectorToVolume(vector, R, C, Z)

    volume = 1;
    
    if Z > 1
        volume = reshape(vector, C, R, Z);
        volume = permute(volume, [2,1,3]);
    else
        volume = vectorToMatrix(vector, R, C);
    end

end

% [1]
% [2]
% [3]                 /[5,6] 
% [4]       ->       / [7,8]
% [5]       ->      [1,2] / 
% [6]               [3,4]/
% [7]
% [8]
