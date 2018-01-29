function[ZShifts,RowShifts,ColumnShifts] = DetermineXYZShifts(...
    full_vol, BlurFactor, KeepingFactor, ReferenceVolumeIndex)

    Size = size(full_vol);
    Keep = KeepingFactor;
    red_vol = full_vol(...
        floor(Size(1)*(1-Keep)/2):floor(Size(1)*(1-(1-Keep)/2)),...
        floor(Size(2)*(1-Keep)/2):floor(Size(2)*(1-(1-Keep)/2)),:,:);
    Tmax = Size(4);
    
    RowShifts = [];
    ColumnShifts = [];
    OrderedVolumes = [];
    tvector = 1:Tmax;
    
    disp('FIRST STEP: Perform XY registration across planes and across time')
    [value1, value2, value3] = ...
        OrderVolumes(tvector, Size, BlurFactor, red_vol);
    
    RowShifts = cat(2, RowShifts, value1);
    ColumnShifts = cat(2, ColumnShifts, value2);
    OrderedVolumes = cat(4, OrderedVolumes, value3);  
    
    ReferenceVolume = OrderedVolumes(:,:,:,ReferenceVolumeIndex);  
    
    disp('SECOND STEP: Perform Z registration across time')
    disp('Start find best matching planes...');
    [value4, value5, value6] = ComputeZshift(tvector,...
    ReferenceVolume,OrderedVolumes,Size);

    RowShifts2 = [];
    ColumnShifts2 = [];
    ZShifts = [];
    
    RowShifts2 = cat(2,RowShifts2,value4);
    ColumnShifts2 = cat(2,ColumnShifts2,value5);
    ZShifts = cat(2,ZShifts,value6);  
    
    RowShifts = RowShifts + RowShifts2;
    ColumnShifts = ColumnShifts + ColumnShifts2;
    
    disp('End find best matching planes')
end