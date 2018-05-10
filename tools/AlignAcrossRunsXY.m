function [] = AlignAcrossRunsXY(inputfolders, mouse, date, runs,...
    BlurFactor, KeepingFactor, n, outputfolders, nbchunck)
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
info = sbxInfo(sbxPath(mouse, date, runs(1),'sbx'));
zp = info.otparam(3);

% REFERENCE 1st RUN
[volumeregaffineref] = sbxReadPMT(strcat(inputfolders(1,:), ...
    '\volumeregaffine\', mouse, '_', date, '_', num2str(runs(1)),...
    '_volumeregaffine.sbx'));
Size = size(volumeregaffineref);
volumeregaffineref = reshape(volumeregaffineref,...
    [Size(1), Size(2), zp, floor(Size(3)/zp)]);
[refacrossruns] = DefineReference(volumeregaffineref, n);
[RefARowShifts,RefAColumnShifts] = DetermineXYShifts(refacrossruns,...
    BlurFactor,KeepingFactor,refacrossruns(:,:,:,1));
[refAreg] = ApplyXYShifts(refacrossruns, RefARowShifts,...
    RefAColumnShifts);
save(strcat(outputfolders(1,:), '\', mouse, '_', date, '_',...
    num2str(runs(1)), '\ShiftsRow\RefARowShifts'), 'RefARowShifts');
save(strcat(outputfolders(1,:), '\', mouse, '_', date, '_',...
    num2str(runs(1)), '\ShiftsColumn\RefAColumnShifts'),...
    'RefAColumnShifts');
saveVolumeRegistration(strcat(outputfolders(1,:), ...
    '\', mouse, '_', date, '_', num2str(runs(1)), '\'), refAreg,...
    'refAreg', mouse, date, runs(1), 15);
clear volumeregaffineref; clear refaccrossruns; clear RefARowShifts;
clear RefAColumnShifts;

% APPLY REGISTRATION TO OTHER RUNS
idx = 2;
 for run = runs(2:end)
    savingpath = strcat(outputfolders(idx,:), '\', mouse, '_date', ...
    date, '_', num2str(run), '\');
    [volumeregaffine] = sbxReadPMT(strcat(inputfolders(idx,:), ...
    '\volumeregaffine\', mouse, '_', date, '_', num2str(runs(idx)),...
    '_volumeregaffine.sbx'));
    Size = size(volumeregaffine);
    volumeregaffine = reshape(volumeregaffine,...
    [Size(1), Size(2), zp, floor(Size(3)/zp)]);
    [RowShiftsXYA, ColumnShiftsXYA] = DetermineXYShifts(...
        volumeregaffine,...
        BlurFactor,KeepingFactor,refAreg);
    save(strcat(outputfolders(idx,:), '\', mouse, '_', date, '_',...
    num2str(runs(idx)), '\ShiftsRow\RowShiftsXYA'), 'RowShiftsXYA');
    save(strcat(outputfolders(idx,:), '\', mouse, '_', date, '_',...
    num2str(runs(idx)), '\ShiftsColumn\ColumnShiftsXYA'),...
    'ColumnShiftsXYA');
    [volumeregacrossruns] = ApplyXYShifts(volumeregaffine, ...
        RowShiftsXYA, ColumnShiftsXYA);
    saveVolumeRegistration(savingpath, volumeregacrossruns,...
        'volumeregacrossrunsXY', mouse, date, run, nbchunck);
    clear volumeregacrossruns; 
%     saveSBXfilesPerPlane(mouse, date, run, volumeregacrossruns, m, ...
%         savingpathbegin);
 end

tEnd = toc;
fprintf('Elapsed time is %d minutes and %f seconds\n.', ...
    floor((tEnd-tStart)/60),rem((tEnd-tStart),60));
