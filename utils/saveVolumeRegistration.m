function [] = saveVolumeRegistration(savingpath, volume, namefile,...
    mouse, date, run, channel, varargin)

%   SAVEVOLUMEREGISTRATION: save each plane of the 4D volume as
%       fake runs with a sbx file per plane
%
%   Inputs:
%     savingpath -- str, path to folder where to save the data 
%     volume -- input volume to save, 4D matrix of double, dim = x,y,z,t
%     namefile -- str, 
%     mouse -- str, mouse name
%     date -- str, imaging session date
%     run -- int, run number
%     channel -- 0 for green or 1 for red, channel number
%   Outputs:
%     none

p = inputParser;
    addOptional(p, 'server', 'megatron'); % default server
    addOptional(p, 'type', 'both'); % type = 'both', 'tif' or sbx'
    addOptional(p, 'nbchuncktiff', 1); % default number of chuncks 
    % for the file file
    if length(varargin) == 1 && iscell(varargin{1})
        varargin = varargin{1};
    end
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
writeTiffHanae(savingpathv, uint16(volume), ...
    strcat(mouse,'_', date,'_', num2str(run),'_', num2str(channel),...
    '_', namefile), sizechunck);
end
if strcmp(p.type,'sbx') && ~exist(savingpathv, 'dir')
    mkdir(savingpathv);
end
if strcmp(p.type,'sbx') || strcmp(p.type,'both')
    sbxpath = sbxPath(mouse, date, run, 'sbx', 'server', p.server);
    info2 = sbxInfo(sbxpath);
    info2.recordsPerBuffer = w;
    info2.scanmode = 1;
    info2.nchan = 1;
    sbxWrite(strcat(savingpathv, mouse,'_', date,'_', ...
        num2str(run),'_', num2str(channel),'_', namefile),...
        reshape(volume, [w,h,zp*ts]), info2);
end

tEndsVR = toc(tStartsVR);
fprintf('saveVolumeRegistration in %d minutes and %f seconds\n.', ...
    floor((tEndsVR)/60),rem(tEndsVR,60));

end