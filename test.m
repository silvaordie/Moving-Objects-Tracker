clear;

d=dir('*.jpg');
dd=dir('images*.mat');

imgseq1.rgb=d;
imgseq1.depth=dd;

objects = track3D_part1( imgseq1,   1 );

for k=1:length(imgseq1.rgb),
    imagesc(objects(:,:,k));
    pause(0.2);
end
    
    
siz=size(objects);
for k=1:siz(3)
    obs=max(max(objects(:,:,k)));
    l=0;
    for l=1:obs
       [x,y]=find(objects(:,:,k)==l );

       frame(k).obj(l).x=x;
       frame(k).obj(l).y=y; 
       
       [j, frame(k).obj(l).maxx]=max(x);
       [j, frame(k).obj(l).maxy]=max(y);
       [j, frame(k).obj(l).minx]=min(x);
       [j, frame(k).obj(l).miny]=min(y);        
    end 
    
end

figure;
load(imgseq1.depth(1).name)
hold on;
x1=frame(1).obj(1).x(frame(1).obj(1).maxx);
y1=frame(1).obj(1).y(frame(1).obj(1).maxx);
z1=double(depth_array(x1,y1))/1000;

x2=frame(1).obj(1).x(frame(1).obj(1).maxy);
y2=frame(1).obj(1).y(frame(1).obj(1).maxy);
z2=double(depth_array(x2,y2))/1000;

x3=frame(1).obj(1).x(frame(1).obj(1).minx);
y3=frame(1).obj(1).y(frame(1).obj(1).minx);
z3=double(depth_array(x3,y3))/1000;

x4=frame(1).obj(1).x(frame(1).obj(1).miny);
y4=frame(1).obj(1).y(frame(1).obj(1).miny);
z4=double(depth_array(x4,y4))/1000;

c=[x1 x2 x3 x4; y1 y2 y3 y4; z1 z2 z3 z4 ];

scatter3(c(1,:), c(2,:), c(3,:));