clear
gcp;

name = 'C:\Lab\#Yinan\ROI Extraction\Videos\537.tif';

tic; Y = read_file(name); toc; % read the file (optional, you can also pass the path in the function instead of Y)
Y = single(Y);                 % convert to single precision 
T = size(Y,ndims(Y));
Y = Y - min(Y(:));
% Y = Y(:,:,1:5:end);

dimension = size(Y);

crop_num = 4;
crop_size = 0.4;

assert(crop_size*crop_num > 1)
output_folder = 'C:\Lab\#Yinan\ROI Extraction\Output\';
video_num = '537';

gridsize = 10;

for crop_index = 1:crop_num
    if crop_index == 1
        crop_position = [1, dimension(1)*crop_size, 1, dimension(2)*crop_size];
    else
        x1 = ((1-crop_size)*dimension(1)/(crop_num - 1))*(crop_index - 1);
        x2 = x1 + crop_size*dimension(1);
        y1 = ((1-crop_size)*dimension(2)/(crop_num - 1))*(crop_index - 1);
        y2 = y1 + crop_size*dimension(2);
        crop_position = [x1, x2, y1, y2];
    end
    crop = Y(crop_position(1):crop_position(2),crop_position(3):crop_position(4),:);
    
    options_nonrigid = NoRMCorreSetParms('d1',size(crop,1),'d2',size(crop,2),'grid_size',[gridsize,gridsize],'overlap_pre',[gridsize,gridsize] ,'mot_uf',4,'overlap_post',[gridsize,gridsize],'bin_width',25,'max_shift',20,'max_dev',5,'us_fac',50,'init_batch',50);
    tic; [M2,shifts2,template2,options_nonrigid] = normcorre_batch(crop,options_nonrigid); toc
    file_name = strcat(output_folder,'d',video_num,'_gs_',string(gridsize),'_ci_',string(crop_index),'.tif')
    saveastiff(M2,char(file_name));
end
