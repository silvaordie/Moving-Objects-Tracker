  clear;

d=dir('*.jpg');
dd=dir('images*.mat');

load cameraparametersAsus.mat
imgseq1.rgb=d;
imgseq1.depth=dd;

frame = track3D_part1( imgseq1,   'cameraparametersAsus.mat' );
 
%%
figure;
for f=1:length(imgseq1.depth)
    load(imgseq1.depth(f).name)
    hold on;
        
    for o=1:length(frame(f).obj)
        if(~isnan(frame(f).obj(o).xyz))
            p1=frame(f).obj(o).xyz(:,frame(f).obj(o).maxx);

            p2=frame(f).obj(o).xyz(:,frame(f).obj(o).maxy);

            p3=frame(f).obj(o).xyz(:,frame(f).obj(o).minx);

            p4=frame(f).obj(o).xyz(:,frame(f).obj(o).miny);

            c=[p1, p2, p3, p4]

            scatter3(c(1,:), c(2,:), c(3,:));
        end
    end
    axis([-10 10 -10 10 0 10]);
    view([130 45]);
    xlabel('x');
    ylabel('y');
    zlabel('z');
    pause(0.2);
    clf;
end