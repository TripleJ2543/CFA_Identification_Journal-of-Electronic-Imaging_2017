clear all
close all
clc
%%
[filename, pathname] = uigetfile({'*.jpg;*.tif;*.png;*.gif;*.bmp','All Image Files';'*.*','All Files' },'Open File', pwd);
prompt = {'Block Size (32, 64, 128, 256, 512):'};
dlg_title = 'Input Values';
num_lines = 1;
def = {'512'};
answer = inputdlg(prompt,dlg_title,num_lines,def);

input_image = double(imread([pathname filename]));
blocksize = str2num(answer{1});
[M, N, ~]=size(input_image);
center_M = floor(M/2);
center_N = floor(N/2);
                
center_image = input_image(center_M - blocksize/2 + 1:center_M + blocksize/2, center_N - blocksize/2 + 1:center_N + blocksize/2, :);
[m, n, ~]=size(center_image);

%% Subtraction_DC_component
red_two_square = im2col(center_image(1:end, :, 1), [2 2], 'distinct');
red_mean = mean(red_two_square(:,1:end));
red_mean = repmat(red_mean,4,1);
red_mean_im = col2im(red_mean,[2 2],[m,n], 'distinct');
center_image(:,:,1) = center_image(:,:,1) - red_mean_im;

green_two_square = im2col(center_image(1:end, :, 2), [2 2], 'distinct');
green_mean = mean(green_two_square(:,1:end));
green_mean = repmat(green_mean,4,1);
green_mean_im = col2im(green_mean,[2 2],[m,n], 'distinct');
center_image(:,:,2) = center_image(:,:,2) - green_mean_im;

blue_two_square = im2col(center_image(1:end, :, 3), [2 2], 'distinct');
blue_mean = mean(blue_two_square(:,1:end));
blue_mean = repmat(blue_mean,4,1);
blue_mean_im = col2im(blue_mean,[2 2],[m,n], 'distinct');
center_image(:,:,3) = center_image(:,:,3) - blue_mean_im;

%%
red_1 = center_image(1:2:blocksize, 1:2:blocksize, 1);
red_2 = center_image(1:2:blocksize, 2:2:blocksize, 1);
red_3 = center_image(2:2:blocksize, 1:2:blocksize, 1);
red_4 = center_image(2:2:blocksize, 2:2:blocksize, 1);

green_1 = center_image(1:2:blocksize, 1:2:blocksize, 2);
green_2 = center_image(1:2:blocksize, 2:2:blocksize, 2);
green_3 = center_image(2:2:blocksize, 1:2:blocksize, 2);
green_4 = center_image(2:2:blocksize, 2:2:blocksize, 2);

blue_1 = center_image(1:2:blocksize, 1:2:blocksize, 3);
blue_2 = center_image(1:2:blocksize, 2:2:blocksize, 3);
blue_3 = center_image(2:2:blocksize, 1:2:blocksize, 3);
blue_4 = center_image(2:2:blocksize, 2:2:blocksize, 3);


diff_gr_1 = green_1 - red_1;
diff_gr_2 = green_2 - red_2;
diff_gr_3 = green_3 - red_3;
diff_gr_4 = green_4 - red_4;

diff_gb_1 = green_1 - blue_1;
diff_gb_2 = green_2 - blue_2;
diff_gb_3 = green_3 - blue_3;
diff_gb_4 = green_4 - blue_4;

var_gr_1 = var(diff_gr_1(:));
var_gr_2 = var(diff_gr_2(:));
var_gr_3 = var(diff_gr_3(:));
var_gr_4 = var(diff_gr_4(:));

var_gb_1 = var(diff_gb_1(:));
var_gb_2 = var(diff_gb_2(:));
var_gb_3 = var(diff_gb_3(:));
var_gb_4 = var(diff_gb_4(:));

%%
if (abs(var_gr_1 - var_gr_4 + var_gb_4 - var_gb_1) > abs(var_gr_2 - var_gr_3+var_gb_3 - var_gb_2)) ...
        && ( var_gr_1 + var_gb_4  > var_gr_4 + var_gb_1  ); %% RGGB
    display('pattern: RGGB')
elseif (abs(var_gr_1 - var_gr_4 + var_gb_4 - var_gb_1) > abs(var_gr_2 - var_gr_3+var_gb_3 - var_gb_2)) ...
        && ( var_gr_1 + var_gb_4  < var_gr_4 + var_gb_1  ); %% BGGR
    display('pattern: BGGR')
elseif (abs(var_gr_1 - var_gr_4 + var_gb_4 - var_gb_1) < abs(var_gr_2 - var_gr_3+var_gb_3 - var_gb_2)) ...
        &&( var_gr_2 + var_gb_3  > var_gr_3 + var_gb_2  ); %% GRBG
    display('pattern: GRBG')
elseif (abs(var_gr_1 - var_gr_4 + var_gb_4 - var_gb_1) < abs(var_gr_2 - var_gr_3+var_gb_3 - var_gb_2)) ...
        &&( var_gr_2 + var_gb_3  < var_gr_3 + var_gb_2  ); %% GBRG
    display('pattern: GBRG')
end

