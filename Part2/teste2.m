clear;

d1=dir('data_rgb\rgb_image1*.png');
dd1=dir('data_rgb\depth1*.mat');

d2=dir('data_rgb\rgb_image2*.png');
dd2=dir('data_rgb\depth2*.mat');

load cameraparametersAsus.mat

imgseq1.rgb=d1;
imgseq1.depth=dd1;

imgseq2.rgb=d2;
imgseq2.depth=dd2;

for k=1:length(imgseq1.rgb)
        imgs1(:,:,k)=rgb2gray(imread(['data_rgb\', imgseq1.rgb(k).name]));
        load(['data_rgb\',imgseq1.depth(k).name]);
        imgsd1(:,:,k)=double(depth_array)/1000;
        
        Z=double(depth_array(:)')/1000;
        [v u]=ind2sub([480 640],(1:480*640));
        t=inv(cam_params.Kdepth)*[Z.*u ;Z.*v;Z];
        xyz1(k).coord=reshape(t',[480,640,3]);
        
        %figure(1);
        %pc=pointCloud(reshape(xyz1(k).coord,[480*640,3]));
        %showPointCloud(pc);
        %view(0,-90);
        %pause(0.01);
        
        imgs2(:,:,k)=rgb2gray(imread(['data_rgb\', imgseq1.rgb(k).name]));
        load(['data_rgb\',imgseq2.depth(k).name]);
        imgsd2(:,:,k)=double(depth_array)/1000;
        
        Z=double(depth_array(:)')/1000;
        [v u]=ind2sub([480 640],(1:480*640));
        t=inv(cam_params.Kdepth)*[Z.*u ;Z.*v;Z];
        xyz2(k).coord=reshape(t',[480,640,3]);

end

idx=0;
for k=1:fix(length(imgseq2.rgb)/5):length(imgseq2.rgb)

    Ia=single(rgb2gray(imread(['data_rgb\', imgseq1.rgb(k).name]))) ;
    Ib=single(rgb2gray(imread(['data_rgb\', imgseq2.rgb(k).name]))) ;

    [fa, da] = vl_sift(Ia) ;
    [fb, db] = vl_sift(Ib) ;
    [m, s] = vl_ubcmatch(da, db) ;
    
    mcoords1=fa(1:2,m(1,:));
    mcoords2=fb(1:2,m(2,:));
    
    for j=1:1:length(mcoords1)
        matches(1:3,idx+j) = squeeze(xyz1(k).coord(fix(mcoords1(2,j)),fix(mcoords1(1,j)),:));
        matches(4:6,idx+j) = squeeze(xyz2(k).coord(fix(mcoords2(2,j)),fix(mcoords2(1,j)),:));
    end
    idx=idx+length(mcoords1);

end

%%
errorthresh=0.4;
niter=fix(log(0.01)/log(1-0.5^4));
numinliers=[];
%generate sets of 3 points (randomly selected)
aux=fix(rand(4*niter,1)*length(matches))+1;
for k=1:1:niter-4
    id=4*(k-1)+1;
    [ d,Z, transf(k) ]=procrustes( matches(4:6,aux(id:id+3))' , matches(1:3,aux(id:id+3))', 'scaling', false, 'reflection', false );
    erro= abs(matches(1:3,:)-(transf(k).T'*matches(4:6,:) +  repmat(transf(k).c(1,:)',1,length(matches(1,:)))));

    inds=find(erro<errorthresh);
    numinliers=[numinliers length(find(erro<errorthresh))];
    
    
end

[~,K]=max(numinliers);
figure(2);
pc=pointCloud(reshape(xyz1(k).coord,[480*640,3]));
showPointCloud(pc);
view(0,-90);

pc2=pointCloud( (transf(K).T'*reshape(xyz2(k).coord,[480*640,3])'+repmat(transf(K).c(1,:)',1,480*640))' );
figure(2);
hold on;
showPointCloud(pc2);
view(0,-90);

%track3D_part2( imgseq1, imgseq2,   cam_params );