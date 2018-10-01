function [ median ] = getMedian( patch,p)
%MYMEDIAN Summary of this function goes here
%   Detailed explanation goes here
    

    patch_vec = volumeToVector(patch);
    patch_vec = sort(patch_vec);
    medianPosition = size(patch_vec);
    medianPosition = ceil((medianPosition(1)+1)*p);
    median = patch_vec(ceil(medianPosition));

end

