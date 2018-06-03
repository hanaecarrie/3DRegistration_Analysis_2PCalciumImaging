
% Column_DL102 = cat(3, Column_DL102, ColumnShiftsXY1 + ColumnShiftsXY2 + cat(1, ColumnShiftsZ, zeros(3,930)) + ColumnShiftsW');
% Row_DL102 = cat(3, Row_DL102, RowShiftsXY1 + RowShiftsXY2 + cat(1, RowShiftsZ, zeros(3,930)) + RowShiftsW');
% Z_DL102 = cat(3, Z_DL102, ZShifts);


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

heatmap(Call, 'grid', 'off');
heatmap(Rall, 'grid', 'off');
heatmap(Zall, 'grid', 'off');
heatmap(Zall, 'grid', 'off', 'colorlimits', [-1 1]);

Z = Zall;
for i = 1:30
Z(i,:) = Z(i,:) +i;
end
Z = Z(4:27,:);
plot(Z');

for i = 1:24
Zs(i,:) = smooth(Z(i,:));
end
plot(Zs');

meanZ = mean(Z,1);
plot(smooth(meanZ));
plot(smooth(smooth(meanZ)));

running = sbxSpeed('DL89', '171122', 1);
for i = 2:6
running = cat(2, running, sbxSpeed('DL89', '171122', i));
end
n = 30; % average every n values
a = reshape(running,[],1); % arbitrary data
avgrun = arrayfun(@(i) mean(a(i:i+n-1)),1:n:length(a)-n+1)';

meanZ = mean(Zall);
plot(smooth(smooth((meanZ))));
hold on; plot(avgrun/50-0.3);

n = 930; corrZrun = [];
for i = 1:6*930/n
corrZrun = cat(1, corrZrun, corr((meanZ((i-1)*n+1:n*i))', avgrun((i-1)*n+1:n*i)));
end
bar(corrZrun)

n = 180; corrZrun = [];
for i = 1:6*930/n
corrZrun = cat(1, corrZrun, corr((meanZ((i-1)*n+1:n*i))', avgrun((i-1)*n+1:n*i)));
end
bar(corrZrun)