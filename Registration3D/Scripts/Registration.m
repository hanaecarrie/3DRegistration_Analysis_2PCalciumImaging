function [] = Registration(mouse, date, runs, ...
    BlurFactor, KeepingFactor, n, PlanesCorr,...
    nbchunck, m1, savingpathbegin, paths)
% Registration per run: XYZXY, save sbx files *100, affine reg / plane
% Parameters example
% mouse = 'DL89';
% date = '171122';
% runs = 1:6;
% n = 30; % chunck size
% BlurFactor = 1;
% KeepingFactor = 0.95;
% PlaneRemove = 3;
% savingpathbegin = 'E:\hanae_data\alextry';
% nbchunck = 10;
% m1 = 10000;
% HELP NOTE  
%     load volumereg3
% pathvolumereg3 = strcat(savingpathbegin, '\', mouse, '_date', ...
%         date, '_run', num2str(run), '\volumereg3\',...
%         mouse, '_', date, '_', num2str(run), '_volumereg3.sbx');
%     volumereg3 = sbxReadPMT(pathvolumereg3);
%     volumereg3 = reshape(volumereg3, [512, 796, 15, 1860]);

tS = tic;

if nargin <10
    savingpathbegin = 'E:\hanae_data\Dura\registrationFiles\';
end
idx = 0;
for run = runs
    idx = idx+1;
    % XY, Z, XY registration
    [volumereg3, savingpath] = XYZXYRegistration(mouse, date, run, n,...
        BlurFactor, KeepingFactor, PlanesCorr,...
        savingpathbegin, nbchunck);
%     load volumereg3
%     pathvolumereg3 = strcat(savingpathbegin, paths(idx,:),'\', mouse, '_', ...
%         date, '_', num2str(run), '\volumereg3\',...
%         mouse, '_', date, '_', num2str(run), '_volumereg3.sbx');
%     volumereg3 = sbxReadPMT(pathvolumereg3);
%     volumereg3 = reshape(volumereg3, [512, 796, 30, 930]);
    % save sbx files per plane
    savingpath = strcat(savingpathbegin, paths(idx,:),'\');
    saveSBXfilesPerPlane(mouse, date, run, volumereg3, m1, savingpath);
    % affine alignement per plane
    zp = size(volumereg3, 3);
    newruns = (1:zp)+ m1*run;
    volumeregaffine = affineRegistrationPerPlane(mouse, date,...
        newruns, volumereg3, n, savingpath);
    saveVolumeRegistration(savingpath, volumeregaffine, ...
        'volumeregaffine', mouse, date, run, nbchunck);
end

tE = toc;
fprintf('Elapsed time is %d minutes and %f seconds\n.', ...
    floor((tE-tS)/60),rem((tE-tS),60));

end
