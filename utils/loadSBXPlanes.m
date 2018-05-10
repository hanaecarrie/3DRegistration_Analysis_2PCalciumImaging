function [volume] = loadSBXPlanes(mouse, date, planeruns, type, pathbegin)

volume = [];
if nargin < 5
    pathbegin = 'D:\twophoton_data\2photon\scan\';
end

for i = planeruns
    pathplane = strcat(...
        pathbegin, mouse, '\', date, ...
        '_', mouse, '\', date, '_', mouse, '_run',...
        num2str(i), '\', mouse, '_', date, '_',...
        num2str(i-1), '_', type);
    plane = sbxReadPMT(pathplane);
    volume = cat(4, volume, plane);
end
volume = permute(volume, [1,2,4,3]);

end