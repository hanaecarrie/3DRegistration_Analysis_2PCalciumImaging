%% initialize and crop video
% javaaddpath 'C:\Program Files\MATLAB\R2018a\java\mij.jar'
% javaaddpath 'C:\Program Files\MATLAB\R2018a\java\ij-1.52a.jar'
% javaaddpath 'C:\Program Files\Fiji.app\jars\mij-1.3.6-fiji2.jar'
clear all;
javaaddpath 'C:\Program Files\MATLAB\R2017a\java\mij.jar'
javaaddpath 'C:\Program Files\Fiji.app\jars\ij-1.51g.jar'
addpath(genpath('D:\Analysis_scripts\Dropbox\AndermannLab\users\Fred\'));

fdir = 'E:\hanae_data\Microglia\VF42_170428_482\';
fname = 'VF42_170428_482';
cd(fdir);
% suffix=input('Input file suffix: ','s');

z = sbxread([fdir,fname],1,1);
global info;
pxshift = 0;
N = info.max_idx+1;
Nz = 124;
vol_idx = Nz:Nz:N-1;
sizechunck = 20;

chunk = sbxread([fdir,fname],1+Nz,sizechunck*Nz);
redchunk = squeeze(chunk(2,:,:,:));

%REGION SELECTION
[xmin,xmax,ymin,ymax] = Crop2PMovie(redchunk);
%% CORRECT FOR OPTITUNE DISTORTION
redchunk = redchunk(ymin:ymax,xmin:xmax,:);
Nx = size(redchunk,1);
Ny = size(redchunk,2);
redchunk = reshape(redchunk,Nx,Ny,Nz,[]);
mean_red_vol = squeeze(mean(redchunk,4));
tforms_optitune = MultiStackReg_FijiFred(mean_red_vol);
save('tforms_optitune.mat','tforms_optitune');

clear chunk
clear redchunk

idx = Nz;

warning('off', 'MATLAB:colon:nonIntegerIndex')

temp_vol = sbxread([fdir,fname],Nz,Nz);
for j = 1:Nz %correct distortion due to optitune
    red_slice = squeeze(temp_vol(2,:,:,j));
    red_slice = uint16(shift_correction(red_slice,pxshift));
    red_slice = red_slice(ymin:ymax,xmin:xmax);

    target_vol(1,:,:,j) = imwarp(red_slice,tforms_optitune(j),'OutputView',imref2d(size(red_slice)));
end
reg_target = mean(squeeze(target_vol),3);
% figure,imshow(reg_target,[]);


%% apply warping and DFT registration
mkdir('chunks');
cd('chunks');
Nt = floor(N/Nz);
Nchunk = Nt/sizechunck;
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
    vol30ch1 = sbxReadPMT([fdir,fname],idx,(sizechunck-b)*Nz);
    vol30ch2 = sbxReadPMT([fdir,fname],idx,(sizechunck-b)*Nz, 1);
    vol30 = cat(4, vol30ch1, vol30ch2);
    vol30 = permute(vol30, [4,1,2,3]);
    
    unwarp_chunk = UnwarpChunkFred(vol30, sizechunck-b, ...
        tforms_optitune, reg_target, xmin,xmax,ymin,ymax,Nz,pxshift);
    unwarp_lin = permute(unwarp_chunk,[2,3,1,4,5]);
    unwarp_lin = reshape(unwarp_lin,size(unwarp_lin,1),size(unwarp_lin,2),[]);
    writeTiffFile(unwarp_lin,['chunk',num2str(k),'.tif']);
    unwarp_chunk = [];
    unwarp_lin = [];
    
    h.iterate(1);
end
close(h)

%% do z projections
% imFilesTif=dir('*.tif'); %ensure that you are only looking at the original .tif data
% namesTif=sort_nat({imFilesTif.name});
% Nchannels = 2;
% Nz = 62;
% Nt = 30;
% zproj = [];
% h = waitbar(0,'doing z proj');
% for i = 1:size(namesTif,2)
%     tempchunk = loadTiffFile(namesTif{i});
%     tempchunk = reshape(tempchunk,size(tempchunk,1),size(tempchunk,2),Nchannels,Nz,[]);
%     tempslice = mean(tempchunk,4);
%     tempslice = reshape(tempslice,size(tempchunk,1),size(tempchunk,2),[]);
%     zproj = cat(3,zproj,tempslice);
%     clear tempchunk
%     waitbar(i/size(namesTif,2));
% end
% close(h);
% % writeTiffFile(uint16(zproj),'..\Zproj.tif');
% writeLargeTiff_fbs(uint16(zproj),3600,'..\Zproj');