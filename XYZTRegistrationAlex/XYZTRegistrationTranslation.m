function[correctedVolume, ZShifts, RowShiftsXYZ, ColumnShiftsXYZ,...
    RowShiftsXY, ColumnShiftsXY] = XYZTRegistrationTranslation(full_vol,...
    ReferenceVolumeIndex, BlurFactor, KeepingFactor)

disp('Starting');

[ZShifts,RowShiftsXYZ,ColumnShiftsXYZ] = DetermineXYZShifts(full_vol,...
    BlurFactor, KeepingFactor, ReferenceVolumeIndex);

disp('Apply XYZ correction shifts') 
[correctedVolume] = ApplyXYZShifts(full_vol, ZShifts, RowShiftsXYZ, ...
    ColumnShiftsXYZ); 

disp('THIRD STEP: Perform another XY registration across planes and across time')

disp('Determine new XY correction shifts') 
[RowShiftsXY, ColumnShiftsXY] = DetermineXYShifts(correctedVolume,...
    BlurFactor, KeepingFactor, ReferenceVolumeIndex);

disp('Apply new XY correction shifts')
[correctedVolume] = ApplyXYShifts(correctedVolume, RowShiftsXY, ...
    ColumnShiftsXY);

disp('Ending');

end