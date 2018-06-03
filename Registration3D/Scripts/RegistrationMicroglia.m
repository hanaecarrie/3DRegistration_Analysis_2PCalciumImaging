function [] = RegistrationMicroglia(mouse, date, runs, refchannel, ...
    edges, blurfactor, keepingfactor, n, planescorr,...
    nbchunck, m1, varargin)
% REGISTRATIONMICROGLIA: performs registration of microglia movies

    p = inputParser;
    addOptional(p, 'strdate', ...
        regexprep(regexprep(datestr(datetime('now')), ' ', '_'), ':', '-'));
    % get current time and date to create new folder if new registration
    addOptional(p, 'paths', []);  % default sbxpaths in scanbox 
    addOptional(p, 'savingpathbegin',...
        'E:\hanae_data\Microglia\registrationFiles\'); 
    % default saving location
    addOptional(p, 'warpingversion', 'hanae');  % 'hanae' or 'freds'
    addOptional(p, 'sizedata', [512, 796,124, 200]);  % data size
    addOptional(p, 'server', 'megatron');  % default server
    if length(varargin) == 1 && iscell(varargin{1})
        varargin = varargin{1};
    end
    parse(p, varargin{:});
    p = p.Results;

tStartRM = tic;

if isempty(p.paths)
    for rr = 1:length(runs)
        p.paths = cat(1, p.paths, sbxPath(mouse, date, runs(rr), 'sbx', ...
            'server', p.server));
    end
end
idx = 0;

for run = runs
    idx = idx+1;
    % Create directory (if necessary)
    savingpath = strcat(p.savingpathbegin, '\', p.strdate, '\');
    if ~exist(savingpath, 'dir')
        mkdir(savingpath)
    end
    savingpath = strcat(p.savingpathbegin, '\', p.strdate, '\');
    savingpath = strcat(savingpath, mouse, '_', date, '_',...
        num2str(run), '\');
    if ~exist(savingpath, 'dir')
        mkdir(savingpath)
    end
    % Correct warping
    if ~exist(strcat(savingpath, mouse, '_', date, '_',...
        num2str(run), '_', num2str(refchannel), '\warpreg\', mouse,...
        '_', date, '_', num2str(run), '_', num2str(refchannel), '_', ...
        'warpreg.sbx'), 'file')
        disp('CorrectWarping2Channels');
        if p.warpingversion == 'hanae'
        [outputpaths, EdgesWarp] = CorrectWarping2Channels(...
            p.paths(idx,:), savingpath, mouse, date, run, refchannel, ...
            blurfactor, edges, nbchunck, p.sizedata, p.server);
        else
        [outputpaths, EdgesWarp] = CorrectWarpingFred(p.paths(idx,:), ...
            savingpath, mouse, date, run, 124, edges, n);
        end
    else
        outputpaths = cell(2,1);
        outputpaths{1} = strcat(savingpath, mouse, '_', date, '_',...
        num2str(run), '_', num2str(refchannel), '\warpreg\', mouse,...
        '_', date, '_', num2str(run), '_', num2str(refchannel), '_', ...
        'warpreg.sbx');
    	outputpaths{2} = strcat(savingpath, mouse, '_', date, '_',...
        num2str(run), '_', num2str(~refchannel), '\warpreg\', mouse,...
        '_', date, '_', num2str(run), '_', num2str(refchannel), '_', ...
        'warpreg.sbx');
          EdgesWarp = load(strcat(savingpath, mouse, '_', date, '_',...
             num2str(run), '_', num2str(refchannel), '\EdgesWarp'));
             EdgesWarp = EdgesWarp.EdgesWarp;
    end
    % CHANNEL 1
    if ~exist(strcat(savingpath, mouse, '_', date, '_',...
        num2str(run), '_', num2str(refchannel), '\datareg3\', mouse,...
        '_', date, '_', num2str(run), '_', num2str(refchannel), '_', ...
        'datareg3.sbx'), 'file')
        disp('CHANNEL 1 - XYZXY registration');
        [datareg3, ~] = XYZXYRegistration(outputpaths{1},...
            mouse, date, run, refchannel, n, blurfactor, keepingfactor, ...
            EdgesWarp, planescorr, nbchunck, p.sizedata, 'savingpathbegin', ...
            savingpath, 'server', p.server);
        % save sbx files per plane
        saveSBXfilesPerPlane(mouse, date, run, refchannel,...
            datareg3, m1,sbxPath(mouse, date, run, 'sbx', 'server', p.server), ...
            'server', p.server);
        disp('CHANNEL 1 - Affine Alignement');
        zp = p.sizedata(3);
        newruns = (1:zp)+ m1*run;
        affineRegistrationPerPlane(mouse, date,...
            run, newruns, refchannel, datareg3, EdgesWarp, n, nbchunck,...
             'pathbeginwrite', savingpath, 'server', p.server);
        clear datareg3;
    elseif ~exist(strcat(savingpath, mouse, '_', date, '_',...
        num2str(run), '_', num2str(refchannel), '\dataregaffine\', mouse,...
        '_', date, '_', num2str(run), '_', num2str(refchannel), '_', ...
        'dataregaffine.sbx'), 'file')
        datareg3 = sbxReadPMT(strcat(savingpath, mouse, '_', date, '_',...
        num2str(run), '_', num2str(refchannel), '\datareg3\', mouse,...
        '_', date, '_', num2str(run), '_', num2str(refchannel), '_', ...
        'datareg3.sbx'));
        zp = p.sizedata(3);
        datareg3 = reshape(datareg3, p.sizedata);
        % save sbx files per plane
        saveSBXfilesPerPlane(mouse, date, run, refchannel,...
            datareg3, m1, ...
            sbxPath(mouse, date, run, 'sbx', 'server', p.server), ...
            'server', p.server);
        disp('CHANNEL 1 - Affine Alignement');
        newruns = (1:zp)+ m1*run;
        affineRegistrationPerPlane(mouse, date,...
            run, newruns, refchannel, datareg3, EdgesWarp, n, nbchunck, ...
            'server', p.server, 'pathbeginwrite', savingpath);
        clear datareg3;
    else
         EdgesWarp = load(strcat(savingpath, mouse, '_', date, '_',...
        num2str(run), '_', num2str(refchannel), '\EdgesWarp'));
        EdgesWarp = EdgesWarp.EdgesWarp;
    end
    
    % CHANNEL 2
    disp('CHANNEL 2 - Apply XYZXY shifts');
    otherchannel = ~refchannel;
    % load shifts from other channel
    pathshifts = strcat(savingpath, '\',mouse, '_', date, '_',...
        num2str(run), '_', num2str(refchannel), '\');
    RowShifts1 = load(strcat(pathshifts,'ShiftsRow\RowShiftsXY1'));
    RowShifts1 = RowShifts1.RowShiftsXY1;
    RowShifts2 = load(strcat(pathshifts,'ShiftsRow\RowShiftsZ'));
    RowShifts2 = RowShifts2.RowShiftsZ;
    RowShifts3 = load(strcat(pathshifts,'ShiftsRow\RowShiftsXY2'));
    RowShifts3 = RowShifts3.RowShiftsXY2;
    ColumnShifts1 = load(strcat(pathshifts,'ShiftsColumn\ColumnShiftsXY1'));
    ColumnShifts1 = ColumnShifts1.ColumnShiftsXY1;
    ColumnShifts2 = load(strcat(pathshifts,'ShiftsColumn\ColumnShiftsZ'));
    ColumnShifts2 = ColumnShifts2.ColumnShiftsZ;
    ColumnShifts3 = load(strcat(pathshifts,'ShiftsColumn\ColumnShiftsXY2'));
    ColumnShifts3 = ColumnShifts3.ColumnShiftsXY2;
    ZShifts = load(strcat(pathshifts, 'ShiftsZ\Zshifts'));
    ZShifts = ZShifts.ZShifts;
    % load data wraping corrected
    pathwarpotherch = strcat(savingpath, '\', mouse, '_', date, '_', ...
        num2str(run), '_', num2str(otherchannel), '\warpreg\', ...
        mouse, '_', date, '_', num2str(run), '_', ...
        num2str(otherchannel), '_warpreg.sbx');
    dataw = sbxReadPMT(pathwarpotherch);
    zp = p.sizedata(3);
    ts = p.sizedata(4);
    dataw = reshape(dataw, [size(dataw,1), size(dataw, 2), zp, ts]);
    dataw = dataw(EdgesWarp(3)+1:end-EdgesWarp(4),...
        EdgesWarp(1)+1:end-EdgesWarp(2),:,:);
    % apply shifts
    savinpathotherch = strcat(savingpath, mouse, '_', date, '_',...
        num2str(run), '_', num2str(otherchannel), '\');
    [datareg1] = ApplyXYShifts(dataw, RowShifts1, ColumnShifts1);
    clear dataw; % clear variables to free space
    [datareg2] = ApplyZShiftInterpolate(datareg1, ZShifts, ...
      ColumnShifts2, RowShifts2);
    datareg1 = padarray(datareg1, [EdgesWarp(3), EdgesWarp(1)], 'pre');
    datareg1 = padarray(datareg1, [EdgesWarp(4), EdgesWarp(2)], 'post');
    saveVolumeRegistration(savinpathotherch, datareg1, 'datareg1', ...
        mouse, date, run, otherchannel, 'server', p.server, 'type', 'sbx');
    clear datareg1;
    [datareg3] = ApplyXYShifts(datareg2, RowShifts3, ColumnShifts3);
    datareg2 = padarray(datareg2, [EdgesWarp(3), EdgesWarp(1)], 'pre');
    datareg2 = padarray(datareg2, [EdgesWarp(4), EdgesWarp(2)], 'post');
    saveVolumeRegistration(savinpathotherch, datareg2, 'datareg2', ...
        mouse, date, run, otherchannel, nbchunck,'server', p.server,'type', 'sbx');
    clear datareg2;
    datareg3 = padarray(datareg3, [EdgesWarp(3), EdgesWarp(1)], 'pre');
    datareg3 = padarray(datareg3, [EdgesWarp(4), EdgesWarp(2)], 'post');
    mkdir(strcat(savinpathotherch, 'datareg3\'));
    saveVolumeRegistration(savinpathotherch, datareg3, 'datareg3',...
        mouse, date, run, otherchannel, nbchunck,'server', p.server,'type', 'sbx');
    dataregaffine = datareg3(:,:,:,:);
    clear datareg3;
    disp('CHANNEL 2 - Apply affine');
    allaffine = cell(1,zp);
%     pathaffinebegin = strcat(savingpath,  mouse, '_', date, '_',...
%         num2str(run), '_', num2str(refchannel), '\affineplanes\', ...
%         date, '_', mouse, '_run');
    for plane = 1:zp
        disp(plane)
        transplane = squeeze(dataregaffine(:,:,plane, :));
%         aafine = load(strcat(pathaffinebegin,...
%             num2str(run*m1+plane), '\', mouse, '_', date, '_',...
%             num2str(run*m1+plane-1), '.alignaffine'), '-mat');
            aafine = sbxLoad(mouse, date, run*m1+plane, 'alignaffine',...
                p.server);
        affine = aafine.tform;
        allaffine{1,plane} = affine;
        for t = 1:ts
            transplane(:,:,t) = imwarp(transplane(:,:,t), ...
                affine{1,t}, 'OutputView', ...
                imref2d(size(transplane(:,:,t))));
            dataregaffine(:,:,plane,t) = transplane(:,:,t);
        end 
    end
%     mkdir(strcat(savinpathotherch, 'dataregaffine\'));
    saveVolumeRegistration(savinpathotherch, dataregaffine, ...
        'dataregaffine', mouse, date, run, otherchannel, ...
        'nbchuncktiff', nbchunck, 'server', p.server);
    
    clear dataregaffine;
    end

tEndRM = toc(tStartRM);
fprintf('RegistrationMicroglia in %d minute(s) and %f seconds\n.', ...
    floor((tEndRM)/60),rem((tEndRM),60));

end