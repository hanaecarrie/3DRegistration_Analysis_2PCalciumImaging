%% Script for Kelly
% Goal: first, register 2 volumes together corresponding to the same volume
% 1st volume: imaged in the green channel (all cells) and in the red 
% channel(subset of cells) 
% 2nd volume: imaged in the red channel and in the blue channel (subset)
% second, XXX 

%% load and save tiff for 2 volumes 

mouse = 'CC175';
date = '180613';
run_rg = 6; % red and green
run_rb = 7; % red and blue
sizevol = [512, 796, 31, 100];
edge = 91;

path_rg = sbxPath(mouse, date, run_rg, 'sbx', 'server', 'anastasia');
vol_rg_r = sbxReadPMT(path_rg, 0, 300000, 1);
vol_rg_r = reshape(vol_rg_r, sizevol);
vol_rg_r(:,1:edge,:,:) = 0;
WriteTiffHanae('E:\hanae_data\', vol_rg_r, 'vol_rg_r', sizevol(3)*sizevol(4));
vol_rg_g = sbxReadPMT(path_rg);
vol_rg_g = reshape(vol_rg_g, sizevol);
vol_rg_g(:,1:edge,:,:) = 0;
WriteTiffHanae('E:\hanae_data\', vol_rg_g, 'vol_rg_g', sizevol(3)*sizevol(4));

path_rb = sbxPath(mouse, date, run_rb, 'sbx', 'server', 'anastasia');
vol_rb_r = sbxReadPMT(path_rb, 0, 300000, 1);
vol_rb_r = reshape(vol_rb_r, sizevol);
vol_rb_r(:,1:edge,:,:) = 0;
WriteTiffHanae('E:\hanae_data\', vol_rb_r, 'vol_rb_r', sizevol(3)*sizevol(4));
vol_rb_b = sbxReadPMT(path_rb);
vol_rb_b = reshape(vol_rb_b, sizevol);
vol_rb_b(:,1:edge,:,:) = 0;
WriteTiffHanae('E:\hanae_data\', vol_rb_b, 'vol_rb_b', sizevol(3)*sizevol(4));

%% Registration same as glia

mouse = 'CC175';
date = '180613';
run_rg = 6; % red and green
refchannel = 1; % red channel as reference
edges = [0,0,edge,0];
blurfactor = 1;
keepingfactor = 0.95;
n = 100;
planescorr = 5;
nbchunck = 1;
m1 = 100;
savingpathbegin = 'E:\hanae_data\Kelly\registrationFiles\';
sizedata = [512, 796, 31, 100]; 
server = 'anastasia';

RegistrationKelly(mouse, date, run_rg, refchannel, edges, ...
    blurfactor, keepingfactor, n, planescorr, nbchunck, m1,...
    'server', server, 'strdate', '22-Jun-2018_14-18-53');


