function rstl = evaluate_results(labs_est, labs)
% Evaluate Classification Results
%
% Syntax:
%       [kappa acc acc_O acc_A] = evaluate_results(tlabs, Trlabs)
%
% Input:
%       labs_est:  M-by-1 vector of labels given to test data
%       labs    : M-by-1 vector of ground truth labels
%
% Output:
%       kappa:  kappa coefficient
%       acc:    accuracy per class
%       acc_o:  overall accuracy
%       acc_a:  average accuracy
% 


%c = max(labs) - min(labs) + 1;

nc = unique(labs);
nc(nc==0)=[];
c = length(nc);
% make confusion matrix

CM = zeros(c,c);

for i = 1:c
    for j = 1:c
        CM(i,j) = sum(labs_est==nc(i) & labs==nc(j));
    end
end

% Class accuracy
acc = zeros(c, 1);
for j = 1:c
    acc(j) = CM(j,j)/sum(CM(:,j));
end

% Overall and average accuracy
acc_o = sum(diag(CM))/sum(sum(CM));
acc_a = mean( acc );

% Kappa coefficient of agreement
kappa = (acc_o - sum( sum(CM,1)*sum(CM,2) )/sum(sum(CM)).^2)...
           /(1 - sum( sum(CM,1)*sum(CM,2) )/sum(sum(CM)).^2);
rstl.acc   = acc;
rstl.acc_o = acc_o;
rstl.acc_a = acc_a;
rstl.kappa = kappa;

