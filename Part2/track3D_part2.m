function OBJ = track3D_part2( imgseq1, imgseq2,   cam_params )
    
    load(cam_params)
    imgs1=zeros(480,640,length(imgseq1.rgb));
    imgsd1=zeros(480,640,length(imgseq1.rgb));
 
    imgs2=zeros(480,640,length(imgseq1.rgb));
    imgsd2=zeros(480,640,length(imgseq1.rgb));
    
    for k=1:length(imgseq1.rgb)
        imgs1(:,:,k)=rgb2gray(imread(imgseq1.rgb(k).name));
        load(imgseq1.depth(k).name);
        imgsd1(:,:,k)=double(depth_array)/1000;
        
        Z=double(depth_array(:)')/1000;
        [v u]=ind2sub([480 640],(1:480*640));
        t=inv(cam_params.Kdepth)*[Z.*u ;Z.*v;Z];
        xyz1(k).coord=reshape(t',[480,640,3]);
        
        imgs2(:,:,k)=rgb2gray(imread(imgseq2.rgb(k).name));
        load(imgseq2.depth(k).name);
        imgsd2(:,:,k)=double(depth_array)/1000;
        
        Z=double(depth_array(:)')/1000;
        [v u]=ind2sub([480 640],(1:480*640));
        t=inv(cam_params.Kdepth)*[Z.*u ;Z.*v;Z];
        xyz2(k).coord=reshape(t',[480,640,3]);
        
        figure(1);
        showointcloud
    end

    objects=bg_subtraction(imgsd,imgs);
    

    
end