
% compute the look-up table Q (of the median values) to approximate the quantile filter
% inputs:
%   volume -> the volume to calculate the lookup table for
%   patchsize -> the patch size of the median filter
% outputs:
%   lookUpRow -> the rows for generating the sparse lookup matrix
%   lookUpColumn -> the columns for generating the sparse lookup matrix

function [lookUpRow,lookUpColumn] = compute_Q3dt(volume, patchsize,p)

    % get the size of the volume
    [R,C,Z] = size(volume);
    % initialise the look-up table row and column (remember position)
    lookUpRow = zeros(C*R*Z,1);
    lookUpColumn = zeros(C*R*Z,1);
    % half of the patch size to caculate the center
    halfpatch = floor(patchsize/2);

    iterationCounter = 1;
    for z=1:Z        
       for r=1:R
            for c=1:C 
                % get the start and end position of the patch
                rMin = max(1, r-halfpatch);
                rMax = min(R, r+halfpatch);
                cMin = max(1, c-halfpatch);
                cMax = min(C, c+halfpatch);
                zMin = max(1, z-halfpatch);
                zMax = min(Z, z+halfpatch);
                % get the current patch
                patch = volume(rMin:rMax, cMin:cMax, zMin:zMax);
                % save position of the median in the image

                
                lookUpRow(iterationCounter,1) = iterationCounter;       % saves the 'up->down' position in the matrix
                [patchRowPos,patchColPos,patchZPos] = getLookUpColumnValue(patch,p, c, r, z, C, R);
                
                row = rMin + patchRowPos-1;
                col = cMin + patchColPos-1;
                slice = zMin + patchZPos-1;
                
                lookUpColumn(iterationCounter,1) = (slice-1)*(R*C) + (row-1)*C + col;   % saves the 'left->right' position in the matrix
                iterationCounter = iterationCounter + 1;
				
            end
        end
    end
end

