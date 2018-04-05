function [Edges, FrameEdges] = detectEmptyEdges(volume) 
% Detect empty edge 

[w,h,z,t] = size(volume);
Edges = zeros(z, 4); 
FrameEdges = zeros(z,4);

for plane = 1:z

    planei = squeeze(volume(:,:,plane,:));

for frame = 1:t
    rowTop = 1; rowBottom = w;
    while sum(abs(planei(rowTop,:, frame))) == 0 && rowTop <w
        Edges(plane,1) = max(Edges(plane,1), rowTop);
        if rowTop == Edges(plane,1)
            FrameEdges(plane,1) = frame;
        end
        rowTop = rowTop + 1;
    end
    while sum(abs(planei(rowBottom, :, frame))) == 0 && rowBottom >1
        Edges(plane,2) = max(Edges(plane,2), w-rowBottom+1);
        if w-rowBottom+1 == Edges(plane,2)
            FrameEdges(plane,2) = frame;
        end
        rowBottom = rowBottom - 1;
    end
    columnLeft = 1; columnRight = h;
    while sum(abs(planei(:,columnLeft, frame))) == 0 && columnLeft <h
        Edges(plane,3) = max(Edges(plane,3), columnLeft);
        if columnLeft == Edges(plane,3)
            FrameEdges(plane,3) = frame;
        end
        columnLeft = columnLeft + 1;
    end
    while sum(abs(planei(:,columnRight, frame))) == 0 && columnRight >1
        Edges(plane,4) = max(Edges(plane,4), h-columnRight+1);
        if h-columnRight+1 == Edges(plane,4)
            FrameEdges(plane,4) = frame;
        end
        columnRight = columnRight - 1;
    end
end
end
end