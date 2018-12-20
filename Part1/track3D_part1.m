function OBJ = track3D_part1( imgseq1,   cam_params )
    
    load(cam_params)
    imgs=zeros(480,640,length(imgseq1.rgb));
    imgsd=zeros(480,640,length(imgseq1.rgb));
    
    cam1toW.R=eye(3);
    cam1toW.T=[0;0;0];
    
    frame=tracking(imgseq1, cam_params, cam1toW);
    
    [frame, counts]=label(frame);
    
    OBJ=get_obj(frame, counts);
    
end