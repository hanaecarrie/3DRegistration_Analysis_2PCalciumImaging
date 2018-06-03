clear all;
close all;
clc;

%% load regsitered data

tStart = tic;
mouse = 'DL89';
date = '171122';
run = 1;
cd 'E:\hanae_data\alextry2\mouseDL89_date171122_run1\noregistration\';
list = dir('*zlevel*');
names = struct2cell(list);
names = names(1,:);
for i = 1:size(names,2)
   if contains(names{i},'.avi') == 1
       names{i} = [];
   end
end
names = names(~cellfun('isempty',names));

volume = zeros(512, 796, 930, 29);
for i = 1:29
    load(strcat('zlevel', num2str(i),'_930volumes_BF1_KF095_RVI1_1.mat'));
    volume(:,:,1:465, i) = seq_1;
    load(strcat('zlevel', num2str(i),'_930volumes_BF1_KF095_RVI1_2.mat'));
    volume(:,:,466:930, i) = seq_2;
end

clear seq_1; clear seq_2;
%savingpath = strcat('E:\hanae_data\alextry\mouse', mouse, '_date', ...
%    date, '_run', num2str(run), '\')


%% crop data

volume = volume(1:400,100:696,:,:);
volume = permute(volume, [1, 2, 4, 3]);
save(strcat(savingpath, '\volume'), 'volume');
savingpathv = strcat(savingpath, 'volume\');
WriteTiff(savingpathv,volume,899);

%% Params

w = size(volume, 1);
h = size(volume, 2);
zp = size(volume, 3);
ts = size(volume, 4);
n = 30; % chunck size
if mod(ts, n) ~= 0
    disp('Chunck size should be a divider of the number of frames');
end

BlurFactor = 1;
KeepingFactor = 0.95;

%save(strcat(savingpath, 'volume'), volume);

%% reference

% average every n frames
ref1 = zeros(w, h, zp, ts/n);
for i = 1:ts/n
    for z = 1:size(volume, 3)
        a = volume(:,:,z,(i-1)*n+1:i*n);
        a = squeeze(permute(a, [1, 2, 4, 3]));
        a = mean(a, 3);
        ref1(:,:,z,i) = a;
    end
end

% Determine reg for the reference
[Ref1RowShifts,Ref1ColumnShifts] = DetermineXYShifts(ref1(:,:,:,:),...
    BlurFactor,KeepingFactor,ref1(:,:,:,1));

% Apply reg to reference
[ref1reg] = ApplyXYShifts(ref1, Ref1RowShifts, Ref1ColumnShifts);

save(strcat(savingpath, '\ref1reg'), 'ref1reg');


%% XY registration to the moving reference

[RowShiftsXY, ColumnShiftsXY] = DetermineXYShifts(volume,...
    BlurFactor,KeepingFactor,ref1reg);

[volumereg1] = ApplyXYShifts(volume, RowShiftsXY, ColumnShiftsXY);

%clear volume;

savingpath1 = strcat(savingpath, 'volumereg1\');
WriteTiff(savingpath1,volumereg1,899);
save(strcat(savingpath, '\volumereg1'), 'volumereg1');

%% Taking a new reference for the zshift

% average every 30 frames
ref2 = zeros(w, h, zp, ts/n);
for i = 1:ts/n
    for z = 1:size(volumereg1, 3)
        a = volumereg1(:,:,z,(i-1)*n+1:i*n);
        a = squeeze(permute(a, [1, 2, 4, 3]));
        a = mean(a, 3);
        ref2(:,:,z,i) = a;
    end
end

% Determine reg for the reference
[Ref2RowShifts,Ref2ColumnShifts] = DetermineXYShifts(ref2(:,:,:,:),...
    BlurFactor,KeepingFactor,ref2(:,:,:,1));

% Apply reg to reference
[ref2reg] = ApplyXYShifts(ref2, Ref2RowShifts, Ref2ColumnShifts);

save(strcat(savingpath, '\ref2reg'), 'ref2reg');

%% Zshift new registration - rigid body no interpolation

% RowShifts=[];
% ColumnShifts=[];
% ZShifts=[];
% Determine Zshift
% poolobj = gcp('nocreate');
%     if(isempty(poolobj))
%             poolobj = parpool(3);
%     end
% F(1) = parfeval(poolobj,@ComputeZshiftInterpolate,3,...
%     ref2reg(:,:,:,1:3), volumereg1(:,:,:,1:90), 5); Zmax=1;
% F(2) = parfeval(poolobj,@ComputeZshiftInterpolate,3,...
%     ref2reg(:,:,:,4:6), volumereg1(:,:,:,91:180), 5); Zmax=2;
% F(3) = parfeval(poolobj,@ComputeZshiftInterpolate,3,...
%     ref2reg(:,:,:,7:9), volumereg1(:,:,:,181:270), 5); Zmax=3;

% for z = 1:Zmax
%     [completedIdx,value1,value2,value3] = fetchNext(F);
%     Results{completedIdx,1} = value1;
%     Results{completedIdx,2} = value2;
%     Results{completedIdx,3} = value3;
%     RowShifts=cat(2,RowShifts,Results{z,1});
%     ColumnShifts=cat(2,ColumnShifts,Results{z,2});
%     ZShifts=cat(4,ZShifts,Results{z,3});  
% end

%% Z Shift

[RowShifts,ColumnShifts,ZShifts] = ComputeZshiftInterpolate(...
    ref2reg(:,:,:,:), volumereg1(:,:,:,:), 3);
% [RowShifts2,ColumnShifts2,ZShifts2] = ComputeZshiftInterpolate(...
%     ref2reg(:,:,:,4:6), volumereg1(:,:,:,91:180), 5);
% [RowShifts3,ColumnShifts3,ZShifts3] = ComputeZshiftInterpolate(...
%     ref2reg(:,:,:,7:9), volumereg1(:,:,:,181:270), 5);
% [RowShifts4,ColumnShifts4,ZShifts4] = ComputeZshiftInterpolate(...
%     ref2reg(:,:,:,10:12), volumereg1(:,:,:,271:360), 5);
% [RowShifts5,ColumnShifts5,ZShifts5] = ComputeZshiftInterpolate(...
%     ref2reg(:,:,:,13:15), volumereg1(:,:,:,361:450), 5);
% [RowShifts6,ColumnShifts6,ZShifts6] = ComputeZshiftInterpolate(...
%     ref2reg(:,:,:,16:18), volumereg1(:,:,:,451:540), 5);
% [RowShifts7,ColumnShifts7,ZShifts7] = ComputeZshiftInterpolate(...
%     ref2reg(:,:,:,19:21), volumereg1(:,:,:,540:630), 5);
% [RowShifts8,ColumnShifts8,ZShifts8] = ComputeZshiftInterpolate(...
%     ref2reg(:,:,:,22:24), volumereg1(:,:,:,631:720), 5);
% [RowShifts9,ColumnShifts9,ZShifts9] = ComputeZshiftInterpolate(...
%     ref2reg(:,:,:,25:27), volumereg1(:,:,:,721:810), 5);
% [RowShifts10,ColumnShifts10,ZShifts10] = ComputeZshiftInterpolate(...
%     ref2reg(:,:,:,28:30), volumereg1(:,:,:,811:900), 5);
% [RowShifts11,ColumnShifts11,ZShifts11] = ComputeZshiftInterpolate(...
%     ref2reg(:,:,:,31), volumereg1(:,:,:,901:930), 5);

%%
% % RowShifts = cat(2,RowShifts1,RowShifts2,RowShifts3,RowShifts4,...
% %     RowShifts5,RowShifts6,RowShifts7,RowShifts8,RowShifts9,...
% %     RowShifts10,RowShifts11);
% % %%
% % clear RowShifts1;clear RowShifts2;clear RowShifts3;clear RowShifts4;
% % clear RowShifts5;clear RowShifts6;clear RowShifts7;clear RowShifts8;
% % clear RowShifts9;clear RowShifts10;clear RowShifts11;
% % 
% % %%
% % ColumnShifts = cat(2,ColumnShifts1,ColumnShifts2,ColumnShifts3,...
% %     ColumnShifts4,ColumnShifts5,ColumnShifts6,ColumnShifts7,...
% %     ColumnShifts8,ColumnShifts9,ColumnShifts10,ColumnShifts11);
% % %%
% % clear ColumnShifts1;clear ColumnShifts2;clear ColumnShifts3;
% % clear ColumnShifts4;clear ColumnShifts5;clear ColumnShifts6;
% % clear ColumnShifts7;clear ColumnShifts8;clear ColumnShifts9;
% % clear ColumnShifts10;clear ColumnShifts11;
% % %%
% % ZShifts = cat(2,ZShifts1,ZShifts2,ZShifts3,ZShifts4,...
% %     ZShifts5,ZShifts6,ZShifts7,ZShifts8,ZShifts9,...
% %     ZShifts10,ZShifts11);
% % %%
% % clear ZShifts1;clear ZShifts2;clear ZShifts3;clear ZShifts4;
% % clear ZShifts5;clear ZShifts6;clear ZShifts7;clear ZShifts8;
% clear ZShifts9;clear ZShifts10;clear ZShifts11;
%%

% Apply Zshift
[volumereg2] = ApplyZShiftInterpolate(volumereg1, ZShifts, ...
    ColumnShifts, RowShifts);

%clear volumereg1;

save(strcat(savingpath, '\volumereg2'), 'volumereg2');
savingpath2 = 'E:\hanae_data\alextry\mouseDL89_date171122_run2\volumereg2\';
WriteTiff(savingpath2,volumereg2,899);

 %% New XY reg : reference

% average every n frames
ref3 = zeros(w, h, zp, ts/n);
for i = 1:ts/n
    for z = 1:size(volumereg2, 3)
        a = volumereg2(:,:,z,(i-1)*n+1:i*n);
        a = squeeze(permute(a, [1, 2, 4, 3]));
        a = mean(a, 3);
        ref3(:,:,z,i) = a;
    end
end

% Determine reg for the reference
[Ref3RowShifts,Ref3ColumnShifts] = DetermineXYShifts(ref3(:,:,:,:),...
    BlurFactor,KeepingFactor,ref3(:,:,:,1));

% Apply reg to reference
[ref3reg] = ApplyXYShifts(ref3, Ref3RowShifts, Ref3ColumnShifts);

%% XY registration to the moving reference

[RowShiftsXY2, ColumnShiftsXY2] = DetermineXYShifts(volumereg2,...
    BlurFactor,KeepingFactor,ref3reg);

[volumereg3] = ApplyXYShifts(volumereg2, RowShiftsXY2, ColumnShiftsXY2);

tEnd = toc;
fprintf('Elapsed time is %d minutes and %f seconds\n.', ...
    floor(tEnd-tStart/60),rem(tEnd-tStart,60));

%% Save files

save(strcat(savingpath, '\RowShiftsXY1'), 'RowShiftsXY');
save(strcat(savingpath, '\RowShiftsZ'), 'RowShifts');
save(strcat(savingpath, '\ColumnShiftsXY1'), 'ColumnShiftsXY');
save(strcat(savingpath, '\ColumnShiftsZ'), 'ColumnShifts');
save(strcat(savingpath, '\ZShifts'), 'ZShifts');
%save(strcat(savingpath, '\ref3reg'), 'ref3reg');
%save(strcat(savingpath, '\volumereg3'), 'volumereg3');

%%
save(strcat(savingpath, '\RowShiftsXY2'), 'RowShiftsXY2');
save(strcat(savingpath, '\ColumnShiftsXY2'), 'ColumnShiftsXY2');


%% Save sbx file

% Getting infos
mouse = 'DL68';
date = '170523';
run = 3;

path = sbxPath(mouse, date, run, 'sbx');
info = sbxInfo(path);
% XXX
info.otparam(3) = 1;
info.sz = [400, 597];
info.max_idx = 1859;
info.nsamples = 1860;
otwave = info.otwave;


% Create folders
path_begin = 'D:\twophoton_data\2photon\scan\DL68\170523_DL68\';
path_begin = strcat(path_begin, date, '_', mouse, '_run');

% Registered (warning because double to int16) 
nbplanes = 14;%info.otparam(3);

for plane = 1:nbplanes
    info.otwave = otwave(plane);
    nbrun = run*100 + (plane);
    newfolder = strcat(path_begin, num2str(nbrun));
    mkdir(newfolder);
    savepath = strcat(newfolder, '\', mouse, '_', date,...
    '_', num2str(nbrun-1), '.sbx');
    seq = volumereg3(:,:,plane, :);
    seq = squeeze(seq);
    sbxWrite(savepath, seq, info);
end
 
%% Affine alignment

n = 30; % chunck size
for newrun = 301:329
path = sbxPath(mouse, date, newrun, 'sbx');
out = sbxAlignAffineDFT({path}, 'refsize', size(volumereg3, 4),...
    'refoffset', n);
sbxSaveAlignedSBX(path);
end



