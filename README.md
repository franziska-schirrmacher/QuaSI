# Temporal and Volumetric Denoising via Quantile Sparse Image Prior

Official implementation of **Temporal and Volumetric Denoising via Quantile Sparse Image Prior** including evaluation scripts.

## Getting started

### Store your data
First, store all your images or volumes in the data folder. Each dataset should be stored in indivudual folders, as the framework automatically reads all images or volumes in the denoted input folder in the evaluation script.

### Set the parameters
If you wish to adjust the parameter, modify the init files. 

### Start your evaluation
State the input and ouput folders in the evaluation scripts as well as the name of the output file. You can change the mode of the framework to

* '2d' : denotes image denoising
* '3d' : denotes volumetric denoising
* '3dt': denotes volumetric+temporal denoising

If you want to evaluate the value of the objective function in each iteration step, create a new variable in runEvaluation that stores the second output of the framework (e.g. [f,E] = feval(sprintf('admm%s',mode),g,lambda,mu,omega,alpha,beta,gamma,tol,T_outer,T_inner,patchsize,p);) 

## Remarks
You might have to run the following command line in MATLAB in case you use Linux or iOS:
mex nth_element.cpp


## Citation

```
@article{SCHIRRMACHER2018131,
	title = "Temporal and volumetric denoising via quantile sparse image prior",
	journal = "Medical Image Analysis",
	volume = "48",
	pages = "131 - 146",
	year = "2018",
	issn = "1361-8415",
	doi = "https://doi.org/10.1016/j.media.2018.06.002",
	url = "http://www.sciencedirect.com/science/article/pii/S1361841518303566",
	author = "Franziska Schirrmacher and Thomas Köhler and Jürgen Endres and Tobias Lindenberger and Lennart Husvogt and James G. Fujimoto and Joachim Hornegger and Arnd Dörfler and Philip Hoelter and Andreas K. Maier",
	keywords = "Spatio-temporal denoising, Variational approach, Quasi prior, ADMM"
}
```