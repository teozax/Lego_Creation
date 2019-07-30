function [gabor, Labels] = gabor_example(frame)

    
    img = frame(:,:,1); 
%     figure;imshow(img);
    [rows,columns,~] = size(img); 

    se = strel('disk',5);
    background = imopen(img,se);
%     background = background/2;
    img = img - background;
%     figure;imshow(img);

%     imwrite(img,'9.jpg');

%     rtemp = min(img);         % find the min. value of pixels in all the columns (row vector)
%     rmin = min(rtemp);      % find the min. value of pixel in the image
%     rtemp = max(img);         % find the max. value of pixels in all the columns (row vector)
%     rmax = max(rtemp);      % find the max. value of pixel in the image
%     m = 255/(rmax - rmin);  % find the slope of line joining point (0,255) to (rmin,rmax)
%     c = 255 - m*rmax;       % find the intercept of the straight line with the axis
%     img = m*img + c;        % transform the image according to new slope
    img = histeq(img);
%     figure; imshow(img);
    
    mean_val = 0.3;
    Luminance = 0.1;
%     figure, imshow(Luminance_Image);
        
        img1 = adaptivethreshold(img,50,mean_val,0);
        
        img = img <= Luminance;
        Holes = img;

    Nets = img1 + imcomplement(img);
%     Holes = imcomplement(imfill(imcomplement(Holes),'holes'));   
    Nets = imcomplement(imfill(imcomplement(Nets),'holes'));
%     figure;imshow(img);   

%     img = imclearborder(img);
 
    connectivity = 4;
    [L,n] = bwlabel(img, connectivity);
    [L1] = bwlabel(Holes, connectivity);
%     RGB_label = label2rgb(L, @copper, 'c', 'shuffle');
%     figure;imshow(RGB_label);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    labels = unique(L);
    labels = labels(labels ~= 0);
    labels = [labels,zeros(n,1),zeros(n,1)];

    for i=1:rows
        for j=1:columns
            if (L(i,j) ~= 0)
               labels(L(i,j),2) = labels(L(i,j),2) + 1;
               if (Nets(i,j) == 1)
                    labels(L(i,j),3) = labels(L(i,j),3) + 1;
               end
            end
        end
    end
    
    global_median = unique(labels(:,2));
    global_median = median(global_median(1:ceil(size(global_median,1)/2)));
    
    sizes = zeros(rows,columns);

    for i=1:rows
        for j=1:columns
            if(L(i,j) ~= 0)
                sizes(i,j) = labels(L(i,j),2);
%                 .* (labels(L(i,j),3) <= 0.0 * labels(L(i,j),2));
            end
        end
    end

    results = zeros(rows,columns);
    
    pos = 0;
    [x,y] = size(img);
    offset = 50;   row = 1 - offset/2;    
    r = 0;  c = 0;  
    while (r == 0) || (c == 0)
        row = row + offset/2;
        myrow = row + offset;
        if(myrow > x)   
           myrow = x;
           row = x - offset;
           r = 1;
        end  
        col = 1 - offset/2;    
        c = 0;
        while c == 0
            col = col + offset/2; 
            mycol = col + offset;
            
            if(mycol > y)   
                mycol = y;
                col = y - offset;
                c = 1;
            end 
            
            window = sizes(row:myrow, col:mycol);
            window_sizes = unique(window(window~=0));
            window_median = median(window_sizes,'all');
%             [medrow, medcol] = find(window_sizes == local_median);
            x1 = size(window_sizes,1);
            i = 1;
            
            if(x1>0)
                while (i <= x1) && (window_sizes(i) < window_median/2) 
                    i = i + 1;
                end
                error = 0;
                start = i;
                while (i <= x1) && (error == 0)
                    local_median = window_sizes(ceil((start+i)/2));
                    if (local_median >= global_median/2)
                        if ((window_sizes(i) > local_median * 2) || (window_sizes(i) > global_median * 4))
                            pos = i;
                            error = 1;
                        elseif (i < x1)
                            if(window_sizes(i) + local_median < window_sizes(i+1))
                                pos = i + 1;
                                error = 1;
                            end
                        end
                    end
                    if (error == 1)
                        for j = pos:x1
                            sizes2 = sizes.*0;
                            sizes2(row:myrow, col:mycol) = sizes(row:myrow, col:mycol);
                            results = results + (sizes2 == window_sizes(j)) .* (results ~= 1);
                        end
                    end
                    i = i + 1;
                end
            end
        end
    end

    gabor(:,:,1) = Holes .*  results;
    gabor(:,:,2) = 0;
    gabor(:,:,3) = Nets;
    
%     gabor(1:30,:,2)=1;
%     gabor(rows-30:rows,:,2)=1;
%     gabor(:,1:30,2)=1;
%     gabor(:,columns-30:columns,2)=1;
%     figure, imshow(gabor);
    Labels = L1;
end
