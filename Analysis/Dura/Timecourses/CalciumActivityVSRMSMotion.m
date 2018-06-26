% Plot Calcium Activity VS Root Mean Square Motion

startup;
clear all;
clc;

%% Load data

mouse = 'DL68';
date = '170523';
run = 2;
zlev = 6;
foldername = strcat('mouse', mouse, '_date', date, '_run', num2str(run));
path = strcat('E:\hanae_data\alextry2\', foldername, '\Alexregistration\');

load(strcat(path,'zlevel6_1860volumes_11PPR_5PFC_BF3_KF0_35_RVI1_1.mat'))
load(strcat(path,'zlevel6_1860volumes_11PPR_5PFC_BF3_KF0_35_RVI1_2.mat'))
load(strcat(path,'zlevel6_1860volumes_11PPR_5PFC_BF3_KF0_35_RVI1_3.mat'))
load(strcat(path,'zlevel6_1860volumes_11PPR_5PFC_BF3_KF0_35_RVI1_4.mat'))
data = cat(3, seq_1, seq_2, seq_3, seq_4);

load(strcat(path,'ColumnShiftsXY.mat'))
load(strcat(path,'ColumnShiftsXYZ.mat'))
load(strcat(path,'RowShiftsXY.mat'))
load(strcat(path,'RowShiftsXYZ.mat'))
%load(strcat(path,'RunningState.mat'))
load(strcat(path,'ZShifts.mat'))

ColumnShifts = ColumnShiftsXYZ + ColumnShiftsXY;
RowShifts = RowShiftsXYZ + RowShiftsXY;

%% Compute RMS motion

DeltaZ = diff(ZShifts);

for i = 1:14
    DeltaRow = diff(RowShifts(i,:));
    DeltaColumn = diff(ColumnShifts(i,:));
    RmsMotion = sqrt(DeltaRow.^2 + DeltaColumn.^2 + DeltaZ.^2);
    figure; plot(smoothdata(RmsMotion, 'gaussian', 10));% ylim([0,3]);
end

%% Get ROI

ROI = data;

for i = 1000: 1100
example = data(:,:,10);
imshow(example);
end
h = imfreehand;

%% Intensity of ROI for a single zlevel

meanIntensityValue = zeros(1, size(ROI, 3));
for t = 1:size(ROI, 3)
        meanIntensityValue(1, t) = mean2(ROI(:,:,t));
end

figure; plot(smooth(meanIntensityValue));


