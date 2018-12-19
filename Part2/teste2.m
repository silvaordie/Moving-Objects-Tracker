%%
clear;
run 'vlfeat-0.9.21\toolbox\vl_setup'
d1=dir('corredor1\rgb_image1*.png');
dd1=dir('corredor1\depth1*.mat');

d2=dir('corredor1\rgb_image2*.png');
dd2=dir('corredor1\depth2*.mat');

load cameraparametersAsus.mat

imgseq1.rgb=d1;
imgseq1.depth=dd1;

imgseq2.rgb=d2;
imgseq2.depth=dd2;
clear d1 dd1 d2 dd2 

cam2toW=track3D_part2( imgseq1, imgseq2,   cam_params );

frames1=tracking(imgseq1, cam_params);
frames2=tracking2(imgseq2, cam_params, cam2toW);

%%
for k=1:1:length(frames1)
    
    if(isfield(frames1(k).obj,'maxx') && isfield(frames2(k).obj,'maxx'))
        cost=5*ones(length(frames1(k).obj) , length(frames2(k).obj) );

        for a=1:1:length(frames1(k).obj)
            for b=1:1:length(frames2(k).obj)
                cost(a,b)=abs(frames1(k).obj(a).maxx-frames2(k).obj(b).maxx) +...
                          abs(frames1(k).obj(a).minx-frames2(k).obj(b).minx) +...
                          abs(frames1(k).obj(a).maxy-frames2(k).obj(b).maxy) +...
                          abs(frames1(k).obj(a).miny-frames2(k).obj(b).miny) +...
                          abs(frames1(k).obj(a).maxz-frames2(k).obj(b).maxz) +...
                          abs(frames1(k).obj(a).minz-frames2(k).obj(b).minz);
            end
        end
        
        ass=munkres(cost);
        check=ones(1,length(frames2(k).obj));
        for i=1:1:length(ass)
            if(ass(i)~=0)
                check(ass(i))=0;  
            end
        end
        for i=1:1:length(ass)
            if( ass(i)~=0 )
                maxx=max(frames1(k).obj(i).maxx,frames2(k).obj(ass(i)).maxx);
                maxy=max(frames1(k).obj(i).maxy,frames2(k).obj(ass(i)).maxy);
                maxz=max(frames1(k).obj(i).maxz,frames2(k).obj(ass(i)).maxz);
                minx=min(frames1(k).obj(i).minx,frames2(k).obj(ass(i)).minx);
                miny=min(frames1(k).obj(i).miny,frames2(k).obj(ass(i)).miny);
                minz=min(frames1(k).obj(i).minz,frames2(k).obj(ass(i)).minz);
                
                frame(k).obj(i).maxx=maxx;
                frame(k).obj(i).maxy=maxy;
                frame(k).obj(i).maxz=maxz;
                frame(k).obj(i).minx=minx;
                frame(k).obj(i).miny=miny;
                frame(k).obj(i).minz=minz;
            else
                if(length(frames1(k).obj)>length(frames2(k).obj))
                    frame(k).obj(i)=frames1(k).obj(i);
                end
            end          
        end
        if(length(frames1(k).obj)<length(frames2(k).obj))
            frame(k).obj(i+1:length(frames2(k).obj))=frames2(k).obj(find(check==1,length(frames2(k).obj)-length(frames1(k).obj) ));
        end
        
        
    else
        if(isfield(frames1(k).obj,'maxx'))
            frame(k).obj=frames1(k).obj;
        else
            frame(k).obj=frames2(k).obj;
        end
    end    
end

x=1;
while(~isfield(frame(x).obj,'maxx') )
   x=x+1;
end
for cnt=1:1:length(frame(1).obj)
   frame(x).obj(cnt).label= cnt;
   frame(x).obj(cnt).start=1;
   labels(cnt)=cnt;
   counts(cnt)=1;
end 

for k=1:length(frame)-1
    if(isfield(frame(k).obj,'maxx') && isfield(frame(k+1).obj,'maxx') )
        cost=10*ones(length(frame(k+1).obj), length(frame(k).obj));
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
           if(ass(cnt)~=0)
            frame(k+1).obj(cnt).label= frame(k).obj(ass(cnt)).label;
            frame(k+1).obj(cnt).start= frame(k).obj(ass(cnt)).start;
            counts(frame(k).obj(ass(cnt)).label)=counts(frame(k).obj(ass(cnt)).label)+1;
           else
            frame(k+1).obj(cnt).label= max(labels)+1;
            frame(k+1).obj(cnt).start=k+1;
            counts(max(labels)+1)=1;
            labels(max(labels)+1)=max(labels)+1;
           end
        end            
    else
        if(isfield(frame(k+1).obj,'maxx') )
            for y=1:1:length(frame(k+1).obj)
                frame(k+1).obj(y).label= max(labels)+1;
                frame(k+1).obj(y).start=k+1;
                counts(max(labels)+1)=1;
                labels(max(labels)+1)=max(labels)+1;
            end
        end
    end
end  

 for k=1:1:length(frame)
        for o=1:1:length(frame(k).obj)
            if(isfield(frame(k).obj, 'maxx' ) && counts(frame(k).obj(o).label)>2)
                maxx=frame(k).obj(o).maxx;
                maxy=frame(k).obj(o).maxy;
                maxz=frame(k).obj(o).maxz;
                minx=frame(k).obj(o).minx;
                miny=frame(k).obj(o).miny;
                minz=frame(k).obj(o).minz;

                idx=k-frame(k).obj(o).start+1;
                label=frame(k).obj(o).label;

                OBJaux(label).X(:,idx)=[maxx*ones(4,1); minx*ones(4,1)];
                OBJaux(label).Y(:,idx)=[maxy*ones(2,1); miny*ones(2,1); maxy*ones(2,1); miny*ones(2,1)];
                OBJaux(label).Z(:,idx)=[maxz ; minz ; maxz ; minz ; maxz ; minz ; maxz ; minz];           
                OBJaux(label).frames_tracked(idx)=k;          
            end
            
        end       
 end
 
 count=1;
 for k=1:1:length(OBJaux)    
   if(find(OBJaux(k).X))
       OBJ(count)=OBJaux(k);
       count=count+1;       
   end     
 end

