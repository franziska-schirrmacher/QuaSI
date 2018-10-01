function  runEvaluation(inputDir,resultDir,resultName,mode,lambda,mu,omega,alpha,beta,gamma,tol,T_outer,T_inner,patchsize,p,numScans)



 if strcmp(mode,'2d')
     g = readImages(inputDir);
 elseif strcmp(mode,'3d') || strcmp(mode,'3dt')
     g = readVolumes(inputDir,numScans);
 else
    error("Invalid mode")
 end


[f] = feval(sprintf('admm%s',mode),g,lambda,mu,omega,alpha,beta,gamma,tol,T_outer,T_inner,patchsize,p);

if ~exist([resultDir,'/',resultName],'file')
    save(fullfile(resultDir,resultName),'f');
else
    fprintf('File %s already exists \n',fullfile(resultDir,resultName));
end
end

