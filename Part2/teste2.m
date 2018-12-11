clear;

d1=dir('corredor1\rgb_image1*.png');
dd1=dir('corredor1\depth1*.mat');

d2=dir('corredor1\rgb_image2*.png');
dd2=dir('corredor1\depth2*.mat');

load cameraparametersAsus.mat

imgseq1.rgb=d1;
imgseq1.depth=dd1;

imgseq2.rgb=d2;
imgseq2.depth=dd2;

for k=1:length(imgseq1.rgb)
        imgs1(:,:,k)=rgb2gray(imread(['corredor1\', imgseq1.rgb(k).name]));
        load(['corredor1\',imgseq1.depth(k).name]);
        imgsd1(:,:,k)=double(depth_array)/1000;
        
        Z=double(depth_array(:)')/1000;
        [v u]=ind2sub([480 640],(1:480*640));
        t=inv(cam_params.Kdepth)*[Z.*u ;Z.*v;Z];
        xyz1(k).coord=reshape(t',[480,640,3]);
                
        Z=double(depth_array(:)')/1000;
        [v u]=ind2sub([480 640],(1:480*640));
        t=inv(cam_params.Kdepth)*[Z.*u ;Z.*v;Z];

        %figure(1);
        %pc=pointCloud(reshape(xyz1(k).coord,[480*640,3]));
        %showPointCloud(pc);
        %view(0,-90);
        %pause(0.01);
        
        imgs2(:,:,k)=rgb2gray(imread(['corredor1\', imgseq1.rgb(k).name]));
        load(['corredor1\',imgseq2.depth(k).name]);
        imgsd2(:,:,k)=double(depth_array)/1000;
        
        
        Z=double(depth_array(:)')/1000;
        [v u]=ind2sub([480 640],(1:480*640));
        t=inv(cam_params.Kdepth)*[Z.*u ;Z.*v;Z];
        xyz2(k).coord=reshape(t',[480,640,3]);

end
%%
idx=0;
for k=1:fix(length(imgseq2.rgb)/8):length(imgseq2.rgb)

    Ia=single(rgb2gray(imread(['corredor1\', imgseq1.rgb(k).name]))) ;
    Ib=single(rgb2gray(imread(['corredor1\', imgseq2.rgb(k).name]))) ;

    [fa, da] = vl_sift(Ia) ;
    [fb, db] = vl_sift(Ib) ;
    [m, s] = vl_ubcmatch(da, db) ;
    
    mcoords1=fa(1:2,m(1,:));
    mcoords2=fb(1:2,m(2,:));
    
    xyz_depth1=reshape(xyz1(k).coord, [480*640,3] );
    xyz_depth2=reshape(xyz2(k).coord, [480*640,3] );
    %figure(6);
    %pc=pointCloud(reshape(xyz1(k).coord,[480*640,3]));
    %showPointCloud(pc);
    %view(0,-90);

    xyz_rgb1 = cam_params.R*xyz_depth1' + repmat(cam_params.T,1,size(xyz_depth1,1));
    xyz_rgb2 = cam_params.R*xyz_depth2' + repmat(cam_params.T,1,size(xyz_depth2,1));
    
    %figure(5);
    %pc=pointCloud(xyz_rgb1);
    %showPointCloud(pc);
    %view(0,-90);  
    xyz_rgb1 = reshape(xyz_rgb1, [480,640,3]);
    xyz_rgb2 = reshape(xyz_rgb2', [480,640,3]);
    
    for j=1:1:length(mcoords1)
        matches(1:3,idx+j) = squeeze(xyz_rgb1(fix(mcoords1(2,j)),fix(mcoords1(1,j)),:));
        matches(4:6,idx+j) = squeeze(xyz_rgb2(fix(mcoords2(2,j)),fix(mcoords2(1,j)),:));
    end
    idx=idx+length(mcoords1);

end

%%
errorthresh=0.35;
niter=100;
numinliers=[];
%generate sets of 3 points (randomly selected)
aux=fix(rand(4*niter,1)*length(matches))+1;
for k=1:1:niter-4
    
    id=4*(k-1)+1;
    pontos1=matches(1:3,aux(4*k:4*k+3))';
    pontos2=matches(4:6,aux(4*k:4*k+3))';
    
    [ ~,~, transf ]=procrustes( pontos1 , pontos2 , 'scaling', false, 'reflection', false );
    
    
    erro= abs(matches(1:3,:)-(transf.T*matches(4:6,:) +  repmat(transf.c(1,:)',1,length(matches(1,:)))));

    if(length(find(sqrt(sum(erro.^2))<errorthresh)) > max(numinliers))
        inliers=find(sqrt(sum(erro.^2))<errorthresh);
    end
    numinliers=[numinliers length(find(sqrt(sum(erro.^2))<errorthresh))];
    
    
end

[~,K]=max(numinliers);
points1=matches(1:3, inliers)';
points2=matches(4:6, inliers)';
[ d,Z, F ]=procrustes(points1, points2, 'scaling', false, 'reflection', false );

figure(2);
pc=pointCloud(reshape(xyz1(1).coord,[480*640,3]));
showPointCloud(pc);
view(0,-90);

pc2=pointCloud( (F.T*reshape(xyz2(1).coord,[480*640,3])'+repmat(F.c(1,:)',1,480*640))' );
figure(2);
hold on;
showPointCloud(pc2);
view(0,-90);

%track3D_part2( imgseq1, imgseq2,   cam_params );