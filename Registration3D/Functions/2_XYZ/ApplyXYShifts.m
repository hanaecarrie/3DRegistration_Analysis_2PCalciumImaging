function[correctedVolume] = ApplyXYShifts(correctedVolume,...
    RowShifts, ColumnShifts)
    
%   APPLYXYSHITS: apply XY shifts per plane with a parfor loop

%   Inputs:
%     correctedVolume -- 4D matrix of uint16 or other, dim (x,y,z,t)
%     RowShifts -- 2D matrix of doubles, dim 
%     ColumnShifts -- 2D matrix of doubles, dim 
%   Outputs:
%     correctedVolume -- 4D matrix of uint16 or other, dim (x,y,z,t)

    tStartAXYS = tic;
    nbplanes = size(correctedVolume, 3); % get number of frames before the
    % parfor loop

    parfor t = 1:size(correctedVolume, 4)
        for i = 1:nbplanes
            correctedVolume(:,:,i,t) = ...
                imtranslate((correctedVolume(:,:,i,t)),...
                [ColumnShifts(i,t) RowShifts(i,t)]); % careful order!
        end
    end
    tEndAXYS = toc(tStartAXYS);
    fprintf('ApplyXYShifts in %d minutes and %f seconds\n.', ...
        floor(tEndAXYS/60),rem(tEndAXYS,60));
end