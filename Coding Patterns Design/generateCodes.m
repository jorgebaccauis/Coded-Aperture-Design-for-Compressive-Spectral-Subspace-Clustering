%--------------------------------------------------------------------------
% Copyright @ Carlos Hinojosa, 2018
%--------------------------------------------------------------------------
function [Phi] = generateCodes(L,shots,delta,designed)


%% Generate the Optimal designed codes
if designed == 1
    eigM = inf;
    for ix=1:10
        temp = optimalCodingPatterns(shots,L,delta);
        [~,S,~] = svd(temp);
        eigdd = S(1,1)/S(rank(temp),rank(temp));
        if (eigdd < eigM)
            Phi = temp;
            eigM = eigdd;
        end
    end
else
    %% Generate random codes
    eigM = inf;
    for ix=1:10
        temp=double(rand(shots,L)<(delta/L));
        [~,S,~] = svd(temp);
        eigdd = S(1,1)/S(rank(temp),rank(temp));
        if (eigdd < eigM)
            Phi = temp;
            eigM = eigdd;
        end
    end
    
end


end
