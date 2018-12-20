function inliers=RANSAC(matches)

    niter=100;
    aux=fix(rand(4*niter,1)*length(matches))+1;
    numinliers=[];
    th=0.4;
    for k=0:1:niter-5
        P=matches(1:3, aux( (4*k+1):(4*k+4) ));
        P2=matches(4:6, aux( (4*k+1):(4*k+4) ));

        [ ~,~, transf ]=procrustes( P' , P2' , 'scaling', false, 'reflection', false );


        erro= abs(matches(1:3,:)-(transf.T*matches(4:6,:) +  repmat(transf.c(1,:)',1,length(matches(4:6,:)))));

        if(length(find(sqrt(sum(erro.^2))<th)) > max(numinliers))
            inliers=find(sqrt(sum(erro.^2))<th);
        end
        numinliers=[numinliers length(find(sqrt(sum(erro.^2))<th))]; 
    end

end