% mode can be '2d', '3d' or '3dt'
mode = '2d';

%parameter TV
mu = 0.075;
beta = 1.5;

%parameter QuaSI
lambda = 5;
alpha = 100;
patchsize = 3;
p = 0.5;

%parameter TV-t
omega = 0;
gamma = 0;

%termination tolerance
tol = 0.001;

%number of iterations
T_outer = 20;
T_inner = 2;

%number of scans that are considered in the volumes 
%(for numScans = 5, the first 5 scans of the volume are considered)
%please change readVolumes.m in the utility folder, if you want to read
%specific scans of a volume.
numScans = 1;