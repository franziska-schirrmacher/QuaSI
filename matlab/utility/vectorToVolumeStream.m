
% transforms the input volume into a vector.
% inputs:
%   volume -> the volume to write into a vector
% outputs:
%   vector -> the volume as vector
function [ volumeStream ] = vectorToVolumeStream(vector, numberOfVolumes, C, R, Z)

volumeStream = cell(1,1);

for i=1:numberOfVolumes
    startPos = ((i-1)*R*C*Z)+1;
    endPos = i*R*C*Z;
    subVector = vector(startPos:endPos);
    %volume = reshape(subVector, R, C, Z);
    volume = reshape(subVector, C, R, Z);
    volume = permute(volume, [2,1,3]);
    volumeStream{i} = volume;
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
