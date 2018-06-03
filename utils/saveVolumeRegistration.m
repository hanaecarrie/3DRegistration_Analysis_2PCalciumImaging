function [] = saveVolumeRegistration(savingpath, volume, namefile,...
    mouse, date, run, channel, varargin)

p = inputParser;
    addOptional(p, 'server', 'megatron');
    addOptional(p, 'type', 'both');
    addOptional(p, 'nbchuncktiff', 1);
    if length(varargin) == 1 && iscell(varargin{1}), varargin = varargin{1}; end
    parse(p, varargin{:});
    p = p.Results;

 tStartsVR = tic;
 
[w, h, zp, ts] = size(volume);

sizechunck = zp*ts/p.nbchuncktiff;
if mod(zp*ts, p.nbchuncktiff) ~= 0
    error('nbchuncktiff should divide the number of frames');
end

savingpathv = strcat(savingpath, '\', namefile, '\');

if strcmp(p.type,'tif') || strcmp(p.type,'both') 
WriteTiffHanae(savingpathv, uint16(volume), ...
    strcat(mouse,'_', date,'_', num2str(run),'_', num2str(channel),...
    '_', namefile), sizechunck);
end
if strcmp(p.type,'sbx') && ~exist(savingpathv, 'dir')
    mkdir(savingpathv);
end
if strcmp(p.type,'sbx') || strcmp(p.type,'both')
    sbxpath = sbxPath(mouse, date, run, 'sbx', 'server', p.server);
    info = sbxInfo(sbxpath);
    info.recordsPerBuffer = w;
    info.nchan = 1;
    sbxWrite(strcat(savingpathv, mouse,'_', date,'_', ...
        num2str(run),'_', num2str(channel),'_', namefile),...
        reshape(volume, [w,h,zp*ts]), info);
end

tEndsVR = toc(tStartsVR);
fprintf('saveVolumeRegistration in %d minutes and %f seconds\n.', ...
    floor((tEndsVR)/60),rem(tEndsVR,60));

end