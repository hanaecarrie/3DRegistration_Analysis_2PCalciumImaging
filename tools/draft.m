%% SCRIPT XYZT REGISTRATION

clear all;
close all;
clc;
addpath(genpath('D:\Analysis_scripts\Dropbox\AndermannLab\users\hanae'));

%% STEP 0: GET DATA 

disp('STEP 0: GET DATA')

% Choose datafile
mouse = 'DL89'; 
date = '171122';
nbrun = 3;

% Get datafile info
path = sbxPath(mouse, date, nbrun, 'sbx'); % path to data
info = sbxInfo(path);
nbframes_total = info.max_idx + 1;
% almost always 27900, which is 30 minutes * 60 seconds/minute * 15.5 Hz
nbplanes = uint16(info.otparam(3));

% Read data and running state
data = sbxReadPMT(path, 0, nbframes_total,  0, []); % 512 x 796 x 27900
running = sbxSpeed(mouse, date, nbrun);
time = 1:nbframes_total;

% Reshape data as a 4D matrix (x,y,z,t)
full_vol = reshape(data, [size(data, 1), size(data, 2), nbplanes, ...
    floor(nbframes_total/nbplanes)]);
%full_vol = full_vol(:,:,:,1:50); %XXX for test 512 x 796 x 30 x 3

%% STEP 1: MAKE REGISTRATION

disp('STEP 1: MAKE REGISTRATION')

% Parameters
%nPlanesForCorrelation = 11;
%nPlanesPerReferenceVolume = 15;
KeepingFactor = 0.8;
BlurFactor = 1;
%ReferenceVolumeIndex = 1:10;
%%
tic;
% Make xyzt registration (Alex Fratzl)
[correctedVolume, ZShifts, RowShiftsXYZ, ColumnShiftsXYZ,...
    RowShiftsXY, ColumnShiftsXY] = XYZTRegistrationTranslation(full_vol,...
    nPlanesForCorrelation, nPlanesPerReferenceVolume, ...
    ReferenceVolumeIndex, BlurFactor, KeepingFactor);
 toc;

%% STEP 2: SAVE RESULTS

disp('STEP 2: SAVE RESULTS');

% Choose a saving folder
save_folder_path = 'E:\hanae_data\alextry\';
    
% Create folders
foldername_begin = strcat('mouse', mouse, '_date', date, '_run', num2str(nbrun));
mkdir([save_folder_path foldername_begin]);
newdir = strcat(save_folder_path, foldername_begin, '\');

% Save registered data
mkdir([newdir 'Alexregistration']);
savingpathreg = strcat(newdir, 'Alexregistration\');

fig1 = figure;
plot(time(1:size(full_vol, 3):end), running(1:size(full_vol, 3):end));
saveas(fig1, strcat(savingpathreg, 'RunningState.png'));
save(strcat(savingpathreg, 'RunningState.mat'),'running');

fig2 = figure;
plot(ZShifts);
saveas(fig2, strcat(savingpathreg, 'ZShifts.png'));

% Save shifts
save(strcat(savingpathreg, 'ZShifts.mat'),'ZShifts');
save(strcat(savingpathreg, 'RowShiftsXY.mat'),'RowShiftsXY');
save(strcat(savingpathreg, 'RowShiftsXYZ.mat'),'RowShiftsXYZ');
save(strcat(savingpathreg, 'ColumnShiftsXY.mat'),'ColumnShiftsXY');
save(strcat(savingpathreg, 'ColumnShiftsXYZ.mat'),'ColumnShiftsXYZ');

% Videos per zlevel and .mat file
for i = 1:size(full_vol, 3)

title = strcat(savingpathreg, 'zlevel', num2str(i),...
    '_', num2str(size(full_vol, 4)),'volumes_BF1_KF095_RVI1_full.avi');
seq = permute(correctedVolume, [1,2,4,3]);
seq = mat2gray(double(seq(:,:,:,i)));

WriteVideo(title, seq);

% XXX
seq_1 = seq(:,:,1:465);
save(strcat(savingpathreg, 'zlevel', num2str(i),...
     '_', num2str(size(full_vol, 4)), 'volumes_BF1_KF095_RVI1_1.mat'),...
     'seq_1');
seq_2 = seq(:,:,466:930);
save(strcat(savingpathreg, 'zlevel', num2str(i),...
     '_', num2str(size(full_vol, 4)), 'volumes_BF1_KF095_RVI1_2.mat'),...
     'seq_2');
% seq_3 = seq(:,:,931:1395);
% save(strcat(savingpathreg, 'zlevel', num2str(i),...
%      '_', size(full_vol, 4), 'volumes_BF1_KF095_RVI1_3.mat'), 'seq_3');
% seq_4 = seq(:,:,1396:end);
% save(strcat(savingpathreg, 'zlevel', num2str(i),...
%      '_', size(full_vol, 4), 'volumes_BF1_KF095_RVI1_4.mat'), 'seq_4');

end

% XZ Crosssection
res = zeros(size(full_vol, 1),size(full_vol,3),size(full_vol,4));
% XXX
for i= 1:size(full_vol, 4)
vol_y400 = mat2gray(double(correctedVolume(:, 393:402,:,i)));
avg_vol_y400 = mean(vol_y400, 2);
avg_vol_y400 = reshape(avg_vol_y400, [size(avg_vol_y400,1), size(avg_vol_y400,3)]);
res(:,:,i) = avg_vol_y400;
end

save(strcat(savingpathreg, 'xzcrosssection_avgy393to402.mat'), 'res');
WriteVideo(strcat(savingpathreg, 'xzcrosssection_avgy393to402.avi'), res);

% Save control, unregistered data
mkdir([newdir 'noregistration']);
savingpathunreg = strcat(newdir, 'noregistration\');

% Videos per zlevel and .mat file
for i = 1:size(full_vol, 3)

title = strcat(savingpathunreg, 'zlevel', num2str(i),...
    '_', num2str(size(full_vol,4)), 'volumes_BF1_KF095_RVI1_full.avi');
seq = permute(full_vol, [1,2,4,3]);
seq = mat2gray(double(seq(:,:,:,i)));

WriteVideo(title, seq);
% XXX
seq_1 = seq(:,:,1:465);
save(strcat(savingpathunreg, 'zlevel', num2str(i),...
     '_', num2str(size(full_vol, 4)), 'volumes_BF1_KF095_RVI1_1.mat'),...
     'seq_1');
seq_2 = seq(:,:,466:930);
save(strcat(savingpathunreg, 'zlevel', num2str(i),...
     '_', num2str(size(full_vol, 4)), 'volumes_BF1_KF095_RVI1_2.mat'),...
     'seq_2');
% seq_3 = seq(:,:,931:1395);
% save(strcat(savingpathunreg, 'zlevel', num2str(i),...
%      '_1860volumes_BF1_KF095_RVI1_3.mat'), 'seq_3');
% seq_4 = seq(:,:,1396:end);
% save(strcat(savingpathunreg, 'zlevel', num2str(i),...
%      '_1860volumes_BF1_KF095_RVI1_4.mat'), 'seq_4');
end

% XZ Crosssection
res = zeros(size(full_vol, 1),size(full_vol,3),size(full_vol,4));
% XXX
for i= 1:size(full_vol,4)
vol_y400 = mat2gray(double(full_vol(:, 393:402,:,i)));
avg_vol_y400 = mean(vol_y400, 2);
avg_vol_y400 = reshape(avg_vol_y400, [size(avg_vol_y400,1), size(avg_vol_y400,3)]);
res(:,:,i) = avg_vol_y400;
end

save(strcat(savingpathunreg, 'xzcrosssection_avgy393to402.mat'), 'res');
WriteVideo(strcat(savingpathunreg, 'xzcrosssection_avgy393to402.avi'), res);

