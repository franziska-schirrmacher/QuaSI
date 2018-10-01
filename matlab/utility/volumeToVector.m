
% transforms the input volume into a vector.
% inputs:
%   volume -> the volume to write into a vector
% outputs:
%   vector -> the volume as vector

function [ vector ] = volumeToVector(volume)

vector = 0;

% get the dimensions of the input volume
dimensions = size(volume);
numberOfDimensions = size(dimensions);

if numberOfDimensions(2) == 3
    % change the dimensions of the volume x->x y->z z->y
    volume = permute(volume, [1,3,2]);
    % reshape the volume into a matrix in z direction
    matrix = reshape(volume, [dimensions(1)*dimensions(3), dimensions(2), 1]);
    % reshape the matrix into a vector in a row-wise manner
    vector = reshape(transpose(matrix),[numel(matrix),1]);
end

if numberOfDimensions(2) == 2
    vector = matrixToVector(volume);
end

end
%                       [1]
%                       [2]
%   /[5,6]              [3]
%  / [7,8]      ->      [4]
% [1,2] /       ->      [5]
% [3,4]/                [6]
%                       [7]
%                       [8]
