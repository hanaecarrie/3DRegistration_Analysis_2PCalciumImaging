
% need to open the folder:
% 'E:\hanae_data\alextry2\mouseXXXX_dateXXXXXX_runX\noregistration'
clear all;
close all;
clc;

%% Bin in time (every n frames)

seq = cell(14, 1); % here 14 z levels
n = 10; % number of frames in a bin

for i = 1:14
    disp(i);
    load(strcat('zlevel', num2str(i),...
        '_1860volumes_11PPR_5PFC_BF3_KF0_35_RVI1_1.mat'));
    load(strcat('zlevel', num2str(i),...
        '_1860volumes_11PPR_5PFC_BF3_KF0_35_RVI1_2.mat'));
    load(strcat('zlevel', num2str(i),...
        '_1860volumes_11PPR_5PFC_BF3_KF0_35_RVI1_3.mat'));
    load(strcat('zlevel', num2str(i),...
        '_1860volumes_11PPR_5PFC_BF3_KF0_35_RVI1_4.mat'));
    seqi = cat(3, seq_1, seq_2, seq_3, seq_4);
    seqi = reshape(seqi, [size(seqi, 1), size(seqi, 2), n, ...
        idivide(int16(size(seqi, 3)),n)]);
    seqi = mean(seqi, 3);
    seqi = squeeze(permute(seqi, [1, 2, 4, 3]));
    seq{i} = seqi;
    clear seq_1;
    clear seq_2;
    clear seq_3;
    clear seq_4;
    clear seqi;
end

%% Bin in Z

binseq = cat(4, seq{1},seq{2},seq{3},seq{4},seq{5},seq{6},seq{7},seq{8},...
    seq{9},seq{10},seq{11},seq{12},seq{13},seq{14});
binseq = mean(binseq, 4);

%% Save video and data

WriteVideo('binseq_unreg.avi', binseq);
save('binseq_unreg.mat', 'binseq');
