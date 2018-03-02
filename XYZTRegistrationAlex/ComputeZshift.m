function[RowShifts,ColumnShifts,ZShifts] = ComputeZshift(...
    ReferenceVolumes, Volume, WidthCorr)
    tic
    Size = size(Volume);
    chunck = floor(Size(4)/size(ReferenceVolumes, 4));
    
    for t=1:Size(4)
        reft = ReferenceVolumes(:,:,:,ceil(t/chunck));
        Correlations = ones(Size(3)-2*WidthCorr,2*WidthCorr+1)*NaN;
        for j = WidthCorr+1:Size(3)-WidthCorr % considered plane
            for i = j-WidthCorr:j+WidthCorr % ref plane
                output = dftregistrationAlex(...
                    fft2(reft(:,:,i)),...
                    fft2(Volume(:,:,j,t)),10);
                row_shift = output(1); column_shift = output(2);
                Correlations(j-WidthCorr,i-j+WidthCorr+1) = corr2(...
                    reft(:,:,i),imtranslate(Volume(:,:,j,t),...
                    [column_shift row_shift]));
            end
        end
        Mean = nanmean(Correlations);
        [~,J] = max(Mean);
            disp(strcat('Zshift volume n°', num2str(t), ':  ',...
                num2str(J-WidthCorr-1)));
        
        x = J-4:0.01:J+4;
        FitOrder = 5;
        P = polyfit(J-4:J+4, Mean(J-4:J+4),FitOrder);
        CorrelationFit = polyval(P, x);
        [~,I] = max(CorrelationFit);
        output = dftregistrationAlex(fft2(mean(reft,3)),...
            fft2(mean(Volume(:,:,:,t),3)),100);
        row_shift = output(1); column_shift = output(2);

        RowShifts(:,t) = ones(Size(3),1)*row_shift;
        ColumnShifts(:,t) = ones(Size(3),1)*column_shift;
        ZShifts(t) = -((I-1)*0.01+J-4-WidthCorr-1);
    end
    tEnd = toc;
    fprintf('Elapsed time is %d minutes and %f seconds\n', ...
        floor(tEnd/60),rem(tEnd,60));
end