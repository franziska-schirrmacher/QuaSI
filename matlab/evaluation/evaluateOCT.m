addpath(genpath('../algorithms'))
addpath(genpath('../utility'))

inputDir = '../../data/OCT';
resultDir = '../../results/OCT';
resultName = 'result.mat';

initEvaluationParameterForOCT;

runEvaluation(inputDir,resultDir,resultName,mode,lambda,mu,omega,alpha,beta,gamma,tol,T_outer,T_inner,patchsize,p,numScans)
