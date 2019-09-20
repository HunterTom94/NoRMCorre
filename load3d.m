function imstack = load3d(filename)
%% LOAD3D loads filename into a 3d stack

    inf=imfinfo(filename);      %gather file info

    nslices=length(inf);        %number of slices in image stack

    w=inf.Width;                %width in pixels
    h=inf.Height;               %height in pixels

    imstack=zeros(h,w,nslices); %preallocate memory for the image stack

    for c = 1 : nslices
        locim = (imread(filename,c));   %read image
        imstack(:,:,c) = locim;         % pass image as slice to stack
    
    end %for
    

end