function[RowShifts,ColumnShifts,OrderedVolumes] = OrderVolumes(...
    tvector,Size,BlurFactor,red_vol)
    tic;
    S3 = Size(3); S4 = Size(4);
    stackFixed = zeros(size(red_vol));
    RowShifts = zeros(S3, S4);
    ColumnShifts = zeros(S3, S4);
    OrderedVolumes = zeros(Size);
    
    for t=tvector
        stackFixed(:,:,ceil(S3/2)) = imgaussfilt(...
            red_vol(:,:,ceil(S3/2),t),BlurFactor);

        for i=1:S3  
            if i < ceil(S3/2)
                inda = min(ceil(S3/2), ceil(S3/2)-i+5);
                indb = ceil(S3/2)-i;
            else
                inda = max(ceil(S3/2), ceil(S3/2)+i-5);
                indb = ceil(S3/2)+i;
            end
            output = dftregistrationAlex(...
                fft2(imgaussfilt(stackFixed(:,:,inda,BlurFactor)),...
                fft2(imgaussfilt(red_vol(:,:,indb,t),...
                BlurFactor)),10);
            row_shift = output(1);
            column_shift = output(2);
            stackFixed(:,:,indb) = imtranslate(...
                red_vol(:,:,indb,t),[column_shift row_shift]);
            RowShifts(indb,t) = row_shift;
            ColumnShifts(indb,t) = column_shift;
        end
        
        OrderedVolumes(:,:,:,t) = stackFixed;
    end
    tEnd = toc;
    fprintf('Elapsed time is %d minutes and %f seconds\n.', ...
        floor(tEnd/60),rem(tEnd,60));
end