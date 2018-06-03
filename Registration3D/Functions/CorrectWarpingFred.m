function [outputpaths, EdgesWarp] = CorrectWarpingFred(inputpath, savingpath,...
    mouse, date, run, Nz, edges, sizechunck)
% CORRECTWARPINGFRED: Compute and apply unwarping on both channels with 
% affine and dft transformation along the z axis for a given volume
% 
%   Inputs:
%     inputpath -- str, path to sbx file without 'sbx'
%     outputpath -- str, path to a folder
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

global info;
N = info.max_idx+1;
Nt = floor(N/Nz);
Nchunk = Nt/sizechunck;
pxshift = 0;

parts = strsplit(inputpath, '\');
folder = fullfile(parts{1:end-1});
file = parts{end};
cd(folder);
chunk = sbxread(file,Nz,sizechunck*Nz);
redchunk = squeeze(chunk(2,:,:,:));

Nx = size(redchunk,1);
Ny = size(redchunk,2);
redchunk = reshape(redchunk,Nx,Ny,Nz,[]);
mean_red_vol = squeeze(mean(redchunk,4));
tforms_optitune = MultiStackReg_FijiFred(mean_red_vol);
save('tforms_optitune.mat','tforms_optitune');

clear chunk
clear redchunk
warning('off', 'MATLAB:colon:nonIntegerIndex')

temp_vol = sbxread(inputpath,Nz,Nz);

for j = 1:Nz %correct distortion due to optitune
    red_slice = squeeze(temp_vol(2,:,:,j));
    red_slice = uint16(shift_correction(red_slice,pxshift));

    target_vol(1,:,:,j) = imwarp(red_slice,tforms_optitune(j),...
        'OutputView',imref2d(size(red_slice)));
end
reg_target = mean(squeeze(target_vol),3);

% apply warping and DFT registration
res = cell(1, Nchunk);

h = parfor_progressbar(Nchunk,'Chunking...');
openParallel();
C = parallel.pool.Constant(pxshift);
parfor k = 1:Nchunk
    disp(k);
     idx = Nz+(k-1)*sizechunck*Nz;
     if k == Nchunk
         b = 1;
     else
         b = 0;
     end
    vol30ch1 = sbxReadPMT(inputpath,idx,(sizechunck-b)*Nz);
    vol30ch2 = sbxReadPMT(inputpath,idx,(sizechunck-b)*Nz, 1);
    vol30 = cat(4, vol30ch1, vol30ch2);
    vol30 = permute(vol30, [4,1,2,3]);
    
    unwarp_chunk = UnwarpChunkFred(vol30, sizechunck-b, ...
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
data1 = padarray(data1, [edges(3), edges(1)], 'pre');
data1 = padarray(data1, [edges(4), edges(2)], 'post');
data2 = squeeze(res(2,:,:,:,:));
data2 = padarray(data2, [edges(3), edges(1)], 'pre');
data2 = padarray(data2, [edges(4), edges(2)], 'post');
clear res;

% saving wrapreg results after creating directory (if necessary)
if ~exist(outputpath, 'dir')
    mkdir(outputpath);
end
dirchannel1 = strcat(outputpath, mouse, '_', date, '_', num2str(run),...
    '_', 0, '\');
dirchannel2 = strcat(outputpath, mouse, '_', date, '_', num2str(run),...
    '_', 1, '\');
if ~exist(dirchannel1, 'dir')
    mkdir(dirchannel1);
end
if ~exist(dirchannel2, 'dir')
    mkdir(dirchannel2);
end

EdgesWarp = detectEmptyEdges(res);
save(strcat(dirchannel1, '\EdgesWarp'), 'EdgesWarp');

saveVolumeRegistration(dirchannel1, ...
    data1, 'warpreg', mouse, date, run, channel, Nchunk);
saveVolumeRegistration(dirchannel2, ...
    data2, 'warpreg', mouse, date, run, otherchannel, Nchunk); 

% outputpaths
outputpaths = cell(2,1);
outputpaths{1} = strcat(outputpath,  mouse, '_', date, '_',...
    num2str(run), '_', num2str(channel),'\warpreg\', mouse, '_',...
    date, '_', num2str(run), '_', num2str(channel), '_warpreg.sbx'); 
outputpaths{2} = strcat(outputpath,  mouse, '_', date, '_',...
    num2str(run), '_', num2str(otherchannel),'\warpreg\', mouse, '_',...
    date, '_', num2str(run), '_', num2str(otherchannel), '_warpreg.sbx');

tEndCWF = toc(tStartCWF); % ending time
fprintf('CorrectWarping2Channels in %d minute(s) and %f seconds\n.', ...
    floor((tEndCWF-tStartCW2C)/60),rem(tEndCWF,60));
end