function [] = RegistrationDura(mouse, date, runs, ...
    edges, blurfactor, keepingfactor, n, planescorr,...
    nbchunck, m1, varargin)

% REGISTRATIONDURA: performs registration of the dura movies
%
%   Inputs:
%     mouse -- str, mouse name
%     date -- str, imaging session date
%     runs -- int or list of int, run numbers
%     refchannel -- 0 for green or 1 for red, channel on which the
%         registration is performed
%     edges -- array of int, dim 1x4, number of pixels to remove
%         [left, right, top, bottom]
%     blurfactor -- float, width of the gaussian filter (ex: 1)
%         keepingfactor --  float in ]0,1[,
%         croping indicator for z correction (ex: 0.95)
%     n -- int > 0, number of volumes to define a moving reference, n
%         should divide the total number of volumes (ex: 30 dura)
%     planescorr -- int in ]0, nbplanes/2[, 
%         the spatial correlation will be computed between the considered
%         plane and the planescorr olanes above and the planescorr planes
%         below (ex: 3)
%     nbchunck -- int > 0, number of chunck to save tiff images, nbchuncl
%         should divide the number of volumes (ex: 10)
%     m1 -- int, extension to add when saving the sbx files per plane
%         new run = (oldrun*m1) + planenumber (ex: 100 if nbplanes <100)
%   Outputs:
%     none

    p = inputParser;
    addOptional(p, 'strdate', ...
        regexprep(regexprep(datestr(datetime('now')), ' ', '_'), ':', '-'));
    % get current time and date to create new folder if new registration
    addOptional(p, 'paths', []);  % to create list of sbxpath from default
    % D server in 2photon folder by default
    addOptional(p, 'savingpathbegin',...
        'E:\hanae_data\Dura\registrationFiles\'); 
    % default saving location
    addOptional(p, 'sizedata', [512, 796, 30, 930]);  % data size
    addOptional(p, 'server','megatron'); % default server
    if length(varargin) == 1 && iscell(varargin{1})
        varargin = varargin{1};
    end
    parse(p, varargin{:});
    p = p.Results;

tStartRD = tic;
channel = 0; % 1 channel only (green)

if isempty(p.paths)
    for rr = 1:length(runs)
        p.paths = cat(1, p.paths, sbxPath(mouse, date, runs(rr), 'sbx',...
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
        num2str(run), '_', num2str(channel), '\warpreg\', mouse,...
        '_', date, '_', num2str(run), '_', num2str(channel), '_', ...
        'warpreg.sbx'), 'file')
        disp('CorrectWarping1Channel');
        [outputpath, EdgesWarp] = CorrectWarping1Channel(...
            p.paths(idx,:), savingpath, mouse, date, run, ...
            blurfactor, edges, nbchunck);
    else
        outputpath = strcat(savingpath, mouse, '_', date, '_',...
            num2str(run), '_', num2str(channel), '\warpreg\', mouse,...
            '_', date, '_', num2str(run), '_', num2str(channel), '_', ...
            'warpreg.sbx');
        EdgesWarp = load(strcat(savingpath, mouse, '_', date, '_',...
            num2str(run), '_', num2str(channel), '\EdgesWarp'));
        EdgesWarp = EdgesWarp.EdgesWarp;
    end
    if ~exist(strcat(savingpath, mouse, '_', date, '_',...
        num2str(run), '_', num2str(channel), '\datareg3\', mouse,...
        '_', date, '_', num2str(run), '_', num2str(channel), '_', ...
        'datareg3.sbx'), 'file')
        disp('XYZXY registration');
        [datareg3, ~] = XYZXYRegistration(outputpath,...
            mouse, date, run, channel, n, blurfactor, keepingfactor, ...
            EdgesWarp, planescorr, nbchunck, p.sizedata, 'savingpathbegin', ...
            savingpath, 'server', p.server);
        % save sbx files per plane
       saveSBXfilesPerPlane(mouse, date, run, channel,...
           datareg3, m1, ...
           sbxPath(mouse, date, run, 'sbx', 'server', p.server), ...
           'server', p.server);
        disp('Affine Alignement');
        zp = size(datareg3, 3);
        newruns = (1:zp)+ m1*run;
        affineRegistrationPerPlane(mouse, date,...
            run, newruns, channel, datareg3, EdgesWarp, n, nbchunck,...
            'pathbeginwrite', savingpath);
        clear datareg3;
    elseif ~exist(strcat(savingpath, mouse, '_', date, '_',...
        num2str(run), '_', num2str(channel), '\dataregaffine\', mouse,...
        '_', date, '_', num2str(run), '_', num2str(channel), '_', ...
        'dataregaffine.sbx'), 'file')
        datareg3 = sbxReadPMT(strcat(savingpath, mouse, '_', date, '_',...
        num2str(run), '_', num2str(channel), '\datareg3\', mouse,...
        '_', date, '_', num2str(run), '_', num2str(channel), '_', ...
        'datareg3.sbx'));
        info = sbxInfo(p.paths(idx,:));
        zp = info.otparam(3);
        sizedata = [size(datareg3,1), size(datareg3,2), zp,...
            size(datareg3,3)/zp];
        datareg3 = reshape(datareg3, sizedata);
        % save sbx files per plane
        saveSBXfilesPerPlane(mouse, date, run, channel,...
           datareg3, m1, ...
           sbxPath(mouse, date, run, 'sbx', 'server', p.server), ...
           'server', p.server);
        disp('Affine Alignement');
        zp = size(datareg3, 3);
        newruns = (1:zp)+ m1*run;
        affineRegistrationPerPlane(mouse, date,...
            run, newruns, channel, datareg3, EdgesWarp, n, nbchunck, ...
            'server', p.server, 'pathbeginwrite', savingpath);
        clear datareg3;
    end
end

tEndRD = toc(tStartRD);
fprintf('RegistrationDura in %d minute(s) and %f seconds\n.', ...
    floor((tEndRD)/60),rem((tEndRD),60));

end
