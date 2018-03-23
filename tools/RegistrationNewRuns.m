clear all;
close all;
clc;
tStart = tic;

%% info

mouse = 'DL68';
date = '170712';

%% Registration per run

for run = 3:4
if run ==4
% load data
sbxpath = sbxPath(mouse, date, run, 'sbx');
info = sbxInfo(sbxpath);
volume = sbxReadPMT(sbxpath);
savingpath = strcat('E:\hanae_data\alextry\mouse', mouse, '_date', ...
    date, '_run', num2str(run), '\');
% crop data
volume = reshape(volume, [512, 796, 15, 1860]);
volume = volume(1:400,100:696,:,:);

% params
w = size(volume, 1);
h = size(volume, 2);
zp = size(volume, 3);
ts = size(volume, 4);
n = 30; % chunck size
if mod(ts, n) ~= 0
    disp("Chunck size should be a divider of the number of frames");
end
BlurFactor = 1;
KeepingFactor = 0.95;
% saving
savingpathv = strcat(savingpath, 'volume\');
WriteTiff(savingpathv,volume,strcat(mouse,'_', date,'_', ...
    num2str(run),'_'), 2790);
sbxWrite(strcat(savingpathv, '\volume'),...
     reshape(volume, [w,h,zp*ts]), info);


% REFERENCE 1
ref1 = zeros(w, h, zp, ts/n);
for i = 1:ts/n
    for z = 1:size(volume, 3)
        a = volume(:,:,z,(i-1)*n+1:i*n);
        a = squeeze(permute(a, [1, 2, 4, 3]));
        a = mean(a, 3);
        ref1(:,:,z,i) = a;
    end
end
% determine shifts
[Ref1RowShifts,Ref1ColumnShifts] = DetermineXYShifts(ref1(:,:,:,:),...
    BlurFactor,KeepingFactor,ref1(:,:,:,1));
% apply shift to ref1
[ref1reg] = ApplyXYShifts(ref1, Ref1RowShifts, Ref1ColumnShifts);
% saving
savingpathref = strcat(savingpath, 'ref1reg\');
sbxWrite(strcat(savingpath, '\ref1reg'), ...
     reshape(ref1reg, [w,h,zp*ts/n]), info);
WriteTiff(savingpathref,ref1reg,strcat(mouse,'_', date,'_',...
    num2str(run),'_'));

% VOLUMEREG1 to the moving reference
[RowShiftsXY, ColumnShiftsXY] = DetermineXYShifts(volume,...
    BlurFactor,KeepingFactor,ref1reg);
[volumereg1] = ApplyXYShifts(volume, RowShiftsXY, ColumnShiftsXY);
% saving
clear volume;
savingpath1 = strcat(savingpath, 'volumereg1\');
WriteTiff(savingpath1,volumereg1,strcat(mouse,'_', date,'_', ...
    num2str(run),'_'), 2790);
sbxWrite(strcat(savingpath, '\volumereg1'), ...
     reshape(volumereg1, [w,h,zp*ts]), info);

% REFERENCE 2
ref2 = zeros(w, h, zp, ts/n);
for i = 1:ts/n
    for z = 1:size(volumereg1, 3)
        a = volumereg1(:,:,z,(i-1)*n+1:i*n);
        a = squeeze(permute(a, [1, 2, 4, 3]));
        a = mean(a, 3);
        ref2(:,:,z,i) = a;
    end
end
% determine reg for the reference
[Ref2RowShifts,Ref2ColumnShifts] = DetermineXYShifts(ref2(:,:,:,:),...
    BlurFactor,KeepingFactor,ref2(:,:,:,1));
% apply reg to reference
[ref2reg] = ApplyXYShifts(ref2, Ref2RowShifts, Ref2ColumnShifts);
% saving
savingpathref = strcat(savingpath, 'ref2reg\');
sbxWrite(strcat(savingpath, '\ref2reg'), ...
     reshape(ref2reg, [w,h,zp*ts/n]), info);
WriteTiff(savingpathref,ref2reg,strcat(mouse,'_', date,'_', ...
    num2str(run),'_'));

% REGISTRATION 2: ZSHIFTS INTERPOLATION
% determine
[RowShifts,ColumnShifts,ZShifts] = ComputeZshiftInterpolate(...
    ref2reg(:,:,:,:), volumereg1(:,:,:,:), 3);
% apply
[volumereg2] = ApplyZShiftInterpolate(volumereg1, ZShifts, ...
    ColumnShifts, RowShifts);
% save and clear variables
clear volumereg1;
savingpath2 = strcat(savingpath, 'volumereg2\');
sbxWrite(strcat(savingpath, '\volumereg2'), ...
     reshape(volumereg2, [w,h,zp*ts]), info);
WriteTiff(savingpath2,mat2gray(volumereg2),strcat(mouse,'_', ...
    date,'_', num2str(run),'_'), 2790);

% REFERENCE 3
ref3 = zeros(w, h, zp, ts/n);
for i = 1:ts/n
    for z = 1:size(volumereg2, 3)
        a = volumereg2(:,:,z,(i-1)*n+1:i*n);
        a = squeeze(permute(a, [1, 2, 4, 3]));
        a = mean(a, 3);
        ref3(:,:,z,i) = a;
    end
end
% determine
[Ref3RowShifts,Ref3ColumnShifts] = DetermineXYShifts(ref3(:,:,:,:),...
    BlurFactor,KeepingFactor,ref3(:,:,:,1));
% apply
[ref3reg] = ApplyXYShifts(ref3, Ref3RowShifts, Ref3ColumnShifts);
% save variables
savingpathref = strcat(savingpath, 'ref3reg\');
sbxWrite(strcat(savingpath, '\ref3reg'), ...
    reshape(ref3reg, [w,h,zp*ts/n]), info);
WriteTiff(savingpathref,ref3reg,strcat(mouse,'_', date,'_', ...
    num2str(run),'_'));

% REGISTRATION 3
% determine
[RowShiftsXY2, ColumnShiftsXY2] = DetermineXYShifts(volumereg2,...
    BlurFactor,KeepingFactor,ref3reg);
% apply
[volumereg3] = ApplyXYShifts(volumereg2, RowShiftsXY2, ...
    ColumnShiftsXY2);
% save and clear variables
clear volumereg2;
savingpath3 = strcat(savingpath, '\volumereg3\');
WriteTiff(savingpath3,mat2gray(volumereg3),strcat(mouse,'_',...
    date,'_', num2str(run),'_'), 2790);
sbxWrite(strcat(savingpath, '\volumereg3'),...
    reshape(volumereg3, [w,h,zp*ts]), info);

tEnd = tic;
fprintf('Elapsed time is %d minutes and %f seconds\n.', ...
    floor(tEnd-tStart/60),rem(tEnd-tStart,60));

% save files
save(strcat(savingpath, '\RowShiftsXY1'), 'RowShiftsXY');
save(strcat(savingpath, '\RowShiftsZ'), 'RowShifts');
save(strcat(savingpath, '\ColumnShiftsXY1'), 'ColumnShiftsXY');
save(strcat(savingpath, '\ColumnShiftsZ'), 'ColumnShifts');
save(strcat(savingpath, '\ZShifts'), 'ZShifts');
save(strcat(savingpath, '\RowShiftsXY2'), 'RowShiftsXY2');
save(strcat(savingpath, '\ColumnShiftsXY2'), 'ColumnShiftsXY2');

% save sbx file
info = sbxInfo(sbxpath);
nbplanes = info.otparam(3);
info.otparam(3) = 1;
info.sz = [400, 597];
info.max_idx = 1859;
info.nsamples = 1860;
otwave = info.otwave;
path_begin = strcat('D:\twophoton_data\2photon\scan\', mouse, ...
    '\', date, '_', mouse, '\');
path_begin = strcat(path_begin, date, '_', mouse, '_run');

for plane = 1:nbplanes
    info.otwave = otwave(plane);
    nbrun = run*100 + (plane);
    newfolder = strcat(path_begin, num2str(nbrun));
    mkdir(newfolder);
    savepathp = strcat(newfolder, '\', mouse, '_', date,...
    '_', num2str(nbrun-1), '.sbx');
    seq = volumereg3(:,:,plane, :);
    seq = squeeze(seq);
    sbxWrite(savepathp, seq, info);
end
end
% affine alignment
for i = 1:nbplanes
    if run ~= 3 || i > 4
    newrun = run*100+i;
    newpath = sbxPath(mouse, date, newrun, 'sbx');
    out = sbxAlignAffineDFT({newpath}, 'tbin', 0, 'refsize', ...
        size(volumereg3, 4), 'refoffset', n);
    sbxSaveAlignedSBX(newpath);
    end
end
clear volumereg3;

end

%% Align across runs

% REFERENCE 1st RUN
% load 1st run
volumeregaffine1 = [];
for i = 1:nbplanes
    pathplane = strcat(...
        'D:\twophoton_data\2photon\scan\', mouse, '\', date, ...
        '_', mouse, '\', date, '_', mouse, '_run',...
        num2str(100+i), '\', mouse, '_', date, '_',...
        num2str(100+i-1), '_reg-0.sbxreg');
    plane = sbxReadPMT(pathplane);
    volumeregaffine1 = cat(4, volumeregaffine1, plane);
end
volumeregaffine1 = permute(volumeregaffine1, [1,2,4,3]);
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
% determine shifts
[RefARowShifts,RefAColumnShifts] = DetermineXYShifts(...
refacrossruns(:,:,:,:),...
    BlurFactor,KeepingFactor,refacrossruns(:,:,:,1));
% apply shifts
[refAreg] = ApplyXYShifts(refacrossruns, RefARowShifts,...
    RefAColumnShifts);

% APPLY REGISTRATION TO OTHER RUNS
for run = 2:4
% load data
volumeregaffine = [];
i = 1;
for i = 1:nbplanes
    pathplane = strcat(...
        'D:\twophoton_data\2photon\scan\', mouse, '\', date, ...
        '_', mouse, '\', date, '_', mouse, '_run',...
        num2str(run*100+i), '\', mouse, '_', date, '_',...
        num2str(run*100+i-1), '_reg-0.sbxreg');
    plane = sbxReadPMT(pathplane);
    volumeregaffine = cat(4, volumeregaffine, plane);
end
volumeregaffine = permute(volumeregaffine, [1,2,4,3]);
% determine shifts
[RowShiftsXYA, ColumnShiftsXYA] = DetermineXYShifts(...
    volumeregaffine,...
    BlurFactor,KeepingFactor,refAreg);
% apply shifts
[volumeregacrossruns] = ApplyXYShifts(volumeregaffine, ...
    RowShiftsXYA, ColumnShiftsXYA);
% save sbx files
path = sbxPath(mouse, date, run, 'sbx');
info = sbxInfo(path);
info.otparam(3) = 1;
info.sz = [400, 597];
info.max_idx = 1859;
info.nsamples = 1860;
otwave = info.otwave;
nbplanes = info.otparam(3);
% create folders
path_begin = strcat('D:\twophoton_data\2photon\scan\', mouse,...
    '\', date, '_', mouse,'\');
path_begin = strcat(path_begin, date, '_', mouse, '_run');
% save sbx files
for plane = 1:nbplanes
    info.otwave = otwave(plane);
    nbrun = run*1000 + (plane);
    newfolder = strcat(path_begin, num2str(nbrun));
    mkdir(newfolder);
    savepath = strcat(newfolder, '\', mouse, '_', date,...
    '_', num2str(nbrun-1), '.sbx');
    seq = volumeregacrossruns(:,:,plane, :);
    seq = squeeze(seq);
    sbxWrite(savepath, seq, info);
end

end

%% ROIs

for ni = 1:nbplanes
    disp(ni)
    n1 = 1000+ni;
    n2 = 2000+ni;
    n3 = 3000+ni;
    n4 = 4000+ni;
    sbxPreprocessDuraStack(mouse, date, 'runs', [n1, n2, n3, n4]);
end




