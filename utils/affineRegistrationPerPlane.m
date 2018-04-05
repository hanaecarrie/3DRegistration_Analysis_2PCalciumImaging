function [volumeregaffine] = affineRegistrationPerPlane(mouse, date, ...
    runs, volumereg3, n, pathbegin)

if nargin < 6
    indice = 1;
else
    indice = 0;
end

volumeregaffine = [];

for run = runs
    disp(run);
    if indice == 1
        path = sbxPath(mouse, date, run, 'sbx');
    else
        path = strcat(pathbegin, 'affineplanes\', date, '_', mouse, ...
            '_run', num2str(run), '\',...
            mouse, '_', date, '_', num2str(run-1), '.sbx');
    end
    out = sbxAlignAffineDFT({path}, 'tbin', 0, 'refsize', ...
        size(volumereg3, 4), 'refoffset', n);
    sbxSaveAlignedSBX(path);
    if indice == 1
        pathaffine = sbxPath(mouse, date, run, 'sbxreg');
    else
        pathaffine = strcat(pathbegin,  'affineplanes\',...
            date, '_', mouse, '_run', num2str(run), '\',...
            mouse, '_', date, '_', num2str(run-1), '_reg-0.sbxreg');
    end
    plane = sbxReadPMT(pathaffine);
    volumeregaffine = cat(4, volumeregaffine, plane);
end

volumeregaffine = permute(volumeregaffine, [1,2,4,3]);
end