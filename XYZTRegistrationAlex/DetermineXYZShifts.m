function[ZShifts,RowShifts,ColumnShifts] = DetermineXYZShifts(...
    full_vol, BlurFactor, KeepingFactor, ReferenceVolumeIndex, ...
    nPlanesPerReferenceVolume, nPlanesForCorrelation)

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
    
    disp('Rectifying volumes...')
    [value1, value2, value3] = ...
        OrderVolumes(tvector, Size, BlurFactor, red_vol);
    
    RowShifts = cat(2, RowShifts, value1);
    ColumnShifts = cat(2, ColumnShifts, value2);
    OrderedVolumes = cat(4, OrderedVolumes, value3);  

    OrderedVolumes = OrderedVolumes(:,:,...
        ceil(Size(3)/2)-ceil(nPlanesPerReferenceVolume/2-1):...
        ceil(Size(3)/2)+ceil(nPlanesPerReferenceVolume/2-1)+1,:); %XXX
    ReferenceVolume = OrderedVolumes(:,:,:,referenceTimePoint);  
    
    disp('Find best matching planes...');

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
    
end