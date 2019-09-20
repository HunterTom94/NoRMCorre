

clear
clc
gcp;

files = dir('D:\Gut Imaging\Videos\bg_output');

% half = ceil(length(files)/2);
% files = files(1:half);
% files = files(half+1:end);

correct_failed = 0;
skip = []; % !!! Note: applied to all videos in the bg_output folder

for i = fliplr(1:length(files))
    if files(i).isdir == 0 
        if isfile(strcat('D:\Gut Imaging\Videos\failed_videos\',files(i).name))
            if ~correct_failed
                continue
            end
        end
        full_address = strcat(files(i).folder,'\',files(i).name);
        process(full_address,files(i).name,skip)
        vars = {'crop','M2','shifts2','template2','Y','v_concat','h_concat','crop_storage_array'};
        clear(vars{:})
    end
end

function process(absolute_file_address,file_name,skip)
tic;

try
    Y = read_file(absolute_file_address); % read the file (optional, you can also pass the path in the function instead of Y)
catch
    return
end
Y = single(Y);                 % convert to single precision 
% pieced = zeros(size(Y));
T = size(Y,ndims(Y));

dimension = size(Y);

crop_num_horizontal = 3;
crop_num_vertical = 3;
crop_width = dimension(2)/crop_num_vertical;
crop_height = dimension(1)/crop_num_horizontal;
% crop_storage_array = cell(crop_num_horizontal,crop_num_vertical);

output_folder = 'D:\Gut Imaging\Videos\crop_output\';

video_num_split = strsplit(file_name,'.');
video_num = video_num_split{1};
% start_from = 1;

gridsize = 10;
counter = 0;

for crop_index_horizontal = 1:crop_num_horizontal
    y1 = 1+crop_height*(crop_index_horizontal-1);
    y2 = crop_height*crop_index_horizontal;
    for crop_index_vertical = 1:crop_num_vertical
%         counter = counter + 1;
%         if counter < start_from
%             continue
%         end
        crop_index = (crop_index_horizontal-1)*crop_num_vertical + crop_index_vertical;
        file_name_nopath = strcat('d',video_num,'_gs_',string(gridsize),'_h_',string(crop_num_horizontal),'_v_',string(crop_num_vertical),'_ci_',string(crop_index),'.tif');
        file_name = strcat(output_folder,file_name_nopath);
%         finished_name = strcat('', file_name_nopath);
        if isfile(file_name)
            continue
        end
        x1 = 1+crop_width*(crop_index_vertical-1);
        x2 = crop_width*crop_index_vertical;
        crop = Y(y1:y2,x1:x2,:);

        options_nonrigid = NoRMCorreSetParms('d1',size(crop,1),'d2',size(crop,2),'grid_size',[gridsize,gridsize],'overlap_pre',[gridsize,gridsize] ,'mot_uf',4,'overlap_post',[gridsize,gridsize],'bin_width',25,'max_shift',20,'max_dev',5,'us_fac',50,'init_batch',50);
        if ~ismember(crop_index,skip)
            try
                tic; [M2,~,~,~] = normcorre_batch(crop,options_nonrigid); toc
                counter = counter + 1;
            catch e
                fprintf(1,'The identifier was:\n%s',e.identifier);
                fprintf(1,'There was an error! The message was:\n%s',e.message);
                skipped = file_name
                continue
            end
            saveastiff(M2,char(file_name));
        else
            saveastiff(crop,char(file_name));
        end
        
        saved = file_name 
%         crop_storage_array{crop_index_horizontal,crop_index_vertical} = M2;
        vars = {'crop','M2'};
        clear(vars{:})
    end
end
toc;
end
