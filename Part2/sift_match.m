%% sift_match
% Arguments
%   - im1 - rgb image of one frame for camera 1
%   - im2 - rgb image of the same frame for camera 2
%
% Return values
%   - x1 - v of camera 1
%   - y1 - u of camera 1
%   - x2 - v of camera 2
%   - y2 - u of camera 2
function [x1,y1,x2,y2] = sift_match(im1, im2)

%cálculo das features
[f1,d1] = vl_sift(im2single(rgb2gray(im1)), 'PeakThresh', 0.02) ;
[f2,d2] = vl_sift(im2single(rgb2gray(im2)), 'PeakThresh', 0.02) ;

[matches, scores] = vl_ubcmatch(d1,d2);

[~, perm] = sort(scores, 'descend') ;
matches = matches(:, perm) ;

%cálculo das coordenadas homogéneas para cada keypoint em cada imagem
x1 = f1(1,matches(1,:)) ;
x2 = f2(1,matches(2,:));
y1 = f1(2,matches(1,:)) ;
y2 = f2(2,matches(2,:)) ;

end