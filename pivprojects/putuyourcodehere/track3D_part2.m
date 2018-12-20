function [OBJ,cam2toW] = track3D_part2( imgseq1, imgseq2,   cam_params )
    
    for k=1:length(imgseq1.rgb)      
        [~, da] = vl_sift(single(rgb2gray(imread(imgseq1.rgb(k).name)))) ;
        [~, db] = vl_sift(single(rgb2gray(imread(imgseq1.rgb(k).name)))) ;
        [m, ~] = vl_ubcmatch(da, db) ;
        ms(1,k)=length(m);
    end

    [~,ind] = sort(ms,'descend');

    clearvars -except ind imgseq1 imgseq2 cam_params
    
    matches=sift_matching(imgseq1, imgseq2, ind(1:3), cam_params );


    inliers=RANSAC(matches);

    points1=matches(1:3,inliers);
    points2=matches(4:6,inliers);

    [ ~,~, transf ]=procrustes( points1' , points2' , 'scaling', false, 'reflection', false );

    cam2toW.R=transf.T;
    cam2toW.T=transf.c(1,:)';
 
    cam1toW.R=eye(3);
    cam1toW.T=[0;0;0];

    frames1=tracking(imgseq1, cam_params, cam1toW);
    frames2=tracking(imgseq2, cam_params, cam2toW);

    frame=merge(frames1, frames2);
    [frame, counts]=label(frame);
    OBJ=get_obj(frame, counts);
    
end