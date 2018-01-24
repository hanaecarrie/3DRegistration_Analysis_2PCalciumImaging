function[correctedVolume] = ApplyXYShifts(correctedVolume,RowShifts,ColumnShifts) 
    for(t=1:size(correctedVolume,4))
        for(i=1:size(correctedVolume,3))
            correctedVolume(:,:,i,t)=imtranslate((correctedVolume(:,:,i,t)),[ColumnShifts(i,t) RowShifts(i,t)]);
        end
    end
end