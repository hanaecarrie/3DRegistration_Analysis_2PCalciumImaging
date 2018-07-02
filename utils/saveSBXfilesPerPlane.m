function [] = saveSBXfilesPerPlane(mouse, date, run, channel,...
    volumereg3, extension, pathsbx, varargin)

%   SAVESBXFILESPERPLANE: save each plane of the 4D volume as
%       fake runs with a sbx file per plane
%
%   Inputs:
%     mouse -- str, mouse name
%     date -- str, imaging session date
%     run -- int, run number
%     channel -- 0 for green or 1 for red, channel number
%     volumereg3 -- the input volume to be splitted into individual 
%       planes, 4D matrix of double, dim = x,y,z,t
%     extension -- int, extension to add when saving the sbx files 
%       per plane, new run = (oldrun*m1) + planenumber
%     pathsbx -- sbx path to pull the info file from
%   Outputs:
%     none

p = inputParser;
    addOptional(p, 'pathbegin', '');
    addOptional(p, 'savingstructure', 'onscanbox');
    % can be 'onstorage' or 'onscanbox'
    addOptional(p, 'server', 'megatron');
    if length(varargin) == 1 && iscell(varargin{1})
        varargin = varargin{1};
    end
parse(p, varargin{:});
p = p.Results;

sizedata = size(volumereg3);

% info file to extract from initial file and to modify
info = sbxInfo(pathsbx);
info.scanmode = 1;
info.otparam(3) = 1;
info.nchan = 1;
info.sz(1) = sizedata(1);
info.sz(2) = sizedata(2);
zp = sizedata(3);
ts = sizedata(4);
info.max_idx = ts-1;
info.nsamples = ts;

% set paths and otwave
otwave = info.otwave;
if p.savingstructure == 'onscanbox'
    path_begin = strcat(sbxScanbase(p.server), mouse, ...
    '\', date, '_', mouse, '\', date, '_', mouse, '_run');
elseif p.savingstructure == 'onstorage'
    path_begin = strcat(p.pathbegin,'\', mouse, '_', date, '_',...
        num2str(run), '_', num2str(channel), '\affineplanes\', ...
        date, '_', mouse, '_run');
end

% write and save planes individually
for plane = 1:zp
    try
            info.otwave = otwave(plane);
    catch
            info.otwave = 1; % create a fake otwave if otwave is empty
            % in the original file
    end

    nbrun = run*extension + (plane);
    newfolder = strcat(path_begin, num2str(nbrun), '\');
    if ~exist(newfolder, 'dir') % create folder if doesn't exist
        mkdir(newfolder);
    end

    savepathp = strcat(newfolder, '\', mouse, '_', date,...
    '_', num2str(nbrun-1),'.sbx'); % save path

    if ~exist(savepathp, 'file') % write sbx file if doesn't exist
        seq = volumereg3(:,:,plane, :);
        seq = squeeze(seq);
        sbxWrite(savepathp, seq, info);
    end
end

end