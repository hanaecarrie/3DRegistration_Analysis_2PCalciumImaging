% Align Microglia across runs

clear all;

%% load data

sizedata = [512, 796, 124, 200];
% load run1
pathrun1 = strcat('\\Megatron\e\hanae_data\Microglia\regdata',...
    '\VF42_FOV2\VF42_170421_200\VF42_170421_200_1\dataregaffine\',...
    'VF42_170421_200_1_dataregaffine.sbx');
run1 = sbxReadPMT(pathrun1);
run1 = reshape(run1, [512, 796, 124, 180]);
run1 = run1(:,:,2:end,2:end);
% ref
ref = squeeze(max(run1, [], 3));
ref = mean(ref, 3);

% load run2
pathrun2 = strcat('\\Megatron\e\hanae_data\Microglia\regdata\',...
    'VF42_FOV2\VF42_170421_212\VF42_170421_212_1\dataregaffine\',...
    'VF42_170421_212_1_dataregaffine.sbx');
run2 = sbxReadPMT(pathrun2);
run2 = reshape(run2, sizedata);
run2 = run2(:,:,2:end,2:end);
% to align
toalign = squeeze(max(run2, [], 3));
toalign = mean(toalign, 3);

[J, rect2] = imcrop(imfuse(ref, toalign));
ref = imcrop(ref, rect2);
toalign = imcrop(toalign, rect2);

ref = uint16(ref);
toalign = uint16(toalign);

%% align ref

BlurFactor = 1;
output = dftregistrationAlex(fft2((ref)),fft2((toalign)),100);
aligned2 = imtranslate(toalign, [output(2) output(1)]);
figure; imshow(imfuse(ref, aligned2));

%% align run

aligned = uint16(zeros([size(ref,1) size(ref,2) sizedata(3)-1 sizedata(4)-1]));
run2bis = uint16(zeros([size(ref,1) size(ref,2) sizedata(3)-1 sizedata(4)-1]));

for t = 1:sizedata(4)-1
    for z = 1:sizedata(3)-1
    run2bis(:,:,z,t) = imcrop(run2(:,:,z,t), rect2);
    end
end

for t = 1:sizedata(4)-1
    for z = 1:sizedata(3)-1
        aligned(:,:,z,t) = imtranslate(run2bis(:,:,z,t),...
            [output(2) output(1)]);
    end
end

%% crop ref run

run1bis = uint16(zeros([size(ref,1) size(ref,2) sizedata(3)-1 179]));

for t = 1:sizedata(4)-1
    for z = 1:sizedata(3)-1
    run1bis(:,:,z,t) = imcrop(run1(:,:,z,t), rect2);
    end
end


%%

projrun1 = squeeze(max(run1bis, [], 3));
projrun2 = squeeze(max(aligned, [], 3));
projruns = cat(3, projrun1, projrun2);
implay(projruns);

%%
A = mean(projrun1,3);
B = mean(projrun2,3);
[I, rectI] = imcrop(imfuse(A,B));
projrun1bis = uint16(zeros(size(I,1), size(I,2), 179));
for i = 1:179
    projrun1bis(:,:,i) = imcrop(projrun1(:,:,i), rectI);
end
projrun2bis = uint16(zeros(size(I,1), size(I,2), 199));
for i = 1:199
    projrun2bis(:,:,i) = imcrop(projrun2(:,:,i), rectI);
end
projruns = cat(3, projrun1bis, projrun2bis);
implay(projruns);

