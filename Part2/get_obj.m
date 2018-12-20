function OBJ=get_obj(frame, counts)
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
end