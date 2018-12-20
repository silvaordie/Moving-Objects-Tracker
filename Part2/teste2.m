%%
%clear;
run 'vlfeat-0.9.21\toolbox\vl_setup'
d1=dir('data_rgb\rgb_image1*.png');
dd1=dir('data_rgb\depth1*.mat');

d2=dir('data_rgb\rgb_image2*.png');
dd2=dir('data_rgb\depth2*.mat');

load cameraparametersAsus.mat

for k=1:1:length(d1)
    imgseq1.rgb(k).name=['data_rgb\' d1(k).name];
    imgseq1.depth(k).name=['data_rgb\' dd1(k).name];
    
    imgseq2.rgb(k).name=['data_rgb\' d2(k).name];
    imgseq2.depth(k).name=['data_rgb\' dd2(k).name];
end
clear d1 dd1 d2 dd2 

%[OBJ, cam2toW]=track3D_part2( imgseq1, imgseq2,   cam_params );

%%
figure;
hold on;
siz=size(OBJ(7).X)
for k=OBJ(7).frames_tracked;
    
    im=imread([imgseq1.rgb(k).name]);
    load([imgseq1.depth(k).name]);
    Kd=cam_params.Kdepth;
    Z=double(depth_array(:)')/1000;
    % Compute correspondence between two imagens in 5 lines of code
    [v u]=ind2sub([480 640],(1:480*640));
    P=inv(Kd)*[Z.*u ;Z.*v;Z];
    niu=cam_params.Krgb*[cam_params.R cam_params.T]*[P;ones(1,640*480)];
    u2=round(niu(1,:)./niu(3,:));
    v2=round(niu(2,:)./niu(3,:));

    im2=zeros(640*480,3);
    indsclean=find((u2>=1)&(u2<=641)&(v2>=1)&(v2<=480));
    indscolor=sub2ind([480 640],v2(indsclean),u2(indsclean));
    im1aux=reshape(im,[640*480 3]);
    im2(indsclean,:)=im1aux(indscolor,:);
    pc=pointCloud(P', 'color',uint8(im2));
    showPointCloud(pc);
    hold on;
    
    X=OBJ(7).X;
    Y=OBJ(7).Y;
    Z=OBJ(7).Z;
    P=[X(:,k-OBJ(7).frames_tracked(1)+1)'; Y(:,k-OBJ(7).frames_tracked(1)+1)';Z(:,k-OBJ(7).frames_tracked(1)+1)'];

    scatter3(P(1,:),P(2,:),P(3,:), 'MarkerFaceColor', 'g');
    
        %axis([-10 10 -10 10 0 6]);
        grid on;
        view([0 -90]);
        xlabel('x');
        ylabel('y');
        zlabel('z');
        pause(0.2);
        clf;
end
