function[RowShifts,ColumnShifts,ZShifts] = ComputeZshiftInterpolate(...
    ReferenceVolumes, Volume, WidthCorr)
    tic;
    Size = size(Volume);
    nbChunck = size(ReferenceVolumes, 4);
    Chunck = floor(Size(4)/nbChunck);

    RowShifts = zeros(Size(3)-WidthCorr,Size(4));
    ColumnShifts = zeros(Size(3)-WidthCorr,Size(4));
    ZShifts = zeros(Size(3)-WidthCorr,Size(4));

    for t=1:Size(4)
        reft = ReferenceVolumes(:,:,:,ceil(t/Chunck));
        row_shift = zeros((Size(3)-WidthCorr),1);
        column_shift = zeros((Size(3)-WidthCorr),1);
        z_shift = zeros((Size(3)-WidthCorr),1);
        for j = WidthCorr+1:Size(3)-WidthCorr % considered plane
            Corrj = ones(1,2*WidthCorr+1)*NaN;
            
            for i = j-WidthCorr:j+WidthCorr % ref plane
                output = dftregistrationAlex(...
                    fft2(reft(:,:,i)),...
                    fft2(Volume(:,:,j,t)),10);
                row_shift = output(1); column_shift = output(2);
                Corrj(1,i-j+WidthCorr+1) = corr2(...
                    reft(:,:,i),imtranslate(Volume(:,:,j,t),...
                    [column_shift row_shift]));
            end
            [~,J] = max(Corrj);
            disp(strcat('Zshift volume n°', num2str(t), ' plane n°', ...
                num2str(j), ':  ', num2str(J-WidthCorr-1)));
            if  (J-5 > 0) & (J+5 <= size(Corrj))
                idx = 5;
            else
                idx = (min([length(Corrj)-J, J-1]));
            end
            x = J-idx:0.01:J+idx;
            FitOrder = 5;
            P = polyfit(J-idx:J+idx, Corrj(J-idx:J+idx),FitOrder);
            CorrelationFit = polyval(P, x);
            [~,I] = max(CorrelationFit);
            output = dftregistrationAlex(fft2(reft(:,:,j)),...
            fft2(Volume(:,:,j,t)),100);
            row_shift(j,1) = output(1);
            column_shift(j,1) = output(2);
            z_shift(j,1) = (I-1)*0.01+J-idx-WidthCorr-1;
        end
        RowShifts(:,t) = row_shift;
        ColumnShifts(:,t) = column_shift;
        ZShifts(:,t) = z_shift;
    end
    tEnd = toc;
    fprintf('Elapsed time is %d minutes and %f seconds\n.', ...
        floor(tEnd/60),rem(tEnd,60));
end
