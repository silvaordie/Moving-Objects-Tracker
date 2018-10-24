d=dir('*.jpg');
dd=dir('*.mat');

imgseq1.rgb=d;
imgseq1.depth=dd;

objects = track3D_part1( s,   1 );

    for i=1:length(s.rgb),
        imagesc(objects(:,:,i));
        pause(0.2);
    end
