clear;

d=dir('*.jpg');
dd=dir('images*.mat');

imgseq1.rgb=d;
imgseq1.depth=dd;

frame = track3D_part1( imgseq1,   1 );
 
%%
figure;
for f=1:length(imgseq1.depth)
    load(imgseq1.depth(f).name)
    hold on;
    for o=1:length(frame(f).obj)
        if(~isnan(frame(f).obj(o).x))
            x1=frame(f).obj(o).x(frame(f).obj(o).maxx);
            y1=frame(f).obj(o).y(frame(f).obj(o).maxx);
            z1=double(depth_array(x1,y1))/1000;

            x2=frame(f).obj(o).x(frame(f).obj(o).maxy);
            y2=frame(f).obj(o).y(frame(f).obj(o).maxy);
            z2=double(depth_array(x2,y2))/1000;

            x3=frame(f).obj(o).x(frame(f).obj(o).minx);
            y3=frame(f).obj(o).y(frame(f).obj(o).minx);
            z3=double(depth_array(x3,y3))/1000;

            x4=frame(f).obj(o).x(frame(f).obj(o).miny);
            y4=frame(f).obj(o).y(frame(f).obj(o).miny);
            z4=double(depth_array(x4,y4))/1000;

            c=[x1 x2 x3 x4; y1 y2 y3 y4; z1 z2 z3 z4 ];

            scatter3(c(1,:), c(2,:), c(3,:));
        end
    end
    axis([0 480 0 640 0 10]);
    view([45 45]);
    xlabel('x');
    ylabel('y');
    zlabel('z');
    pause(0.2);
    clf;
end