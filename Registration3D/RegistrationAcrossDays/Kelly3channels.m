%% Script for Kelly

% Goal: first, register each of the 2 volumes,which actually correspond
% to the same volume
% 1st volume: imaged in the green channel (all cells) and in the red 
% channel(subset of cells) 
% 2nd volume: imaged in the red channel and in the blue channel (subset)
% secondly, register the red channel of volume 2 to the red channel 
% of volume 1 and apply the same shifts to the blue channel of volume 2 so
% that everything is registered to the 1st volume
% thirdly, take a average of a registered plane (green channel) and 
% an avarage of the registered volume in the green channel. Find the
% closest plane in the volume corresponding to the imaged plane based on
% spatial correlations

% (run my startup file first)
% D:\Analysis_scripts\Dropbox\AndermannLab\users\hanae\code\startup.m

%% file info

mouse = 'CC175';
date = '180613';
run_rg = 6; % red and green
run_rb = 7; % red and blue
sizevol = [512, 796, 31, 100];
edge = 91; % to remove the weird stipes on the left

%% load both channels of both volumes 

path_rg = sbxPath(mouse, date, run_rg, 'sbx', 'server', 'anastasia');
vol_rg_r = sbxReadPMT(path_rg, 0, 300000, 1);
vol_rg_r = reshape(vol_rg_r, sizevol);
vol_rg_r(:,1:edge,:,:) = 0; % replace stipes by zeros
vol_rg_g = sbxReadPMT(path_rg);
vol_rg_g = reshape(vol_rg_g, sizevol);
vol_rg_g(:,1:edge,:,:) = 0; % replace stipes by zeros

path_rb = sbxPath(mouse, date, run_rb, 'sbx', 'server', 'anastasia');
vol_rb_r = sbxReadPMT(path_rb, 0, 300000, 1);
vol_rb_r = reshape(vol_rb_r, sizevol);
vol_rb_r(:,1:edge,:,:) = 0; % replace stipes by zeros
vol_rb_b = sbxReadPMT(path_rb);
vol_rb_b = reshape(vol_rb_b, sizevol);
vol_rb_b(:,1:edge,:,:) = 0; % replace stipes by zeros

%% save volumes as tiff to visualise them in ImageJ
% 
% writeTiffHanae('E:\hanae_data\', vol_rg_r, 'vol_rg_r', sizevol(3)*sizevol(4));
% writeTiffHanae('E:\hanae_data\', vol_rg_g, 'vol_rg_g', sizevol(3)*sizevol(4));
% writeTiffHanae('E:\hanae_data\', vol_rb_r, 'vol_rb_r', sizevol(3)*sizevol(4));
% writeTiffHanae('E:\hanae_data\', vol_rb_b, 'vol_rb_b', sizevol(3)*sizevol(4));

%% 1st step: Registration of both volumes of both channels - version for Kelly

% input of registration
mouse = 'CC175';
date = '180613';
refchannel = 1; % red channel as reference
edges = [0,0,edge,0];
blurfactor = 1;
keepingfactor = 0.95;
n = 100;
planescorr = 5;
nbchunck = 1;
m1 = 100;
server = 'storage'; % careful: 'anastasia' doesn't work for now with the
% registration pipeline

% perform registration for vol1 and vol2
RegistrationKelly(mouse, date, run_rg, refchannel, edges, ...
    blurfactor, keepingfactor, n, planescorr, nbchunck, m1,...
    'server', server);
RegistrationKelly(mouse, date, run_rb, refchannel, edges, ...
    blurfactor, keepingfactor, n, planescorr, nbchunck, m1,...
    'server', server);

% I moved manually the reg data called dataregaffine to another folder
% called 'regdata'. I did that for both channels of both volumes.

%% 2nd step: Registration red channel vol2 to red channel vol1

path6 = 'E:\hanae_data\Kelly\regdata\CC175_180613_6_1_dataregaffine.sbx';
path7 = 'E:\hanae_data\Kelly\regdata\CC175_180613_7_1_dataregaffine.sbx';

datared = sbxReadPMT(path6);
datared = reshape(datared, [512, 796, 31, 100]);
datared = datared(:,:,2:30,:); % I removed first and last plane (optionnal)
datared2 = sbxReadPMT(path7);
datared2 = reshape(datared2, [512, 796, 31, 100]);
datared2 = datared2(:,:,2:30,:); % I removed first and last plane (optional)

% Registration
[RowS, ColS] = DetermineXYShifts(datared2, 1, 0.95, datared);
dataredreg = ApplyXYShifts(datared2, RowS, ColS);

% Projections
maxdataredreg = mean(squeeze(max(dataredreg, [], 3)),3);
maxdatared2 = mean(squeeze(max(datared2, [], 3)),3);
maxdatared = mean(squeeze(max(datared, [], 3)),3);
figure; imshow(imfuse(maxdatared2, maxdatared));
figure; imshow(imfuse(maxdataredreg, maxdatared));

% Apply same transformation to the blue channel

pathblue = 'E:\hanae_data\Kelly\regdata\CC175_180613_7_0_dataregaffine.sbx';
datablue = sbxReadPMT(pathblue);
datablue = reshape(datablue, [512, 796, 31, 100]);
datablue = datablue(:,:,2:30,:);
databluereg = ApplyXYShifts(datablue, RowS, ColS);

%% remove 1st and last plane and replace by zeros

pathgreen = 'E:\hanae_data\Kelly\regdata\CC175_180613_6_0_dataregaffine.sbx';
datagreen = sbxReadPMT(pathgreen);
datagreen = reshape(datagreen, [512, 796, 31, 100]);
datagreen = datagreen(:,:,2:30,:);

A = uint16(zeros(512, 796, 1, 100));
datagreen = cat(3, A, datagreen, A);
datablue = cat(3, A, datablue, A);
dataredreg = cat(3, A, dataredreg, A);
datared = cat(3, A, datared, A);

%% Write Tiff and SBX
% 
% saveVolumeRegistration('E:\hanae_data\Kelly\regdata\allreg\', ...
%      datagreen(:,:,2:30,:), 'datagreen', ...
%     'CC175', '180613', 6, 0, 'server', 'storage', 'type', 'tif');
% 
% saveVolumeRegistration('E:\hanae_data\Kelly\regdata\allreg\', ...
%      datared(:,:,2:30,:), 'datared', ...
%     'CC175', '180613', 6, 1, 'server', 'storage', 'type', 'tif');
% 
% saveVolumeRegistration('E:\hanae_data\Kelly\regdata\allreg\', ...
%      dataredreg(:,:,2:30,:), 'dataredreg', ...
%     'CC175', '180613', 7, 1, 'server', 'storage', 'type', 'tif');
% 
% saveVolumeRegistration('E:\hanae_data\Kelly\regdata\allreg\', ...
%      datablue(:,:,2:30,:), 'datablue', ...
%     'CC175', '180613', 7, 0, 'server', 'storage', 'type', 'tif');

%% 3rd step: find closest plane in the volume - green channel

% load AVG of plane 500 first and 500 last frames registered
% (or load directly the 1000 frames and average them in MATLAB)
path = 'E:\hanae_data\Kelly\regdata\AVG_CC175_180613_002.sbx_first_last_500_frames.tif';
plane = imread(plane);
figure; imshow(plane);

% take the average of the volume
avggreen = mean(datagreen, 4);
avggreen = mat2gray(avggreen);
avggreen = avggreen(1:502,91:786,:);

% reg vol to plane
ref = repmat(plane, 1,1,31);
[Row, Col] = DetermineXYShifts(avggreen, 1, 0.95, ref);
avggreenreg = ApplyXYShifts(avggreen, Row, Col);

% compute spatial correlations
correlations = zeros(1,31);
for i = 1:31
correlations(i) = corr2(plane, avggreenreg(:,:,i));
end

plot(correlations);
xlabel('plane number'); ylabel('correlation value');

[~, maxcorr] = max(correlations);
figure; imshow(imfuse(plane, avggreenreg(:,:,maxcorr)));



