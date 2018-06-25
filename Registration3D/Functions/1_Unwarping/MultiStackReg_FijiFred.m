function tform_cum = MultiStackReg_FijiFred(mean_vol)

javaaddpath 'C:\Program Files\MATLAB\R2017a\java\mij.jar'
javaaddpath 'C:\Program Files\MATLAB\R2017a\java\ij.jar'
addpath(genpath('C:\Program Files\Fiji.app'));
addpath(genpath('D:\Analysis_scripts\Dropbox\AndermannLab\users\Fred\'));

N = size(mean_vol,3)-1;
Miji(false);
MIJ.createImage(mean_vol);
MIJ.setSlice(1);
MIJ.run("MultiStackReg", "stack_1=[Import from Matlab] action_1=Align file_1=[] stack_2=None action_2=Ignore file_2=[] transformation=[Affine] save");
MIJ.run('Close');
MIJ.exit;

%%
%load and parse transformed points from Miji
 transforms = ParseTransformationMatrix('TransformationMatrices.txt');
% transforms = LoadTransforms('TransformationMatrices.txt');

M = repmat([true; true; true; false; false; false],N,2);

movingPoints = transforms(M);
movingPoints = reshape(movingPoints,[],2);

%% get step-wise transformation (NOT cumulative)
idx = 1:3:size(movingPoints,1);
fixedPoints = transforms(4:6,:);
tform(1) = fitgeotrans(fixedPoints,fixedPoints,'affine');
for i = 1:length(idx)
    A = movingPoints(idx(i):idx(i)+2,:);
%     tform(i+1) = fitgeotrans(fixedPoints,A,'affine');
    tform(i+1) = fitgeotrans(A,fixedPoints,'affine');
end

%% get cumulative transforms
M_cum = eye(3);
for i = 1:length(tform)
    M_cum = M_cum * tform(i).T;
    tform_cum(i) = affine2d(M_cum);
end


end