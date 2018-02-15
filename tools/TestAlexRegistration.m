%% Test Alex Registration
%startup;
clear all;
clc;
%cd D:\Analysis_scripts\Dropbox\AndermannLab\users\hanae\code\XYZTRegistrationAlex

% load data
full_vol = load('E:\hanae_data\test_fMRI_4D_data\filtered_func_data.mat');
full_vol = full_vol.fmri_data;
full_vol = full_vol(:,:,1:15,1:12);
sizeseq = size(full_vol); % 64 x 64 x 21 x 180

% Choose shifts
FakeRowShiftsXYZ = zeros(sizeseq(3), sizeseq(4));
FakeRowShiftsXYZ(7, 10) = 1;
FakeColumnShiftsXYZ = zeros(sizeseq(3), sizeseq(4));
FakeColumnShiftsXYZ(8, 5) = 4;
FakeZShifts = zeros(1, sizeseq(4));
FakeZShifts(1, 2) = 1.6;
FakeZShifts(1, 4) = 5.2;
FakeZShifts(1, 6) = -3.5;

% Apply Shifts to misaligned the sequence of volumes
MisalignedVolume = ApplyXYZShifts(full_vol, FakeZShifts, FakeRowShiftsXYZ, ...
    FakeColumnShiftsXYZ);
% MisalignedVolume = ApplyXYShifts(full_vol, FakeRowShiftsXYZ, ...
%     FakeColumnShiftsXYZ);
% MisalignedVolume = ApplyZShifts(MisalignedVolume, FakeZShifts);

% Parameters
KeepingFactor = 0.95;
BlurFactor = 1;
ReferenceVolumeIndex = 1;

% Registration
[correctedVolume, ZShifts, RowShiftsXYZ, ColumnShiftsXYZ,...
    RowShiftsXY, ColumnShiftsXY] = XYZTRegistrationTranslation(...
    MisalignedVolume, ReferenceVolumeIndex, BlurFactor, KeepingFactor);
