function[correctedVolume] = ApplyXYShifts(correctedVolume,...
    RowShifts, ColumnShifts)
    tic;
    S3 = size(correctedVolume, 3);
    S4 = size(correctedVolume, 4);

    parfor t = 1:S4
        for i = 1:S3
            correctedVolume(:,:,i,t) = ...
                imtranslate((correctedVolume(:,:,i,t)),...
                [ColumnShifts(i,t) RowShifts(i,t)]);
        end
    end
    tEnd = toc;
    fprintf('Elapsed time is %d minutes and %f seconds\n.', ...
        floor(tEnd/60),rem(tEnd,60));
end