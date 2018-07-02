function[ZShifts,RowShifts,ColumnShifts] = DetermineXYZShifts(...
    full_vol, BlurFactor, KeepingFactor, ReferenceVolumeIndex, ...
    nPlanesPerReferenceVolume, nPlanesForCorrelation)

%   DETERMINEXYZSHITS: determine XYZ shifts per plane with a parfor loop
%   Credits: Alex Fratzl
%
%   Inputs:
%     full_vol -- 4D matrix of uint16 or other, dim (x,y,z,t)
%     BlurFactor -- width of the gaussian filter (ex: 1)
%     KeepingFactor -- 0 < KeepingFactor < 1, % of FOV taken into account,
%       removes edges to determine shifts (ex: 0.95)
%     ReferenceVolume -- 4D matrix of uint, moving volume reference, 
%       dim (x,y,z,t/n) with n = nb avg frames per reference volume
%     nPlanesPerReferenceVolume -- int, nb planes per ref volume 
%     nPlanesForCorrelation -- int, nb of planes to take into account for
%       spatial correlations
%   Outputs:
%     RowShifts -- 2D matrix of doubles, dim (z,t)
%     ColumnShifts -- 2D matrix of doubles, dim (z,t)
%     ZShifts -- 2D matrix of doubles, dim (z,t)


    tStartDXYZS = tic;

    Size = size(full_vol);
    Keep = KeepingFactor;
    red_vol = full_vol(...
        ceil(Size(1)*(1-Keep)/2):ceil(Size(1)*(1-(1-Keep)/2)),...
        ceil(Size(2)*(1-Keep)/2):ceil(Size(2)*(1-(1-Keep)/2)),:,:);
    referenceTimePoint = ReferenceVolumeIndex;
    StartCorrelation = ceil(nPlanesPerReferenceVolume/2) - ...
        floor(nPlanesForCorrelation/2);
    EndCorrelation = ceil(nPlanesPerReferenceVolume/2) + ...
        floor(nPlanesForCorrelation/2);
    StartPlane = floor(-(EndCorrelation - StartCorrelation + ...
        nPlanesPerReferenceVolume)/2+1);
    Tmax = Size(4);
    
    RowShifts = [];
    ColumnShifts = [];
    OrderedVolumes = [];
    tvector = 1:Tmax;
    
    % Rectifying volumes
    [value1, value2, value3] = ...
        OrderVolumes(tvector, Size, BlurFactor, red_vol);
    
    RowShifts = cat(2, RowShifts, value1);
    ColumnShifts = cat(2, ColumnShifts, value2);
    OrderedVolumes = cat(4, OrderedVolumes, value3);  

    OrderedVolumes = OrderedVolumes(:,:,...
        ceil(Size(3)/2)-ceil(nPlanesPerReferenceVolume/2-1):...
        ceil(Size(3)/2)+ceil(nPlanesPerReferenceVolume/2-1)+1,:);
    ReferenceVolume = OrderedVolumes(:,:,:,referenceTimePoint);  
    
    %Find best matching planes
    [value4, value5, value6] = ComputeZshift(tvector,...
    ReferenceVolume,OrderedVolumes,Size,StartCorrelation,EndCorrelation,...
    StartPlane,nPlanesPerReferenceVolume);

    RowShifts2 = [];
    ColumnShifts2 = [];
    ZShifts = [];
    
    RowShifts2 = cat(2,RowShifts2,value4);
    ColumnShifts2 = cat(2,ColumnShifts2,value5);
    ZShifts = cat(2,ZShifts,value6);  
    
    RowShifts = RowShifts + RowShifts2;
    ColumnShifts = ColumnShifts + ColumnShifts2;
    
    tEndDXYZS = toc(tStartDXYZS);
    fprintf('DetermineXYZShifts is %d minutes and %f seconds\n.', ...
        floor(tEndDXYZS/60),rem(tEndDXYZS,60));
end