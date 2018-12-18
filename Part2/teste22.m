%%
clear;
run 'vlfeat-0.9.21\toolbox\vl_setup'
d1=dir('data_rgb1\rgb_image1*.png');
dd1=dir('data_rgb1\depth1*.mat');

d2=dir('data_rgb1\rgb_image2*.png');
dd2=dir('data_rgb1\depth2*.mat');

load cameraparametersAsus.mat

imgseq1.rgb=d1;
imgseq1.depth=dd1;

imgseq2.rgb=d2;
imgseq2.depth=dd2;

for k=1:length(imgseq1.rgb)
        imgs1(k).rgb=rgb2gray(imread(['data_rgb1\', imgseq1.rgb(k).name]));
        load(['data_rgb1\',imgseq1.depth(k).name]);
        imgsd1(:,:,k)=double(depth_array)/1000;
        
        Z=double(depth_array(:)')/1000;
        [v u]=ind2sub([480 640],(1:480*640));
        xyz1(k).coord=(inv(cam_params.Kdepth)*[Z.*u ;Z.*v;Z]);           
        
        imgs2(k).rgb=rgb2gray(imread(['data_rgb1\', imgseq2.rgb(k).name]));
        load(['data_rgb1\',imgseq2.depth(k).name]);
        imgsd2(:,:,k)=double(depth_array)/1000;
         
        Z=double(depth_array(:)')/1000;
        [v u]=ind2sub([480 640],(1:480*640));
        xyz2(k).coord=(inv(cam_params.Kdepth)*[Z.*u ;Z.*v;Z]);
        
        
        [fa, da] = vl_sift(single(imgs1(k).rgb)) ;
        [fb, db] = vl_sift(single(imgs2(k).rgb)) ;
        [m, s] = vl_ubcmatch(da, db) ;
        ms(1,k)=length(m);
end

[val ind] = sort(ms,'descend');


%% SIFT
    prev_len = 0;
    frame = 0;
    %para todas as imagens na sequência de imagens, vê-se qual a que tem
    %maior número de features
    for i = 1:length(imgseq1)
        im1 = imread(fullfile(['data_rgb1\', imgseq1.rgb(i).name]));
        im2 = imread(fullfile(['data_rgb1\', imgseq2.rgb(i).name]));

        [v1,u1,v2,u2] = sift_match(im1, im2);
        v1 = v1';
        u1 = u1';
        v2 = v2';
        u2 = u2';
        if length(v1) > prev_len
            frame = i;
            v1_sift = v1;
            u1_sift = u1;
            v2_sift = v2;
            u2_sift = u2;
            prev_len = length(v1);
        end
    end

    %carregam-se as imagens de profundidade da frame com mais features e 
    %calculam-se as coordenadas cartesianas da imagem para a câmara de
    %profundidade e depois para a câmara rgb
    load(['data_rgb1\',imgseq2.depth(frame).name]);
    depth1 = double(depth_array)/1000;  
    load(['data_rgb1\',imgseq2.depth(frame).name]);
    depth2 = double(depth_array)/1000;   

    xyz_depth1 = get_xyz(depth1, cam_params.Kdepth);        
    xyz_depth2 = get_xyz(depth2, cam_params.Kdepth);         

    xyz_rgb1 = cam_params.R*xyz_depth1' + repmat(cam_params.T,1,size(xyz_depth1,1));
    xyz_rgb2 = cam_params.R*xyz_depth2' + repmat(cam_params.T,1,size(xyz_depth2,1));

    xyz_rgb1 = xyz_rgb1';
    xyz_rgb2 = xyz_rgb2';
    %% calcula-se o xyz para os pontos retornados pelo SIFT 
    for i = 1:length(u1)
        p1(i,:) = xyz_rgb1((uint32(v1_sift(i))-1)*size(depth1,1)+uint32(u1_sift(i)), :);
        p2(i,:) = xyz_rgb2((uint32(v2_sift(i))-1)*size(depth2,1)+uint32(u2_sift(i)), :);
    end     

    %% RANSAC  
    n_inliers = 0;
    for k = 1: 5000
        %escolhem-se 3 pontos aleatórios entre todos os retornados pelo SIFT
        rand_idxs = randi(size(p1,1), 3, 1);

        p1_rand = p1(rand_idxs, :);
        p2_rand = p2(rand_idxs, :);

        %calcula-se a transformação de um conjunto de pontos para o outro
        [~,~,tr] = procrustes(p1_rand,p2_rand,'scaling',false);

        cam2toW_aux.R = tr.T;
        cam2toW_aux.T = tr.c(1,:);

        %aplica-se essa transformação a todos os pontos retornados pelo SIFT
        p2_aux = p2*cam2toW_aux.R + repmat(cam2toW_aux.T, size(p2,1), 1);

        %calcula-se a distância euclideana entre os vetores de features de
        %uma câmara e doutra
        eps = sqrt((p1(:,1)-p2_aux(:,1)).^2 + (p1(:,2)-p2_aux(:,2)).^2 + (p1(:,3)-p2_aux(:,3)).^2);        

        %classificam-se como inliers os pontos que tenham um erro menor que 0.5        
        inliers_idxs = find(eps < 0.5);

        %se tiverem sido encontrados mais inliers do que anteriormente,
        %faz-se update aos inliers e ao número dos mesmos
        if length(inliers_idxs) > n_inliers

            inliers1 = p1(inliers_idxs,:);
            inliers2 = p2(inliers_idxs,:);
            n_inliers = size(inliers1,1);
        end
    end     
    eps = sqrt((p1(:,1)-p2_aux(:,1)).^2 + (p1(:,2)-p2_aux(:,2)).^2 + (p1(:,3)-p2_aux(:,3)).^2);
    %% cálculo da transformação final baseado em todos os inliers encontrado
    [~,~,tr] = procrustes(inliers1,inliers2,'scaling', false);

    %assume-se que o sistema de coordenadas do mundo é o mesmo da câmara 1
    cam1toW.R = eye(3);
    cam1toW.T = zeros(1,3);
    cam2toW.R = tr.T;
    cam2toW.T = tr.c(1,:);    
    
figure(2);
pc=pointCloud(xyz1(1).coord');
showPointCloud(pc);
view(0,-90);

pc2=pointCloud( (cam2toW_aux.R*xyz2(1).coord+repmat(cam2toW_aux.T',1,480*640))') ;
figure(2);
hold on;
showPointCloud(pc2);
view(0,-90);

%track3D_part2( imgseq1, imgseq2,   cam_params );