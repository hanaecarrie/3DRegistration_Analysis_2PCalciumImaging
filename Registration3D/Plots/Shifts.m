%% Script Shifts figures DL89 (part 1) and DL102 (part 2)
% On Magatron

% PART1: DL89 Z shifts

clear all;

%% Load shifts

path = 'E:\hanae_data\Dura\AnalysisDura\';
Column_DL89before = load(strcat(path, 'Column_DL89before'));
Column_DL89before = Column_DL89before.Column_DL89before;
Row_DL89before = load(strcat(path, 'Row_DL89before'));
Row_DL89before = Row_DL89before.Row_DL89before;
Z_DL89before = load(strcat(path, 'Z_DL89before'));
Z_DL89before = Z_DL89before.Z_DL89before;

Call = reshape(Column_DL89before, [30, 6*930]);
Rall = reshape(Row_DL89before, [30, 6*930]);
Zall = reshape(Z_DL89before, [30, 6*930]);
Row_DL89before = reshape(Row_DL89before, [30, 930*6]);

%% preprocess Z shifts

Z = Zall;
for i = 1:30
Z(i,:) = Z(i,:) +i;
end
Z = Z(4:27,:);
%plot(Z');

Zs = Z;
for i = 1:24
Zs(i,:) = smooth(Z(i,:));
end
%plot(Zs');

ZDL89align = Zs;
ZmeanbeforeCSD = mean(ZDL89align(:, 1:1860), 2);
for i = 1:24
    ZDL89align(i,:) = ZDL89align(i,:) - ZmeanbeforeCSD(i) + i+3; 
end 
%plot(ZDL89align');

ZDL89mean = [];
for i = 1:24
    n = 20; % average every n values
    a = reshape(ZDL89align(i,:)-i-3,[],1); % arbitrary data
    ZDL89meanplane = arrayfun(@(i) mean(a(i:i+n-1)),1:n:length(a)-n+1)';
    ZDL89meanplane = ZDL89meanplane + i+3;
    ZDL89mean = cat(2, ZDL89mean, ZDL89meanplane);
end 

running = sbxSpeed('DL89', '171122', 1);
for i = 2:6
running = cat(2, running, sbxSpeed('DL89', '171122', i));
end
n = 30*20; % average every n values
a = reshape(running,[],1); % arbitrary data
avgrun = arrayfun(@(i) mean(a(i:i+n-1)),1:n:length(a)-n+1)';


%% heatmap Z

ZDL89meanshifts = ZDL89mean';
for i = 1:24
    ZDL89meanshifts(i,:) = ZDL89meanshifts(i,:)-3-i;
end

figure;
imagesc(flipud(ZDL89meanshifts(1:21,:))); colorbar;
% yticks(1:24);
% yticklabels({'24', '23','22','21','20', '19','18', ...
%     '17', '16', '15','14',  '13', '12', '11', '10', '9','8', '7', '6', ...
%     '5', '4' });
% xticks(1:46:279);
% xticklabels({'0', '30', '60', '90', '120', '150', '180'});
xlabel('time (min)');
ylabel('plane number');
title('Z Shifts per plane across time DL89');
%caxis([-1.3 2.4]);


%% Mean Zshift VS Running state

running = sbxSpeed('DL89', '171122', 1);
for i = 2:6
running = cat(2, running, sbxSpeed('DL89', '171122', i));
end
n = 30*30; % average every n values
a = reshape(running,[],1); % arbitrary data
avgrun = arrayfun(@(i) mean(a(i:i+n-1)),1:n:length(a)-n+1)';
corrZDL89 = zeros(1,6);
meanZDL89align = mean(ZDL89align, 1)';
n = 30; % average every n values
b = reshape(meanZDL89align,[],1); % arbitrary data
avgmeanZDL89 = arrayfun(@(i) mean(b(i:i+n-1)),1:n:length(b)-n+1)';
figure;
plot((avgmeanZDL89-mean(avgmeanZDL89))'); hold on; plot(avgrun/10-1);
title('mean Z shifts across time VS running state - DL89');

%% Correlation per run

n = 30;
avgrun = arrayfun(@(i) mean(a(i:i+n-1)),1:n:length(a)-n+1);
for i = 1:6
    corrZDL89(i) = corr(meanZDL89align(930*(i-1)+1:930*i), ...
        avgrun(930*(i-1)+1:930*i)');
end
figure;
bar(corrZDL89);
xlabel('run number');
ylabel('correlation value');
title('correlation between mean Z shift and running state for each run DL89');


%% Shifts DL102

clear all;

%% COLUMN Shifts

% initialize path and matrix
pathbegin = 'E:\hanae_data\Dura\regdata\DL102\DL102_180514_';
ColumnXY1DL102 = zeros(30, 930, 6);
ColumnXY2DL102 = zeros(30, 930, 6);
ColumnWDL102 = zeros(30, 930, 6);
ColumnZDL102 = zeros(30, 930, 6);
RowDL102 = zeros(30, 930, 6);
ZDL102 = zeros(30, 930, 6);

% read shift values
for runidx = 1:6
    pathidxC = strcat(pathbegin, num2str(runidx),'\DL102_180514_',...
        num2str(runidx), '_0\ShiftsColumn\ColumnShifts');
    aux1 = load(strcat(pathidxC, 'XY1'));
    aux1 = aux1.ColumnShiftsXY1;
    ColumnXY1DL102(:,:,runidx) = aux1;
    aux2 = load(strcat(pathidxC, 'XY2'));
    aux2 = aux2.ColumnShiftsXY2;
    ColumnXY2DL102(:,:,runidx) = aux2;
    aux3 = load(strcat(pathidxC, 'Z'));
    aux3 = aux3.ColumnShiftsZ;
    aux3 = cat(1, aux3, zeros(3, 930));
    ColumnZDL102(:,:,runidx) = aux3;
    aux = load(strcat(pathidxC, 'W'));
    aux = aux.ColumnShiftsW;
    ColumnWDL102(:,:,runidx) = aux';
end

% reshape and combine shifts
ColumnWDL102 = reshape(ColumnWDL102, [30, 930*6]);
ColumnXY1DL102 = reshape(ColumnXY1DL102, [30, 930*6]);
ColumnXY2DL102 = reshape(ColumnXY2DL102, [30, 930*6]);
ColumnZDL102 = reshape(ColumnZDL102, [30, 930*6]);
ColumnDL102 = ColumnWDL102 + ColumnXY1DL102 + ColumnXY2DL102 + ColumnZDL102;

% figures
figure; imagesc(ColumnWDL102); colorbar; caxis([-10 10]);
title('ColumnW DL102');
figure; imagesc(ColumnXY1DL102); colorbar; caxis([-20 20]);
title('ColumnXY1 DL102');
figure; imagesc(ColumnZDL102); colorbar; caxis([-1 1]);
title('ColumnZ DL102');
figure; imagesc(ColumnXY2DL102); colorbar; caxis([-1 1]);
title('ColumnXY2 DL102');
figure; imagesc(ColumnDL102); colorbar;
title('ColumnALL DL102');

%% ROWS shifts

% initialize matrix and get path
pathbegin = 'E:\hanae_data\Dura\regdata\DL102\DL102_180514_';
RowXY1DL102 = zeros(30, 930, 6);
RowXY2DL102 = zeros(30, 930, 6);
RowWDL102 = zeros(30, 930, 6);
RowZDL102 = zeros(30, 930, 6);

% read shift values
for runidx = 1:6
    pathidxC = strcat(pathbegin, num2str(runidx),'\DL102_180514_',...
        num2str(runidx), '_0\ShiftsRow\RowShifts');
    aux1 = load(strcat(pathidxC, 'XY1'));
    aux1 = aux1.RowShiftsXY1;
    RowXY1DL102(:,:,runidx) = aux1;
    aux2 = load(strcat(pathidxC, 'XY2'));
    aux2 = aux2.RowShiftsXY2;
    RowXY2DL102(:,:,runidx) = aux2;
    aux3 = load(strcat(pathidxC, 'Z'));
    aux3 = aux3.RowShiftsZ;
    aux3 = cat(1, aux3, zeros(3, 930));
    RowZDL102(:,:,runidx) = aux3;
    aux = load(strcat(pathidxC, 'W'));
    aux = aux.RowShiftsW;
    RowWDL102(:,:,runidx) = aux';
end

% reshape and combine rows
RowWDL102 = reshape(RowWDL102, [30, 930*6]);
RowXY1DL102 = reshape(RowXY1DL102, [30, 930*6]);
RowXY2DL102 = reshape(RowXY2DL102, [30, 930*6]);
RowZDL102 = reshape(RowZDL102, [30, 930*6]);
RowDL102 = RowWDL102 + RowXY1DL102 + RowXY2DL102 + RowZDL102;

% figures
figure; imagesc(RowWDL102); colorbar; caxis([-10 10]);
title('RowW DL102');
figure; imagesc(RowXY1DL102); colorbar; caxis([-20 20]);
title('RowXY1 DL102');
figure; imagesc(RowZDL102); colorbar; caxis([-1 1]); 
title('RowZ DL102');
figure; imagesc(RowXY2DL102); colorbar; caxis([-1 1]); 
title('RowXY2 DL102');
figure; imagesc(RowDL102); colorbar; 
title('RowALL DL102');


%% Z shifts

pathbegin = 'E:\hanae_data\Dura\regdata\DL102\DL102_180514_';
ZDL102 = zeros(30, 930, 6);

for runidx = 1:6
    pathidxZ = strcat(pathbegin, num2str(runidx),'\DL102_180514_',...
        num2str(runidx), '_0\ShiftsZ\ZShifts');
    aux = load(pathidxZ);
    aux = aux.ZShifts;
    aux = cat(1, aux, zeros(3, 930));
    ZDL102(:,:,runidx) = aux;
end

ZDL102 = reshape(ZDL102, [30, 930*6]);
figure; imagesc(ZDL102(4:27,:)); colorbar; caxis([-1.5 1.5]);
title('Z DL102');

% reshape and smooth shifts
ZDL102planes = ZDL102;
for i = 1:30
    ZDL102planes(i,:) = ZDL102planes(i,:) + i; 
end

ZDL102planessmooth = ZDL102planes;
for i = 1:30
    ZDL102planessmooth(i,:) = smooth(smooth(ZDL102planes(i,:))); 
end
ZDL102align = ZDL102planessmooth;
ZmeanbeforeCSD = mean(ZDL102align(:, 1:1860), 2);
for i = 1:30
    ZDL102align(i,:) = ZDL102align(i,:) - ZmeanbeforeCSD(i) + i; 
end 

% figure
figure; plot(ZDL102align(4:27,:)');
title('Z planes position across time - DL102');
