%% Script to write all sbx files

% clear all;
%close all;
%clc;
%startup;

% Getting infos
mouse = 'DL68';
date = '170523';

%for nbrun = 3
%run = nbrun;
run = 4;
path = sbxPath(mouse, date, run, 'sbx');
info = sbxInfo(path);
% XXX
info.otparam(3) = 1;
info.sz = [400, 597];
info.max_idx = 1859;
info.nsamples = 1860;

% Create folders
path_begin = 'E:\hanae_data\Dura\registrationFiles\24-Apr-2018_18-06-30\affineplanes\170523_DL68_run';
% path_begin = 'D:\twophoton_data\2photon\scan\DL68\170523_DL68\';
% path_begin = strcat(path_begin, date, '_', mouse, '_run');
% %path_unreg = strcat(path_begin, '\sbxfiles\');
%path_reg = strcat(path_begin, '\sbxfiles_reg\');
%mkdir(path_unreg);
%mkdir(path_reg);

% Unregistered (warning because double to int16)
% nbplanes = info.otparam(3);
% 
% for plane = 1 : nbplanes-1
%     savepath = strcat(path_unreg, 'plane', num2str(plane));
%     myfolder = strcat(path_begin, '\noregistration\');
%     oldfolder = cd(myfolder);
%     liste = [];
%     indice = strcat('zlevel', num2str(plane), '_');
%     listfiles = dir(strcat(indice, '*.mat'));
%     for i = 1 : length(listfiles)
%         liste = cat(1, liste, listfiles(i, :).name);
%     end
%     seq = [];
%     for num = 1: size(liste,1)
%         disp(liste(num, :)); % control right order
%         seqi = load(strcat(myfolder,liste(num, :)));
%         fn = fieldnames(seqi)';
%         seqi = seqi.(fn{1});
%         seq = cat(3, seq, seqi);
%     end
%     sbxWrite(savepath, seq, info);
% end
% 
% clear savepath;

% Registered (warning because double to int16) 
nbplanes = 15;%info.otparam(3);

for plane = 1:nbplanes
    %savepath = strcat(path_reg, 'plane', num2str(plane), '_reg');
    nbrun = run*100 + (plane);
    newfolder = strcat(path_begin, num2str(nbrun));
    mkdir(newfolder);
    savepath = strcat(newfolder, '\', mouse, '_', date,...
    '_', num2str(nbrun-1), '.sbx');
%     myfolder = strcat(path_begin, '\Alexregistration\');
%     oldfolder = cd(myfolder);
%     liste = [];
%     indice = strcat('zlevel', num2str(plane), '_');
%     listfiles = dir(strcat(indice, '*.mat'));
%     for i = 1 : length(listfiles)
%         liste = cat(1, liste, listfiles(i, :).name);
%     end
%     seq = [];
%     for num = 1: size(liste,1)
%         %disp(liste(num, :)); % control right order
%         seqi = load(strcat(myfolder,liste(num, :)));
%         fn = fieldnames(seqi)';
%         seqi = seqi.(fn{1});
%         seq = cat(3, seq, seqi);
%     end
    seq = volumereg3(:,:,plane, :);
    seq = squeeze(seq);
    sbxWrite(savepath, seq, info);
end

%clear savepath;

%end

%% Change files locations and rename

mouse = 'DL89';
date = '171122';
run = ;
nbtotalz = 29;

begintargetpath = 'D:\twophoton_data\2photon\scan\';
midtargetpath = strcat(begintargetpath, '\', mouse, '\', date, '_', mouse, '\');

begininitialpath = 'E:\hanae_data\alextry2\';
midinitialpath = strcat(begininitialpath, 'mouse', mouse, '_date', date,...
    '_run', num2str(run));
unreginitialpath = strcat(midinitialpath, '\sbxfiles\');
reginitialpath = strcat(midinitialpath, '\sbxfiles_reg\');

for nbz = 1: nbtotalz
    disp(nbz);
    if nbz < 10
        part = '0';
    else
        part = '';
    end
    newtargetfolder = strcat(midtargetpath, date, '_', mouse, '_run', num2str(run), part, num2str(nbz));
    mkdir(newtargetfolder);
	% .mat unreg
	inputFullFileName = strcat(unreginitialpath, 'plane', num2str(nbz), '.mat');
	outputFullFileName = strcat(newtargetfolder, '\', mouse, '_', date, '_', num2str(run), part, num2str(nbz), '.mat');
	copyfile(inputFullFileName, outputFullFileName);
    
    % .mat reg
	inputFullFileName = strcat(reginitialpath, 'plane', num2str(nbz), '_reg.mat');
	outputFullFileName = strcat(newtargetfolder, '\', mouse, '_', date, '_', num2str(run), part, num2str(nbz), '_reg.mat');
	copyfile(inputFullFileName, outputFullFileName);
    
    % .sbx unreg
	inputFullFileName = strcat(unreginitialpath, 'plane', num2str(nbz), '.sbx');
	outputFullFileName = strcat(newtargetfolder, '\', mouse, '_', date, '_', num2str(run), part, num2str(nbz), '.sbx');
	copyfile(inputFullFileName, outputFullFileName);
    
     % .sbx reg
	inputFullFileName = strcat(reginitialpath, 'plane', num2str(nbz), '_reg.sbx');
	outputFullFileName = strcat(newtargetfolder, '\', mouse, '_', date, '_', num2str(run), part, num2str(nbz), '.sbxreg');
	copyfile(inputFullFileName, outputFullFileName);
end




