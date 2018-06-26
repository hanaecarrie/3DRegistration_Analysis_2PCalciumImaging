function [closestplaneinterp, corrvector] = SpatialCorrPlaneVolumeMicroglia(...
    refvol, plane, edges, planeidx)
% ComputeZshiftPlaneVolume
% get the closest plane in the ref volume by computing spatial correlation
% between the ref planes and the considered plane
% Inputs:
%   refvol - the reference volume, 3D matrix of double, dim = x,y,z
%   plane - the test plane, 2D matrix of double, dim = x,y
%   edges - [top, bottom, left, right], number of pixels to revove on each
%       side
%   planeidx - the current plane position in the current run, integer
% Outputs:
%   closestplane - integer, the index of the closest plane to the input
%       plane
%   corrvector - array of double, dim = 1,z, values of spatial
%       correlation between plane and refvol plane

    tStartCZPV = tic;
    
    %Parameters
    nbplanes = size(refvol,3);
    
    % Remove edges
    plane = plane(edges(1)+1:end-edges(2),edges(3)+1:end-edges(4));
    refvol = refvol(edges(1)+1:end-edges(2),...
        edges(3)+1:end-edges(4),:);
    
    % DFT registration of every plane of the reference to the considered
    % plane
    correctedVolume = refvol;
    
    output = dftregistrationAlex(fft2(refvol(:,:,planeidx)),...
        fft2(plane),100);
    for p = 1:nbplanes
        correctedVolume(:,:,p) = imtranslate((correctedVolume(:,:,p)),...
           [-output(2),-output(1)]);
    end
    figure; imshow(imfuse(mat2gray(plane), mat2gray(...
        correctedVolume(:,:,planeidx))));

    % compute spatial correlation for each plane of the ref
    corrvector = zeros(1,nbplanes);
    for i = 1:nbplanes
        corrvector(1,i) = corr2(correctedVolume(:,:,i),plane);
    end
    idxlow = 20; idxhigh = 20;
    if planeidx-idxlow < 1
        idxlow = 1;
    end
    idxhigh = 20;
    if planeidx+idxhigh > nbplanes
        idxhigh = nbplanes-planeidx;
    end
    [~,J] = max(corrvector(planeidx-idxlow+1:planeidx+idxhigh));        
    % get index max correlation
    closestplane = J+planeidx-idxlow; % get the closestplane
    idx = 5;
    % Perform interpolation
    if closestplane < planeidx-3
        x = closestplane-3:0.01:planeidx;
    elseif closestplane >= planeidx-3 & closestplane <= planeidx+3
        x = closestplane-3:0.01:closestplane+3;
    else
        x = planeidx:0.01:closestplane+3;
    end    
    FitOrder = idx;
    P = polyfit(closestplane-idx:closestplane+idx,...
        corrvector(closestplane-idx:closestplane+idx),FitOrder);
    CorrelationFit = polyval(P, x);
    figure; plot(x, CorrelationFit);
    [~,I] = max(CorrelationFit); % max of the interpolating curve
    closestplaneinterp = round(x(I));
    if closestplaneinterp < 1; closestplaneinterp = 1;
    elseif closestplaneinterp > nbplanes; closestplaneinterp = nbplanes;end;
    disp(closestplaneinterp);


    tEndCZPV = toc(tStartCZPV);
    fprintf('ComputeZshiftPlaneVolume in %d minutes and %f seconds\n.', ...
        floor(tEndCZPV/60),rem(tEndCZPV,60));
end
