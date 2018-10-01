
% creates a matrix which yields the gradient of the volume (volume must be in
% vector form). The variable delta determines whether the gradient is
% computed in x-direction (delta = 1), in y-direction (delta = #columns of the volume)
% or z-direction (delta = #columns * #rows of the volume)

function Q = getGradientMatrix(numPixel, delta)

    % Assemble pixel positions in linearized order.
    pixelPos = 1:numPixel;
    
    % Get positions (circular) shifted by a certain number of pixels. 
    pixelPos_delta = mod(pixelPos + delta, numPixel);
    pixelPos_delta(pixelPos_delta == 0) = numPixel;
    
    % Sparse matrix with -1 on a certain diagonal. (pixelPos' is the transposed)
    % sparse(i,j,v,r,c) sets the values from v at the positions given by i and j into a matrix of size r*c 
    V = sparse(pixelPos', pixelPos_delta, -ones(1,numPixel), numPixel, numPixel);
    % Sparse identity matrix.
    I = speye(numPixel, numPixel);
    % Get overall gradient matrix.
    Q = I + V;