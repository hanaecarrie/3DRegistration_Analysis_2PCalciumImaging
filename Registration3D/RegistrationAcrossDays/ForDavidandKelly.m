% Script finding the closest plane to planes in a reference volume
% Based on spatial correlations

clear all;
close all;

%% Parameters

mouse = 'VF226';
date = '180330';

%% Volume

R = 7;      % run containing the volume
I = 512;    % rows
J = 786;    % columns
P = 31;     % planes in the volume
V = 100;    % volumes taken in run R
pathvolumes = ['\\anastasia\data\2p\kelly\cross_day_volumes\' mouse '_' date '_00' num2str(R)];
volumes = sbxReadPMT(pathvolumes); % green channel by default
volumes = reshape(volumes, [I, J, P, V]);


%% Define reference volume and edges
refvol = defineReference(volumes, V);
edges = [10, 10, 60, 60]; % top, bottom, left, right


%% Plane

corr_byrun = zeros(R,P);
for r = 1:R-1
    plane = sbxReadPMT(sbxPath(mouse, date, r, 'sbx', 'server', 'beastmode'), 1, 1000);
    meanplane = mean(plane,3);
    [~, corr_byrun(r,:)] = SpatialCorrPlaneVolume(refvol(:,:,:), meanplane, edges);
end

corr_byrun  = zscore(corr_byrun');
corr_byrun(:,R) = mean(corr_byrun(:,1:R-1),2);
[~, closestplane] = max(corr_byrun(:,R));

figure;
hold on;
for r = 1:R-1
    plot(corr_byrun(:,r),'color','b','linewidth',0.7);
end
plot(corr_byrun(:,R),'color','b','linewidth',2);
hold off;

%% red channel

volumesred = sbxReadPMT(pathvolumes, 0, P*V, 1); % red channel
volumesred = reshape(volumesred, [I, J, P, V]);
refvolred = defineReference(volumesred, V);
figure; imshow(mat2gray(mean(refvolred(edges(1):end-edges(2),edges(3):end-edges(4),:),3)));

redplane = mean(refvolred(:,:,closestplane-2:closestplane+2),3);
figure; imshow(mat2gray(refvolred(edges(1):end-edges(2),edges(3):end-edges(4),closestplane)));

