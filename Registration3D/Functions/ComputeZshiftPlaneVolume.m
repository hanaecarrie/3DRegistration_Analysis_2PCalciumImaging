function [closestplane, corrvector] = SpatialCorrPlaneVolume(...
    refvol, plane, edges)
% ComputeZshiftPlaneVolume
% get the closest plane in the ref volume by computing spatial correlation
% between the ref planes and the considered plane
% Inputs:
%   refvol - the reference volume, 3D matrix of double, dim = x,y,z
%   plane - the test plane, 2D matrix of double, dim = x,y
%   edges - [top, bottom, left, right], number of pixels to revove on each
%       side
% Outputs:
%   closestplane - integer, the index of the closest plane to the input
%       plane
%   corrvector - array of double, dim = 1,z, values of spatial
%       correlation between plane and refvol plane

    tStartCZPV = tic;
    
    %Parameters
    nbplanes = size(refvol,3);
    
    % Remove edges
    plane = plane(edges(1):end-edges(2),edges(3):end-edges(4));
    refvol = refvol(edges(1):end-edges(2),...
        edges(3):end-edges(4),:);
    
    % DFT registration of every plane of the reference to the considered
    % plane
    correctedVolume = refvol;
    for p = 1:nbplanes
        output = dftregistrationAlex(fft2(...
            imgaussfilt(refvol(:,:,p),1)),...
            fft2(imgaussfilt(plane, 1)),100);
        correctedVolume(:,:,p) = imtranslate((correctedVolume(:,:,p)),...
            output);
    end

    % compute spatial correlation for each plane of the ref
    corrvector = zeros(1,nbplanes);
    for i = 1:nbplanes
        corrvector(1,i) = corr2(correctedVolume(:,:,i),plane);
    end    
    [~,J] = max(corrvector); % get index max correlation
    if  (J-5 > 0) & (J+5 <= size(corrvector))
        idx = 5;
    else
        idx = (min([length(corrvector)-J, J-1]));
    end
    % Perform interpolation
    x = J-idx:0.01:J+idx;
    FitOrder = idx;
    P = polyfit(J-idx:J+idx, Corrj(J-idx:J+idx),FitOrder);
    CorrelationFit = polyval(P, x);
    [~,I] = max(CorrelationFit); % max of the interpolating curve
    disp(I);
    closestplane = J; % get the closestplane

    tEndCZPV = toc(tStartCZPV);
    fprintf('ComputeZshiftPlaneVolume in %d minutes and %f seconds\n.', ...
        floor(tEndCZPV/60),rem(tEndCZPV,60));
end
