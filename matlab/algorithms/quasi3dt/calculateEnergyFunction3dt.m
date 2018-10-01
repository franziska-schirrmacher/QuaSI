function E = calculateEnergyFunction3dt(f, g, gradient, gradient_t, sigma, mu, lambda, omega, patchsize,p, C, R, Z, numberOfVolumes)

    % Calculate data fidelity term.
    r = f - g;
    E_data = sum( huber(r, sigma) );
    
    % Calculate TV regularization term for the x,y,z direction.
    E_tv_xyz = 0;
    for pos = 1:length(gradient)
        E_tv_xyz = E_tv_xyz + sum( abs(gradient{pos}) );
    end
    
    % Calculate TV regularization term for the t direction.
    E_tv_t = sum( abs(gradient_t) );
    
    % Calculate QuaSI regularization term.
    lookUpRow = zeros(C*R*Z*numberOfVolumes,1);
    lookUpColumn = zeros(C*R*Z*numberOfVolumes,1);
    currentVolumes = vectorToVolumeStream(f,numberOfVolumes,C,R,Z);
    %for current=1:size(currentVolumes)
    for current=1:numberOfVolumes
        [currentLookUpRow,currentLookUpColumn] = compute_Q3dt(currentVolumes{current}, patchsize,p);
        startPos = (current-1)*C*R*Z + 1;
        endPos = current*C*R*Z;
        currentLookUpRow = currentLookUpRow + (startPos-1);
        currentLookUpColumn = currentLookUpColumn + (startPos-1);
        lookUpRow(startPos:endPos) = currentLookUpRow;
        lookUpColumn(startPos:endPos) = currentLookUpColumn;
    end
    M = speye(numel(f), numel(f)) - sparse(lookUpRow,lookUpColumn,1,numel(f),numel(f));
    E_quasi = sum( abs(M * f) );
    
    % Overall energy function.
    E_tv_xyz = mu*E_tv_xyz;
    E_quasi = lambda*E_quasi;
    E_tv_t = omega*E_tv_t;
    E_ges = E_data + E_tv_xyz + E_quasi + E_tv_t;
    
    E = [E_data, E_tv_xyz, E_tv_t, E_quasi, E_ges];
    
function h = huber(x, sigma)

    h = 1/2 * x.^2;
    h(abs(x) > sigma) = sigma * (abs( x(abs(x) > sigma) ) - 1/2*sigma);