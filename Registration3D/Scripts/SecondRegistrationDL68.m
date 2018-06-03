clear all;
close all;
clc;

%% load regsitered data

tStart = tic;
mouse = 'DL68';
date = '170523';
run = 4;
cd 'E:\hanae_data\alextry2\mouseDL68_date170523_run4\noregistration\';
list = dir('*zlevel*');
names = struct2cell(list);
names = names(1,:);
for i = 1:size(names,2)
   if contains(names{i},'.avi') == 1
       names{i} = [];
   end
end
names = names(~cellfun('isempty',names));

volume = zeros(512, 796, 1860, 14);
for i = 1:14
    load(strcat('zlevel', num2str(i),'_1860volumes_11PPR_5PFC_BF3_KF0_35_RVI1_1.mat'));
    volume(:,:,1:465, i) = seq_1;
    load(strcat('zlevel', num2str(i),'_1860volumes_11PPR_5PFC_BF3_KF0_35_RVI1_2.mat'));
    volume(:,:,466:930, i) = seq_2;
    load(strcat('zlevel', num2str(i),'_1860volumes_11PPR_5PFC_BF3_KF0_35_RVI1_3.mat'));
    volume(:,:,931:1395, i) = seq_3;
    load(strcat('zlevel', num2str(i),'_1860volumes_11PPR_5PFC_BF3_KF0_35_RVI1_4.mat'));
    volume(:,:,1396:1860, i) = seq_4;
end

clear seq_1; clear seq_2;clear seq_3; clear seq_4;
savingpath = strcat('E:\hanae_data\alextry\mouse', mouse, '_date', ...
    date, '_run', num2str(run), '\')


%% crop data

volume = volume(1:400,100:696,:,:);
volume = permute(volume, [1, 2, 4, 3]);
%save(strcat(savingpath, '\volume'), 'volume');
savingpathv = strcat(savingpath, 'volume\');
WriteTiff(savingpathv,volume,'DL68_170523_4_', 2604);

%% Params

w = size(volume, 1);
h = size(volume, 2);
zp = size(volume, 3);
ts = size(volume, 4);
n = 30; % chunck size
if mod(ts, n) ~= 0
    disp('Chunck size should be a divider of the number of frames');
end

BlurFactor = 1;
KeepingFactor = 0.95;

%save(strcat(savingpath, 'volume'), volume);

%% reference

% average every n frames
ref1 = zeros(w, h, zp, ts/n);
for i = 1:ts/n
    for z = 1:size(volume, 3)
        a = volume(:,:,z,(i-1)*n+1:i*n);
        a = squeeze(permute(a, [1, 2, 4, 3]));
        a = mean(a, 3);
        ref1(:,:,z,i) = a;
    end
end

% Determine reg for the reference
[Ref1RowShifts,Ref1ColumnShifts] = DetermineXYShifts(ref1(:,:,:,:),...
    BlurFactor,KeepingFactor,ref1(:,:,:,1));

% Apply reg to reference
[ref1reg] = ApplyXYShifts(ref1, Ref1RowShifts, Ref1ColumnShifts);

%save(strcat(savingpath, '\ref1reg'), 'ref1reg');


%% XY registration to the moving reference

[RowShiftsXY, ColumnShiftsXY] = DetermineXYShifts(volume,...
    BlurFactor,KeepingFactor,ref1reg);

[volumereg1] = ApplyXYShifts(volume, RowShiftsXY, ColumnShiftsXY);

%clear volume;
%%
savingpath1 = strcat(savingpath, 'volumereg1\');
WriteTiff(savingpath1,volumereg1,'DL68_170523_4_', 2604);
%save(strcat(savingpath, '\volumereg1'), 'volumereg1');

%% Taking a new reference for the zshift

% average every 30 frames
ref2 = zeros(w, h, zp, ts/n);
for i = 1:ts/n
    for z = 1:size(volumereg1, 3)
        a = volumereg1(:,:,z,(i-1)*n+1:i*n);
        a = squeeze(permute(a, [1, 2, 4, 3]));
        a = mean(a, 3);
        ref2(:,:,z,i) = a;
    end
end

% Determine reg for the reference
[Ref2RowShifts,Ref2ColumnShifts] = DetermineXYShifts(ref2(:,:,:,:),...
    BlurFactor,KeepingFactor,ref2(:,:,:,1));

% Apply reg to reference
[ref2reg] = ApplyXYShifts(ref2, Ref2RowShifts, Ref2ColumnShifts);

%save(strcat(savingpath, '\ref2reg'), 'ref2reg');

%% Zshift new registration - rigid body no interpolation

[RowShifts,ColumnShifts,ZShifts] = ComputeZshiftInterpolate(...
    ref2reg(:,:,:,:), volumereg1(:,:,:,:), 3);

% Apply Zshift
[volumereg2] = ApplyZShiftInterpolate(volumereg1, ZShifts, ...
    ColumnShifts, RowShifts);

%clear volumereg1;

%save(strcat(savingpath, '\volumereg2'), 'volumereg2');
savingpath2 = strcat(savingpath, 'volumereg2\');
WriteTiff(savingpath2,volumereg2,'DL68_170523_4_', 2604);

%% New XY reg : reference

% average every n frames
ref3 = zeros(w, h, zp, ts/n);
for i = 1:ts/n
    for z = 1:size(volumereg2, 3)
        a = volumereg2(:,:,z,(i-1)*n+1:i*n);
        a = squeeze(permute(a, [1, 2, 4, 3]));
        a = mean(a, 3);
        ref3(:,:,z,i) = a;
    end
end

% Determine reg for the reference
[Ref3RowShifts,Ref3ColumnShifts] = DetermineXYShifts(ref3(:,:,:,:),...
    BlurFactor,KeepingFactor,ref3(:,:,:,1));

% Apply reg to reference
[ref3reg] = ApplyXYShifts(ref3, Ref3RowShifts, Ref3ColumnShifts);

%% XY registration to the moving reference

[RowShiftsXY2, ColumnShiftsXY2] = DetermineXYShifts(volumereg2,...
    BlurFactor,KeepingFactor,ref3reg);

[volumereg3] = ApplyXYShifts(volumereg2, RowShiftsXY2, ColumnShiftsXY2);

savingpath3 = strcat(savingpath, '\volumereg3\');
WriteTiff(savingpath3,volumereg3,'DL68_170523_4_', 2604);

tEnd = tic;
fprintf('Elapsed time is %d minutes and %f seconds\n.', ...
    floor(tEnd-tStart/60),rem(tEnd-tStart,60));

%% Save files

save(strcat(savingpath, '\RowShiftsXY1'), 'RowShiftsXY');
save(strcat(savingpath, '\RowShiftsZ'), 'RowShifts');
save(strcat(savingpath, '\ColumnShiftsXY1'), 'ColumnShiftsXY');
save(strcat(savingpath, '\ColumnShiftsZ'), 'ColumnShifts');
save(strcat(savingpath, '\ZShifts'), 'ZShifts');
%save(strcat(savingpath, '\ref3reg'), 'ref3reg');
%save(strcat(savingpath, '\volumereg3'), 'volumereg3');

%%
save(strcat(savingpath, '\RowShiftsXY2'), 'RowShiftsXY2');
save(strcat(savingpath, '\ColumnShiftsXY2'), 'ColumnShiftsXY2');

%% Save sbx file

% Getting infos
mouse = 'DL68';
date = '170523';
run = 4;

path = sbxPath(mouse, date, run, 'sbx');
info = sbxInfo(path);
% XXX
info.otparam(3) = 1;
info.sz = [400, 597];
info.max_idx = 1859;
info.nsamples = 1860;
otwave = info.otwave;


% Create folders
path_begin = 'D:\twophoton_data\2photon\scan\DL68\170523_DL68\';
path_begin = strcat(path_begin, date, '_', mouse, '_run');

% Registered (warning because double to int16) 
nbplanes = 14;%info.otparam(3);

for plane = 1:nbplanes
    info.otwave = otwave(plane);
    nbrun = run*200 + (plane);
    newfolder = strcat(path_begin, num2str(nbrun));
    mkdir(newfolder);
    savepath = strcat(newfolder, '\', mouse, '_', date,...
    '_', num2str(nbrun-1), '.sbx');
    seq = volumereg3(:,:,plane, :);
    seq = squeeze(seq);
    sbxWrite(savepath, seq, info);
end

% savingpath2 = 'E:\hanae_data\alextry\mouseDL89_date171122_run2\volumereg2\';
% WriteTiff(savingpath2,volumereg2,2604);

%% Affine alignment
mouse = 'DL68';
date = '170523';
n = 30;

for nbrun = 4
    for i = 1:14
        newrun = nbrun*200+i;
        path = sbxPath(mouse, date, newrun, 'sbx');
        out = sbxAlignAffineDFT({path}, 'tbin', 0, 'refsize', ...
            size(volumereg3, 4), 'refoffset', n);
        sbxSaveAlignedSBX(path);
    end
end

%% Align across runs

% load data
volumeregaffine1 = [];
for i = 1:14
    pathplane = strcat(...
        'D:\twophoton_data\2photon\scan\DL68\170523_DL68\170523_DL68_run',...
        num2str(100+i), '\DL68_170523_', num2str(100+i-1), '_reg-0.sbxreg');
    plane = sbxReadPMT(pathplane);
    volumeregaffine1 = cat(4, volumeregaffine1, plane);
end
volumeregaffine1 = permute(volumeregaffine1, [1,2,4,3]);
%%
volumeregaffine2 = [];
i = 1;
for i = 1:14
    pathplane = strcat(...
        'D:\twophoton_data\2photon\scan\DL68\170523_DL68\170523_DL68_run',...
        num2str(200+i), '\DL68_170523_', num2str(200+i-1), '_reg-0.sbxreg');
    plane = sbxReadPMT(pathplane);
    volumeregaffine2 = cat(4, volumeregaffine2, plane);
end
volumeregaffine2 = permute(volumeregaffine2, [1,2,4,3]);
%%
volumeregaffine3 = [];
for i = 1:14
    pathplane = strcat(...
        'D:\twophoton_data\2photon\scan\DL68\170523_DL68\170523_DL68_run',...
        num2str(300+i), '\DL68_170523_', num2str(300+i-1), '_reg-0.sbxreg');
    plane = sbxReadPMT(pathplane);
    volumeregaffine3 = cat(4, volumeregaffine3, plane);
end
volumeregaffine3 = permute(volumeregaffine3, [1,2,4,3]);
%%
volumeregaffine4 = [];
for i = 1:14
    pathplane = strcat(...
        'D:\twophoton_data\2photon\scan\DL68\170523_DL68\170523_DL68_run',...
        num2str(800+i), '\DL68_170523_', num2str(800+i-1), '_reg-0.sbxreg');
    plane = sbxReadPMT(pathplane);
    volumeregaffine4 = cat(4, volumeregaffine4, plane);
end
volumeregaffine4 = permute(volumeregaffine4, [1,2,4,3]);
%%
% reference

% average every n frames
refacrossruns = zeros(w, h, zp, ts/n);
for i = 1:ts/n
    for z = 1:size(volumeregaffine1, 3)
        a = volumeregaffine1(:,:,z,(i-1)*n+1:i*n);
        a = squeeze(permute(a, [1, 2, 4, 3]));
        a = mean(a, 3);
        refacrossruns(:,:,z,i) = a;
    end
end

% Determine reg for the reference
[RefARowShifts,RefAColumnShifts] = DetermineXYShifts(refacrossruns(:,:,:,:),...
    BlurFactor,KeepingFactor,refacrossruns(:,:,:,1));
% Apply reg to reference
[refAreg] = ApplyXYShifts(refacrossruns, RefARowShifts, RefAColumnShifts);
%%
% XY registration to the moving reference

[RowShiftsXYA, ColumnShiftsXYA] = DetermineXYShifts(volumeregaffine4,...
    BlurFactor,KeepingFactor,refAreg);

[volumeregacrossruns] = ApplyXYShifts(volumeregaffine4, RowShiftsXYA, ColumnShiftsXYA);

%% Save sbx files

% Getting infos
mouse = 'DL68';
date = '170523';
run = 3;

path = sbxPath(mouse, date, run, 'sbx');
info = sbxInfo(path);
% XXX
info.otparam(3) = 1;
info.sz = [400, 597];
info.max_idx = 1859;
info.nsamples = 1860;
otwave = info.otwave;


% Create folders
path_begin = 'D:\twophoton_data\2photon\scan\DL68\170523_DL68\';
path_begin = strcat(path_begin, date, '_', mouse, '_run');

% Registered (warning because double to int16) 
nbplanes = 14;%info.otparam(3);

for plane = 1:nbplanes
    info.otwave = otwave(plane);
    nbrun = run*1000 + (plane);
    newfolder = strcat(path_begin, num2str(nbrun));
    mkdir(newfolder);
    savepath = strcat(newfolder, '\', mouse, '_', date,...
    '_', num2str(nbrun-1), '.sbx');
    seq = volumeregacrossruns3(:,:,plane, :);
    seq = squeeze(seq);
    sbxWrite(savepath, seq, info);
end

% savingpath2 = 'E:\hanae_data\alextry\mouseDL89_date171122_run2\volumereg2\';
% WriteTiff(savingpath2,volumereg2,2604);

%% Affine alignment
mouse = 'DL68';
date = '170523';
n = 30;

for nbrun = 2:4
    for i = 1:14
        newrun = nbrun*100+i;
        path = sbxPath(mouse, date, newrun, 'sbx');
        out = sbxAlignAffineDFT({path}, 'tbin', 0, 'refsize', ...
            size(volumereg3, 4), 'refoffset', n);
        sbxSaveAlignedSBX(path);
    end
end

%% ROIs

for ni = [1,3,14]
    disp(ni)
    n1 = 1000+ni;
    n2 = 2000+ni;
    n3 = 3000+ni;
    n4 = 4000+ni;
    sbxPreprocessDuraStack('DL68', '170523', 'runs', [n1, n2, n3, n4]);
end




