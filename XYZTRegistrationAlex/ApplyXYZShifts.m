function[correctedVolume] = ApplyXYZShifts(fullVolume,ZShifts,RowShifts,ColumnShifts) 
    correctedVolume=(fullVolume);

    for(t=1:size(fullVolume,4))
        Higher=ceil(ZShifts(t));
        Lower=floor(ZShifts(t));
        HigherCoeff=1-(Higher-ZShifts(t));
        if(Higher==Lower)
            LowerCoeff=0;
        else
            LowerCoeff=1-(ZShifts(t)-Lower);
        end
        for(i=1:size(fullVolume,3))
            fullVolume(:,:,i,t)=imtranslate((fullVolume(:,:,i,t)),[ColumnShifts(i,t) RowShifts(i,t)]);
        end
        
        
        for(i=1:size(fullVolume,3))
           if(i+Lower<=0 || i+Higher>size(fullVolume,3))
               correctedVolume(:,:,i,t)=0*fullVolume(:,:,i,t);
           else
               correctedVolume(:,:,i,t)=LowerCoeff*fullVolume(:,:,i+Lower,t)+HigherCoeff*fullVolume(:,:,i+Higher,t);
           end
        end
    end
end
