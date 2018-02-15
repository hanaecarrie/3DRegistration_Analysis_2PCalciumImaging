function[RowShifts,ColumnShifts] = DetermineXYShifts(full_vol,...
    BlurFactor,KeepingFactor,ReferenceVolumeIndex)

    Size = size(full_vol);
    Keep = KeepingFactor;
    red_vol = full_vol(ceil(Size(1)*(1-Keep)/2):...
        ceil(Size(1)*(1-(1-Keep)/2)),...
        ceil(Size(2)*(1-Keep)/2):...
        ceil(Size(2)*(1-(1-Keep)/2)),:,:);
    referenceTimePoint = ReferenceVolumeIndex;
    Tmax = Size(4);
    
    for(t = 1:Tmax)
        for(i = 1:Size(3))
            output = dftregistrationAlex(fft2(imgaussfilt(...
                red_vol(:,:,i,referenceTimePoint),BlurFactor)),...
                fft2(imgaussfilt(red_vol(:,:,i,t),BlurFactor)),100);
            RowShifts(i,t) = output(1);
            ColumnShifts(i,t) = output(2);
        end
    end
end