files = ['17-Apr-2018_13-32-21'; '17-Apr-2018_14-17-43';'17-Apr-2018_15-05-45';...
'17-Apr-2018_15-54-07';'17-Apr-2018_16-42-41';'17-Apr-2018_17-29-43'];
mouse = 'DL89';
date ='171122';

run = 1;
file = files(run,:);
pathbegin = strcat('E:\hanae_data\Dura\registrationFiles\', file, '\');
newruns = 100*run+1:100*run+30;
newruns(20) = [];

%%
mouse = 'VF42';
date = '170428';
file = '25-Apr-2018_07-51-16_redchannel';
pathbegin = strcat('E:\hanae_data\Microglia\registrationFiles\', file, '\');
newruns = 48356;

%%

files = ['24-Apr-2018_15-27-24'; '24-Apr-2018_16-24-43';'24-Apr-2018_17-14-55';...
'24-Apr-2018_18-06-30'];
mouse = 'DL68';
date ='170523';
%%
for run = 2:6
file = files(run,:);
pathbegin = strcat('E:\hanae_data\Dura\registrationFiles\', file, '\');
newruns = 100*run+1:100*run+30;
newruns(20) = [];

for newrun = newruns
disp(newrun)
path = strcat(pathbegin, 'affineplanesacrossruns\', date, '_', mouse, ...
            '_run', num2str(newrun), '\',...
            mouse, '_', date, '_', num2str(newrun-1), '.sbx');
out = sbxAlignAffineDFT({path}, 'tbin', 0, 'refsize', ...
            930, 'refoffset', 30);
sbxSaveAlignedSBX(path);
end
end
