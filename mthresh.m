function [ thresholded, laplace ] = mthresh( image, threshold, size )
%% MTHRESH threshold image using Laplace operator
%thresholded is the binary ROI mask
%laplace is the Laplace operator of image
%image is the image to be thresholded
%threshold is the threshold (which will be normalised by the negative SD of
%the Laplace operator)
%All pixels with an area of size or lower will be rejected

locimage=double(image); %just in case

laplace=del2(locimage);

locthresh=-threshold*std(laplace(:));  %calculate wighted threshold

thresholded=laplace<locthresh;  %thresholding

%% removing ROIs smaller than size
if size
   rp=regionprops(thresholded, 'Area', 'PixelIdxList');
   
   nROIs=numel(rp);     %number of ROIs 
   sizes=cell2mat({rp.Area});   %sizes of ROIs
   plist={rp.PixelIdxList}; %linear pixel indices
   
   for ii=1:nROIs
       if sizes(ii)<=size
          pixels=cell2mat(plist(ii));
           thresholded(pixels)=0;     %set pixels to 0
          
       end
           
   end
        
end


end

