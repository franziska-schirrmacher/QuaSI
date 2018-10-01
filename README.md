# Temporal and Volumetric Denoising via Quantile Sparse Image Prior

Official implementation of **Temporal and Volumetric Denoising via Quantile Sparse Image Prior** including evaluation scripts.

## Getting started

### Store your data
First, store all your images or volumes in the data folder. 

### Set the parameter
If you wish to adjust the parameter, modify the init files. 

### Start your evaluation
State the input and ouput folders in the evaluation scripts as well as the name of the output file. You can adjust the mode of the framework 

* '2d' : denotes image denoising
* '3d' : denotes volumetric denoising
* '3dt': denotes volumetric+temporal denoising


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