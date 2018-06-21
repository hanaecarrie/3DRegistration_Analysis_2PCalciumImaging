% ApplyCalibration(ColumnShifts, RowShifts, )

ColumnShifts = load('\\Megatron\e\hanae_data\Microglia\calibration\ColumnShifts_VF42_170428_248');
ColumnShifts = ColumnShifts.polynome;
RowShifts = load('\\Megatron\e\hanae_data\Microglia\calibration\RowShifts_VF42_170428_248');
RowShifts = RowShifts.polynome;

%% load data

mouse = 'VF42';
date = '170428';
run = 248;

datagreen = sbxReadPMT(sbxPath(mouse, date, run, 'sbx'));
datagreen = reshape(datagreen, [512, 796, 124, 200]);
datagreen = datagreen(:,:,:,2:20);

datared = sbxReadPMT(sbxPath(mouse, date, run, 'sbx'), 0, 300000, 1);
datared = reshape(datared, [512, 796, 124, 200]);
datared = datared(:,:,:,2:20);

%% apply shifts
RowShifts = repmat(RowShifts', 1, 19);
ColumnShifts = repmat(ColumnShifts', 1, 19);
datagreenreg = ApplyXYShifts(datagreen, RowShifts, ColumnShifts);
dataredreg = ApplyXYShifts(datared, RowShifts, ColumnShifts);

%%
WriteTiffHanae('\\Megatron\e\hanae_data\Microglia\calibration\', datagreenreg,...
    'datagreen', 19*124);
WriteTiffHanae('\\Megatron\e\hanae_data\Microglia\calibration\', dataredreg,...
    'datared', 19*124);



