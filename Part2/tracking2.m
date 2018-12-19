function  frame=tracking2(imgseq1, cam_params, cam2toW)  

    for k=1:length(imgseq1.rgb)
        imgs(:,:,k)=rgb2gray(imread(['corredor1\',imgseq1.rgb(k).name]));
        load(['corredor1\',imgseq1.depth(k).name]);
        imgsd(:,:,k)=double(depth_array)/1000;
        
        Z=double(depth_array(:)')/1000;
        [v u]=ind2sub([480 640],(1:480*640));
        t=inv(cam_params.Kdepth)*[Z.*u ;Z.*v;Z];
        t=[cam2toW.R, cam2toW.T]*[t; ones(1,length(t))];
        xyz(k).coord=reshape(t',[480,640,3]);
    end

    objects=bg_subtraction(imgsd,imgs);
    
    siz=size(objects);
    for k=1:siz(3)
        frame(k)=max_xyz(objects(:,:,k), xyz(k));
    end
    
end