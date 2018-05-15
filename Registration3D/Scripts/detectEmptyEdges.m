function [Edges] = detectEmptyEdges(data) 
% Detect empty edge last frame

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
    Edges = max(Edges);

end