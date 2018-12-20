function frame=merge(frames1, frames2)
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
end