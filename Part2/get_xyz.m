%% get xyz
% Arguments
%   - depth_img - depth data of an image
%   - K - intrinsic parameters of the camera
%   - R - rotation matrix
%   - T - translation vector
%
% Return values
%   xyz - n_pixels(depth_img)*3 matrix.
function xyz = get_xyz(depth_img, K)
    %% vectorize image
    depth_img_T = depth_img;
    im_vec = double(depth_img_T(:));
    
    %% build uv array
    u = double(repmat((1:size(depth_img, 1))', 1, size(depth_img, 2)));
    u = u(:);

    v = double(repmat(1:size(depth_img,2), size(depth_img, 1), 1));
    v = v(:);

    uv = [u v ones(length(u), 1)];
    for i = 1:length(u)
        uv(i,:) = im_vec(i).*uv(i,:);
    end
    
        %% Projection Matrix
        
        xyz = inv(K) * uv';
        xyz = xyz';
    
end