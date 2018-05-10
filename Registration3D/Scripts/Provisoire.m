function [] = Provisoire(mouse, date, runs, paths,...
    n, BlurFactor, KeepingFactor, savingpathbegin, nbchunck)%, Zdepthall)

i=0;
for run = runs
    i = i+1;
    tStart = tic;
    strdate = regexprep(datestr(datetime('now')), ' ', '_');
    strdate = regexprep(strdate, ':', '-');
savingpath = strcat(savingpathbegin, '\', strdate, '\');
mkdir(savingpath)
savingpath = strcat(savingpath, mouse, '_', date, '_',...
    num2str(run), '\');
mkdir(savingpath);

% infos
sbxpath = sbxPath(mouse, date, run, 'sbx');
info = sbxInfo(sbxpath);
w = info.sz(1); h = info.sz(2); zp = length(info.otwave);
ts = (info.max_idx+1)/(length(info.otwave));

% % load data volumereg2, 
% pathvolumereg1 = strcat(savingpathbegin, paths(i,:), '\', mouse, '_', date, '_',...
%     num2str(run), '\',  'volumereg1\', mouse, '_', date, '_', num2str(run),...
%     '_volumereg1.sbx');
%  volumereg1 = sbxReadPMT(pathvolumereg1);
%  volumereg1 = reshape(volumereg1, [w, h, zp, ts]);
% 
% ZShifts = Zdepthall(:,1+(run-1)*ts:run*ts);
% ZShifts = cat(1, zeros(3, ts), ZShifts);
% 
% pathC = strcat(savingpathbegin, paths(i,:), '\',mouse, '_', date, '_',...
%     num2str(run), '\',  'ShiftsColumn\ColumnShiftsZ.mat');
% ColumnShifts = load(pathC);
% ColumnShifts = ColumnShifts.ColumnShifts;
% 
% pathR = strcat(savingpathbegin, paths(i,:), '\',mouse, '_', date, '_',...
%     num2str(run), '\',  'ShiftsRow\RowShiftsZ.mat');
% RowShifts = load(pathR);
% RowShifts = RowShifts.RowShifts;
% 
% [volumereg2] = ApplyZShiftInterpolate(volumereg1, ZShifts, ...
%       ColumnShifts, RowShifts);
mkdir(strcat(savingpath, 'ShiftsRow\'));
mkdir(strcat(savingpath, 'ShiftsColumn\'));
% volumereg2 = uint16(volumereg2);
% saveVolumeRegistration(savingpath, volumereg2, 'volumereg2', ...
%     mouse, date, run, nbchunck);
% clear volumereg1;

pathvolumereg2 = strcat(savingpathbegin, paths(i,:), '\', mouse, '_', date, '_',...
    num2str(run), '\',  'volumereg2\', mouse, '_', date, '_', num2str(run),...
    '_volumereg2.sbx');
 volumereg2 = sbxReadPMT(pathvolumereg2);
 volumereg2 = reshape(volumereg2, [w, h, zp, ts]);

% REFERENCE 3
disp("reference 3");
ref3 = DefineReference(volumereg2, n);
[Ref3RowShifts,Ref3ColumnShifts] = DetermineXYShifts(ref3(:,:,:,:),...
    BlurFactor,KeepingFactor,ref3(:,:,:,1));
[ref3reg] = ApplyXYShifts(ref3, Ref3RowShifts, Ref3ColumnShifts);
saveVolumeRegistration(savingpath, ref3reg, 'ref3reg', mouse, date, run,...
    nbchunck);

% REGISTRATION 3
disp("volumereg3");
[RowShiftsXY2, ColumnShiftsXY2] = DetermineXYShifts(volumereg2,...
    BlurFactor,KeepingFactor,ref3reg);
save(strcat(savingpath, 'ShiftsRow\RowShiftsXY2'), 'RowShiftsXY2');
save(strcat(savingpath, 'ShiftsColumn\ColumnShiftsXY2'), ...
    'ColumnShiftsXY2');
[volumereg3] = ApplyXYShifts(volumereg2, RowShiftsXY2, ...
    ColumnShiftsXY2);
clear volumereg2;
volumereg3 = uint16(volumereg3);
saveVolumeRegistration(savingpath, volumereg3, 'volumereg3',...
    mouse, date, run, nbchunck);
clear volumereg3;

tEnd = toc;
fprintf('Elapsed time is %d minutes and %f seconds\n.', ...
    floor(tEnd-tStart/60),rem(tEnd-tStart,60));
end
end