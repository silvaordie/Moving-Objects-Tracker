function [frame, counts]=label(frame)
    
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
end