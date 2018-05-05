function [Phi,BPhi,J] = optimalCodingPatterns(M,N,Bmax)
%BMax es el numero de 1 que quiero en la banda
%Checks

Phi = zeros(M,N);
Bmax = 2*Bmax;%is the real Delta
%Generate first row at random

idx1 = randi(N,1);
J = zeros(Bmax*M,N);
while(~(idx1>=1 && idx1<=N-Bmax+1))
    
    idx1 = randi(N,1);
end
k=1;
BPhi = zeros(M,Bmax*M); %block diagonal structure
for jpos=idx1:idx1+Bmax-1
    vtmp = double(rand(1)<0.5);
    Phi(1,jpos)=vtmp;
    BPhi(1,k)=vtmp;
    J(k,jpos)=1;
    k=k+1;
end

for i=2:M
    
    %matrix with variance results
    varM = zeros(1,N-Bmax+1);
    for j=1:N-Bmax+1
        varM(1,j)=sum(sum(Phi(:,j:j+Bmax-1),2));
    end
    %sort in ascend order
    [~,Idx]=sort(varM);
    %group by equal values
    [~,~,ic] = unique(varM(Idx));
    %choose one position with low variance
    vtemp = find(ic==1);
    p = randperm(length(vtemp));
    p = p(1);
    pos = Idx(vtemp(p));
    
    while(~(pos>=1 && pos<=N-Bmax+1))
        p = randperm(length(vtemp));
        p = p(1);
        pos = Idx(vtemp(p));
    end
    
    %put the filter on the selected position
%     for jpos=pos:pos+Bmax-1
%         Phi(i,jpos)=double(rand(1)<0.5);
%     end
    
    %Set Weights
    w=[1 1];
    ss = zeros(1,Bmax);
    kk= 1;
    for jpos=pos:pos+Bmax-1
        if jpos>pos
            vrt = Phi(1:i,jpos-1:jpos);
        else
            vrt = Phi(1:i,jpos);
        end
        vrt = sum(vrt,2);
        vrt(i)=[];
        %horz = Phi(i,:);
        %horz(jpos)=[];
        
        %ss(kk)=w(1)*norm(vrt,1) + w(2)*norm(horz,1);
        ss(kk) = norm(vrt,1);
        kk = kk + 1;
    end
    [~,idxss] = sort(ss);
    [~,~,icss] = unique(ss(idxss));
    %choose Bmax/2 positions with low ss
    kb = 0;
    eqi = 1;
    npos =[];
    while (length(npos) <= floor(Bmax/2))
       sstemp = find(icss == eqi);
       sstemp = sstemp(randperm(length(sstemp)));
       npos = [ npos, (idxss(sstemp) + pos -1)]; 
       eqi = eqi +1;
    end
    
    Phi(i,npos(1:floor(Bmax/2)))=1;
    
    BPhi(i,k:k+Bmax-1)=Phi(i,pos:pos+Bmax-1);
    
    for ii=k:k+Bmax-1
        J(ii,pos+ii-k)=1;
    end
    k=k+Bmax;
    
    
    
%     while( kb <= floor(Bmax/2) )
%        sstemp = find(icss == eqi);
%        kb = kb + length(sstemp);
%        eqi = eqi +1;
%        sstemp = sstemp(randperm(length(sstemp)));
%        
%        npos = idxss(sstemp) + pos -1;
%        if (kb > floor(Bmax/2))
%         Phi(i,npos(1:floor(Bmax/2)))=1;
%        else
%            Phi(i,npos(1:kb))=1;
%        end
%        %kb = kb+1;
%     end
%     while( kb<=floor(Bmax/2) )
%         if(length(find(icss==eqi))==0)
%             eqi = eqi + 1; 
%         end
%         sstemp = find(icss == eqi);
%         %choose one position at random
%         p = randperm(length(sstemp));
%         p = p(1);
%         npos = idxss(sstemp(p)) + pos -1;
%         sstemp(p)
%         Phi(i,npos)=1;
%         kb =kb+1;
%     end
    %idxss = pos + idxss -1;
    
%      %sort in ascend order
%     [~,Idx]=sort(varM);
%     %group by equal values
%     [~,~,ic] = unique(varM(Idx));
%     %choose one position with low variance
%     vtemp = find(ic==1);
%     p = randperm(length(vtemp));
%     p = p(1);
%     pos = Idx(vtemp(p));
    
%     Phi(i,idxss(1:floor(Bmax/2)))=1;
%     Phi(i,idxss(floor(Bmax/2)+1:end))=0;
    
end
end