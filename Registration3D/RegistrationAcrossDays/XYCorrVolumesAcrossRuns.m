%% Script reg across runs Microglia

path1 = '\\Megatron\e\hanae_data\Microglia\regdata\VF42_FOV2\VF42_170421_200\VF42_170421_200_0\dataregaffine\VF42_170421_200_0_dataregaffine.sbx';
run1 = sbxReadPMT(path1);
run1 = reshape(run1, [512, 796, 124, 180]);

projz1 = uint16(zeros([size(run1,1), size(run1, 2), size(run1,4)]));

for t = 1:size(run1,4)
projz1(:,:,t) = max(run1(:,:,:,t), [], 3);
end

avgprojz1 = mean(projz1,3);

pathedges1 = 'E:\hanae_data\Microglia\regdata\VF42_FOV2\VF42_170421_200\VF42_170421_200_0\EdgesWarp';
edges1 = load(pathedges1);
edges1 = edges1.EdgesWarp;
avgprojz1crop = avgprojz1(edges1(3):end-edges1(4), edges1(1):end-edges1(2));
figure; imshow(mat2gray(avgprojz1crop));

%%

path2 = '\\Megatron\e\hanae_data\Microglia\regdata\VF42_FOV2\VF42_170421_212\VF42_170421_212_0\dataregaffine\VF42_170421_212_0_dataregaffine.sbx';
run2 = sbxReadPMT(path2);
run2 = reshape(run2, [512, 796, 124, 200]);

projz2 = uint16(zeros([size(run2,1), size(run2, 2), size(run2,4)]));

for t = 1:size(run2,4)
projz2(:,:,t) = max(run2(:,:,:,t), [], 3);
end

avgprojz2 = mean(projz2, 3);

pathedges2 = 'E:\hanae_data\Microglia\regdata\VF42_FOV2\VF42_170421_212\VF42_170421_212_0\EdgesWarp';
edges2 = load(pathedges2);
edges2 = edges2.EdgesWarp;
avgprojz2crop = avgprojz2(edges2(3):end-edges2(4), edges2(1):end-edges2(2));
figure; imshow(mat2gray(avgprojz2crop));

%% max edges

edgesmax = max(edges1,edges2);
avgprojz2crop = avgprojz2(edgesmax(3):end-edgesmax(4), edgesmax(1):end-edgesmax(2));
avgprojz1crop = avgprojz1(edgesmax(3):end-edgesmax(4), edgesmax(1):end-edgesmax(2));

%% 

figure; imshow(imfuse(avgprojz1crop, avgprojz2crop));

%%

output = dftregistrationAlex(fft2(imgaussfilt(avgprojz1crop, 1)),...
    fft2(imgaussfilt(avgprojz2crop,1)),100);
rowshift = output(1);
columnshift = output(2);

%%

avgprojz2reg = imtranslate(avgprojz2crop, [columnshift, rowshift]);
figure; imshow(imfuse(avgprojz1crop, avgprojz2reg));

%%
refvol = mean(run1(:,:,:,2:end), 4);

%%
closestvec = zeros(1,124);
plane = mean(squeeze(run2(:,:,planeidx,:)), 3);

%%

for planeidx = 2:50
[closestplane, corrvector] = SpatialCorrPlaneVolumeMicroglia(...
    refvol(:,:,2:end), plane, [0,0,0,0], planeidx-1);
disp(closestplane+1-planeidx);
closestvec(planeidx) = closestplane;
end

%%

implay(mat2gray(refvol(edgesmax(3):end-edgesmax(4), edgesmax(1):end-edgesmax(2),:)));
figure; imshow(mat2gray(plane(edgesmax(3):end-edgesmax(4), edgesmax(1):end-edgesmax(2))));

