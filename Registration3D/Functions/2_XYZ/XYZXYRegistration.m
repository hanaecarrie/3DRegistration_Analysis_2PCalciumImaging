function [datareg3, savingpathbegin] = XYZXYRegistration(inputsbxpath, ...
    mouse, date, run, channel, n, blurfactor, keepingfactor,...
    edges, planescorr, nbchunck, sizedata, varargin)

tStartXYZXYR = tic;

p = inputParser;
    addOptional(p, 'server', 'megatron');
    addOptional(p, 'savingpathbegin', []);
    if length(varargin) == 1 && iscell(varargin{1}), varargin = varargin{1}; end
    parse(p, varargin{:});
    p = p.Results;

if  isempty(p.savingpathbegin)
    p.savingpathbegin = ...
        '\\megatron\E:\hanae_data\Microglia\registrationFiles\';
    strdate = regexprep(datestr(datetime('now')), ' ', '_');
    strdate = regexprep(strdate, ':', '-');
    p.savingpathbegin = strcat(p.savingpathbegin, '\', strdate, '\');
    mkdir(p.savingpathbegin);
end

savingpath = strcat(p.savingpathbegin, mouse, '_', date, '_',...
    num2str(run), '_', num2str(channel),'\');
if ~exist(savingpath, 'dir')
    mkdir(savingpath);
end

savingpathbegin = p.savingpathbegin;

% load data
zp = sizedata(3);
ts = sizedata(4);
data = sbxReadPMT(inputsbxpath, 0, zp*ts, channel);
w = size(data, 1); h = size(data, 2); nbframes = size(data,3);
data = reshape(data, [w, h, zp, ts]);
% crop or ds
data = data(edges(3)+1:end-edges(4),edges(1)+1:end-edges(2),:,:);

% errors
if mod(nbframes, nbchunck) ~= 0
    error(strcat('number of chuncks for WriteTiff should divide ',...
        'the number of frames'));
elseif mod(ts, n) ~= 0
    error(strcat('Chunck size for reference should be', ...
        'a divider of the number of frames'));
elseif zp*ts ~= nbframes
    error(strcat('number of volumes smaller than expected'));
end


% REFERENCE 1: define, register and save reference 1
disp('reference 1');
ref1 = DefineReference(data, n); 
[Ref1RowShifts,Ref1ColumnShifts] = DetermineXYShifts(ref1,...
    blurfactor,keepingfactor,ref1(:,:,:,1));
[ref1reg] = ApplyXYShifts(ref1, Ref1RowShifts, Ref1ColumnShifts);
clear ref1; clear Ref1RowShifts; clear Ref1ColumnShifts;

% VOLUMEREG1: XY registration and save 1st registration
disp('datareg1');
[RowShiftsXY1, ColumnShiftsXY1] = DetermineXYShifts(data,...
    blurfactor,keepingfactor,ref1reg);
% pad images with zeros to recover image size
ref1reg = padarray(ref1reg, [edges(3), edges(1)], 'pre');
ref1reg = padarray(ref1reg, [edges(4), edges(2)], 'post');
mkdir(strcat(savingpath, 'ref1reg\'));
saveVolumeRegistration(savingpath, ref1reg, 'ref1reg',...
    mouse, date, run, channel, 1, 'type', 'sbx', 'server', p.server);
clear ref1reg;
[datareg1] = ApplyXYShifts(data, RowShiftsXY1, ColumnShiftsXY1);
if ~exist(strcat(savingpath, 'ShiftsRow\'), 'dir')
    mkdir(strcat(savingpath, 'ShiftsRow\'));
end
if ~exist(strcat(savingpath, 'ShiftsColumn\'), 'dir')
    mkdir(strcat(savingpath, 'ShiftsColumn\'));
end
save(strcat(savingpath, 'ShiftsRow\RowShiftsXY1'), 'RowShiftsXY1');
save(strcat(savingpath, 'ShiftsColumn\ColumnShiftsXY1'), ...
    'ColumnShiftsXY1');
% pad images with zeros to recover image size
data = padarray(data, [edges(3), edges(1)], 'pre');
data = padarray(data, [edges(4), edges(2)], 'post');
mkdir(strcat(savingpath, 'data\'));
saveVolumeRegistration(savingpath, data, 'data', mouse, ...
    date, run, channel, 1, 'type', 'sbx', 'server', p.server);
clear data; clear RowShiftsXY1; clear ColumnShiftsXY1; 

% REFERENCE 2
disp('reference 2');
ref2 = DefineReference(datareg1, n);
[Ref2RowShifts,Ref2ColumnShifts] = DetermineXYShifts(ref2(:,:,:,:),...
    blurfactor,keepingfactor,ref2(:,:,:,1));
[ref2reg] = ApplyXYShifts(ref2, Ref2RowShifts, Ref2ColumnShifts);
clear ref2; clear Ref1RowShifts; clear Ref1ColumnShifts;

% REGISTRATION 2: Z registration with interpolation
disp('datareg2');
[RowShiftsZ,ColumnShiftsZ,ZShifts] = ComputeZshiftInterpolate(...
  ref2reg, datareg1, planescorr, edges(1:4));
ref2reg = padarray(ref2reg, [edges(3), edges(1)], 'pre');
ref2reg = padarray(ref2reg, [edges(4), edges(2)], 'post');
mkdir(strcat(savingpath, 'ref2reg\'));
saveVolumeRegistration(savingpath, ref2reg, 'ref2reg',...
  mouse, date, run, channel, 1, 'type', 'sbx', 'server', p.server);
clear ref2reg;
save(strcat(savingpath, 'ShiftsRow\RowShiftsZ'), 'RowShiftsZ');
save(strcat(savingpath, 'ShiftsColumn\ColumnShiftsZ'), 'ColumnShiftsZ');
mkdir(strcat(savingpath, 'ShiftsZ\'));
save(strcat(savingpath, 'ShiftsZ\ZShifts'), 'ZShifts');
[datareg2] = ApplyZShiftInterpolate(datareg1, ZShifts, ...
  ColumnShiftsZ, RowShiftsZ);
datareg1 = padarray(datareg1, [edges(3), edges(1)], 'pre');
datareg1 = padarray(datareg1, [edges(4), edges(2)], 'post');
mkdir(strcat(savingpath, 'datareg1\'));
saveVolumeRegistration(savingpath, datareg1, 'datareg1', ...
    mouse, date, run, channel, 1, 'type', 'sbx', 'server', p.server);
clear datareg1; clear RowShiftsZ; clear ColumnShiftsZ; clear ZShifts;

% REFERENCE 3
disp('reference 3');
ref3 = DefineReference(datareg2, n);
[Ref3RowShifts,Ref3ColumnShifts] = DetermineXYShifts(ref3(:,:,:,:),...
    blurfactor,keepingfactor,ref3(:,:,:,1));
[ref3reg] = ApplyXYShifts(ref3, Ref3RowShifts, Ref3ColumnShifts);
clear ref3; clear Ref3RowShifts; clear Ref3ColumnShifts;

% REGISTRATION 3
disp('datareg3');
datareg2 = uint16(datareg2);
[RowShiftsXY2, ColumnShiftsXY2] = DetermineXYShifts(datareg2,...
    blurfactor, keepingfactor, ref3reg);
ref3reg = padarray(ref3reg, [edges(3), edges(1)], 'pre');
ref3reg = padarray(ref3reg, [edges(4), edges(2)], 'post');
mkdir(strcat(savingpath, 'ref3reg\'));
saveVolumeRegistration(savingpath, ref3reg, 'ref3reg', ...
    mouse, date, run, channel, 1, 'type', 'sbx', 'server', p.server);
clear ref3reg;
[datareg3] = ApplyXYShifts(datareg2, RowShiftsXY2, ...
    ColumnShiftsXY2);
datareg3 = uint16(datareg3);
save(strcat(savingpath, 'ShiftsRow\RowShiftsXY2'), 'RowShiftsXY2');
save(strcat(savingpath, 'ShiftsColumn\ColumnShiftsXY2'), ...
    'ColumnShiftsXY2');
datareg2 = padarray(datareg2, [edges(3), edges(1)], 'pre');
datareg2 = padarray(datareg2, [edges(4), edges(2)], 'post');
mkdir(strcat(savingpath, 'datareg2\'));
saveVolumeRegistration(savingpath, datareg2, 'datareg2', ...
    mouse, date, run, channel, 1, 'type', 'sbx', 'server', p.server);
clear datareg2; clear RowShiftsXY2; clear ColumnShiftsXY2;

datareg3 = padarray(datareg3, [edges(3), edges(1)], 'pre');
datareg3 = padarray(datareg3, [edges(4), edges(2)], 'post');
mkdir(strcat(savingpath, 'datareg3\'));
saveVolumeRegistration(savingpath, datareg3, 'datareg3',...
    mouse, date, run, channel, 1, 'type', 'sbx', 'server', p.server);

tEndXYZXY = toc(tStartXYZXYR);
fprintf('XYZXYRegistration in %d minute(s) and %f seconds\n.', ...
    floor(tEndXYZXY/60),rem(tEndXYZXY,60));

end