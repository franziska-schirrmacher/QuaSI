
% transforms the input volume into a vector.
% inputs:
%   volume -> the volume to write into a vector
% outputs:
%   vector -> the volume as vector
function [ vector ] = volumeStreamToVector(volumeStream)

% get the number of volumes
numberOfVolumes = numel(volumeStream);
%numberOfVolumes = numberOfVolumes(2);
% get the dimensions of the input volume
dimensions = size(volumeStream{1});

% initialize the vector
vector = zeros(numberOfVolumes(1)*dimensions(1)*dimensions(2)*dimensions(3),1);

for i=1:numberOfVolumes
    % get the current volume
    volume = volumeStream{i};
    % change the dimensions of the volume x->x y->z z->y
    volume = permute(volume, [1,3,2]);
    % reshape the volume into a matrix in z direction
    matrix = reshape(volume, [dimensions(1)*dimensions(3), dimensions(2), 1]);
    % reshape the matrix into a vector in a row-wise manner
    subVector = reshape(transpose(matrix),[numel(matrix),1]);
    % write the subvector to the output vector
    startPos = ((i-1)*dimensions(1)*dimensions(2)*dimensions(3))+1;
    endPos = i*dimensions(1)*dimensions(2)*dimensions(3);
    vector(startPos:endPos) = subVector;
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
