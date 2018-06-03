function [] = saveSBXfilesPerPlane(mouse, date, run, channel,...
    volumereg3, extension, pathsbx, varargin)
% savesbxfiles

p = inputParser;
    addOptional(p, 'pathbegin', '');
    addOptional(p, 'savingstructure', 'onscanbox'); % can be 'onstorage' or 'onscanbox'
    addOptional(p, 'server', 'megatron');
    if length(varargin) == 1 && iscell(varargin{1})
        varargin = varargin{1};
    end
parse(p, varargin{:});
p = p.Results;

sizedata = size(volumereg3);

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
otwave = info.otwave;
if p.savingstructure == 'onscanbox'
    path_begin = strcat(sbxScanbase(p.server), mouse, ...
    '\', date, '_', mouse, '\', date, '_', mouse, '_run');
elseif p.savingstructure == 'onstorage'
    path_begin = strcat(p.pathbegin,'\', mouse, '_', date, '_',...
        num2str(run), '_', num2str(channel), '\affineplanes\', ...
        date, '_', mouse, '_run');
end

for plane = 1:zp
    try
            info.otwave = otwave(plane);
    catch
            info.otwave = 1;
    end
    nbrun = run*extension + (plane);
    newfolder = strcat(path_begin, num2str(nbrun), '\');
    if ~exist(newfolder, 'dir')
        mkdir(newfolder);
    end
    savepathp = strcat(newfolder, '\', mouse, '_', date,...
    '_', num2str(nbrun-1),'.sbx');
    if ~exist(savepathp, 'file')
        seq = volumereg3(:,:,plane, :);
        seq = squeeze(seq);
        sbxWrite(savepathp, seq, info);
    end
end

end