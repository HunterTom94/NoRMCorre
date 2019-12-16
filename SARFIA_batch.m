files = dir('D:\Gut Imaging\Videos\Temp\');

filterSize = 8;
threshold=1.5;
ROIsize_min=8;
ROIsize_max=1000;

for iii = 1:length(files)
    if files(iii).name(1) == 'd'
        root_folder = strcat('D:\Gut Imaging\Videos\Temp\', files(iii).name, '\');
        path = root_folder;
        file_ls = dir(root_folder);
        for file_ls_index = 1:length(file_ls)
            if contains(file_ls(file_ls_index).name, '.tif') && ~contains(file_ls(file_ls_index).name, 'max')
                imagefile = file_ls(file_ls_index).name; 
            end
        end
         
        %% Load image using load3d.m
        ImageStack=load3d([path imagefile]);
        % ImageStack=gpuArray(load3d([path imagefile]));  
        %% Calculate z-average
        MaxImage=max(ImageStack,[],3);
        
        
        GaussFilter = zeros(filterSize);
        scale = 1.17/(filterSize/2);
        for i = 1:filterSize
            for j = 1: filterSize
                ii= (i-1)-filterSize/2;
                jj= (j-1)-filterSize/2;
                xval= scale*ii;
                yval= scale*jj;
                GaussFilter(i,j) = exp(-(xval*xval) -(yval*yval));
            end
        end


        GassianImage = conv2(MaxImage, GaussFilter,'same');
        %Display
        sortGassianImage = sort(GassianImage(:));
        lenGassianImage = numel(sortGassianImage);
        lo=sortGassianImage(round(lenGassianImage*0.001));     %minimum pixel value
        hi=sortGassianImage(round(lenGassianImage*0.999));    %maximum pixel value
        
        %% Perform thresholding based on Laplace operator using mthresh.m
              %Threshold used for segmentation
          %size of ROIs to reject
        [ROIMask,Laplace]=mthresh(GassianImage,threshold, ROIsize_min, ROIsize_max);
        
        f = figure;
        f.WindowState = 'maximized';
        imshow(GassianImage, [0 hi], 'InitialMagnification', 'fit','Border','tight')
        hold all
        [C,h] = contour(ROIMask,1);
        h.LineColor = 'y';
        temp_delim = strsplit(root_folder, '\');
        set(gcf,'Name',temp_delim{end-1})

        para_cell = {'filterSize', filterSize; 'Threshold', threshold; 'size min threshold', ROIsize_min; 'size max threshold', ROIsize_max};
        writetable(cell2table(para_cell),[path 'SARFIA_para.csv'])
        %% Generate roi.csv
        ROILabel = ones(size(ROIMask));
        pl = regionprops(ROIMask,'PixelList');
        for ROI_index = 1:numel(pl)
            indmx = fliplr(pl(ROI_index).PixelList);
            linearIndexes = sub2ind(size(ROILabel), indmx(:,1), indmx(:, 2));
            ROILabel(linearIndexes) = -ROI_index;
        end
        dimension = size(ROILabel');
        ROILabel = [zeros(2,dimension(2));ROILabel']; % Add two row to accomodate for old Igor output
        csvwrite([path 'roi.csv'],ROILabel)
        %% Extract data using zstack.m
        Pop=zstack(ImageStack,ROIMask);    %pop is formatted to be displayed as a raster plot
        %% Show traces
        dimension = size(Pop');
        Traces = Pop';
        TracesSave = [zeros(1,dimension(2));0:dimension(2)-1;Pop']; % Add two row to accomodate for old Igor output
        csvwrite([path 'f.csv'],TracesSave)
        ntraces=size(Traces, 2); %number of traces
        temp_f = figure('visible','off');
        figure_count = 1;
        trace_folder = [root_folder 'Traces'];
        if ~exist(trace_folder)
               mkdir(trace_folder)
        end
        r_num=4;
        c_num=3;
        for ii = 1:ntraces
            place=mod(ii,r_num*c_num);    %position of subplot   
            if place == 0
                place=r_num*c_num;
            end
            titlestr=['ROI #' int2str(ii-1)];
            subplot(r_num,c_num,place), plot(Traces(:,ii)), title(titlestr)
            axis([0 size(Traces,1) min(Traces(:,ii)) max(Traces(:,ii))])
            if place == r_num*c_num && ii < ntraces  
                figurename=[trace_folder '\Trace_' int2str(figure_count)];
                saveas(temp_f,figurename,'png')
                close(temp_f)
                figure_count = figure_count+1;
                temp_f = figure('visible','off');
                
            end
            
        end
        figurename=[trace_folder '\Trace_' int2str(figure_count)];
        saveas(temp_f,figurename,'png')
        close(temp_f)
        
        %% Cleaning up
        clearvars hi ii invlpl lo ntraces place titlestr
        clearvars Done
        clearvars MaxImage ImageStack GassianImage
    end
end
