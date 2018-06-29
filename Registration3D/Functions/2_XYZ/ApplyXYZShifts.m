function[correctedVolume] = ApplyXYZShifts(fullVolume,...
    ZShifts, ColumnShifts, RowShifts)

%   APPLYXYZSHITS: apply XY shifts per plane with a parfor loop
%
%   Inputs:
%     fullVolume -- 4D matrix of uint16 or other, dim (x,y,z,t)
%     ZShifts -- 2D matrix of doubles, dim (z,t)
%     ColumnShifts -- 2D matrix of doubles, dim (z,t)
%     RowShifts -- 2D matrix of doubles, dim (z,t)
%   Outputs:
%     correctedVolume -- 4D matrix of uint16 or other, dim (x,y,z,t)

    tStartAXYZS = tic;
    correctedVolume = fullVolume;

    for t = 1:size(fullVolume,4)
        Higher = ceil(ZShifts(t));
        Lower = floor(ZShifts(t));
        HigherCoeff = 1-(Higher-ZShifts(t));
        if(Higher == Lower)
            LowerCoeff = 0;
        else
            LowerCoeff = 1-(ZShifts(t)-Lower);
        end
        for i = 1:size(fullVolume,3)
            fullVolume(:,:,i,t) = imtranslate((fullVolume(:,:,i,t)),...
                [ColumnShifts(i,t) RowShifts(i,t)]);
        end
        
        
        for i = 1:size(fullVolume,3)
           if(i+Lower<=0 || i+Higher>size(fullVolume,3))
               correctedVolume(:,:,i,t)=0*fullVolume(:,:,i,t);
           else
               correctedVolume(:,:,i,t) = ...
                   LowerCoeff*fullVolume(:,:,i+Lower,t)+...
                   HigherCoeff*fullVolume(:,:,i+Higher,t);
           end
        end
    end

    tEndAXYZS = toc(tStartAXYZS);
    fprintf('ApplyXYZShifts in %d minutes and %f seconds\n.', ...
        floor(tEndAXYZS/60),rem(tEndAXYZS,60));
end
