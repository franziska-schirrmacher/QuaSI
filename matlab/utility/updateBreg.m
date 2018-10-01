function [bregNew] = updateBreg(bregOld,prior,auxVariable)
   % update the bregman variables
    bregNew = bregOld + (prior - auxVariable);
end

