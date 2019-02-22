clc
clear

input_folder = 'C:\Lab\#Yinan\ROI Extraction\Videos\crop_output\';
bg_folder = 'C:\Lab\#Yinan\ROI Extraction\Videos\bg_output\';
root_folder = 'C:\Lab\#Yinan\ROI Extraction\Videos\';
finished_folder = 'C:\Lab\#Yinan\ROI Extraction\Videos\finished_videos\';
failed_folder = 'C:\Lab\#Yinan\ROI Extraction\Videos\failed_videos\';

files = dir(input_folder);
names = {};
for i=1:length(files)
    if files(i).isdir == 0
        name_split = strsplit(files(i).name,'.');
        names{end+1} = name_split{1};
    end
end

video_indices = cell(1,length(names));
for i=1:length(names)
    video_index_split = strsplit(names{i},'_');
    video_indices{i} = video_index_split{1};
    for j = 2:length(video_index_split)
        if ~strcmp(video_index_split{j},'gs')
            video_indices{i} = strcat(video_indices{i},'_',video_index_split{j});
        else
            break
        end
    end
end

unique_indices = unique(video_indices);

ready_indices = {};
for i = 1:length(unique_indices)
    ready_string_check = {};
    for k = 1:length(video_indices)
        if strcmp(video_indices{k},unique_indices{i})
            ready_string_check{end+1} = names{k};
        end
    end
    if length(ready_string_check) == 9
        ready_indices{end+1} = ready_string_check;
    else
        crop_index = [];
        for j = 1:length(ready_string_check)
            index_split = strsplit(ready_string_check{j},'_');
            crop_index = [crop_index,str2num(index_split{end})];
        end
        num_list = 1:9;
        unique_index = index_split{1};
        for l = 2:length(index_split)
            if ~strcmp(index_split{l},'gs')
                unique_index = strcat(unique_index,'_',index_split{l});
            else
                break
            end
        end
        unique_index
        num_list(~ismember(num_list,crop_index))
        failed_filename = strcat(unique_index(2:end),'.tif');
        if ~isfile(strcat(finished_folder,failed_filename))
            if isfile(strcat(root_folder,failed_filename))
                movefile(strcat(root_folder,failed_filename),strcat(failed_folder,failed_filename))
            end
        end
    end
end
%%

for i = 1:length(ready_indices)
    jump = 0;
    index_split = strsplit(ready_indices{i}{1},'_');
    unique_index = index_split{1};
    for l = 2:length(index_split)
        if ~strcmp(index_split{l},'gs')
            unique_index = strcat(unique_index,'_',index_split{l});
        else
            break
        end
    end
    
    out_foldernames1 = dir('C:\Lab\#Yinan\ROI Extraction\Videos\stitch_output\**\');
    out_foldernames2 = dir('C:\Lab\#Yinan\ROI Extraction\Videos\AA_dosage_curve\');
    out_foldernames = [out_foldernames1; out_foldernames2];
    target_folder_names = {};
    target_folder_path = {};
    for j = 1:length(out_foldernames)
        if out_foldernames(j).isdir == 1 && ((~strcmp(out_foldernames(j).name, '.')) && (~strcmp(out_foldernames(j).name,'..')))
            name_split = split(out_foldernames(j).name,'_');
            if strcmp(name_split{1}(1),'d')
                target_folder_names{end+1} = out_foldernames(j).name;
                target_folder_path{end+1} = strcat(out_foldernames(j).folder,'\');
            end
        end
    end
    
    success_name = strcat(unique_index(2:end),'.tif');
    delete_name = strcat(bg_folder,success_name);
    
    contain_result = 0;
    for j = 1:length(target_folder_names)
        if contains(target_folder_names{j}, unique_index)
            contain_result = 1;
%             strcat('has folder:', unique_index)
            
            stitch_name = strcat(target_folder_path{j},target_folder_names{j},'\stitched_',unique_index,'.tif');
            
            if isfile(stitch_name)
                jump = 1;
                if ~isfile(strcat(finished_folder,success_name))
                    if isfile(strcat(root_folder,success_name))
                    movefile(strcat(root_folder,success_name) ,strcat(finished_folder,success_name))
                    end
                end
                if isfile(delete_name)
                    delete(delete_name)
                end
                break
            else
%                 strcat('no file:', stitch_name)
            end
        end
    end
    if jump
        continue
    end
    if ~contain_result
            folder_name = strcat('C:\Lab\#Yinan\ROI Extraction\Videos\stitch_output\',unique_index);
            if ~exist(folder_name, 'dir')
               mkdir(folder_name)
            end
            stitch_name = strcat(folder_name,'\stitched_',unique_index,'.tif');
%             strcat('no folder:', unique_index)
    end
    
    crop_num_split = strsplit(ready_indices{i}{1},'_');
    crop_num_horizontal = str2num(crop_num_split{find(strcmp(crop_num_split,'h'))+1});
    crop_num_vertical = str2num(crop_num_split{find(strcmp(crop_num_split,'v'))+1});
    crop_storage_array = cell(crop_num_horizontal,crop_num_vertical);
    for j = 1:length(ready_indices{i})
        absolute_file_address = strcat(input_folder,ready_indices{i}{j},'.tif');
        Y = read_file(absolute_file_address);
        
        crop_index_vertical = mod(j,crop_num_vertical);
        if crop_index_vertical == 0
            crop_index_vertical = crop_num_vertical;
        end
        crop_index_horizontal = floor(j/crop_num_horizontal)+1;
        if mod(j,crop_num_vertical)==0
            crop_index_horizontal = crop_index_horizontal - 1;
        end
        crop_storage_array{crop_index_horizontal,crop_index_vertical} = Y;
        clear Y
    end
    
    h_concat = [];
    for crop_index_horizontal = 1:crop_num_horizontal
        v_concat = [];
        for crop_index_vertical = 1:crop_num_vertical
            v_concat = cat(2,v_concat,crop_storage_array{crop_index_horizontal,crop_index_vertical});
        end
        h_concat = cat(1,h_concat,v_concat);
    end
    saveastiff(h_concat,char(stitch_name));
    vars = {'h_concat','v_concat','Y','crop_storage_array'};
    clear(vars{:})
    
    if ~isfile(strcat(finished_folder,success_name))
        if isfile(strcat(root_folder,success_name))
            movefile(strcat(root_folder,success_name) ,strcat(finished_folder,success_name))
        end
    end
    if isfile(delete_name)
        delete(delete_name)
    end
end