%--------------------------------------------------------------------------
% This is the function to call the sparse optimization program, to call the 
% spectral clustering algorithm and to compute the clustering error.
% r = projection dimension, if r = 0, then no projection
% affine = use the affine constraint if true
% s = clustering ground-truth
% results = clustering results
% CMat = coefficient matrix obtained by SSC
% W = weighted matrix
%--------------------------------------------------------------------------
% Copyright @ Carlos Hinojosa, 2018
%--------------------------------------------------------------------------

function [results,CMat,img,time1,time2] = CSI_SSC(X,r,affine,alpha,outlier,rho,s,l,lambda,alphass,M,N,Fname,arch)

if (nargin < 6)
    rho = 1;
end
if (nargin < 5)
    outlier = false;
end
if (nargin < 4)
    alpha = 20;
end
if (nargin < 3)
    affine = false;
end
if (nargin < 2)
    r = 0;
end


n = l;

%% Select ADMM Function
    switch(arch)
        case 1
            admm_func = @admmLasso_mat_func_CSI_SSC_GPU;
        case 2
            admm_func = @admmLasso_mat_func_CSI_SSC_GPU_Double;
        case 3
            admm_func = @admmLasso_mat_func_CSI_SSC_CPU;
    end


%% Optimization Program Parameters
Xp = DataProjection(X,r);
thr = [2*10^-4,4*10^-4];
maxIter = 100; 

%% Run Optimization Program
tic
if (~outlier)
    
    CMat = admm_func(Xp,affine,alpha,thr,maxIter,lambda,alphass,M,N);
    C = CMat;
else
    error("Function for Outliers not implemented");
end

%% Normalization of C Columns
% Uncomment to normalize C columns
% for i=1:length(C)
% C(:,i)=C(:,i)/max(C(:,i));
% end

%% Spectral Clustering
C=gather(C);
CKSym = BuildAdjacency(thrC(C,rho));
time1 = toc;
tic;
grps = SpectralClustering(CKSym,n);
time2 = toc;
grps = bestMap(s,grps);

crV=[];
u1= unique(s);
u1(1)=[];
u2 = unique(grps);

for ii =1:length(u1)
    if ~ismember(u1(ii),u2)
        crV = u1(ii);
        break;
    end
end

if ~isempty(crV)
grps(grps==0)=crV;
end

results = evaluate_results(grps,s);

%% Draw the Results as in the paper
[ img ] = drawResults(Fname,grps,crV,M,N);

%% Save Results
save(['Results/',Fname,'/result_CSISC_alphass:',num2str(alphass),'_oacc:',num2str(results.acc_o),'.mat'],'results','C','CKSym','grps','img','alphass','alpha','n','M','N');
end