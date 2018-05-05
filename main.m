%--------------------------------------------------------------------------
% Copyright @ Carlos Hinojosa, 2018
%--------------------------------------------------------------------------
%% Clear Screen and Workspace
clear all
close all
clc

verbose = true;

%% Add Hyperspectral databases to the path
addpath('./DataBases');

%% Select and load the database
Fname =  'UPavia_Subset';
database = 'UPavia_Subset';
fprintf(['Experiment start at: ',datestr(datetime('now')),'\n'])
fprintf('=======================================================\n');
fprintf('Loading hyperspectral datacue and preparing data \n');
fprintf('=======================================================\n');
load(database);

hyperimg = paviaU; %Set Hyperspectral image
hyperimg_gt = paviaU_gt; %Set Hyperspectral image groundtruth

%if verbose true show Fig 7

[M,N,L]=size(hyperimg);
s = hyperimg_gt(:);

%% Reshape the data cube to LxMN matrix
Xfull=reshape(hyperimg,M*N,L);
Xfull=Xfull';

%% Set coded aperture design parameters

shots =25;    %Measurement shots
delta = 10;   %Bandpass filters bandwidth
designed = 1; % 1 = Use designed codes, 0 = use random codes
noise = 25;   % Noise added

%% Sparse Subspace Clustering parameters

l = 8;% number of clusters

% Original SSC parameters
alpha = [1000,300];
r = 0; % data projection
affine = true; % affine constraint
outlier = false; % data has outlier
rho = 0.7;
la = 7.76e-7; % sparsity/noise tradeoff

% Spatial information regularization parameter
alphass = 8500;

%% Compressive Spectral Imaging (CSI) acquisition
fprintf('Acquiring compressed measurements \n');
fprintf('=======================================================\n');

Phi = generateCodes(L,shots,delta,designed);

% Acquire the compressed measurements
X = Phi*Xfull;
%if verbose true show compressed data

% Add noise to the measurements
if noise>0
    X = awgn(X,noise,'measured');
end

% Data normalization
X = X.*sqrt(delta/shots);

%% Compressed Sparse Subspace Clustering With Spatial Regularizer
[results,C,img] = CSI_SSC(X,r,affine,alpha,outlier,rho,s,l,la,alphass,M,N,Fname);

% Recolecting results
Res = {results, img};
parameters = {shots,delta,noise,l,alpha,rho,la,alphass};
results{iter}={Res,Phi,parameters};

fprintf(['Experiment ends at: ',datestr(datetime('now')),'\n'])
fprintf('=======================================================\n');