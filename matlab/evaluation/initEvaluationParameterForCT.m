% mode can be '2d', '3d' or '3dt'
mode = '3d';

%parameter TV
mu = 0.005;
beta = 0.1;

%parameterQuaSI
lambda = 0.0005;
alpha = 0.1;
patchsize = 3;
p = 0.5;

%parameter TV-t
omega = 0.8;
gamma = 90;

%termination tolerance
tol = 0.001;

%number of iterations
T_outer = 20;
T_inner = 2;

%number of scans that are considered in the volumes 
%(for numScans = 5, the first 5 scans of the volume are considered)
%please change readVolumes.m in the utility folder, if you want to read
%specific scans of a volume.
numScans = 5;



