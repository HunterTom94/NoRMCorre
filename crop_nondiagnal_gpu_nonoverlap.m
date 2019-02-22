clear
gcp;
tic;
name = 'C:\Lab\#Yinan\ROI Extraction\Videos\758.tif';
% name = 'C:\Users\Wang Lab\Desktop\temp\659_late.tif';

tic; Y = read_file(name); toc; % read the file (optional, you can also pass the path in the function instead of Y)
Y = single(Y);                 % convert to single precision 
% pieced = zeros(size(Y));
T = size(Y,ndims(Y));

dimension = size(Y);

crop_num_horizontal = 3;
crop_num_vertical = 3;
crop_width = dimension(2)/crop_num_vertical;
crop_height = dimension(1)/crop_num_horizontal;
% crop_storage_array = cell(crop_num_horizontal,crop_num_vertical);

output_folder = 'C:\Lab\#Yinan\ROI Extraction\Output\';
% output_folder = 'C:\Users\Wang Lab\Desktop\temp\';
video_num = '758';
start_from = 1;

gridsize = 10;
counter = 0;

for crop_index_horizontal = 1:crop_num_horizontal
    y1 = 1+crop_height*(crop_index_horizontal-1);
    y2 = crop_height*crop_index_horizontal;
    parfor crop_index_vertical = 1:crop_num_vertical
%         counter = counter + 1;
%         if counter < start_from
%             continue
%         end
        x1 = 1+crop_width*(crop_index_vertical-1);
        x2 = crop_width*crop_index_vertical;
        crop = Y(y1:y2,x1:x2,:);

        options_nonrigid = NoRMCorreSetParms('d1',size(crop,1),'d2',size(crop,2),'grid_size',[gridsize,gridsize],'overlap_pre',[gridsize,gridsize] ,'mot_uf',4,'overlap_post',[gridsize,gridsize],'bin_width',25,'max_shift',20,'max_dev',5,'us_fac',50,'init_batch',50);
        tic; [M2,shifts2,template2,options_nonrigid] = normcorre_batch(crop,options_nonrigid); toc
        file_name = strcat(output_folder,'d',video_num,'_gs_',string(gridsize),'_h_',string(crop_num_horizontal),'_v_',string(crop_num_vertical),'_ci_',string((crop_index_horizontal-1)*crop_num_horizontal + crop_index_vertical),'.tif')
        if isfile(file_name)
            delete(file_name)
        end
        saveastiff(M2,char(file_name)); 
%         crop_storage_array{crop_index_horizontal,crop_index_vertical} = M2;
    end
end

% h_concat = [];
% for crop_index_horizontal = 1:crop_num_horizontal
%     y1 = 1+crop_height*(crop_index_horizontal-1);
%     y2 = crop_height*crop_index_horizontal;
%     v_concat = [];
%     for crop_index_vertical = 1:crop_num_vertical
%         x1 = 1+crop_width*(crop_index_vertical-1);
%         x2 = crop_width*crop_index_vertical;
%         v_concat = cat(2,v_concat,crop_storage_array{crop_index_horizontal,crop_index_vertical});
%     end
%     h_concat = cat(1,h_concat,v_concat);
% end
% saveastiff(h_concat,char('C:\Users\Wang Lab\Desktop\temp\111.tif')); 
toc;