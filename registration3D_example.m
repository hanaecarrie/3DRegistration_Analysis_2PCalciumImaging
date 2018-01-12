%% ALIGNEMENT OF A SINGLE Z LEVEL IN A 3D VOLUME

clear all;
close all;
clc;

addpath(genpath('D:\Analysis_scripts\Dropbox\AndermannLab\users\arthur'));
startup;

%% STEP 0: PREPROCESSING 

% Choose datafile
mouse = 'DL68'; 
date = '170523';
run = 3;
path = sbxPath(mouse, date, run, 'sbx'); % path to data

% Get datafile info
info = sbxInfo(path);
nframes_total = info.max_idx + 1;
% almost always 27900, which is 30 minutes * 60 seconds/minute * 15.5 
f = 15.5; % Hz frequence to acquire data

% Choose  reasonable number of frames to study
nframes = 1000; % arbitrary reduce the number of considered frames

% Read data
data = sbxReadPMT(path, 0, nframes,  0, []); % size 512 x 796 x 1000

% See running state of the mouse
running = sbxSpeed(mouse, date, run);
time = 1:nframes_total;
figure; plot(time, running); title("Mouse Running State"); hold on;

%% DATA BEFORE REGISTRATION

% Choose a z level  (between 1 and 16) among the 15 levels
level = 5;
pos = level:15:nframes;

%%

% Display the 2D image for the fixed z level w.r.t. time (about 1image/s)
implay_a = implay(data(:,:,pos), length(pos));
set(implay_a.Parent, 'Name', 'Unregistered');

%% 1st STEP : XY ALIGNEMENT

% Compute xy reference for a fixed z level
zlevel_avg = averaget(data(:,:,pos)); % ref = average over the fixed z
%figure; imshow(zlevel_avg, []); title('Average xy for a fixed z');
%colorbar; hold on;

% Perform xy alignement for a fixed z level
first_align = data(:,:,:);
[optimizer, metric] = imregconfig('multimodal');
%optimizer.InitialRadius = optimizer.InitialRadius/3.5;
%optimizer.MaximumIterations = 300;

% IMREGISTRATION
% for i = 1:length(pos)
%     idx = pos(i);
%     first_align(:,:,idx) = imregister(data(:,:,idx),...
%         zlevel_avg, 'affine', optimizer, metric);
% end

% DFT REGISTRATION
target_fft = fft2(double(zlevel_avg));
for i = 1:length(pos)
    idx = pos(i);
    data_fft = fft2(double(data(:,:,idx)));
    [dftoutput, xyaligni] = dftregistration(target_fft, data_fft, 100);
    first_align(:,:,idx) = abs(ifft2(xyaligni)); % double
end

% Display xy alignment
implay_b = implay(first_align(:,:,pos), length(pos));
set(implay_b.Parent, 'Name', '1st step: xy registration');


%% Save video

v = VideoWriter('D:\Analysis_scripts\Dropbox\AndermannLab\users\hanae2\DL68_170523_3_allframes_zlevel5_xyregistration.avi');
open(v);
for k = 1:length(pos)
    writeVideo(v,mat2gray(double(first_align(:,:,pos(k)))));
end
close(v);

%% 2nd STEP :  REFERENCE FOR Z ALIGNEMENT

% Compute z reference (average over each level)
ref = zeros(512, 796, 15);

for zlevel = 1:15
    posi = zlevel:15:nframes;
    ref(:,:,zlevel) = averaget(first_align(:,:,posi));
    %figure; imshow(ref(:,:,zlevel), []); colorbar;
    % ref = average over the fixed z
end

%%  2nd STEP : Z ALIGNEMENT

% Perform z alignment

second_align = first_align(:,:,:);
count = 0;

for i = 1:length(pos)
    idx = pos(i);
    maxcorr = 0;
    corr_list = zeros(1, 15);
    for z = 1:15
        corr = corr2(first_align(:,:,idx), ref(:,:,z));
        corr_list(z) = corr;
        if corr > maxcorr
            maxcorr = corr;
            lev = z;
        end
    end
    if i == 1
        figure; plot(corr_list);
    end
    if lev ~= level
        count = 1;
        disp(i); disp(lev); disp 'yes';
        figure; plot(corr_list);
        superimposed_frame = cat(3, second_align(:,:,idx + level - lev),...
            first_align(:,:,idx));
        second_align(:,:,idx + level - lev) = averaget(superimposed_frame);
        % mean value
        second_align(:,:,idx) = zeros(512, 796); % 
    end
end

if count == 0
    disp("No z registration");
end

% Display z alignment
implay_c = implay(second_align(:,:,pos), length(pos));
set(implay_c.Parent, 'Name', '2nd step: z registration');

% z-interpolation
% XXX


%% 3nd STEP : NEW XY ALIGNEMENT

% Choose a z level  (between 1 and 16) among the 15 levels
level = 5;
pos = level:15:nframes;

% Compute new xy reference for a fixed z level
zlevel_new_avg = averaget(second_align(:,:,pos));
% ref = average over the fixed z
%figure; imshow(zlevel_new_avg, []); title('New average xy for a fixed z');
%colorbar; hold on;

% Perform xy alignement for a fixed z level
third_align = second_align(:,:,:);
% [optimizer, metric] = imregconfig('multimodal');

% IMREGISTRATION
% for i = 1:length(pos)
%     idx = pos(i);
%     third_align(:,:,idx) = imregister(second_align(:,:,idx),...
%         zlevel_new_avg, 'affine', optimizer, metric);
% end

% DFT REGISTRATION
new_target_fft = fft2(double(zlevel_avg));

for i = 1:length(pos)
    idx = pos(i);
    new_data_fft = fft2(double(second_align(:,:,idx)));
    [dftoutput, new_xyaligni] = dftregistration(new_target_fft, ...
        new_data_fft, 100);
    third_align(:,:,idx) = abs(ifft2(new_xyaligni)); % double
end

% Display xy alignment
implay_c = implay(third_align(:,:,pos), length(pos));
set(implay_c.Parent, 'Name', '3rd step: new xy registration');

% Disp error between registred and unregistred volumes
err = sqrt(immse(data,third_align));
fprintf('\n Root Mean-Squared Error (RMSE): %0.4f\n', err);
