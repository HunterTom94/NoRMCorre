clear
gcp;
tic;
name = 'C:\Lab\#Yinan\ROI Extraction\Videos\725.tif';
% name = 'C:\Users\Wang Lab\Desktop\temp\659_late.tif';

tic; Y = read_file(name); toc; % read the file (optional, you can also pass the path in the function instead of Y)
Y = single(Y);                 % convert to single precision 
T = size(Y,ndims(Y));
Y = Y - min(Y(:));
% Y = Y(:,:,1:50:end);

dimension = size(Y);

crop_num_horizontal = 3;
crop_num_vertical = 3;
crop_size = 0.4;

assert(crop_size*crop_num_horizontal > 1)
assert(crop_size*crop_num_vertical > 1)

% output_folder = 'C:\Lab\#Yinan\ROI Extraction\Output\';
output_folder = 'C:\Users\Wang Lab\Desktop\temp\';
video_num = '725';
start_from = 6;

gridsize = 10;
counter = 0;

for crop_index_horizontal = 1:crop_num_horizontal
    if crop_index_horizontal == 1
        x1 = 1;
        x2 = dimension(1)*crop_size;
    else
        x1 = ((1-crop_size)*dimension(1)/(crop_num_horizontal - 1))*(crop_index_horizontal - 1);
        x2 = x1 + crop_size*dimension(1);
    end
    for crop_index_vertical = 1:crop_num_vertical
        counter = counter + 1;
        if counter < start_from
            continue
        end
        if crop_index_vertical == 1
            y1 = 1;
            y2 = dimension(2)*crop_size;
            %crop_position(2)-crop_position(1)
            %crop_position(4)-crop_position(3)
        else
            y1 = ((1-crop_size)*dimension(2)/(crop_num_vertical - 1))*(crop_index_vertical - 1);
            y2 = y1 + crop_size*dimension(2);
            %crop_position(2)-crop_position(1)
            %crop_position(4)-crop_position(3)
        end
        crop_position = [x1, x2, y1, y2];
        crop = Y(crop_position(1):crop_position(2),crop_position(3):crop_position(4),:);
        crop = gpuArray(crop);
        tic;
        for num_iter = 1:20
            if num_iter == 2
                figure
                imshow(crop(:,:,1)/50)
            end
            crop_copy = crop;

            for frame_index = 1:dimension(3)
                frame = crop_copy(:,:,frame_index);
                frame1d = nonzeros(sort(frame(:)))';
                bg = frame1d(ceil(0.05*length(frame1d)));
                crop(:,:,frame_index) = crop_copy(:,:,frame_index) - bg;
            end

            crop(crop(:,:,:)<0) = 0;

        end
        figure
        imshow(crop(:,:,1)/50)
        toc;
        crop = gather(crop);
        options_nonrigid = NoRMCorreSetParms('d1',size(crop,1),'d2',size(crop,2),'grid_size',[gridsize,gridsize],'overlap_pre',[gridsize,gridsize] ,'mot_uf',4,'overlap_post',[gridsize,gridsize],'bin_width',25,'max_shift',20,'max_dev',5,'us_fac',50,'init_batch',50);
        tic; [M2,shifts2,template2,options_nonrigid] = normcorre_batch(crop,options_nonrigid); toc
        file_name = strcat(output_folder,'d',video_num,'_gs_',string(gridsize),'_ci_',string((crop_index_horizontal-1)*crop_num_horizontal + crop_index_vertical),'.tif')
        if isfile(file_name)
            delete(file_name)
        end
        saveastiff(M2,char(file_name)); 
    end
end
toc;