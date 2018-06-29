function [] = DetectROIs(mouse, date, realruns,...
    n, savingpathbegin, nbchunck, m2)
% ROIs and determine affine
% Parameters
% mouse = 'DL89';
% date = '171122';
% zp = 30;
% realruns = 1:6;
% m2 = 10000;
% runs = realruns*m2;
% n = 30; % chunck size
% savingpathbegin = 'E:\hanae_data\alextry';
% nbchunck = 10;

tStart = tic;

for plane = 2:zp
    disp(plane)
    newruns = runs+plane;
    sbxPreprocessDuraStack(mouse, date, 'runs', newruns,...
        'refsize', n, 'refoffset', 0);
end

savingpath = strcat(savingpathbegin, '\', mouse, '_date', ...
    date, '_run', num2str(run), '\');
for r = realruns
    [volumefinal] = loadSBXPlanes(mouse, date, (1:zp) + m2*r, ...
        'reg-0.sbxreg');
    saveVolumeRegistration(savingpath, volumefinal, mouse, date,...
        r, nbchunck);
end

tEnd = toc;
fprintf('Elapsed time is %d minutes and %f seconds\n.', ...
    floor((tEnd-tStart)/60),rem((tEnd-tStart),60));
end