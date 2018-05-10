function [] = saveVolumeRegistration(savingpath, volume, namefile,...
    mouse, date, run, channel, nbchuncktiff, type)

 tic;
 
[w, h, zp, ts] = size(volume);

if nargin < 9
    type = 'both';
end
if nargin < 8
    nbchuncktiff = 1;
end
sizechunck = zp*ts/nbchuncktiff;
if mod(zp*ts, nbchuncktiff) ~= 0
    error("nbchuncktiff should divide the number of frames");
end

savingpathv = strcat(savingpath, '\', namefile, '\');

if strcmp(type,'tif') || strcmp(type,'both') 
WriteTiffHanae(savingpathv, mat2gray(double(volume)), ...
    strcat(mouse,'_', date,'_', num2str(run),'_', num2str(channel),...
    '_', namefile), sizechunck);
end
if strcmp(type,'sbx') || strcmp(type,'both')
    sbxpath = sbxPath(mouse, date, run, 'sbx');
    info = sbxInfo(sbxpath);
    sbxWrite(strcat(savingpathv, mouse,'_', date,'_', ...
        num2str(run),'_', num2str(channel),'_', namefile),...
        reshape(volume, [w,h,zp*ts]), info);
end

tEnd = toc;
fprintf('Elapsed time is %d minutes and %f seconds\n.', ...
    floor((tEnd)/60),rem(tEnd,60));

end