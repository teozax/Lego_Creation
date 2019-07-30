function I_enhanced = ex_enhancement(frame)
% example: detail enhancement
I = double(frame) / 255;

p = I;
r = 16;
eps = 0.1^1;

q = zeros(size(I));

q(:, :, 1) = guidedfilter(I(:, :, 1), p(:, :, 1), r, eps);
q(:, :, 2) = guidedfilter(I(:, :, 2), p(:, :, 2), r, eps);
q(:, :, 3) = guidedfilter(I(:, :, 3), p(:, :, 3), r, eps);

I_enhanced = (I - q) * 10 + 1/1 * q;

% figure();
% imshow(I_enhanced(:,:,1)); 
% imwrite(frame,'C:\Users\theoz\Documents\MATLAB\untitled5.jpg');
end
