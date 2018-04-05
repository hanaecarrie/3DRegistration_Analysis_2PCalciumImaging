function [] = AlignAcrossRuns(mouse, date, runs, ...
    BlurFactor, KeepingFactor, n, savingpathbegin, nbchunck, m1, m2)
% Registration align across runs
% Parameters
% mouse =  'DL89';
% date = '171122';
% n = 30; % chunck size
% BlurFactor = 1;
% KeepingFactor = 0.95;
% savingpathbegin = 'E:\hanae_data\alextry';
% nbchunck = 10;
% runs = 1:6;
% zp = 30;
% m1 = 10000;
% m2 = 100000;

tStart = tic;
info = sbxInfo(mouse, date, runs[1]);
zp = info.otparam[3];

% REFERENCE 1st RUN
[volumeregaffineref] = loadSBXPlanes(mouse, date, (1:zp)+m1*runs(1),...
    'reg-0.sbxreg');
[refacrossruns] = DefineReference(volumeregaffineref, n);
[RefARowShifts,RefAColumnShifts] = DetermineXYShifts(refacrossruns,...
    BlurFactor,KeepingFactor,refacrossruns(:,:,:,1));
[refAreg] = ApplyXYShifts(refacrossruns, RefARowShifts,...
    RefAColumnShifts);

% APPLY REGISTRATION TO OTHER RUNS
count = 0;
 for run = runs
    savingpath = strcat(savingpathbegin, '\', mouse, '_date', ...
    date, '_run', num2str(run), '\');
    [volumeregaffine] = loadSBXPlanes(mouse, date, (1:zp)+m1*run,...
        'reg-0.sbxreg');
    if count == 1
    [RowShiftsXYA, ColumnShiftsXYA] = DetermineXYShifts(...
        volumeregaffine,...
        BlurFactor,KeepingFactor,refAreg);
    [volumeregacrossruns] = ApplyXYShifts(volumeregaffine, ...
        RowShiftsXYA, ColumnShiftsXYA);
    save(strcat(savingpath, 'ShiftsRow\RowShiftsXYA'), 'RowShiftsXYA');
    save(strcat(savingpath, 'ShiftsColumn\ColumnShiftsXYA'), ...
        'ColumnShiftsXYA');
    else
        volumeregacrossruns = volumeregaffine;
        count = 1;
    end
    saveVolumeRegistration(savingpath, volumeregacrossruns,...
        'volumeregacrossruns', mouse, date, run, nbchunck);
    saveSBXfilesPerPlane(mouse, date, run, volumeregacrossruns, m2);
 end

tEnd = toc;
fprintf('Elapsed time is %d minutes and %f seconds\n.', ...
    floor((tEnd-tStart)/60),rem((tEnd-tStart),60));
