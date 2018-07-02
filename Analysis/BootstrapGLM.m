%% Bootstraping
% Test if the model is predictive (% above chance?)

clear all;

% Load data given run
path1 = 'E:\hanae_data\Dura\GLMDura\myout_DL67_170405_1.mat';
path2 = 'E:\hanae_data\Dura\GLMDura\myout_DL67_170405_2.mat';
myout1 = load(path1);
myout1 = myout1.myout;
myout2 = load(path2);
myout2 = myout2.myout;
time = myout1.time;
nbcell = size(myout1.diff, 1);

%% Plot diff run (2 ways)
% 
%
% for c = 1 : 10% size(myout1.diff,1)
%     figure;
%     plot(time, myout1.diff(c,:), 'b', time, myout2.diff(c,:), 'r');
%     legend('diff run1', 'diff run2');
% end

%% Distance cell ref

rescomp = cell(nbcell, 1);
for cr = 1 : floor(nbcell)
    res = zeros(nbcell, size(time, 2));
    for cc = 1 : nbcell
        dcomp = abs(myout1.absdiff(cr,:) - myout2.absdiff(cc,:));
        %figure; plot(time, dref); hold on; plot(time, dcomp);
        %res(cc,:) = trapz(time, dcomp); % area under curve
        res(cc,:) = dcomp(20);
    end
    rescomp{cr} = res;
end

%% Diffmean

diffmean = zeros(1, nbcell);

for c = 1:nbcell
    meanc = rescomp{c};
    ref = meanc(c,1);
    meanc(c,:) = [];
    meanc = mean(meanc);
    meanc = meanc(1);
    diffmean(c) = meanc-ref;
end

%% Figure and % above chance

val = length(diffmean(diffmean>=0))*100/length(diffmean);
figure; hist(diffmean, 50);
line([0, 0], ylim, 'LineWidth', 2, 'Color', 'r');
title(['mouse:DL67, date:170405, run:1&2 - ', num2str(val), ' % above chance'])


