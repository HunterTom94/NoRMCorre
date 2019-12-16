%% Laplace thresholding interactive demo
% This demo shows the functionality of the functions
% load3d, mthresh and zstack,
% which provide the core functionality of the package SARFIA
%(Semi-Automated Routines for Functional Image Analysis),
% originally developed in Igor Pro
%
% By Mario M. Dorostkar
% MRC Laboratory of Molecular Biology, Cambridge, UK
%
%% Load image using load3d.m
[imagefile,path] = uigetfile('*.tif','Select File','D:\Gut Imaging\Videos\Temp');
root_folder = path;
ImageStack=load3d([path imagefile]);
% ImageStack=gpuArray(load3d([path imagefile]));  
%% Calculate z-average
MaxImage=max(ImageStack,[],3);
while 1
    filterSize = input('filterSize: ');
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
    
    %%
    GassianImage = conv2(MaxImage, GaussFilter,'same');
    %Display
    sortGassianImage = sort(GassianImage(:));
    lenGassianImage = numel(sortGassianImage);
    lo=sortGassianImage(round(lenGassianImage*0.001));     %minimum pixel value
    hi=sortGassianImage(round(lenGassianImage*0.999));    %maximum pixel value

    titlestr=['Max projection of ' imagefile];
    close
    f = figure;
    f.WindowState = 'maximized';
    imshow(GassianImage, [lo hi],'InitialMagnification', 'fit')    %show max
    
    title(titlestr)
    
    Done=input('Gaussian Blur Good? (0/1): ');
    if Done == 1
        break
    end
end
%% Perform thresholding based on Laplace operator using mthresh.m
threshold=input('Threshold: ');      %Threshold used for segmentation
ROIsize_min=input('Remove ROIs smaller than: ');  %size of ROIs to reject
ROIsize_max=input('Remove ROIs bigger than: ');
while 1
    [ROIMask,Laplace]=mthresh(GassianImage,threshold, ROIsize_min, ROIsize_max);
    close
    f = figure;
    f.WindowState = 'maximized';
    imshow(GassianImage, [0 hi], 'InitialMagnification', 'fit')
%     imshow(GassianImage, [0 hi], 'InitialMagnification', 'fit','Border','tight')
    hold all
    [C,h] = contour(ROIMask,1);
    h.LineColor = 'y';

    Done=input('Keep settings (0/1): ');
%     Done=1;
    if Done == 1
        break
    end
    
    threshold=input('Threshold: ');      %Threshold used for segmentation
    ROIsize_min=input('Remove ROIs smaller than: ');
    ROIsize_max=input('Remove ROIs bigger than: '); %size of ROIs to reject

end
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
f = figure('visible','off');
figure_count = 1;
trace_folder = [root_folder 'Traces'];
if ~exist(trace_folder)
       mkdir(trace_folder)
end
r_num=input('Number of Rows for Trace Graph: ');
c_num=input('Number of Columns for Trace Graph: ');
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
        saveas(f,figurename,'png')
        figure_count = figure_count+1;
        f = figure('visible','off');
    end
end
figurename=[trace_folder '\Trace_' int2str(figure_count)];
saveas(f,figurename,'png')
%% Cleaning up
clearvars hi ii invlpl lo ntraces place threshold titlestr 
clearvars ROIsize_min ROIsize_max Done
clearvars MaxImage ImageStack GassianImage