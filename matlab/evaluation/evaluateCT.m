addpath(genpath('../algorithms'))
addpath(genpath('../utility'))

inputDir = '../../data/CT/';
resultDir = '../../results/CT/';
resultName = 'result.mat';

initEvaluationParameterForCT;

runEvaluation(inputDir,resultDir,resultName,mode,lambda,mu,omega,alpha,beta,gamma,tol,T_outer,T_inner,patchsize,p,numScans)
