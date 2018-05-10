
path = strcat('D:\twophoton_data\2photon\scan\DL89\171122_DL89\',...
    '171122_DL89_run1003\DL89_171122_1002.signals');
signals = load(path, '-mat');
cellsortall = signals.cellsort;
[cellsortall(:).plane] = deal(3);

for plane = 4:29
path = strcat('D:\twophoton_data\2photon\scan\DL89\171122_DL89\',...
    '171122_DL89_run', num2str(1000+plane), '\DL89_171122_', ...
    num2str(1000+plane-1),'.signals');
signals = load(path, '-mat');
cellsort = signals.cellsort;
[cellsort(:).plane] = deal(plane);
cellsortall = cell2struct(cellfun(@vertcat,...
    struct2cell(cellsortall),struct2cell(cellsort),'uni',0),...
    fieldnames(cellsortall),1);
end

%%
plane = 21;
run = 1;
path = strcat('D:\twophoton_data\2photon\scan\DL89\171122_DL89\',...
        '171122_DL89_run', num2str(run*1000+plane), '\DL89_171122_', ...
        num2str(run*1000+plane-1), '.signals');
signals = load(path, '-mat');
cellsort = signals.cellsort;
roi = 20;
timecour = cellsort(roi).timecourse.dff_axon_norm;
maskref = cellsort(roi).mask;
figure;imagesc(maskref); title('mask ref');
%%
correl = zeros(1,35);
plane = 19;
for roi = 16
    path = strcat('D:\twophoton_data\2photon\scan\DL89\171122_DL89\',...
        '171122_DL89_run', num2str(run*1000+plane), '\DL89_171122_', ...
        num2str(run*1000+plane-1), '.signals');
signals = load(path, '-mat');
cellsort = signals.cellsort;
%timecour = cellsort(roi).timecourse.dff_axon_norm;
mask = cellsort(roi).mask;
disp(roi);
correl(roi) = corr2(mask, maskref);
%figure; imagesc(mask); title(num2str(roi));
end

%%
%[cellsortall(:).plane] = deal(3);

for plane = 4:29
path = strcat('D:\twophoton_data\2photon\scan\DL89\171122_DL89\',...
    '171122_DL89_run', num2str(1000+plane), '\DL89_171122_', ...
    num2str(1000+plane-1),'.signals');
signals = load(path, '-mat');
cellsort = signals.cellsort;
[cellsort(:).plane] = deal(plane);
cellsortall = cell2struct(cellfun(@vertcat,...
    struct2cell(cellsortall),struct2cell(cellsort),'uni',0),...
    fieldnames(cellsortall),1);
end

%%
nplanes = 30;
meantimecourse = zeros(nplanes, 6*930);
%%
for plane = 25:nplanes
%     if plane ~= 1 && plane ~= 2 && plane ~= 3 && plane ~= 9 && plane ~= 28 && plane ~= 29
        path = strcat('D:\twophoton_data\2photon\scan\DL89\171122_DL89\',...
            '171122_DL89_run', num2str(100+plane), '\DL89_171122_', ...
            num2str(100+plane-1), '.signals');
        signals = load(path, '-mat');
        cellsort = signals.cellsort;
        timecourses = zeros(size(cellsort, 2),6*930/2);
        for run = 1:6
                path = strcat('D:\twophoton_data\2photon\scan\DL89\171122_DL89\',...
            '171122_DL89_run', num2str(run*100+plane), '\DL89_171122_', ...
            num2str(run*100+plane-1), '.signals');
                signals = load(path, '-mat');
                cellsort = signals.cellsort;
                for roi = 1:size(cellsort, 2)
                    timecourses(roi,1+(run-1)*1860/2:1860/2*run) = cellsort(roi).timecourse.dff_axon_norm;
                end
        end
        meantimecourse(plane,:) = nanmean(timecourses, 1);
%     else
%         meantimecourse(plane,:) = NaN;
%     end
end
%%
smoothtimecourse = meantimecourse(:,:);
for i = 1:nplanes
    smoothtimecourse(i,:) = smooth(smoothtimecourse(i,:));
end
%%
 
 inBetween = [min(smoothtimecourse(:,:)), fliplr(max(smoothtimecourse(:,:)))];
 fill([x, fliplr(x)], inBetween, [0,0,0]+0.8, 'LineStyle','none');
 hold on;
plot(x, nanmean(smoothtimecourse(:,:)));
hold on; plot(x, runningstate/100 -0.2, 'b');
xlabel('time (min)'); ylabel('mean normalized ddf across ROIs (ratio)');
title(strcat('DL89 171122 runs1to4 plane4to27 - mean neuronal activity during the imaging session'));
% legend('range of dff', 'dff', 'running state');

%%

timecour = zeros(4,930);
planeroi = [19, 20,21,22; 16,19,20,26];
for i = 1:4
    plane = planeroi(1,i);
    roi = planeroi(2,i);
   % for run = 1:4
    path = strcat('D:\twophoton_data\2photon\scan\DL89\171122_DL89\',...
        '171122_DL89_run', num2str(run*1000+plane), '\DL89_171122_', ...
        num2str(run*1000+plane-1), '.signals');
signals = load(path, '-mat');
cellsort = signals.cellsort;
timecour(i,:) = cellsort(roi).timecourse.dff_axon_norm;
%mask = cellsort(roi).mask;
%disp(roi);
%correl(roi) = corr2(mask, maskref);
%figure; imagesc(mask); title(num2str(roi));
end
%

