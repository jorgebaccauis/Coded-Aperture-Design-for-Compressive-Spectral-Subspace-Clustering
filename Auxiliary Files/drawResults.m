function [ img ] = drawResults(Fname,grps,crV,M,N)
img=zeros(M*N,3);
if strcmp(Fname,'Indian_Pines')
    if ~isempty(crV)
    grps(grps==crV)=0;
    end
    
    img(grps==0,2)=1;
    img(grps==2,1)=1;
    img(grps==10,3)=1;
    img(grps==11,1)=1;
    img(grps==11,2)=1;
    
else
    if strcmp(Fname,'SalinasA')
        if ~isempty(crV)
        grps(grps==crV)=0;
        end
        if crV == 13
            img(find(grps==0),2)=0.8;
            img(find(grps==1),1)=1;
            img(find(grps==1),3)=0.5;
        else
            img(find(grps==13),2)=0.8;
            img(find(grps==0),1)=1;
            img(find(grps==0),3)=0.5;
        end
        img(find(grps==10),3)=1;
        img(find(grps==11),1)=1;
        img(find(grps==11),2)=1;
        img(find(grps==12),1)=1;
        img(find(grps==12),2)=0.7;
        img(find(grps==14),3)=1;
        img(find(grps==14),2)=1;
        
    else
        grps(grps==1)=0;
        img(find(grps==0),1)=0.81;
        img(find(grps==0),2)=0.82;
        img(find(grps==0),3)=0.78;
        img(find(grps==2),1)=1;
        img(find(grps==4),2)=0.3;
        img(find(grps==5),2)=1;
        img(find(grps==5),1)=1;
        img(find(grps==6),2)=0.72;
        img(find(grps==6),3)=0.99;
        img(find(grps==7),1)=1;
        img(find(grps==7),2)=0.7;
        img(find(grps==9),1)=0.3;
        img(find(grps==9),3)=0.7;
        img(find(grps==8),1)=0.1;
        img(find(grps==8),2)=0.2;
        img(find(grps==8),3)=0.4;
    end
end

%image(reshape(img,M,N,3))
img = reshape(img,M,N,3);

end