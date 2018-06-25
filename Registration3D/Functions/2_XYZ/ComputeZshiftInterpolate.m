function[RowShifts,ColumnShifts,ZShifts] = ComputeZshiftInterpolate(...
    ReferenceVolumes, Volume, WidthCorr, Edges)

    tic;

    % Parameters
    Size = size(Volume);
    nbChunck = size(ReferenceVolumes, 4); % nb chuncks of the reference
    Chunck = floor(Size(4)/nbChunck); % nb frames by chunck of ref
    
    % Remove edges
    Volume(1:Edges(1),:,:,:) = NaN;
    Volume(Size(1)-Edges(2)+1:end,:,:,:) = NaN;
    Volume(:,1:Edges(3),:,:) = NaN;
    Volume(:,Size(2)-Edges(4)+1:end,:,:) = NaN;
    %Downsample
    Volume = Volume(1:2:end,1:2:end,:,:);
    ReferenceVolumes = ReferenceVolumes(1:2:end,1:2:end,:,:);

    % Preallocating space for output variables
    RowShifts = zeros(Size(3)-WidthCorr,Size(4));
    ColumnShifts = zeros(Size(3)-WidthCorr,Size(4));
    ZShifts = zeros(Size(3)-WidthCorr,Size(4));

    for t=1:Size(4) % for each time frame
        disp(strcat(' Volume n°', num2str(t)));
        % pick corresponding reference
        reft = ReferenceVolumes(:,:,:,ceil(t/Chunck));
        % preallocate output vectors
        row_shift = zeros((Size(3)-WidthCorr),1);
        column_shift = zeros((Size(3)-WidthCorr),1);
        z_shift = zeros((Size(3)-WidthCorr),1);
       
        for j = WidthCorr+1:Size(3)-WidthCorr % j = considered plane
            Corrj = ones(1,2*WidthCorr+1)*NaN;
            
            for i = j-WidthCorr:j+WidthCorr % i = reference plane
%                 output = dftregistrationAlex(...
%                     fft2(reft(:,:,i)),...
%                     fft2(Volume(:,:,j,t)),10);
%                 row_shift(j-WidthCorr,1) = output(1);
%                 column_shift(j-WidthCorr,1) = output(2);
                Corrj(1,i-j+WidthCorr+1) = corr2(...
                    reft(:,:,i),Volume(:,:,j,t));
%                 Corrj(1,i-j+WidthCorr+1) = corr2(...
%                     reft(:,:,i),imtranslate(Volume(:,:,j,t),...
%                     [output(2) output(1)])); % column_shift, row_shift
            end
            [~,J] = max(Corrj);
             % Print shift to the closest plane
%             disp(strcat('Zshift volume n°', num2str(t), ' plane n°', ...
%                 num2str(j), ':  ', num2str(J-WidthCorr-1)));
            % Set interpolation vectors and degree regarding matrix size
            if  (J-5 > 0) & (J+5 <= size(Corrj))
                idx = 5;
            else
                idx = (min([length(Corrj)-J, J-1]));
            end
            % Perform interpolation
            x = J-idx:0.01:J+idx;
            FitOrder = idx;
            P = polyfit(J-idx:J+idx, Corrj(J-idx:J+idx),FitOrder);
            CorrelationFit = polyval(P, x);
            [~,I] = max(CorrelationFit); % max of the interpolating curve
% 
%             %disp(J-WidthCorr-1);           
%             x = 1:0.01:2*WidthCorr+1;
%             P = lagrange(x,1:2*WidthCorr+1,Corrj);
%             [~,I] = max(P); % max of the interpolating curve
            % gives us the
            output = dftregistrationAlex(fft2(reft(:,:,j)),...
            fft2(Volume(:,:,j,t)),100);
            row_shift(j,1) = output(1);
            column_shift(j,1) = output(2);
            z_shift(j,1) = x(I)-WidthCorr-1;
        end
        RowShifts(:,t) = row_shift;
        ColumnShifts(:,t) = column_shift;
        psteps = ones(length(z_shift),1).*(1:length(z_shift))';
        zaux = -z_shift + psteps;
        count = 0;
        while ~issorted(zaux) & count < 10 % ensuring strict monotony
            count = count + 1;
            disp('yes');
            for plane = 2:size(z_shift)
                if zaux(plane) - zaux(plane-1) <= 0
                    if ismember(count, [1,2,5,6,9,10]);%[1,2,5,6,9,10]); %mod(count, 2) ==1;
                        zaux(plane-1) = NaN;
                    else
                        zaux(plane) = NaN;
                    end
                end
            end
        zaux = naninterp(zaux);
        end
        z_shift = zaux - psteps;
        ZShifts(:,t) = -z_shift;
%         for t2 = 1:Size(4)
%             zaux2 = -ZShifts(:,t2)' + psteps;
%             if ~issorted(zaux2) % ensuring strict monotony
%             disp('yes');
%             end
%         end
    end
%     psteps = ones(size(ZShifts,1),1).*(1:size(ZShifts,1))';
%     for t =1:Size(4)
%         Zaux = -ZShifts(:,t) + psteps;
%         if ~issorted(Zaux) % ensuring strict monotony
%             for planeZ = 2:size(ZShifts,1)
%                 if Zaux(planeZ) - Zaux(planeZ-1) <= 0
%                     Zaux(planeZ) = NaN;
%                 end
%             end
%         end
%     end   
    tEnd = toc;
    fprintf('Elapsed time is %d minutes and %f seconds\n.', ...
        floor(tEnd/60),rem(tEnd,60));
end
