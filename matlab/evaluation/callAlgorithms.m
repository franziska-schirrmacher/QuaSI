function [ denoisedImage ] = CallAlgorithms( noisyImages, algorithm, varargin )

numberImages = size(noisyImages,3);

switch algorithm
    case 'noisy'
        % We simply return the noisy input image (in case of image
        % sequence, we take the first frame) for evaluation purposes.
        f = noisyImages(:,:,1);
       
    case 'avg'
        % We simply compute the mean of the given input sequence as a
        % baseline approach.
        f = mean(noisyImages, 3);
        
    case 'bed'
        % Bayesian Estimation Denoising from the Image Denoising Archive.
        % Since this method can only handle single images, we apply the
        % denoising to the average image of the given input sequence.
        f = bayesEstimateDenoise(mean(noisyImages, 3));
        
    case 'wmf'
        f = waveletMultiFrame(noisyImages, 'weightMode', 4);
	
	case 'msbtd'
		averageImage = varargin{1};
		f = farisu(255*mean(noisyImages, 3), 255*averageImage);
    
    case 'bm3d'
        [~, f] = BM3D(mean(noisyImages,3), mean(noisyImages,3), 25, 'np', 0);
        
    case 'tv'
        [f, ~] = admm2d(noisyImages, ...
            numberImages * 0.075, ...   % Regularization weight of TV
            0, ...                      % Regularization weight of quantil
            0, ...                      % Regularization for aux. var. of the quantil
            numberImages * 1.5, ...     % Regularization for aux. var. of TV
            0.001,...                   % Termination tolerance
            20, 2, ...                  % Max. outer/inner iterations
            3, 0.5);                  % Quantil parameters (patch size / quantil)
        
    case 'quasi'
        [f, ~] = admm2d(noisyImages, ...
            numberImages * 0.075, ...   % Regularization weight of TV
            numberImages * 5.0, ...     % Regularization weight of quantil
            numberImages * 100.0, ...   % Regularization for aux. var. of the quantil
            numberImages * 1.5, ...     % Regularization for aux. var. of TV
            0.001,...             		% Termination tolerance
            20, 2, ...                % Max. outer/inner iterations
            3, 0.5);                  % Quantil parameters (patch size / quantil)
        
end

denoisedImage = f;