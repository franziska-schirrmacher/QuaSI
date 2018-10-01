function [g] = readImages(inputDir)
    directoryNames = dir(inputDir);
    files = {directoryNames(~[directoryNames.isdir]).name};

  
    if ~isempty(files)
        img = im2double(imread(fullfile(inputDir,files{1})));
    end
    
    [R,C,~] = size(img);
    if ~ismatrix(img)
         error("Algorithm expects grayscale images")
    end
    
    g = zeros(R,C,numel(files));
    g(:,:,1) = img;
    
    for i = 2:numel(files)
        g(:,:,2) = im2double(imread(fullfile(inputDir,files{i})));
    end

end

