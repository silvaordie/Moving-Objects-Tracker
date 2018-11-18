function objects = track3D_part1( imgseq1,   cam_params )
    
    imgs=zeros(480,640,length(imgseq1.rgb));
    imgsd=zeros(480,640,length(imgseq1.rgb));
    
    for i=1:length(imgseq1.rgb),
        imgs(:,:,i)=rgb2gray(imread(imgseq1.rgb(i).name));
        load(imgseq1.depth(i).name);
        imgsd(:,:,i)=double(depth_array)/1000;
    end

    
    bgdepth=median(imgsd,3);
    bggray=median(imgs,3);
    
objects=zeros(480,640,length(imgseq1.rgb));
    for i=1:length(imgseq1.rgb),
        imdiff=abs(imgsd(:,:,i)-bgdepth)>.20 ;
        [gx, gy]=gradient(imgsd(:,:,i));
        g=(gx.^2+gy.^2).^0.5;
        imdiff= imdiff - (g > .2);
        imdiff= imdiff > 0;
        imgdiffiltered=imopen(imdiff,strel('disk',5));
        objects(:,:,i)=bwlabel(imgdiffiltered);
    end
    
end