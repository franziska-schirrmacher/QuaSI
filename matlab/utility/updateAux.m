function [auxUpdated] = updateAux(prior, bregVariable,weight,lagragianWeight)
    % Update the auxiliary variables
    auxUpdated = zeros(size(prior));
    
    if (lagragianWeight ~= 0)
        auxUpdated = shrink(prior+bregVariable,(weight/lagragianWeight));
    end

end

