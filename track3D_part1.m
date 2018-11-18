function frame = track3D_part1( imgseq1,   cam_params )
    
    imgs=zeros(480,640,length(imgseq1.rgb));
    imgsd=zeros(480,640,length(imgseq1.rgb));
    
    for i=1:length(imgseq1.rgb)
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
    
    %%Isto ainda está em pixeis
    siz=size(objects);
    for k=1:siz(3)
        obs=max(max(objects(:,:,k)));
        l=0;
        for l=1:obs
           [x,y]=find(objects(:,:,k)==l );

           if(length(x)>400)
               frame(k).obj(l).x=x;
               frame(k).obj(l).y=y; 

               [~, frame(k).obj(l).maxx]=max(x);
               [~, frame(k).obj(l).maxy]=max(y);
               [~, frame(k).obj(l).minx]=min(x);
               [~, frame(k).obj(l).miny]=min(y);   
           else
               frame(k).obj(l).x=nan;
               frame(k).obj(l).y=nan;
           end
        end 
    end
end