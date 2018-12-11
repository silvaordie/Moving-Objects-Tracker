clear;
P=5*rand(3,50);
P2=[-1 0 0; 0 0 -1; 0 -1 0]*P+ ones(3,50);
P2=[P2, 5*rand(3,15)];
P=[P, 5*rand(3,15)];
aux=fix(rand(4*50,1)*length(P))+1;
numinliers=[];
for k=1:1:50-4
    
    [ ~,~, transf ]=procrustes( P(:,aux(4*k:4*k+3))' , P2(:,aux(4*k:4*k+3))' , 'scaling', false, 'reflection', false );
    
    
    erro= abs(P-(transf.T*P2 +  repmat(transf.c(1,:)',1,length(P))));

    if(length(find(sqrt(sum(erro.^2))<0.1)) > max(numinliers))
        inliers=find(sqrt(sum(erro.^2))<0.1);
    end
    numinliers=[numinliers length(find(sqrt(sum(erro.^2))<0.1))]; 
end

