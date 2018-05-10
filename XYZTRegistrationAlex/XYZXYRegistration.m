function [volumereg3, savingpath] = XYZXYRegistration(inputsbxpaths, ...
    mouse, date, runs, channel,...
    n, BlurFactor, KeepingFactor, PlanesCorr, ...
    savingpathbegin, nbchunck)

for run = runs
    tStart = tic;
    strdate = regexprep(datestr(datetime('now')), ' ', '_');
    strdate = regexprep(strdate, ':', '-');
savingpath = strcat(savingpathbegin, '\', strdate, '\');
if ~exist(savingpath, 'dir')
  mkdir(savingpath)
end
savingpath = strcat(savingpath, mouse, '_date', date, '_run',...
    num2str(run), '\');
mkdir(savingpath);

% load data
% inputsbxpath = sbxPath(mouse, date, run, 'sbx');
info = sbxInfo(inputsbxpaths(idx,:));
% w = info.sz(1); h = info.sz(2);
% zp = length(info.otwave);
% ts = (info.max_idx+1)/(length(info.otwave));
zp = 115; ts = 200;
volume = sbxReadPMT(inputsbxpaths(idx,:), 0, 30000, channel);
idx = idx + 1;
w = size(volume, 1); h = size(volume, 2);
nbframes = size(volume,3);
volume = reshape(volume, [w, h, zp, ts]);
% crop or ds
volume = volume(1:2:end,1:2:end,:,1:930);
[w, h, zp, ts] = size(volume);

% errors
if mod(nbframes, nbchunck) ~= 0
    error(strcat('number of chuncks for WriteTiff should divide ',...
        'the number of frames'));
elseif mod(ts, n) ~= 0
    error(strcat("Chunck size for reference should be", ...
        "a divider of the number of frames"));
end

saveVolumeRegistration(savingpath, volume, 'volume', mouse, ...
    date, run, nbchunck);

% REFERENCE 1: define, register and save reference 1
disp("reference 1");
ref1 = DefineReference(volume, n); 
[Ref1RowShifts,Ref1ColumnShifts] = DetermineXYShifts(ref1(:,:,:,:),...
    BlurFactor,KeepingFactor,ref1(:,:,:,1));
[ref1reg] = ApplyXYShifts(ref1, Ref1RowShifts, Ref1ColumnShifts);
saveVolumeRegistration(savingpath, ref1reg, 'ref1reg', mouse, date, run);

% VOLUMEREG1: XY registration and save 1st registration
disp("volumereg1");
[RowShiftsXY, ColumnShiftsXY] = DetermineXYShifts(volume,...
    BlurFactor,KeepingFactor,ref1reg);
[volumereg1] = ApplyXYShifts(volume, RowShiftsXY, ColumnShiftsXY);
saveVolumeRegistration(savingpath, volumereg1, 'volumereg1', mouse, date, run, nbchunck);
mkdir(strcat(savingpath, 'ShiftsRow\'));
mkdir(strcat(savingpath, 'ShiftsColumn\'));
save(strcat(savingpath, 'ShiftsRow\RowShiftsXY1'), 'RowShiftsXY');
save(strcat(savingpath, 'ShiftsColumn\ColumnShiftsXY1'), ...
    'ColumnShiftsXY');
clear volume; % clear variables to free space

% REFERENCE 2
disp("reference 2");
ref2 = DefineReference(volumereg1, n);
[Ref2RowShifts,Ref2ColumnShifts] = DetermineXYShifts(ref2(:,:,:,:),...
    BlurFactor,KeepingFactor,ref2(:,:,:,1));
[ref2reg] = ApplyXYShifts(ref2, Ref2RowShifts, Ref2ColumnShifts);
saveVolumeRegistration(savingpath, ref2reg, 'ref2reg', mouse, date, run);

% REGISTRATION 2: Z registration with interpolation
disp("volumereg2");
[RowShifts,ColumnShifts,ZShifts] = ComputeZshiftInterpolate(...
    ref2reg, volumereg1, PlaneRemove, [60,100,10,10]);
[volumereg2] = ApplyZShiftInterpolate(volumereg1, ZShifts, ...
    ColumnShifts, RowShifts);
saveVolumeRegistration(savingpath, volumereg2, 'volumereg2', mouse, date, run, nbchunck);
save(strcat(savingpath, 'ShiftsRow\RowShiftsZ'), 'RowShifts');
save(strcat(savingpath, 'ShiftsColumn\ColumnShiftsZ'), 'ColumnShifts');
mkdir(strcat(savingpath, 'ShiftsZ\'));
save(strcat(savingpath, 'ShiftsZ\ZShifts'), 'ZShifts');
clear volumereg1;

% REFERENCE 3
disp("reference 3");
ref3 = DefineReference(volumereg2, n);
[Ref3RowShifts,Ref3ColumnShifts] = DetermineXYShifts(ref3(:,:,:,:),...
    BlurFactor,KeepingFactor,ref3(:,:,:,1));
[ref3reg] = ApplyXYShifts(ref3, Ref3RowShifts, Ref3ColumnShifts);
saveVolumeRegistration(savingpath, ref3reg, 'ref3reg', mouse, date, run);

% REGISTRATION 3
disp("volumereg3");
[RowShiftsXY2, ColumnShiftsXY2] = DetermineXYShifts(volumereg2,...
    BlurFactor,KeepingFactor,ref3reg);
[volumereg3] = ApplyXYShifts(volumereg2, RowShiftsXY2, ...
    ColumnShiftsXY2);
saveVolumeRegistration(savingpath, volumereg3, 'volumereg3', mouse, date, run, nbchunck);
save(strcat(savingpath, 'ShiftsRow\RowShiftsXY2'), 'RowShiftsXY2');
save(strcat(savingpath, 'ShiftsColumn\ColumnShiftsXY2'), ...
    'ColumnShiftsXY2');
clear volumereg2;

tEnd = toc;
fprintf('Elapsed time is %d minutes and %f seconds\n.', ...
    floor(tEnd-tStart/60),rem(tEnd-tStart,60));
end
end