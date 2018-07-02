
% javaaddpath 'C:\Program Files\MATLAB\R2017a\java\mij.jar'
% javaaddpath 'C:\Program Files\Fiji.app\jars\ij-1.51g.jar'
% addpath(genpath('D:\Analysis_scripts\Dropbox\AndermannLab\users\Fred\'));
% MIJ.start;
%MIJ.run('Open...', 'path=[E:\hanae_data\Microglia\regdata\VF45_FOV2\Crossruns\AVG_MAX_VF45_FOV2.tif]');
% path = 'E:\hanae_data\Microglia\regdata\VF45_FOV2\Crossruns\AVG_MAX_VF45_FOV2.tif';
% img1 = imread(path, 1);
% img2 = imread(path,2);
% MIJ.createImage('img1', img1, true);
% MIJ.createImage('img2', img2, true);
% MIJ.run("MultiStackReg", "stack_1=[img1] action_1=Reference file_1=[] stack_2=[img2] action_2=Align file_2=[] transformation=[Rigid Body] save");
% MIJ.run('Close');
% MIJ.exit;

path_transfo = 'E:\hanae_data\Microglia\regdata\VF45_FOV2\Crossruns\TransformationMatrices.txt';
transforms = LoadTransforms(path_transfo);

%% ref run1

pathrun1 = strcat('E:\hanae_data\Microglia\regdata\VF45_FOV2\',...
    'VF45_171008_200\VF45_171008_200_1\dataregaffine\',...
    'VF45_171008_200_1_dataregaffine.sbx');
run1 = sbxReadPMT(pathrun1);
run1 = reshape(run1, sizedata);
run1 = run1(:,:,2:end,2:end);
ref = squeeze(max(run1, [], 3));
ref = mean(ref, 3);

%% correct other runs

movingPoints = transforms(1:3,:);
fixedPoints = transforms(4:6,:);
tform = fitgeotrans(movingPoints,fixedPoints,'nonreflectivesimilarity');

% load run2
sizedata = [512, 796, 124, 200];
pathrun2 = strcat('E:\hanae_data\Microglia\regdata\VF45_FOV2\',...
    'VF45_171008_224\VF45_171008_224_1\dataregaffine\',...
    'VF45_171008_224_1_dataregaffine.sbx');
run2 = sbxReadPMT(pathrun2);
run2 = reshape(run2, sizedata);
run2 = run2(:,:,2:end,2:end);
% to align
toalign = squeeze(max(run2, [], 3));

aligned = imwarp(toalign, (tform), 'OutputView', imref2d(size(ref)));

falseColorOverlay = imfuse(ref, mean(aligned,3));
imshow(falseColorOverlay);


%% new runs

newruns = cat(3, squeeze(max(run1, [], 3)), aligned);
implay(newruns);

