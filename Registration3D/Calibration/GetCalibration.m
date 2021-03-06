%% WarpingCalibration

clear all;
tStartWC = tic;
edges = [0,0,0,0];
blurfactor = 1;

%% Load data calibration

pollen = (zeros(512, 796, 18));
infos = cell(18,1);
for i = 1:18
    if i < 10
        prep = '0';
    else
        prep = '';
    end
    pathbegin = strcat('D:\twophoton_data\2photon\scan\',...
        'OPTOTEST\optotest_180510_0', prep);
    path = strcat(pathbegin, num2str(i), '.sbx');
    infos{i} = sbxInfo(path);
    pollen(:,:,i) = ((mean(sbxReadPMT(path), 3)));
end

%% Register warping

vol = pollen(edges(3)+1:end-edges(4),edges(1)+1:end-edges(2),:,:);
% crop, NB: edges = [left, right, top, bottom] !!!
RowShifts = zeros(1, size(vol,3));
ColumnShifts = zeros(1, size(vol,3));

for z = 2:size(vol, 3)
    refslice =  vol(edges(3)+1:end-edges(4),...
    edges(1)+1:end-edges(2),z-1); % pick previous slice and crop
    output = dftregistrationAlex(fft2(imgaussfilt(...
        refslice,blurfactor)),...
        fft2(imgaussfilt(vol(:,:,z),blurfactor)),100);
    RowShifts(z) = output(1);
    ColumnShifts(z) = output(2);
    vol(:,:,z) = ...
            imtranslate((vol(:,:,z)),[ColumnShifts(z) RowShifts(z)]);
end    

% pad images with zeros to recover image size
% NB: edges = [left, right, top, bottom] !!!
vol = padarray(vol, [edges(3), edges(1)], 'pre');
vol = padarray(vol, [edges(4), edges(2)], 'post');

%% Register affine warping

path = strcat('E:\hanae_data\Microglia\calibration\pollenvolume.sbx');
% sbxAlignAffineDFT({path}, 'tbin', 0, 'refsize', 1, 'refoffset', 0);
% sbxSaveAlignedSBX(path);

%% Load Fit

pathfitC = 'E:\hanae_data\Microglia\calibration\Cfit';
fitC = load(pathfitC);
fitC = fitC.fit2;
pathfitR = 'E:\hanae_data\Microglia\calibration\Rfit';
fitR = load(pathfitR);
fitR = fitR.fit1;

%% optitune values

optlev = [0, 105, 200, 300, 403, 509, 597, 703, 808, 896, 1002,...
    1107, 1195, 1301, 1407, 1495, 1600, 1706];
midoptlev = optlev(1:end-1) + diff(optlev)/2;
midoptlev = cat(2, midoptlev, optlev(18) + 50);
figure;
plot(midoptlev, ColumnShifts, '+', 'Color', [0 0.4470 0.7410]); hold on;
plot(midoptlev, polyval(fitC.coeff, midoptlev), 'Linewidth', 2, 'Color',[0  0.4470 0.7410]); hold on;
plot(midoptlev, RowShifts, '+', 'Color', [0.4900 0.1800 0.5600]); hold on;
plot(midoptlev, polyval(fitR.coeff, midoptlev),  'Linewidth', 2); hold on;
xlabel('optitune level (arbitrary)'); ylabel('nb pixel shift (pixel)');
legend('Column', 'cubic fitting Column', 'Row', 'cubic fitting Row',...
    'Location', 'southwest');
axis([0 1800 -110 0]);
%eqn will be a string representing the equation
title('Calibration');
view([90 -90]);

%% Plot figures
figure;
distance = sqrt(ColumnShifts.^2+RowShifts.^2);
plot(midoptlev, distance, 'r');
xlabel('optitune level (arbitrary)'); ylabel('nb pixel shift (pixel)');
legend('Distance');
title('Calibration2');
hold on;

tEndWC = toc(tStartWC); % ending time
fprintf('WarpingCalibration in %d minute(s) and %f seconds\n.', ...
    floor(tEndWC/60),rem(tEndWC,60));
