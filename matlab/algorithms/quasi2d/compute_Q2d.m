function [ LookUpRow,LookUpColumn] = compute_Q2d( image,patchsize,p)
% compute the look-up table Q to approximate the quantile filter

%% Initialization
% convert image range from [0,1] to [0,255] (is necessary for the joint histogram)
% as the image value is not important but only the position of the median
% this convertation does not affect the rest of the algorithm
image = double(image);
[R,C] = size(image);
%initialise the look-up table (remember position)
LookUpRow = zeros(R*C,1);
LookUpColumn = zeros(R*C,1);

%verfiy patchsize
if(~mod(patchsize,2))
    error('Invalid patchsize: Number must be odd');
end

halfpatch = floor(patchsize/2);

%% core implementation
i = 1;
%walk over the resulting image, r and c are on the upper left corner of the
%patch and not the center pixel
for r = 1:R   
    for c = 1:C
        
        %Get the current neighbourhood               
		rMin = max(1, r-halfpatch);
        rMax = min(R, r+halfpatch);
        cMin = max(1, c-halfpatch);
        cMax = min(C, c+halfpatch);

        % get the current patch
        patch = image(rMin:rMax, cMin:cMax);
				
        %%Compute the median of the neighbourhood
        pos = round(p*(numel(patch)));
        value = nth_element(patch(:), pos);
        value = value(pos);

        
        %% find the position of the median in the current patch
        [row,column] = find(patch == value);

        % Median is not found in the patch
        % take the value closest to the median
        if(isempty(row))
            [~,index] = min(abs(patch(:) - value));
            value = patch(index);
            [row,column] = find(patch == value);
        end
        
        %% create the LookUp table
        if(length(row) > 1)
            %median appears multiple times in the patch
            row_curr = rMin + (row-1);
            column_curr = cMin + (column-1);
            
            index = 1;
            %make sure the median is not in the padded boundary we
            %added
            while(row_curr(index,1) <= 0 || column_curr(index,1) <= 0)
                index = index + 1;
            end
            
            row = row_curr(index,1);
            column = column_curr(index,1);
        else                      
			row = rMin + (row-1);
			column = cMin + (column-1);
        end
		
        %save position of the median in the lookUp table
        LookUpRow(i,1) = i;
        LookUpColumn(i,1) = C*(row-1) + column;
        i = i + 1;
    end
end
end


