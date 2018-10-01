function [g] = readVolumes(inputDir,numScans)
    directoryNames = dir(inputDir);
    files = {directoryNames(~[directoryNames.isdir]).name};
    
    g = cell(numel(files,1));
    
    for vol = 1:numel(files)
            tmp = im2double(imread(fullfile(inputDir,files{vol}),1));
            [R,C,~] = size(tmp);
            img = zeros(R,C,numScans);
        for scan = 2:numScans
            img(:,:,scan) = im2double(imread(fullfile(inputDir,files{vol}),scan));
        end
        g{vol} = img;
    end
    
end

