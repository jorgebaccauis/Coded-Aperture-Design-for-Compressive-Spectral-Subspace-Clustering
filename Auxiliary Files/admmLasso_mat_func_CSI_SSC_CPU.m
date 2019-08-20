%--------------------------------------------------------------------------
% This function takes a DxN matrix of N data points in a D-dimensional
% space and returns a NxN coefficient matrix of the sparse representation
% of each data point in terms of the rest of the points
% Y: DxN data matrix
% affine: if true then enforce the affine constraint
% thr1: stopping threshold for the coefficient error ||Z-C||
% thr2: stopping threshold for the linear system error ||Y-YZ||
% maxIter: maximum number of iterations of ADMM
% lambda: sparsity/noise trade off
% alphass: spectral/spatial trade off
% C2: NxN sparse coefficient matrix
% W: Weighted Matrix
%--------------------------------------------------------------------------
% Copyright @ Carlos Hinojosa, 2018
%--------------------------------------------------------------------------

function C2 = admmLasso_mat_func_CSI_SSC(Y,affine,alpha,thr,maxIter,lambda,alphass,Md,Nd)

if (nargin < 2)
    % default subspaces are linear
    affine = false;
end
if (nargin < 3)
    % default regularizarion parameters
    alpha = 800;
end
if (nargin < 4)
    % default coefficient error threshold to stop ADMM
    % default linear system error threshold to stop ADMM
    thr = 2*10^-4;
end
if (nargin < 5)
    % default maximum number of iterations of ADMM
    maxIter = 100;
end

if (nargin < 6)
    lambda = 7.76e-7;
end
if (nargin < 7)
    alphass = 0.13;
end

if (length(alpha) == 1)
    alpha1 = alpha(1);
    alpha2 = alpha(1);
elseif (length(alpha) == 2)
    alpha1 = alpha(1);
    alpha2 = alpha(2);
end

if (length(thr) == 1)
    thr1 = thr(1);
    thr2 = thr(1);
elseif (length(thr) == 2)
    thr1 = thr(1);
    thr2 = thr(2);
end

N = size(Y,2);

% setting penalty parameters for the ADMM
mu1 = alpha1 * 1/computeLambda_mat(Y); %lambda in equation 19
%mu1 = lambda;
mu2 = alpha2 * alphass; %alpha in the equation 19
mu3 = alpha2 * 1; % rho in equation 19 (rho=1000)


if (~affine)
    % this part was no modified from the original ssc code
    % initialization
    A = inv(mu1*(Y'*Y)+mu2*eye(N));
    C1 = zeros(N,N);
    Lambda2 = zeros(N,N);
    err1 = 10*thr1; err2 = 10*thr2;
    i = 1;
    % ADMM iterations
    while ( err1(i) > thr1 && i < maxIter )
        % updating Z
        Z = A * (mu1*(Y'*Y)+mu2*(C1-Lambda2/mu2));
        Z = Z - diag(diag(Z));
        % updating C
        C2 = max(0,(abs(Z+Lambda2/mu2) - 1/mu2*ones(N))) .* sign(Z+Lambda2/mu2);
        C2 = C2 - diag(diag(C2));
        % updating Lagrange multipliers
        Lambda2 = Lambda2 + mu2 * (Z - C2);
        % computing errors
        err1(i+1) = errorCoef(Z,C2);
        err2(i+1) = errorLinSys(Y,Z);
        %
        C1 = C2;
        i = i + 1;
    end
    fprintf('err1: %2.4f, err2: %2.4f, iter: %3.0f \n',err1(end),err2(end),i);
else
    
    %Affine = true
    % initialization
    
    %Set Erros
    err1 = 10*thr1; err2 = 10*thr2; err3 = 10*thr1;
    

    Q = inv(mu1*(Y'*Y)+mu2*eye(N)+mu3*eye(N)+mu3*ones(N,N));
    C1 = zeros(N,N); % C^k
    C_average = zeros(N,N); %\bar{C}k^k
    Lambda2 = zeros(N,N); % Delta^k
    lambda3 = zeros(1,N); % delta^kT

    
    i = 1;
    % ADMM iterations
    while ( (err1(i) > thr1 || err3(i) > thr1) && i < maxIter )
        % updating Z
        tic
        A = Q * (mu1*(Y'*Y) + mu2*C_average + mu3*(C1-Lambda2/mu3)+mu3*ones(N,1)*(ones(1,N)-lambda3/mu3));
        A = A - diag(diag(A));
        % updating C
        C_tmp = max(0,(abs(A+Lambda2/mu3) - 1/mu3*ones(N))) .* sign(A+Lambda2/mu3);
        %C2 = W*C_tmp;
        C2=C_tmp;
        C2 = C2 - diag(diag(C2));
        
        % update \bar{C}
        C_temp = reshape(C2,Md,Nd,N);

        C_averagetemp = medfilt3(C_temp,'symmetric');
        
        C_average = reshape(C_averagetemp,N,N);
        
        % updating Lagrange multipliers
        Lambda2 = Lambda2 + mu3 * (A - C2);
        lambda3 = lambda3 + mu3 * (ones(1,N)*A - ones(1,N));
        % computing errors
        
        err1(i+1) = errorCoef(A,C2);
        err2(i+1) = errorLinSys(Y,A);
        err3(i+1) = errorCoef(ones(1,N)*A,ones(1,N));
        %
        C1 = C2;
        toc
        i = i + 1;
        fprintf('Iteracion :%d   err1: %d err3: %d \n',i,err1(i),err3(i));
    end
    fprintf('err1: %2.4f, err2: %2.4f, err3: %2.4f, iter: %3.0f \n',err1(end),err2(end),err3(end),i);
end