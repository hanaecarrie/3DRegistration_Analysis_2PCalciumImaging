function [] = AlignAcrossRunsZ(inputfolders, mouse, date, runs,...
    BlurFactor, KeepingFactor, n, outputfolders, nbchunck, refAreg)
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
% [volumeregaffineref] = sbxReadPMT(strcat(inputfolders(1,:), ...
%     '\volumeregaffine\', mouse, '_', date, '_', num2str(runs(1)),...
%     '_volumeregaffine.sbx'));
% Size = size(volumeregaffineref);
% volumeregaffineref = reshape(volumeregaffineref,...
%     [Size(1), Size(2), zp, floor(Size(3)/zp)]);
% [refacrossruns] = defineReference(volumeregaffineref, n);
% [RefARowShifts,RefAColumnShifts] = DetermineXYShifts(refacrossruns,...
%     BlurFactor,KeepingFactor,refacrossruns(:,:,:,1));
% [refAreg] = ApplyXYShifts(refacrossruns, RefARowShifts,...
%     RefAColumnShifts);
% save(strcat(outputfolders(1,:), '\', mouse, '_', date, '_',...
%     num2str(runs(1)), '\ShiftsRow\RefARowShifts'), 'RefARowShifts');
% save(strcat(outputfolders(1,:), '\', mouse, '_', date, '_',...
%     num2str(runs(1)), '\ShiftsColumn\RefAColumnShifts'),...
%     'RefAColumnShifts');
% saveVolumeRegistration(strcat(outputfolders(1,:), ...
%     '\', mouse, '_', date, '_', num2str(runs(1)), '\'), refAreg,...
%     'refAreg', mouse, date, runs(1), nbchunck);
% clear volumeregaffineref; clear refaccrossruns; clear RefARowShifts;
% clear RefAColumnShifts;

% APPLY REGISTRATION TO OTHER RUNS
idx = 2;
 for run = runs(2:end)
    savingpath = strcat(outputfolders(idx,:), '\', mouse, '_date', ...
    date, '_', num2str(run), '\');
    [volumeregacrossrunsXY] = sbxReadPMT(strcat(inputfolders(idx,:), ...
    '\volumeregacrossrunsXY\', mouse, '_', date, '_',...
        num2str(runs(idx)),'_volumeregacrossrunsXY.sbx'));
    Size = size(volumeregacrossrunsXY);
    volumeregacrossrunsXY = reshape(volumeregacrossrunsXY,...
    [Size(1), Size(2), zp, floor(Size(3)/zp)]);
    [RowShiftsZA,ColumnShiftsZA,ZShiftsZA] = ComputeZshiftInterpolate(...
        refAreg, volumeregacrossrunsXY, 3, [120,200,20,20]);
    save(strcat(outputfolders(idx,:), '\', mouse, '_', date, '_',...
    num2str(runs(idx)), '\ShiftsRow\RowShiftsZA'), 'RowShiftsZA');
    save(strcat(outputfolders(idx,:), '\', mouse, '_', date, '_',...
    num2str(runs(idx)), '\ShiftsColumn\ColumnShiftsZA'),...
    'ColumnShiftsZA');
    mkdir(strcat(outputfolders(idx,:), '\', mouse, '_', date, '_',...
        num2str(runs(idx)), '\ShiftsZ\'));
    save(strcat(outputfolders(idx,:), '\', mouse, '_', date, '_',...
        num2str(runs(idx)), '\ShiftsZ\ZShiftsZA'),...
        'ZShiftsZA');
    [volumeregacrossrunsZ] = ApplyZShiftInterpolate(...
        volumeregacrossrunsXY,ZShiftsZA, ColumnShiftsZA, RowShiftsZA);
    clear volumeregacrossrunsXY;
    saveVolumeRegistration(savingpath, volumeregacrossrunsZ,...
        'volumeregacrossrunsZ', mouse, date, run, nbchunck);
    clear volumeregacrossrunsZ; 
%     saveSBXfilesPerPlane(mouse, date, run, volumeregacrossruns, m, ...
%         savingpathbegin);
 end

tEnd = toc;
fprintf('Elapsed time is %d minutes and %f seconds\n.', ...
    floor((tEnd-tStart)/60),rem((tEnd-tStart),60));

end