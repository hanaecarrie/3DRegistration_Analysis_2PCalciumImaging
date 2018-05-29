% Script finding the closest plane to planes in a reference volume
% Based on spatial correlations

clear all;
close all;
clc;

%% Parameters

mouse = 'VF226';
date = '180330';

%% Volume

runvolume = 7; % volume
pathvolumes = sbxPath(mouse, date, runvolume, 'sbx');
volumes = sbxReadPMT(pathvolumes); % green channel by default
volumes = reshape(volumes, [512, 786, 31, 100]);

%% Plane

run = 6;
plane = sbxReadPMT(sbxPath(mouse, date, run, 'sbx'));
% sbxReadPMT(sbxpath, startframe (default 0), nbframes (default Nb frames))

%% Save tif to visualise volume

% saveVolumeRegistration('E:\hanae_data\', volumes, 'volumes',...
%     mouse, date, runvolume, 0, 'type', 'tif');

%% Define reference volume and edges after visualizing the data

n = 100; % bin size
refvol = DefineReference(volumes, n);
edges = [10, 10, 60, 60]; % top, bottom, left, right

%% Find closest plane and display spatial correlations

meanplane = mean(plane,3);
[closestplane, corr] = SpatialCorrPlaneVolume(refvol, meanplane, edges);
plot(corr);



