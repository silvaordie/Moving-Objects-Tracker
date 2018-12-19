function OBJ = track3D_part1( imgseq1,   cam_params )
    
    imgs=zeros(480,640,length(imgseq1.rgb));
    imgsd=zeros(480,640,length(imgseq1.rgb));
    
    for k=1:length(imgseq1.rgb)
        imgs(:,:,k)=rgb2gray(imread(['corredor1\',imgseq1.rgb(k).name]));
        load(['corredor1\',imgseq1.depth(k).name]);
        imgsd(:,:,k)=double(depth_array)/1000;
        
        Z=double(depth_array(:)')/1000;
        [v u]=ind2sub([480 640],(1:480*640));
        t=inv(cam_params.Kdepth)*[Z.*u ;Z.*v;Z];
        xyz(k).coord=reshape(t',[480,640,3]);
    end

    objects=bg_subtraction(imgsd,imgs);
    
    siz=size(objects);
    for k=1:siz(3)
        frame(k)=max_xyz(objects(:,:,k), xyz(k));
    end
    
    %vert k+1 hor k
    for cnt=1:1:length(frame(1).obj)
       frame(1).obj(cnt).label= cnt;
       frame(1).obj(cnt).start=1;
       counts(cnt)=1;
    end    
    for k=1:1:length(frame)-1
        cost=zeros(length(frame(k+1).obj), length(frame(k).obj));
        siz=size(cost);
        
        for a=1:1:siz(1);
           for b=1:1:siz(2)
               A1=(frame(k).obj(b).maxx-frame(k).obj(b).minx)*(frame(k).obj(b).maxy-frame(k).obj(b).miny)*(frame(k).obj(b).maxz-frame(k).obj(b).minz);
               A2=(frame(k+1).obj(a).maxx-frame(k+1).obj(a).minx)*(frame(k+1).obj(a).maxy-frame(k+1).obj(a).miny)*(frame(k+1).obj(a).maxz-frame(k+1).obj(a).minz);
               
               cost(a,b)=( A2-A1 )^2;
           end
        end
        
        ass=munkres(cost);

        for cnt=1:1:length(ass)
           for aux=1:1:length(frame(k).obj)
              labels(aux)=frame(k).obj(aux).label;
           end
           
           if(ass(cnt)~=0)
            frame(k+1).obj(cnt).label= frame(k).obj(ass(cnt)).label;
            frame(k+1).obj(cnt).start= frame(k).obj(ass(cnt)).start;
            counts(frame(k).obj(aux).label)=counts(frame(k).obj(aux).label)+1;
           else
            frame(k+1).obj(cnt).label= max(labels)+1;
            frame(k+1).obj(cnt).start=k+1;
            counts(max(labels)+1)=1;
            labels(aux)=max(labels)+1;
            aux=aux+1;
           end
        end
    end
    
    for k=1:1:length(frame)
        for o=1:1:length(frame(k).obj)
            if(counts(frame(k).obj(o).label)>2)
                maxx=frame(k).obj(o).maxx;
                maxy=frame(k).obj(o).maxy;
                maxz=frame(k).obj(o).maxz;
                minx=frame(k).obj(o).minx;
                miny=frame(k).obj(o).miny;
                minz=frame(k).obj(o).minz;

                idx=k-frame(k).obj(o).start+1;
                label=frame(k).obj(o).label;

                OBJ(label).X(:,idx)=[maxx*ones(4,1); minx*ones(4,1)];
                OBJ(label).Y(:,idx)=[maxy*ones(2,1); miny*ones(2,1); maxy*ones(2,1); miny*ones(2,1)];
                OBJ(label).Z(:,idx)=[maxz ; minz ; maxz ; minz ; maxz ; minz ; maxz ; minz];           
                OBJ(label).frames_tracked(idx)=k;          
            end
        end       
    end
end