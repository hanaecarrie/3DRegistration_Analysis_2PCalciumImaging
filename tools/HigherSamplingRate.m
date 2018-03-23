

path = strcat('D:\twophoton_data\2photon\scan\DL89\171122_DL89\',...
    '171122_DL89_run1017\DL89_171122_1016.signals');
signals = load(path, '-mat');
timecourse = signals.cellsort(1).timecourse.dff_axon_norm;
plot(timecourse);
