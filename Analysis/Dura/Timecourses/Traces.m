% Script Traces Dura
clear all;
clc;

% Parameters
mouse = 'DL89';
date = '171122';
mycmap = load('D:\Analysis_scripts\Dropbox\AndermannLab\users\hanae\code\utils\cmap_bluewhitered.mat');
mycmap = mycmap.mycmap_BlueWhiteRed;


%% all planes

nbrois = zeros(1,30);

for plane = 1:30
    runs = (1:6)*100 + plane;
    if plane ~= 8 && plane ~= 9 && plane ~= 20 && plane ~= 30
        disp(plane)
        % path = sbxPath(mouse, date, runs(1), 'signals');
        path = strcat('D:\twophoton_data\2photon\scan\DL89\171122_DL89\',...
            '171122_DL89_run', num2str(runs(1)), ...
            '\DL89_171122_', num2str(runs(1)-1), '.signals');
        cellsort = load(path, '-mat'); cellsort = cellsort.cellsort;
        nbrois(plane) = size(cellsort,2)-1;
    end
end

%% timecourses

timecourseallROIS = zeros(sum(nbrois), 5580);

for plane = 1:30
    disp(plane)
    runs = (1:6)*100 + plane;
    for roi = 1:nbrois(plane)
        timecourse = zeros(1, 5580);
        for run = runs
            % path = sbxPath(mouse, date, run, 'signals');
            path = strcat('D:\twophoton_data\2photon\scan\DL89\171122_DL89\',...
            '171122_DL89_run', num2str(run), ...
            '\DL89_171122_', num2str(run-1), '.signals');
            if exist(path, 'file')
                cellsort = load(path, '-mat');
                cellsort = cellsort.cellsort;
                nb = (run-plane)/100;
                timecourse(930*(nb-1)+1:nb*930) =  cellsort(roi).timecourse.dff_axon_norm;
            end
        end
        timecourseallROIS(roi + sum(nbrois(1:plane-1)), :) = timecourse;
    end
end

%%
imagesc(timecourseallROIS);  colorbar; colormap(hot); caxis([0 1]);
heatmap(timecourseallROIS, 'grid', 'off', 'Colormap', hot);
caxis([0 1]);

%%

tcallROIS = timecourseallROIS;

for i = 1:size(tcallROIS, 1)
   meanbaseline = mean(tcallROIS(i,1:1860));
   stdbaseline = std(tcallROIS(i,1:1860));
   tcallROIS(i,:) = (tcallROIS(i,:) - meanbaseline);
end

imagesc(tcallROIS);  colorbar; colormap(hot);caxis([0 1]);

%%

figure();
timecourseallROISsmooth = timecourseallROIS;
for i = 15:size(timecourseallROISsmooth, 1)
timecourseallROISsmooth(i,:) = smooth(timecourseallROIS(i,:));
meanbaseline = mean(timecourseallROISsmooth(i,1:1860));
timecourseallROISsmooth(i,:) = (timecourseallROISsmooth(i,:));

end
imagesc(timecourseallROISsmooth/2); colorbar; colormap(hot);
caxis([0 0.6]);



%% masks

masksallplanes = zeros(512, 796, 30);

for plane = 1:30
    disp(plane)
    runs = (1:6)*100 + plane;
    maskplane = zeros(512, 796);
    disp(nbrois(plane));
    for roi = 1:nbrois(plane)-1
        path = sbxPath(mouse, date, runs(1), 'signals');
        cellsort = load(path, '-mat');
        cellsort = cellsort.cellsort;
        % figure;imshow(cellsort(roi).mask);
        maskplane = maskplane+cellsort(roi).mask;
        masksallplanes(:,:,plane) = maskplane;
    end
end

%% projection all masks

allmasks = zeros(512, 796);
for plane = 1:30
    allmasks = allmasks+masksallplanes(:,:,plane);
end

%% detecting same rois across planes

nbuniquerois = zeros(1,30);
tracesuniquesrois = timecourseallROISsmooth;
idx = 0;
indexes = [];
for plane = 1:30
    disp(plane)
    runs = (1:6)*100 + plane;
    if plane == 1
        nbuniquerois(1) = nbrois(1);
    else
    previousmask = masksallplanes(:,:,plane-1);
    if plane == 21
        previousmask = masksallplanes(:,:,plane-2);
    elseif plane == 10
        previousmask = masksallplanes(:,:,plane+1);
    end
    nbuniquerois(plane) = nbrois(plane);
    for roi = 1:nbrois(plane)-1
        % path = sbxPath(mouse, date, runs(1), 'signals');
        path = strcat('D:\twophoton_data\2photon\scan\DL89\171122_DL89\',...
            '171122_DL89_run', num2str(runs(1)), ...
            '\DL89_171122_', num2str(runs(1)-1), '.signals');
        cellsort = load(path, '-mat');
        cellsort = cellsort.cellsort;
        % figure;imshow(cellsort(roi).mask);
        mask = cellsort(roi).mask;
        overlay = mask.*previousmask;
        overscore = sum(sum(overlay));
        maskscore = sum(sum(mask));
        if overscore/maskscore >= 0.5
            nbuniquerois(plane) = nbuniquerois(plane) - 1;
            idx = sum(nbrois(1:plane-1))+roi;
            indexes = cat(1,indexes, idx);
        end
    end
    end
end

%%

for i = 1:length(indexes)
    disp(indexes(i));
    tracesuniquesrois(indexes(i),:) = NaN(1, 5580);
end

tracesuniquesrois(isnan(tracesuniquesrois(:,1)),:) = [];

%%
maxperROI = max(timecourseallROIS, [], 2);

timecourseallROISnorm = timecourseallROIS;
for i = 1:size(timecourseallROIS, 1)
    timecourseallROISnorm(i,:) = timecourseallROISnorm(i,:)-min(timecourseallROISnorm(i,:));
    timecourseallROISnorm(i,:) = timecourseallROISnorm(i,:)/maxperROI(i);
end

%% sorting 1

% traces = timecourseallROIS;
traces = tracesuniquesrois;

score = zeros(size(traces,1),1);
for i = 1: size(traces,1)
  score(i) = sum(traces(i,1900:2790));
end

[score_sorted, score_order] = sort(score);
newtraces = traces(score_order,:);

xlabel = 1:size(newtraces,2);
xlabel(mod(xlabel,930)~= 0)= NaN;
ylabel = 1:size(newtraces,1);
ylabel(mod(ylabel,100)~= 0)= NaN;

%h = heatmap(newtraces, 'grid', 'off', 'Colormap', hot);
caxis([0 0.6]);
%imshow(h);

imagesc(newtraces/2);
colormap('hot');caxis([0 1]); colorbar; caxis([0 0.6]);
set(gca,'XTick',0:930:size(newtraces,2));
set(gca,'YTick',0:100:size(newtraces,1));

%%



%%
traces21 = traces(438:438+nbrois(21),:);

score21 = zeros(size(traces21,1),1);
for i = 1: size(traces21,1)
  score21(i) = sum(traces21(i,1880:1900));
end

[score21_sorted, score21_order] = sort(score21, 'descend');
traces21 = traces21(score21_order,:);

score21 = zeros(size(traces21,1),1);
for i = 1: size(traces21,1)
  score21(i) = sum(traces21(i,1900:2700));
end

[score21_sorted, score21_order] = sort(score21(1:30,:));
sortorder = cat(1, score21_order(1:30), (31:41)');
traces21 = traces21(sortorder,:);


% score21 = zeros(size(traces21,1),1);
% for i = 1: size(traces21,1)
%   score21(i) = sum(traces21(i,1900:2790/4));
% end
% 
% [score21_sorted, score21_order] = sort(score21);
% traces21 = traces21(score21_order,:);


% heatmap(traces21/2, 'grid', 'off', 'Colormap', hot); caxis([0 0.6]);
imagesc(traces21/2);
colormap('hot');caxis([0 0.6]); colorbar;
set(gca,'XTick',0:930:size(newtraces21,2));
set(gca,'XTicklabels',{'0', '30', '60', '90', '120','150', '180'});
xlabel('time (min)');
set(gca,'YTick',0:10:size(newtraces21,1));
ylabel('ROI number');

%% mean volume

path1 = 'E:\hanae_data\Dura\registrationFiles\17-Apr-2018_13-32-21\volumeregaffine\DL89_171122_1_volumeregaffine.sbx';
path2 = 'E:\hanae_data\Dura\registrationFiles\17-Apr-2018_14-17-43\volumeregacrossrunsZ\DL89_171122_2_volumeregacrossrunsZ.sbx';
path4 = 'E:\hanae_data\Dura\registrationFiles\17-Apr-2018_15-54-07\volumeregacrossrunsZ\DL89_171122_4_volumeregacrossrunsZ.sbx';
path3 = 'E:\hanae_data\Dura\registrationFiles\17-Apr-2018_15-05-45\volumeregacrossrunsZ\DL89_171122_3_volumeregacrossrunsZ.sbx';
path5 = 'E:\hanae_data\Dura\registrationFiles\17-Apr-2018_16-42-41\volumeregacrossrunsZ\DL89_171122_5_volumeregacrossrunsZ.sbx';
path6 = 'E:\hanae_data\Dura\registrationFiles\17-Apr-2018_17-29-43\volumeregacrossrunsZ\DL89_171122_6_volumeregacrossrunsZ.sbx';

vol1 = sbxReadPMT(path1);
vol1 = reshape(vol1, [512, 796, 30, 930]);
vol1 = mean(vol1, 4);
proj1 = sum(vol1, 3);

vol2 = sbxReadPMT(path2);
vol2 = reshape(vol2, [512, 796, 30, 930]);
vol2 = mean(vol2, 4);
proj2 = sum(vol2, 3);

vol3 = sbxReadPMT(path3);
vol3 = reshape(vol3, [512, 796, 30, 930]);
vol3 = mean(vol3, 4);
proj3 = sum(vol3, 3);

vol4 = sbxReadPMT(path4);
vol4 = reshape(vol4, [512, 796, 30, 930]);
vol4 = mean(vol4, 4);
proj4 = sum(vol4, 3);

vol5 = sbxReadPMT(path5);
vol5 = reshape(vol5, [512, 796, 30, 930]);
vol5 = mean(vol5, 4);
proj5 = sum(vol5, 3);

vol6 = sbxReadPMT(path6);
vol6 = reshape(vol6, [512, 796, 30, 930]);
vol6 = mean(vol6, 4);
proj6 = sum(vol6, 3);

proj = proj1 + proj2 + proj3 + proj4 + proj5 +proj6;

%% plot superimpose Rois map and projection

io = mat2gray(proj(10:end-10,80:end-80));
%iob = imbinarize(allmasks(10:end-10,80:end-80));
iob = imbinarize(double(mask(10:end-10,80:end-80)));
green=zeros(size(io,1),size(io,2),3);
green(:,:,2)=1;
iob_p=bwperim(iob);

figure,imshow(io)
hold all
h=imshow(green);
set(h,'AlphaData',iob_p);


%%
 
tracesbeforeCSD = newtraces(:,1:930*2);
tracesafterCSD = newtraces(:,930*3+1:end);
running = Running;
running(running <0) = 0;

for i = 1:682
    tracesbeforeCSD(i,:) = smooth(tracesbeforeCSD(i,:));
    tracesafterCSD(i,:) = smooth(tracesafterCSD(i,:));
end

before = cat(1, running(1:930*2)', tracesbeforeCSD(21,:));
[~, order] = sort(before(1,:));
beforesort = before;
beforesort = beforesort(:,order);
plot(beforesort(1,:));

scatter(beforesort(1,:), beforesort(2,:));
scatter(running(1:930*2), (tracesbeforeCSD(15,:)));
xlim([0 25]); ylim([0 1]);
hold on;
scatter(running(1+930*3:end), (tracesafterCSD(15,:)), 'r');
xlim([0 25]); ylim([0 1]);

%%
n = 6;
% % 
dff1all = zeros(682,62);
dff2all = zeros(682,155);

for cell = 1:682
    disp(cell);

meanrun = reshape(running', [n 5580/n]);
meanrun = mean(meanrun);
meanbefore = reshape(tracesbeforeCSD(cell,:), [n 1860/n]);
meanbefore = mean(meanbefore);
meanafter = reshape(tracesafterCSD(cell,:), [n 3*930/n]);
meanafter = mean(meanafter);
% 
% scatter(meanrun(1:930*2/n), meanbefore*0.6, '.');
% xlim([0 16]);
% ylim([0 1*0.6]);
% hold on;
% scatter(meanrun(1+930/n*3:end), meanafter*0.6, '.');
% xlim([0 16]);
% ylim([0 1*0.6]);
% title(strcat('axon number', num2str(cell)));
% xlabel('running state');
% ylabel('dff/f0');

run1 = meanrun(1:930*2/n);
dff1 = meanbefore;
run2 = meanrun(1+930/n*3:end);
dff2 = meanafter;

[run1, order] = sort(run1);
dff1 = dff1(:,order);
run1 = reshape(run1, [5,310/5]);
run1 = mean(run1);
dff1 = reshape(dff1, [5,310/5]);
dff1 = mean(dff1);
% [run1, index] = unique(run1);
% runbegin = run1(1);
% run1(run1<0.01) = [];
% run1 = cat(2, runbegin, run1);
% lr = length(run1);
% dff1 = dff1(index);
% dff1 = cat(2, dff1(1:2), dff1(length(dff1)-lr+3:end));
% dff1all(cell,:) = interp1(run1, dff1, linspace(0,12,1000), 'linear');
dff1all(cell, :) = dff1;

[run2, order] = sort(run2);
dff2 = dff2(:,order);
run2 = reshape(run2, [3,465/3]);
run2 = mean(run2);
dff2 = reshape(dff2, [3,465/3]);
dff2 = mean(dff2);
% [run2, index] = unique(run2);
% runbegin = run2(1);
% run2(run2<0.1) = [];
% run2 = cat(2, runbegin, run2);
% lr = length(run2);
% dff2 = dff2(index);
% dff2 = cat(2, dff2(1:2), dff2(length(dff2)-lr+3:end));
% dff2all(cell,:) = interp1(run2, dff2, linspace(0,12,1000), 'linear');
dff2all(cell, :) = dff2;

end

%%

dff1all = dff1all(200:400,:);
dff2all = dff2all(200:400,:);
%%

k = 45;
l = 133;
xq1 = 0:0.01:12;
x = run1(k:end);
h = figure;
plot(run1(k:end), mean(dff1all(:,k:end)));
hold on;
% minenv = min(dff1all); maxenv = max(dff1all);
S = std(dff1all(:,k:end));
minenv = mean(dff1all(:,k:end))-S/10; maxenv = mean(dff1all(:,k:end))+S/10;
x = [x,fliplr(x)];    % repeat x values
yy = [minenv, fliplr(maxenv)];   % vector of upper & lower boundaries
h(2) = fill(x,yy, 'b', 'LineStyle','none');    % fill area defined by x & yy in blue
alpha(h(2), 0.3);
hold on;
x = run2(l:end);
plot(run2(l:end), mean(dff2all(:,l:end)));
% minenv = min(dff2all); maxenv = max(dff2all);
S = std(dff2all(:,l:end));
minenv = mean(dff2all(:,l:end))-S/10; maxenv = mean(dff2all(:,l:end))+S/10;
x = [x,fliplr(x)];    % repeat x values
yy = [minenv, fliplr(maxenv)];   % vector of upper & lower boundaries
h(3) = fill(x,yy, 'r', 'LineStyle','none');    % fill area defined by x & yy in blue
alpha(h(3), 0.3);

xlim([0 12]);

%%
for i = uniquesidx
axon = i;
figure;
scatter(run1(k:end), dff1all(axon,k:end)/2);
xlabel('running state'); ylabel('df/f0');
title(strcat('Axon ', num2str(i)));
hold on;
scatter(run2(l:end), dff2all(axon,l:end)/2);
legend('before CSD', 'after CSD');
ylim([0 0.45]);
end
% xdata = run1(k:end); ydata = dff1all(42,k:end);
% fun = @(x,xdata)x(1)*exp(x(2)*xdata);
% x0 = [0,0];
% x = lsqcurvefit(fun,x0,xdata,ydata);
% times = linspace(xdata(1),xdata(end));
% plot(times, fun(x,times));
%%

% ii = [34, 36, 39, 46, 55, 91, 142];
ii = [46, 91];
c = 0;
figure;
for i = ii
    figure;
    plot(smooth(smooth(newtraces(i,:)/2)+c)); hold on;

end


%%
planes = [3,4,4,4,5,10,11];
rois = [10,2,5,12,9,4,31];

for nbidx = 1:7
    plane = planes(nbidx)
    roi = rois(nbidx)
runs(1) = 100+plane;
path = strcat('D:\twophoton_data\2photon\scan\DL89\171122_DL89\',...
'171122_DL89_run', num2str(runs(1)), ...
'\DL89_171122_', num2str(runs(1)-1), '.signals');
cellsort = load(path, '-mat');
cellsort = cellsort.cellsort;
% figure;imshow(cellsort(roi).mask);
mask = cellsort(roi).mask;


io = mat2gray(proj(10:end-10,80:end-80));
%iob = imbinarize(allmasks(10:end-10,80:end-80));
iob = imbinarize(double(mask(10:end-10,80:end-80)));
green=zeros(size(io,1),size(io,2),3);
green(:,:,2)=1;
iob_p=bwperim(iob);

figure,imshow(io)
hold all
h=imshow(green);
set(h,'AlphaData',iob_p);
title(num2str(nbidx));
end

