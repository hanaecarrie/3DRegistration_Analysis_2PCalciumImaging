function[correctedVolume, ZShifts, RowShiftsXYZ, ColumnShiftsXYZ,...
    RowShiftsXY, ColumnShiftsXY] = XYZTRegistrationTranslation(full_vol,...
    nPlanesForCorrelation, nPlanesPerReferenceVolume, ...
    ReferenceVolumeIndex, BlurFactor, KeepingFactor)

disp('Starting');

disp('Compute XYZ-shifts') 
[ZShifts,RowShiftsXYZ,ColumnShiftsXYZ] = DetermineXYZShifts(full_vol,...
    BlurFactor, KeepingFactor, ReferenceVolumeIndex, ...
    nPlanesPerReferenceVolume, nPlanesForCorrelation);

disp('Apply XYZ-shifts') 
[correctedVolume] = ApplyXYZShifts(full_vol, ZShifts, RowShiftsXYZ, ...
    ColumnShiftsXYZ); 

disp('Compute XY-shifts') 
[RowShiftsXY, ColumnShiftsXY] = DetermineXYShifts(correctedVolume,...
    BlurFactor, KeepingFactor, ReferenceVolumeIndex);

disp('Apply XY registration...')
[correctedVolume] = ApplyXYShifts(correctedVolume, RowShiftsXY, ...
    ColumnShiftsXY);

disp('Ending');

end