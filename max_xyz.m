function f = max_xyz(objects, xyz) 
    obs=max(max(objects(:,:)));
            cnt=1;
    for l=1:obs
       [x,y]=find(objects(:,:)==l );

       if(length(x)>1000)
           coords=zeros(3,length(x));
           for count=1:1:length(x);
            coords(:,count)=xyz.coord(x(count),y(count),:);
           end
           f.obj(cnt).xyz=coords;


           [~, f.obj(cnt).maxx]=max(coords(1,:));
           [~, f.obj(cnt).maxy]=max(coords(2,:));
           [~, f.obj(cnt).maxz]=max(coords(3,:));

           [~, f.obj(cnt).minx]=min(coords(1,:));
           [~, f.obj(cnt).miny]=min(coords(2,:)); 
           [~, f.obj(cnt).minz]=min(coords(3,:));          
           cnt=cnt+1;
       end
    end 
end