function[RowShifts,ColumnShifts,ZShifts] = ComputeZshift(tvector,ReferenceVolume,OrderedVolumes,Size,StartCorrelation,EndCorrelation,StartPlane,nPlanesPerReferenceVolume)
    for(t=tvector)
        Correlations=ones(EndCorrelation-StartCorrelation+1,EndCorrelation-StartCorrelation+nPlanesPerReferenceVolume)*NaN;
        for(i=StartCorrelation:EndCorrelation)
            for(j=1:nPlanesPerReferenceVolume)
                output = dftregistrationAlex(fft2(ReferenceVolume(:,:,i)),fft2(OrderedVolumes(:,:,j,t)),10);
                row_shift=output(1);
                column_shift=output(2);
                Correlations(i-(StartCorrelation-1),EndCorrelation+j-i)=corr2(ReferenceVolume(:,:,i),imtranslate(OrderedVolumes(:,:,j,t),[column_shift row_shift]));
            end
        end
        Mean=nanmean(Correlations);
        [~,J]=max(Mean);
  
        x=StartPlane+J-5-1:0.01:StartPlane+J+5-1;
        warning('off','MATLAB:polyfit:RepeatedPointsOrRescale');
        if J-5 < 1
            c = J-1;
        elseif  J+5 > size(Mean,2)
            c = size(Mean,2)-J;
        else
            c = 0;
        end
        FitOrder=c;
        P=polyfit((StartPlane+J-c-1:StartPlane+J+c-1),Mean(J-c:J+c),FitOrder);
        
        CorrelationFit=0;
        for(n=0:FitOrder)
            CorrelationFit=P((FitOrder+1)-n)*(x.^n)'+CorrelationFit;  
        end
        [~,I]=max(CorrelationFit);

        output = dftregistrationAlex(fft2(mean(ReferenceVolume,3)),fft2(mean(OrderedVolumes(:,:,:,t),3)),100);
        row_shift=output(1);
        column_shift=output(2);

        RowShifts(:,t)=ones(Size(3),1)*row_shift;
        ColumnShifts(:,t)=ones(Size(3),1)*column_shift;
        ZShifts(t)=(I-1)*0.01+StartPlane+J-5-1;
    end
end