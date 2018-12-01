function frame = track3D_part1( imgseq1,   cam_params )
    
    load(cam_params)
    imgs=zeros(480,640,length(imgseq1.rgb));
    imgsd=zeros(480,640,length(imgseq1.rgb));
    
    for k=1:length(imgseq1.rgb)
        imgs(:,:,k)=rgb2gray(imread(imgseq1.rgb(k).name));
        load(imgseq1.depth(k).name);
        imgsd(:,:,k)=double(depth_array)/1000;
        Z=double(depth_array(:)')/1000;
        [v u]=ind2sub([480 640],(1:480*640));
        t=inv(cam_params.Kdepth)*[Z.*u ;Z.*v;Z];
        xyz(k).coord=reshape(t',[480,640,3]);
    end

    
    bgdepth=median(imgsd,3);
    bggray=median(imgs,3);
    
    objects=zeros(480,640,length(imgseq1.rgb));
    for k=1:length(imgseq1.rgb),
        imdiff=abs(imgsd(:,:,k)-bgdepth)>.20 ;
        [gx, gy]=gradient(imgsd(:,:,k));
        g=(gx.^2+gy.^2).^0.5;
        imdiff= imdiff - (g > .2);
        imdiff= imdiff > 0;
        imgdiffiltered=imopen(imdiff,strel('disk',5));
        objects(:,:,k)=bwlabel(imgdiffiltered);
    end
    
    siz=size(objects);
    for k=1:siz(3)
        obs=max(max(objects(:,:,k)));
        l=0;
        for l=1:obs
           [x,y]=find(objects(:,:,k)==l );

           if(length(x)>1000)
               coords=zeros(3,length(x));
               for count=1:1:length(x);
                coords(:,count)=xyz(k).coord(x(count),y(count),:);
               end
               frame(k).obj(l).xyz=coords;
                

               [~, frame(k).obj(l).maxx]=max(coords(1,:));
               [~, frame(k).obj(l).maxy]=max(coords(2,:));
               [~, frame(k).obj(l).minx]=min(coords(1,:));
               [~, frame(k).obj(l).miny]=min(coords(2,:));   
           else
               frame(k).obj(l).xyz=nan;
           end
        end 
    end
end