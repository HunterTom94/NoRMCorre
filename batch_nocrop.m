clear
clc
gcp;

global output_folder 
global finished_folder 
global failed_folder 
global root_folder 

files = dir('D:\Gut Imaging\Videos\bg_output');
output_folder = 'D:\Gut Imaging\Videos\stitch_output\';
finished_folder = 'D:\Gut Imaging\Videos\finished_videos\';
failed_folder = 'D:\Gut Imaging\Videos\failed_videos\';
root_folder = 'D:\Gut Imaging\Videos\';

correct_failed = 1;

for i = fliplr(1:length(files))
    if files(i).isdir == 0 
        if isfile(strcat(failed_folder,files(i).name))
            if ~correct_failed
                continue
            end
        end
        full_address = strcat(files(i).folder,'\',files(i).name);
        process(full_address,files(i).name)
        vars = {'crop','M2','shifts2','template2','Y','v_concat','h_concat','crop_storage_array'};
        clear(vars{:})
    end
end

function process(absolute_file_address,raw_file_name) 
global output_folder 
global finished_folder 
global failed_folder 
global root_folder 

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

video_num_split = strsplit(raw_file_name,'.');
video_num = strcat('d',video_num_split{1});
% start_from = 1;

gridsize = 10;
counter = 0;

file_name_nopath = strcat('nocrop_',video_num,'.tif');
file_name = strcat(output_folder,video_num,'\',file_name_nopath);
%         finished_name = strcat('', file_name_nopath);
if isfile(file_name)
    return
end

options_nonrigid = NoRMCorreSetParms('d1',size(Y,1),'d2',size(Y,2),'grid_size',[gridsize,gridsize],'overlap_pre',[gridsize,gridsize] ,'mot_uf',4,'overlap_post',[gridsize,gridsize],'bin_width',25,'max_shift',20,'max_dev',5,'us_fac',50,'init_batch',50);

try
    tic; [M2,shifts2,template2,options_nonrigid] = normcorre_batch(Y,options_nonrigid); toc
    counter = counter + 1;
catch e
    fprintf(1,'The identifier was:\n%s',e.identifier);
    fprintf(1,'There was an error! The message was:\n%s',e.message);
    skipped = file_name

    failed_filename = raw_file_name;
    if isfile(strcat(root_folder,failed_filename))
        movefile(strcat(root_folder,failed_filename),strcat(failed_folder,failed_filename))
    end
    return
end

saveastiff(M2,char(file_name));
saved = file_name

max_name = strcat(output_folder,video_num,'\','max_',video_num,'.tif');
if ~isfile(max_name)
    saveastiff(max(M2,[],3),char(max_name));
end


delete(absolute_file_address)
if ~isfile(strcat(finished_folder,raw_file_name))
    if isfile(strcat(root_folder,raw_file_name))
        movefile(strcat(root_folder,raw_file_name) ,strcat(finished_folder,raw_file_name))
    end
end

vars = {'crop','M2','shifts2','template2'};
clear(vars{:})

toc;
end
