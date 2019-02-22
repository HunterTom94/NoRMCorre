close all
clear
clc

h = fspecial('gaussian',[300 300],10)*2;


h1 = h* 50;

h11 = h* 100;

h2 = insert_c_r(h1,20,20);
h3 = insert_c_r(h1,50,50);
h4 = insert_c_r(h1,80,80);

a1 = cat(3,h,h2,h1);
b1 = mean(a1,3);
bb1 = b1(:);
aa1 = reshape(a1,[],3);

cc1 = corr(h1(:),h2(:));

%%

a2 = cat(3,h,h3,h1);
b2 = mean(a2,3);
bb2 = b2(:);
aa2 = reshape(a2,[],3);

cc2 = corr(aa2,bb2);
%%
a3 = cat(3,h1,h2,h3,h4,h3,h2,h1);
b3 = mean(a3,3);
imshow(b3)

[Gmag1,Gdir1] = imgradient(b1);
[Gmag2,Gdir2] = imgradient(b2);
[Gmag3,Gdir3] = imgradient(b3);
[Gmag4,Gdir4] = imgradient(h1);

imshow(Gmag1*50)
figure
imshow(Gmag2*50)
figure
imshow(Gmag3*50)
figure
imshow(Gmag4*50)

sum(Gmag1.^2,'all')
sum(Gmag2.^2,'all')
sum(Gmag3.^2,'all')
sum(Gmag4.^2,'all')

sum(Gmag1,'all')
sum(Gmag2,'all')
sum(Gmag3,'all')
sum(Gmag4,'all')


% c1 = xcorr2(h1,b1);
% figure
% imshow(c1)
% 
% c2 = xcorr2(h1,b2);
% figure
% imshow(c2)
% 
% sum(c1,'all')
% sum(c2,'all')
% 
% sum(b1,'all')
% sum(b2,'all')

function out = insert_c_r(matrix,col,row)
matrix_size = size(matrix);
out = [zeros(row,matrix_size(1));matrix(1:end-row,:)];
out = [zeros(matrix_size(2),col),out(:,1:end-col)];
end
