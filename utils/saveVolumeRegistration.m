function [] = saveVolumeRegistration(savingpath, volume, namefile,...
    mouse, date, run, nbchuncktiff)

 tic;
 
[w, h, zp, ts] = size(volume);

if nargin < 7
    nbchuncktiff = 1;
end
sizechunck = zp*ts/nbchuncktiff;
if mod(zp*ts, nbchuncktiff) ~= 0
    error("nbchuncktiff should divide the number of frames");
end

savingpathv = strcat(savingpath, '\', namefile, '\');
WriteTiff(savingpathv, mat2gray(double(volume)), strcat(mouse,'_', date,'_', ...
    num2str(run),'_', namefile), sizechunck);
sbxpath = sbxPath(mouse, date, run, 'sbx');
info = sbxInfo(sbxpath);
sbxWrite(strcat(savingpathv, mouse,'_', date,'_', ...
    num2str(run),'_', namefile) ,reshape(volume, [w,h,zp*ts]), info);

tEnd = toc;
fprintf('Elapsed time is %d minutes and %f seconds\n.', ...
    floor((tEnd)/60),rem(tEnd,60));

end