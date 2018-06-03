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
        path = sbxPath(mouse, date, runs(1), 'signals');
        cellsort = load(path, '-mat'); cellsort = cellsort.cellsort;
        nbrois(plane) = size(cellsort,2);
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
            path = sbxPath(mouse, date, run, 'signals');
            cellsort = load(path, '-mat');
            cellsort = cellsort.cellsort;
            nb = (run-plane)/100;
            timecourse(930*(nb-1)+1:nb*930) =  cellsort(roi).timecourse.dff_axon;
        end
        timecourseallROIS(roi + sum(nbrois(1:plane-1)), :) = timecourse;
    end
end


heatmap(timecourseallROIS, 'grid', 'off', 'Colormap', hot);
caxis([0 1]);

%%

figure();
timecourseallROISsmooth = timecourseallROIS;
for i = 1:14
timecourseallROISsmooth(i,:) = smooth(timecourseallROIS(i,:));
end
heatmap(timecourseallROIS, 'grid', 'off', 'Colormap', hot);
caxis([0 1]);

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
