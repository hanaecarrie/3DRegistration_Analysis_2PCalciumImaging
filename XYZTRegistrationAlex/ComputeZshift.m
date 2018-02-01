function[RowShifts,ColumnShifts,ZShifts] = ComputeZshift(...
    tvector, ReferenceVolume, OrderedVolumes, Size)

    for t=tvector
        Correlations = ones(Size(3),2*Size(3)-1)*NaN;
        for j = 1:Size(3) % considered plane
            for i = 1:Size(3) % ref plane
                output = dftregistrationAlex(...
                    fft2(ReferenceVolume(:,:,i)),...
                    fft2(OrderedVolumes(:,:,j,t)),10);
                row_shift = output(1);
                column_shift = output(2);
                Correlations(j,i+ceil(Size(3))-j) = corr2(...
                    ReferenceVolume(:,:,i), ...
                    imtranslate(OrderedVolumes(:,:,j,t),...
                    [column_shift row_shift]));
            end
        end
        Mean = nanmean(Correlations);
        [~,J] = max(Mean);
        if J-Size(3)~= 0
            disp(strcat('Zshift volume n°', num2str(t), ':  ',...
                num2str(J-Size(3))));
        end
        
        x = J-5:0.01:J+5;
        FitOrder = 5;
        P = polyfit(J-5:J+5, Mean(J-5:J+5),FitOrder);
        CorrelationFit = polyval(P, x);
        [~,I] = max(CorrelationFit);
        %figure; plot(x-Size(3), CorrelationFit); hold on;
        output = dftregistrationAlex(fft2(mean(ReferenceVolume,3)),...
            fft2(mean(OrderedVolumes(:,:,:,t),3)),100);
        row_shift = output(1);
        column_shift = output(2);

        RowShifts(:,t) = ones(Size(3),1)*row_shift;
        ColumnShifts(:,t) = ones(Size(3),1)*column_shift;
        ZShifts(t) = (I-1)*0.01+J-5-Size(3);
    end
end