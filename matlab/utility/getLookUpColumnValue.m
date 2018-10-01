
% finds the position of the median value within the vectorized volume
% inputs:
%   patch -> a patch, extracted from the volume
%   colPos -> the column position of the central patch pixel within the volume
%   rowPos -> the row position of the central patch pixel within the volume
%   zPos -> the slice position of the central patch pixel within the volume
%   colSize -> the size of the columns in the volume
%   rowSize -> the size of the rows in the volume
% outputs:
%   LookUpColumnValue -> the position of the median in the vectorized volume

function [patchRowPos,patchColPos,patchZPos] = getLookUpColumnValue( patch,p, colPos, rowPos, zPos, colSize, rowSize)
    
    % get the size of the patch
    [sC, sR, sZ] = size(patch);

    % get the position of the central pixel in the patch
    colPos = colPos - floor(sC / 2);
    rowPos = rowPos - floor(sR / 2);
    zPos = zPos - floor(sZ / 2);
    
    % find the position of the median value in the patch
    % for volumes, the MATLAB find function returns the position as a single value...
  
    %myMedianValue = medianEdited(patch(:)); 
    myMedianValue = getMedian(patch,p);

%     if myMedianValue ~= myMedianValue_1
%         test =  'false';
%     end
    myMedianPos = find(patch == myMedianValue);
    tmp = myMedianPos;
    myMedianPos = myMedianPos(1);
    
    % ... so we need to recalculate the row, col and slice position of the median
   
    patchRowPos = mod(myMedianPos - 1, sC) + 1;
    patchColPos = floor(mod(myMedianPos - 1, sC * sR) / sC) + 1;
    patchZPos = floor((myMedianPos - 1) / (sC * sR)) + 1;
    
    % compute the position of the median in the vectorized volume


