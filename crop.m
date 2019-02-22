clear
gcp;

name = 'C:\Lab\#Yinan\ROI Extraction\Test Videos\Data\368_crop.tif';

tic; Y = read_file(name); toc; % read the file (optional, you can also pass the path in the function instead of Y)
Y = single(Y);                 % convert to single precision 
T = size(Y,ndims(Y));
Y = Y - min(Y(:));
Y = Y(:,:,1:5:end);

dimension = size(Y);

crop1_position = [1, dimension(1)/2, 1, dimension(2)/2];
crop2_position = [dimension(1)/4, dimension(1)*3/4, dimension(2)/4, dimension(2)*3/4];
crop3_position = [dimension(1)/2, dimension(1), dimension(2)/2, dimension(2)];

crop1 = Y(crop1_position(1):crop1_position(2),crop1_position(3):crop1_position(4),:);
crop2 = Y(crop2_position(1):crop2_position(2),crop2_position(3):crop2_position(4),:);
crop3 = Y(crop3_position(1):crop3_position(2),crop3_position(3):crop3_position(4),:);

gridsize = 10;

options_nonrigid = NoRMCorreSetParms('d1',size(crop1,1),'d2',size(crop1,2),'grid_size',[gridsize,gridsize],'overlap_pre',[gridsize,gridsize] ,'mot_uf',4,'overlap_post',[gridsize,gridsize],'bin_width',25,'max_shift',20,'max_dev',5,'us_fac',50,'init_batch',50);
tic; [M2,shifts2,template2,options_nonrigid] = normcorre_batch(crop1,options_nonrigid); toc
saveastiff(M2,'C:\Lab\#Yinan\ROI Extraction\Test Videos\New folder (2)\385_crop1_els_2.tif')

options_nonrigid = NoRMCorreSetParms('d1',size(crop2,1),'d2',size(crop2,2),'grid_size',[gridsize,gridsize],'overlap_pre',[gridsize,gridsize] ,'mot_uf',4,'overlap_post',[gridsize,gridsize],'bin_width',25,'max_shift',20,'max_dev',5,'us_fac',50,'init_batch',50);
tic; [M2,shifts2,template2,options_nonrigid] = normcorre_batch(crop2,options_nonrigid); toc
saveastiff(M2,'C:\Lab\#Yinan\ROI Extraction\Test Videos\New folder (2)\385_crop2_els_2.tif')

options_nonrigid = NoRMCorreSetParms('d1',size(crop3,1),'d2',size(crop3,2),'grid_size',[gridsize,gridsize],'overlap_pre',[gridsize,gridsize] ,'mot_uf',4,'overlap_post',[gridsize,gridsize],'bin_width',25,'max_shift',20,'max_dev',5,'us_fac',50,'init_batch',50);
tic; [M2,shifts2,template2,options_nonrigid] = normcorre_batch(crop3,options_nonrigid); toc
saveastiff(M2,'C:\Lab\#Yinan\ROI Extraction\Test Videos\New folder (2)\385_crop3_els_2.tif')