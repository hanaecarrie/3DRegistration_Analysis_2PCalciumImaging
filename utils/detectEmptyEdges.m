function [Edges] = detectEmptyEdges(data) 

%   DETECTEMPTYEDGES: detect empty edges in the last frame of a 4D volume
%   for each plane and taking the maximum pixels to crop
%   (useful for optotune, to be used as input to crop the volume to get
%   the maximum stable FOV across planes)
%
%   Inputs:
%     data - the input volume, 4D matrix of double, dim = x,y,z,t
%   Outputs:
%     Edges - array of int, [xleft, xright, ytop, ybottom]
%       NB: already taking into account the problem with sbx files
%           (x and y switched)


[w,h,z,t] = size(data);
Edges = zeros(t, 4);
data = squeeze(data(:,:,z,:));

for frame = 1:t
    slice = data(:,:,frame);
    while sum(abs(slice(Edges(t,3)+1,:))) == 0 && Edges(t,3) < w
        Edges(t,3) = Edges(t,3)+1;
    end
     while sum(abs(slice(w-Edges(t,4),:))) == 0 && Edges(t,4) < w
        Edges(t,4) = Edges(t,4)+1;
     end
    while sum(abs(slice(:,Edges(t,1)+1))) == 0 && Edges(t,1) < h
        Edges(t,1) = Edges(t,1)+1;
    end
     while sum(abs(slice(:,h-Edges(t,2)))) == 0 && Edges(t,4) < h
        Edges(t,2) = Edges(t,2)+1;
     end

end

if t > 1
    Edges = max(Edges);
end

end