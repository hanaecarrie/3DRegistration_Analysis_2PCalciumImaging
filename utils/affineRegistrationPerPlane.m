function [] = affineRegistrationPerPlane(mouse, date, ...
    oldrun, runs, channel, volumereg3, edges, n, nbchunck, varargin)
% AFFINEREGISTRATIONPERPLANE

p = inputParser;
    addOptional(p, 'structure', 'onscanbox'); % can be 'onstorage' or 'onscanbox'
    addOptional(p, 'server', 'megatron');
    addOptional(p, 'pathbeginread', '');
    addOptional(p, 'pathbeginwrite', 'E:\hanae_data\Microglia\'),
    if length(varargin) == 1 && iscell(varargin{1})
        varargin = varargin{1};
    end
parse(p, varargin{:});
p = p.Results;

if p.structure == 'onscanbox'
    indice = 1;
elseif p.structure == 'onstorage'
    indice = 0;
end

dataregaffine = [];
idx = 0;

for run = runs
    idx = idx + 1;
    if indice == 1
        path = sbxPath(mouse, date, run, 'sbx', 'server', p.server);
        pathexist = strcat(path(1:end-4),'_reg-0.sbxreg');
    else
        path = strcat(p.pathbeginread, mouse, '_', date, ...
            '_', num2str(oldrun), '_', num2str(channel),...
            '\affineplanes\', date, '_', mouse, ...
            '_run', num2str(run), '\',...
            mouse, '_', date, '_', num2str(run-1), '.sbx');
        pathexist = strcat(p.pathbeginread, mouse, '_', date,...
            '_', num2str(oldrun), '_', num2str(channel), ...
            '\affineplanes\', date, '_', mouse, ...
            '_run', num2str(run), '\', mouse, '_', date, '_', ...
            num2str(run-1), '_reg-0.sbxreg');
    end
    
    if ~exist(pathexist, 'file')
         disp(run);
        out = sbxAlignAffineDFT({path}, 'edges', edges,...
            'tbin', 0, 'refsize', size(volumereg3, 4), 'refoffset', n);
        sbxSaveAlignedSBX(path);
    end
end
idx = 0;
for runbis = runs
    idx = idx + 1;
    if indice == 1
        pathaffine = sbxPath(mouse, date, runbis, 'sbxreg', 'server', p.server);
    else
        pathaffine = strcat(pathbeginread, mouse, '_', date, ...
        '_', num2str(oldrun), '_', num2str(channel),...
        '\affineplanes\', date, '_', mouse, ...
        '_run', num2str(runbis), '\',...
        mouse, '_', date, '_', num2str(runbis-1), '_reg-0.sbxreg');
    end
   plane = sbxReadPMT(pathaffine);
   if isempty(dataregaffine)
       dataregaffine = uint16(zeros(size(plane,1), size(plane,2),...
           size(plane,3), length(runs)));
   end
   dataregaffine(:,:,:,idx) = plane;
end

dataregaffine = permute(dataregaffine, [1,2,4,3]);
if ~exist(strcat(p.pathbeginwrite, mouse, '_', date, '_',...
    num2str(oldrun), '_', num2str(channel), '\dataregaffine\', mouse,...
        '_', date, '_', num2str(oldrun), '_', num2str(channel), '_', ...
        'dataregaffine.sbx'), 'file')
    saveVolumeRegistration(strcat(p.pathbeginwrite, mouse, '_', date, '_',...
        num2str(oldrun), '_', num2str(channel), '\'), dataregaffine, ...
        'dataregaffine', mouse, date, oldrun, channel, ...
        'nbchuncktiff', nbchunck, 'server', p.server);
end
clear dataregaffine;

end