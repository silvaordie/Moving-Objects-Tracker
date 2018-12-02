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
            p1(1,1)=frame(f).obj(o).xyz(1,frame(f).obj(o).maxx);
            p1(2,1)=frame(f).obj(o).xyz(2,frame(f).obj(o).maxy);
            p1(3,1)=frame(f).obj(o).xyz(3,frame(f).obj(o).maxz);
            
            p2(1,1)=frame(f).obj(o).xyz(1,frame(f).obj(o).maxx);
            p2(2,1)=frame(f).obj(o).xyz(2,frame(f).obj(o).miny);
            p2(3,1)=frame(f).obj(o).xyz(3,frame(f).obj(o).maxz);

            p3(1,1)=frame(f).obj(o).xyz(1,frame(f).obj(o).minx);
            p3(2,1)=frame(f).obj(o).xyz(2,frame(f).obj(o).maxy);
            p3(3,1)=frame(f).obj(o).xyz(3,frame(f).obj(o).maxz);

            p4(1,1)=frame(f).obj(o).xyz(1,frame(f).obj(o).minx);
            p4(2,1)=frame(f).obj(o).xyz(2,frame(f).obj(o).miny);
            p4(3,1)=frame(f).obj(o).xyz(3,frame(f).obj(o).maxz);

            p5(1,1)=frame(f).obj(o).xyz(1,frame(f).obj(o).maxx);
            p5(2,1)=frame(f).obj(o).xyz(2,frame(f).obj(o).maxy);
            p5(3,1)=frame(f).obj(o).xyz(3,frame(f).obj(o).minz);
            
            p6(1,1)=frame(f).obj(o).xyz(1,frame(f).obj(o).maxx);
            p6(2,1)=frame(f).obj(o).xyz(2,frame(f).obj(o).miny);
            p6(3,1)=frame(f).obj(o).xyz(3,frame(f).obj(o).minz);

            p7(1,1)=frame(f).obj(o).xyz(1,frame(f).obj(o).minx);
            p7(2,1)=frame(f).obj(o).xyz(2,frame(f).obj(o).maxy);
            p7(3,1)=frame(f).obj(o).xyz(3,frame(f).obj(o).minz);

            p8(1,1)=frame(f).obj(o).xyz(1,frame(f).obj(o).minx);
            p8(2,1)=frame(f).obj(o).xyz(2,frame(f).obj(o).miny);
            p8(3,1)=frame(f).obj(o).xyz(3,frame(f).obj(o).minz);
            c=[p1, p2, p3, p4, p5, p6, p7, p8];

            scatter3(c(1,:), c(2,:), c(3,:));
        end
    end
    axis([-10 10 -10 10 0 6]);
    grid on;
    view([45 45]);
    xlabel('x');
    ylabel('y');
    zlabel('z');
    pause(0.2);
    clf;
end