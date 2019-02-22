tic;
name = 'C:\Lab\#Yinan\ROI Extraction\Videos\737.tif';
Y = read_file(name);
T = size(Y,ndims(Y));
a= Y(:,:,1);
imshow(a*100);
% Y = gpuArray(Y);
se = offsetstrel('ball',20,20)
Y = imtophat(Y,se);
% Y = gather(Y);
toc;
file_name = 'C:\Users\Wang Lab\Desktop\temp\737_copy_2.tif';
if isfile(file_name)
    delete(file_name)
end
saveastiff(Y,char(file_name)); 
