%% SCRIPT XYZT REGISTRATION
clear all;
close all;
clc;

addpath(genpath('D:\Analysis_scripts\Dropbox\AndermannLab\users\arthur'));
startup;
%%

for nbrun = 1:4
    
%% STEP 0: GET DATA 

% Choose datafile
mouse = 'DL68'; 
date = '170523';
run = nbrun;
path = sbxPath(mouse, date, run, 'sbx'); % path to data

% Get datafile info
info = sbxInfo(path);
nframes_total = info.max_idx + 1;
% almost always 27900, which is 30 minutes * 60 seconds/minute * 15.5 

% Read data
%data = sbxReadPMT(path, 0, nframes_total,  0, []); % size 512 x 796 x 27900

% See running state of the mouse
running = sbxSpeed(mouse, date, run);
time = 1:nframes_total;


%% STEP 1: MAKE REGISTRATION

% reshape data as a 4D matrix (x,y,z,t)
full_vol = reshape(data, [size(data, 1), size(data, 2), 15, 1860]);
full_vol = full_vol(:,:,1:14,:); % remove last zlevel to get an even number of zlevel

% Parameters
nPlanesForCorrelation = 5;
nPlanesPerReferenceVolume = 12;
KeepingFactor = 0.35;
BlurFactor = 3;
ReferenceVolumeIndex = 1;

% Make xyzt registration (Alex Fratzl)
[correctedVolume, ZShifts, RowShiftsXYZ, ColumnShiftsXYZ,...
    RowShiftsXY, ColumnShiftsXY] = XYZTRegistrationTranslation(full_vol,...
    nPlanesForCorrelation, nPlanesPerReferenceVolume, ...
    ReferenceVolumeIndex, BlurFactor, KeepingFactor);

%% Save results

% Create folders
foldername_begin = strcat('mouse', mouse, '_date', date, '_run', num2str(run));
mkdir(['E:\hanae_data\alextry2\' foldername_begin]);
newdir = strcat('E:\hanae_data\alextry2\', foldername_begin, '\');
mkdir([newdir 'Alexregistration']);
savingpathreg = strcat(newdir, 'Alexregistration\');

fig1 = figure;
plot(time(1:15:end), running(1:15:end));
saveas(fig1, strcat(savingpathreg, 'RunningState.png'));
save(strcat(savingpathreg, 'RunningState.mat'),'running');

% Videos per zlevel and .mat file
for i = 1:14

title = strcat(savingpathreg, 'zlevel', num2str(i),...
    '_1860volumes_11PPR_5PFC_BF3_KF035_RVI1_full.avi');
seq = permute(correctedVolume, [1,2,4,3]);
seq = mat2gray(double(seq(:,:,:,i)));

WriteVideo(title, seq);

seq_1 = seq(:,:,1:465);
save(strcat(savingpathreg, 'zlevel', num2str(i),...
     '_1860volumes_11PPR_5PFC_BF3_KF0_35_RVI1_1.mat'), 'seq_1');
seq_2 = seq(:,:,466:930);
save(strcat(savingpathreg, 'zlevel', num2str(i),...
     '_1860volumes_11PPR_5PFC_BF3_KF0_35_RVI1_2.mat'), 'seq_2');
seq_3 = seq(:,:,931:1395);
save(strcat(savingpathreg, 'zlevel', num2str(i),...
     '_1860volumes_11PPR_5PFC_BF3_KF0_35_RVI1_3.mat'), 'seq_3');
seq_4 = seq(:,:,1396:end);
save(strcat(savingpathreg, 'zlevel', num2str(i),...
     '_1860volumes_11sPPR_5PFC_BF3_KF0_35_RVI1_4.mat'), 'seq_4');


end

% Save shift
save(strcat(savingpathreg, 'ZShifts.mat'),'ZShifts');
save(strcat(savingpathreg, 'RowShiftsXY.mat'),'RowShiftsXY');
save(strcat(savingpathreg, 'RowShiftsXYZ.mat'),'RowShiftsXYZ');
save(strcat(savingpathreg, 'ColumnShiftsXY.mat'),'ColumnShiftsXY');
save(strcat(savingpathreg, 'ColumnShiftsXYZ.mat'),'ColumnShiftsXYZ');

fig2 = figure;
plot(ZShifts);
saveas(fig2, strcat(savingpathreg, 'ZShifts.png'));

% XZ Crosssection
res = zeros(512,14,1860);

for i= 1:1860
vol_y400 = mat2gray(double(correctedVolume(:, 393:402,:,i)));
avg_vol_y400 = mean(vol_y400, 2);
avg_vol_y400 = reshape(avg_vol_y400, [size(avg_vol_y400,1), size(avg_vol_y400,3)]);
res(:,:,i) = avg_vol_y400;
end

save(strcat(savingpathreg, 'xzcrosssection_avgy393to402.mat'), 'res');
WriteVideo(strcat(savingpathreg, 'xzcrosssection_avgy393to402.avi'), res);


%% Save control: unregistered 

mkdir([newdir 'noregistration']);
savingpathunreg = strcat(newdir, 'noregistration\');

% Videos per zlevel and .mat file
for i = 1:14

title = strcat(savingpathunreg, 'zlevel', num2str(i),...
    '_1860volumes_11PPR_5PFC_BF3_KF035_RVI1_full.avi');
seq = permute(full_vol, [1,2,4,3]);
seq = mat2gray(double(seq(:,:,:,i)));

WriteVideo(title, seq);

seq_1 = seq(:,:,1:465);
save(strcat(savingpathunreg, 'zlevel', num2str(i),...
     '_1860volumes_11PPR_5PFC_BF3_KF0_35_RVI1_1.mat'), 'seq_1');
seq_2 = seq(:,:,466:930);
save(strcat(savingpathunreg, 'zlevel', num2str(i),...
     '_1860volumes_11PPR_5PFC_BF3_KF0_35_RVI1_2.mat'), 'seq_2');
seq_3 = seq(:,:,931:1395);
save(strcat(savingpathunreg, 'zlevel', num2str(i),...
     '_1860volumes_11PPR_5PFC_BF3_KF0_35_RVI1_3.mat'), 'seq_3');
seq_4 = seq(:,:,1396:end);
save(strcat(savingpathunreg, 'zlevel', num2str(i),...
     '_1860volumes_11PPR_5PFC_BF3_KF0_35_RVI1_4.mat'), 'seq_4');
end

% XZ Crosssection
res = zeros(512,14,1860);

for i= 1:1860
vol_y400 = mat2gray(double(full_vol(:, 393:402,:,i)));
avg_vol_y400 = mean(vol_y400, 2);
avg_vol_y400 = reshape(avg_vol_y400, [size(avg_vol_y400,1), size(avg_vol_y400,3)]);
res(:,:,i) = avg_vol_y400;
end

save(strcat(savingpathunreg, 'xzcrosssection_avgy393to402.mat'), 'res');
WriteVideo(strcat(savingpathunreg, 'xzcrosssection_avgy393to402.avi'), res);

end
