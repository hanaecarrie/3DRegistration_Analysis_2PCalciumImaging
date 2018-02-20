function[RowShifts,ColumnShifts] = DetermineXYShifts(full_vol,...
    BlurFactor,KeepingFactor, ChunckSizeRef)
    tStart = tic;
    Size = size(full_vol);
    Keep = KeepingFactor;
    red_vol = full_vol(ceil(Size(1)*(1-Keep)/2):...
        ceil(Size(1)*(1-(1-Keep)/2)),...
        ceil(Size(2)*(1-Keep)/2):...
        ceil(Size(2)*(1-(1-Keep)/2)),:,:);
    
    RowShifts = zeros(Size(3), Size(4));
    ColumnShifts = zeros(Size(3), Size(4));
    
    parfor t = 1:Size(4)
        for i = 1:Size(3)
            ChunckIdx = floor(t/ChunckSizeRef);
            if t < Size(4) - ChunckSizeRef
                ReferenceImage = mean(red_vol(:,:,i,...
                    1+ChunckIdx*ChunckSizeRef:(ChunckIdx + 1)*ChunckSizeRef), 4);
            else
                ReferenceImage = mean(red_vol(:,:,i,...
                    Size(4)-ChunckSizeRef +1 : Size(4)), 4);
            end
           
            output = dftregistrationAlex(fft2(imgaussfilt(...
            ReferenceImage, BlurFactor)),...
            fft2(imgaussfilt(red_vol(:,:,i,t),BlurFactor)),100);
            RowShifts(i,t) = output(1);
            ColumnShifts(i,t) = output(2);
        end
    end
    toc
end