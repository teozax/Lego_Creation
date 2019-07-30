clear all; close all; clc; 

v = VideoReader('my.mp4');
thisFrame = readFrame(v);
% time_interval=0 ;
[x,y,~] = size(thisFrame);

% while v.CurrentTime < 31
%     thisFrame = readFrame(v);
% end
    
% imwrite(thisFrame,'myim.tif');
resize_value = 4;
previous_gabor = zeros(x/resize_value,y/resize_value);

while v.CurrentTime < 45
    thisFrame = readFrame(v);
%     [thisFrame,map] = imread('C:\Users\theoz\Documents\MATLAB\myim2.tif');
%     thisFrame = imread('C:\Users\theoz\Documents\MATLAB\tuc_notext.png');
    thisFrame = imresize(thisFrame,1/resize_value);
    
    I_enhanced = ex_enhancement(thisFrame);
    [gabor, Labels] = gabor_example(I_enhanced);

%         newGabor = gabor;
        newGabor(:,:,1) = gabor(:,:,1) .* previous_gabor(:,:,1);
        newGabor(:,:,2) = 0;
        newGabor(:,:,3) = gabor(:,:,3);
%         newGabor(:,:,3) = (gabor(:,:,3) + previous_gabor(:,:,3)-newGabor(:,:,2));

        R = newGabor(:,:,1);    
        
        Red_labels = unique(R .* Labels);
        Red_labels = Red_labels(Red_labels ~= 0);
        R = Labels .* 0;
        for i = 1:size(Red_labels)
                     R = R + (Labels == Red_labels(i));
        end
        R = R > 0;     

        newGabor(:,:,1) = R;
        newGabor(:,:,2) = newGabor(:,:,1) .* newGabor(:,:,3);
        newGabor(:,:,1) = newGabor(:,:,1) - newGabor(:,:,2);
        newGabor(:,:,3) = newGabor(:,:,3) - newGabor(:,:,2);

        previous_gabor(:,:,1) = gabor(:,:,1);
    %       figure;imshow(previous_gabor(:,:,1));
        thisFrame = imresize(thisFrame,resize_value);
        newGabor_r = imresize(newGabor,resize_value);
        
    %       close all;  
    %       figure;
        imshow(newGabor_r); 
end

