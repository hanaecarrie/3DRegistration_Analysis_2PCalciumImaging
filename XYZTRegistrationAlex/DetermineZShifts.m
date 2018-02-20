function[ZShifts] = DetermineZShifts(ReferenceVolume, full_vol)
    
    Size = size(full_vol);
    ZShifts = zeros(Size(3), Size(4));
    for t=1:Size(4)
        disp(t)
        %idx = ceil(t/length(ReferenceVolume));
        idx = 1;
        refvol = ReferenceVolume(:,:,:,idx);
        Correlations = ones(Size(3))*NaN;
        for j = 1:Size(3) % considered plane
            for i = 1:Size(3) % ref plane
                Correlations(j,i) = corr2(...
                    refvol(:,:,i), full_vol(:,:,j,t));
            end
        end
        %Mean = nanmean(Correlations);
        [~, IdxMax] = max(Correlations, [], 2);
        ZShifts(:,t) = IdxMax-Size(3);
    end
    
end