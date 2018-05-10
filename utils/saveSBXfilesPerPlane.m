function [] = saveSBXfilesPerPlane(sbxpath, mouse, date, run, volumereg3, extension, ...
    pathbegin)
% savesbxfiles

% sbxpath = sbxPath(mouse, date, run, 'sbx');
info = sbxInfo(sbxpath);
info.otparam(3) = 1;
info.sz(1) = size(volumereg3, 1);
info.sz(2) = size(volumereg3, 2);
zp = length(info.otwave);
ts = (info.max_idx+1)/(length(info.otwave));
info.max_idx = ts-1;
info.nsamples = ts;
otwave = info.otwave;
if nargin < 6
path_begin = strcat( 'D:\twophoton_data\2photon\scan\', mouse, ...
    '\', date, '_', mouse, '\', date, '_', mouse, '_run');
else
    path_begin = strcat(pathbegin, 'affineplanes\', date, '_', mouse, '_run');
    
end

for plane = 1:zp
    info.otwave = otwave(plane);
    nbrun = run*extension + (plane);
    newfolder = strcat(path_begin, num2str(nbrun));
    mkdir(newfolder);
    savepathp = strcat(newfolder, '\', mouse, '_', date,...
    '_', num2str(nbrun-1), '.sbx');
    seq = volumereg3(:,:,plane, :);
    seq = squeeze(seq);
    sbxWrite(savepathp, seq, info);
end

end