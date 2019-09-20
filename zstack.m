function poparray = zstack(stack, ROIMask)
%% ZSTACK performs z-stacks on all ROIs in ROIMask on the imagestack stack

rp = regionprops(ROIMask);      %region props of ROI mask
nROIs=numel(rp);                %number of ROIs
nframes=size(stack,3);          %number of frames

poparray=zeros(nROIs,nframes);   %preallocate memory for poparray

for ii=1:nframes

    frame=stack(:,:,ii);     %current frame
    ip = regionprops(ROIMask, frame, 'MeanIntensity');
    int= cell2mat({ip.MeanIntensity});     %assign mean int to array
    poparray(:,ii)=int;       %put data into poparray
end %for

end