function matches=sift_matching(imgseq1, imgseq2, ind, cam_params)

    idx=0;
    for k=ind

        Ia=single(rgb2gray(imread(imgseq1.rgb(k).name))) ;
        Ib=single(rgb2gray(imread(imgseq2.rgb(k).name))) ;   

        load(imgseq1.depth(k).name);
        Z=double(depth_array(:)')/1000;
        [v, u]=ind2sub([480 640],(1:480*640));
        xyz1=(inv(cam_params.Kdepth)*[Z.*u ;Z.*v;Z]);

        load(imgseq2.depth(k).name);
        Z=double(depth_array(:)')/1000;
        [v, u]=ind2sub([480 640],(1:480*640));
        xyz2=(inv(cam_params.Kdepth)*[Z.*u ;Z.*v;Z]);    

        iaux1=cam_params.Krgb*xyz1;
        iaux2=[cam_params.Krgb]*[cam_params.R, cam_params.T]*[xyz2 ; ones(1, length(xyz2))];

        ind1=[iaux1(1,:)./iaux1(3,:); iaux1(2,:)./iaux1(3,:)];
        ind2=[iaux2(1,:)./iaux2(3,:); iaux2(2,:)./iaux1(3,:)];

        [fa, da] = vl_sift(Ia) ;
        [fb, db] = vl_sift(Ib) ;
        [m, ~] = vl_ubcmatch(da, db, 1.3) ;

        mcoords1=fa(1:2,m(1,:));
        mcoords2=fb(1:2,m(2,:));

        fail=0;
        for i=1:1:length(mcoords1)

           err1=sqrt(sum(abs( ind1 - repmat( mcoords1(:,i),1,length(ind1)  ) ).^2));
           err2=sqrt(sum(abs( ind2 - repmat( mcoords2(:,i),1,length(ind2)  ) ).^2));

           [v1, idx1]=min(err1);
           [v2, idx2]=min(err2);

           if(v1<0.8 && v2<0.8)
                matches(1:3,idx+i-fail)=xyz1(:,idx1);
                matches(4:6,idx+i-fail)=xyz2(:,idx2);
           else
               fail=fail+1;
           end
        end
        idx=length(matches);
    end
end