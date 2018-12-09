function objects=bg_sub(imgsd, imgs)  
    siz=size(imgsd);
    bgdepth=median(imgsd,3);
    bggray=median(imgs,3);
    
    objects=zeros(480,640,siz(3));
    for k=1:siz(3),
        imdiff=abs(imgsd(:,:,k)-bgdepth)>.20 ;
        [gx, gy]=gradient(imgsd(:,:,k));
        g=(gx.^2+gy.^2).^0.5;
        imdiff= imdiff - (g > .8);
        imdiff= imdiff > 0;
        imgdiffiltered=imopen(imdiff,strel('disk',5));
        objects(:,:,k)=bwlabel(imgdiffiltered);
    end
end