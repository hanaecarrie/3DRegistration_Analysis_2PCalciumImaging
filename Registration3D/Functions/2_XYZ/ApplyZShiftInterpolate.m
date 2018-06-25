function[correctedVolume] = ApplyZShiftInterpolate(Volume,...
    ZShifts, ColumnShifts, RowShifts)

    tic;
    correctedVolume = zeros(size((Volume)));
    WidthCorr = floor((size(Volume, 3) - size(ZShifts, 1)));
    
    for t = 1:size(Volume,4)
        disp(t)
        fri = 1:size(Volume,3) ;   % plane serie to be inteprolated 
        MiniVol = double(Volume(:,:,:,t));
        for plane = 1:size(Volume,3)
            if plane > WidthCorr && plane <= size(Volume,3)-WidthCorr
                correctedVolume(:,:,plane,t)=...
                    imtranslate((correctedVolume(:,:,plane,t)),...
                    [ColumnShifts(plane,t) RowShifts(plane,t)]); 
                fri(plane) = plane + ZShifts(plane,t);
            else
                correctedVolume(:,:,plane,t) = double(Volume(:,:,plane,t));
            end
        end 
         % interpolation 
         ZSerieNonReg = timeseries(MiniVol, fri); % zseries non reg volume
         ZSerieReg = resample(ZSerieNonReg, 1:size(Volume, 3));
         % resample volume with linear interpolation on every integer plane
         correctedVolume(:,:,:,t) = ZSerieReg.Data;    
    end
    tEnd = toc;
    fprintf('Elapsed time is %d minutes and %f seconds\n.', ...
        floor(tEnd/60),rem(tEnd,60));  
end




