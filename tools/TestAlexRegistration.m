%% Test Alex Registration
%startup;
clear all;
clc;
cd D:\Analysis_scripts\Dropbox\AndermannLab\users\hanae\code\XYZTRegistrationAlex

% load data
seq = load('E:\hanae_data\test_fMRI_4D_data\filtered_func_data.mat');
seq = seq.fmri_data;
seq = seq(:,:,1:15,1:12);
sizeseq = size(seq); % 64 x 64 x 21 x 180

% Choose shifts
FakeRowShiftsXYZ = zeros(sizeseq(3), sizeseq(4));
FakeColumnShiftsXYZ = zeros(sizeseq(3), sizeseq(4));
FakeZShifts = zeros(1, sizeseq(4));
FakeZShifts(1, 2) = 1;
FakeZShifts(1, 4) = 2;
FakeZShifts(1, 6) = -3;

% Apply Shifts to misaligned the sequence of volumes
MisalignedVolume = ApplyXYZShifts(seq, FakeZShifts, FakeRowShiftsXYZ, ...
    FakeColumnShiftsXYZ);

% Parameters
KeepingFactor = 0.9;
BlurFactor = 1;
ReferenceVolumeIndex = 1;

% Registration
[correctedVolume, ZShifts, RowShiftsXYZ, ColumnShiftsXYZ,...
    RowShiftsXY, ColumnShiftsXY] = XYZTRegistrationTranslation(...
    MisalignedVolume, ReferenceVolumeIndex, BlurFactor, KeepingFactor);
