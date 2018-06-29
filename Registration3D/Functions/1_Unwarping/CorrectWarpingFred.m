function [] = CorrectWarpingFred(inputpath,savingpath, ...
    mouse, date, run, Nz, sizechunk)

% CORRECTWARPINGFRED: Compute and apply unwarping on both channels with 
% affine and dft transformation along the z axis for a given volume
% 
%   Inputs:
%     inputpath -- str, path to sbx file without 'sbx'
%     savingpath -- str, path to a folder
%     mouse -- str, mouse name
%     date -- str, imaging session date
%     run -- int, run number
%     Nz -- float, width of the gaussian filter
%     edges -- array of int, dim 1x4, number of pixels to remove
%         [top, bottom, left, right]
%     sizechunck -- int, nb of volumes to compute registration and 
%   Outputs:
%     none

tStartCWF = tic;

javaaddpath 'C:\Program Files\MATLAB\R2017a\java\mij.jar'
javaaddpath 'C:\Program Files\Fiji.app\jars\ij-1.51g.jar'
addpath(genpath('D:\Analysis_scripts\Dropbox\AndermannLab\users\Fred\'));

info = sbxInfo(inputpath);
N = info.max_idx+1;
Nt = floor(N/Nz);
Nchunk = Nt/sizechunk;
pxshift = 0;

parts = strsplit(inputpath, '\');
folder = fullfile(parts{1:end-1});
file = parts{end};
cd(folder);
redchunk = sbxReadPMT(file,Nz,sizechunk*Nz,1); % first sizechunck volumes
% red channel execpt first volume

Nx = size(redchunk,1);
Ny = size(redchunk,2);
redchunk = reshape(redchunk,[Nx,Ny,Nz,sizechunk]);
mean_red_vol = squeeze(mean(redchunk,4)); % temporal avg red channel
tforms_optitune = MultiStackReg_FijiFred(mean_red_vol); % compute shifts 
% stackreg in avg volume
save('tforms_optitune.mat','tforms_optitune');

clear redchunk
warning('off', 'MATLAB:colon:nonIntegerIndex')

temp_vol_green = sbxReadPMT(inputpath, Nz, Nz); % green channel
temp_vol_red = sbxReadPMT(inputpath, Nz, Nz, 1); % red channel
temp_vol = cat(4, temp_vol_green, temp_vol_red); % concatenate green and 
% red channels
clear temp_vol_green; clear temp_vol_red;
temp_vol = permute(temp_vol, [4,1,2,3]);

for j = 1:Nz % correct distortion due to optitune
    red_slice = squeeze(temp_vol(2,:,:,j));
    red_slice = uint16(shift_correction(red_slice,pxshift));
    target_vol(1,:,:,j) = imwarp(red_slice,tforms_optitune(j),...
        'OutputView',imref2d(size(red_slice)));
end
reg_target = mean(squeeze(target_vol),3); % z projection 

% apply warping and DFT registration
res = cell(1, Nchunk);

h = parfor_progressbar(Nchunk,'Chunking...');
openParallel();
C = parallel.pool.Constant(pxshift);
parfor k = 1:Nchunk
    disp(k);
     idx = Nz+(k-1)*sizechunk*Nz;
     if k == Nchunk
         b = 1;
     else
         b = 0;
     end
    vol30ch1 = sbxReadPMT(inputpath,idx,(sizechunk-b)*Nz);
    vol30ch2 = sbxReadPMT(inputpath,idx,(sizechunk-b)*Nz, 1);
    vol30 = cat(4, vol30ch1, vol30ch2);
    vol30 = permute(vol30, [4,1,2,3]);
    
    unwarp_chunk = UnwarpChunkFred(vol30, sizechunk-b, ...
        tforms_optitune, reg_target, 1, Ny, 1, Nx ,Nz,pxshift);
    unwarp_chunk = permute(unwarp_chunk, [1,5,2,3,4]);
    res{k} = unwarp_chunk;
    unwarp_chunk = [];    
    h.iterate(1);
end
close(h)

res = cell2mat(res);
res = permute(res, [1,3,4,5,2]);
data1 = squeeze(res(1,:,:,:,:));
% data1 = padarray(data1, [edges(3), edges(1)], 'pre');
% data1 = padarray(data1, [edges(4), edges(2)], 'post');
data2 = squeeze(res(2,:,:,:,:));
% data2 = padarray(data2, [edges(3), edges(1)], 'pre');
% data2 = padarray(data2, [edges(4), edges(2)], 'post');
clear res;

% saving wrapreg results after creating directory (if necessary)
if ~exist(savingpath, 'dir')
    mkdir(savingpath);
end

EdgesWarp = detectEmptyEdges(data2);
save(strcat(savingpath, '\EdgesWarp'), 'EdgesWarp');

data1 = cat(4, uint16(rand(size(data1,1),size(data1,2),size(data1,3))),...
    data1);
data2 = cat(4, uint16(rand(size(data2,1),size(data2,2),size(data2,3))),...
    data2);
dirchannel1 = strcat(savingpath, mouse, '_', date, ...
                    '_',  num2str(run), '_', num2str(1), '\');
dirchannel2 = strcat(savingpath, mouse, '_', date, ...
    '_',  num2str(run), '_', num2str(0), '\');
saveVolumeRegistration(dirchannel1, ...
    data1, 'datareg_0', mouse, date, run, 0, 'nbchuncktiff', 10);
saveVolumeRegistration(dirchannel2, ...
    data2, 'datareg_1', mouse, date, run, 1, 'nbchuncktiff', 10); 

tEndCWF = toc(tStartCWF); % ending time
fprintf('CorrectWarping2Channels in %d minute(s) and %f seconds\n.', ...
    floor((tEndCWF-tStartCW2C)/60),rem(tEndCWF,60));
end