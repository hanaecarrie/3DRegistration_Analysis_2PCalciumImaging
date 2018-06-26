function [volume] = loadSBXPlanes(mouse, date, planeruns, varargin)

%   LOADSBXPLANES: load planes saved as individual runs in the scanbox of a
%   given server. The type (sbx, sbxreg, ...) can be precised

%   Inputs:
%     mouse -- str, mouse name
%     date -- str, imaging session date
%     planeruns -- list of int, numbers of fake runs which stand for
%          individual planes
%   Outputs:
%     volume - the output volume, 4D matrix of double, dim = x,y,z,t

 p = inputParser;
    addOptional(p, 'type', 'sbx'); % type of file (sbxreg, sbx, ...)
    addOptional(p, 'server', 'megatron');  % default server
    if length(varargin) == 1 && iscell(varargin{1})
        varargin = varargin{1};
    end
parse(p, varargin{:});
p = p.Results;

% load planes and concatenate them on the 4th dimension
volume = [];
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