function [outputpaths, EdgesWarp] = CorrectWarping2Channels(inputpath, outputpath,...
    mouse, date, run, channel, blurfactor, edges, chunck)
% CORRECTWARPING2CHANNELS: Compute, apply and return xy shifts 
% along the z axis for a given volume
% 
%   Inputs:
%     inputpath -- str, path to sbx file
%     outputpath -- str, path to a folder
%     mouse -- str, mouse name
%     date -- str, imaging session date
%     run -- int, run number
%     channel -- int {0,1}, 0 for the green channel, 1 for the red channel
%         channel where the reg is computed
%     blurfactor -- float, width of the gaussian filter
%     edges -- array of int, dim 1x4, number of pixels to remove
%         [top, bottom, left, right]
%     chunck -- int, nb of chuncks for tiff
%   Outputs:
%     none

tStartCW2C = tic; % starting time

% load 2 channels
data1 = sbxReadPMT(inputpath, 0, 30000, channel);

otherchannel = ~channel;

data2 = sbxReadPMT(inputpath, 0, 30000, otherchannel);
info = sbxInfo(inputpath); % get info
if info.otparam(3) ~= (info.max_idx-1) % if multiple volumes
    % reshape data into 4D format
    data1 = reshape(data1, [size(data1,1),size(data1,2),...
        info.otparam(3), floor(size(data1,3)/info.otparam(3))]);
    data2 = reshape(data2, size(data1));
    times = size(data1, 4); % get number of volumes
else
    times = 1; % set number of volumes to 1 if single volume
end
nbplanes = size(data1, 3); % get number of planes
data1 = data1(edges(3)+1:end-edges(4),edges(1)+1:end-edges(2),:,:);
% crop data
data2 = data2(edges(3)+1:end-edges(4),edges(1)+1:end-edges(2),:,:);
% crop data
RowShiftsW = zeros(times, nbplanes); % initialize row shifts
ColumnShiftsW = zeros(times, nbplanes); % initialize column shifts
% prepare parallelisation: out = data1 in cell format 
out = cell(1, times);
for t = 1:times
    out{t} = data1(:,:,:,t);
end

% correct wraping
openParallel(); % uses nb_cpu - 2
parfor t = 1:times % iterate over each volumes in time
    disp(t);
    volume = out{t};
    for z = 2:nbplanes % iterate over each plane
        sliceref = volume(:,:,z-1); % reference
        % Determine XY shifts on the first channel
        output = dftregistrationAlex(fft2(imgaussfilt(...
            sliceref,blurfactor)),...
            fft2(imgaussfilt(volume(:,:,z),blurfactor)),100);
        % Keep output
        RowShiftsW(t,z) = output(1);
        ColumnShiftsW(t,z) = output(2);
        % Apply XY shifts
        volume(:,:,z) = ...
                    imtranslate((volume(:,:,z)),...
                    [ColumnShiftsW(t,z) RowShiftsW(t,z)]);
        % Applying the same shifts to the other channel
        data2(:,:,z,t) = ...
                    imtranslate((data2(:,:,z,t)),...
                    [ColumnShiftsW(t,z) RowShiftsW(t,z)]);
    end
    out{t} = volume;
end

% recover registered data1
for t = 1:times
    data1(:,:,:,t) = out{t};
end
clear('out');
% pad images with zeros to recover image size
% NB: edges = [left, right, top, bottom] !!!
data1 = padarray(data1, [edges(3), edges(1)], 'pre');
data1 = padarray(data1, [edges(4), edges(2)], 'post');
data2 = padarray(data2, [edges(3), edges(1)], 'pre');
data2 = padarray(data2, [edges(4), edges(2)], 'post');
EdgesWarp = detectEmptyEdges(data1);

% saving wrapreg results after creating directory (if necessary)
if ~exist(outputpath, 'dir')
    mkdir(outputpath);
end
dirchannel1 = strcat(outputpath, mouse, '_', date, '_', num2str(run),...
    '_', num2str(channel), '\');
dirchannel2 = strcat(outputpath, mouse, '_', date, '_', num2str(run),...
    '_', num2str(otherchannel), '\');
if ~exist(dirchannel1, 'dir')
    mkdir(dirchannel1);
end
if ~exist(dirchannel2, 'dir')
    mkdir(dirchannel2);
end
    
saveVolumeRegistration(dirchannel1, ...
    data1, 'warpreg', mouse, date, run, channel, chunck);
saveVolumeRegistration(dirchannel2, ...
    data2, 'warpreg', mouse, date, run, otherchannel, chunck);

% saving shifts after creating directory (if necessary)
if ~exist(strcat(dirchannel1, '\ShiftsRow\'), 'dir')
    mkdir(dirchannel1, '\ShiftsRow\');
end
if ~exist(strcat(dirchannel1, '\ShiftsColumn\'), 'dir')
    mkdir(dirchannel1, '\ShiftsColumn\');
end
save(strcat(dirchannel1, '\EdgesWarp'), 'EdgesWarp');
save(strcat(dirchannel1, '\ShiftsRow\RowShiftsW'), 'RowShiftsW');
save(strcat(dirchannel1, '\ShiftsColumn\ColumnShiftsW'), 'ColumnShiftsW');

% outputpaths
outputpaths = cell(2,1);
outputpaths{1} = strcat(outputpath,  mouse, '_', date, '_',...
    num2str(run), '_', num2str(channel),'\warpreg\', mouse, '_',...
    date, '_', num2str(run), '_', num2str(channel), '_warpreg.sbx'); 
outputpaths{2} = strcat(outputpath,  mouse, '_', date, '_',...
    num2str(run), '_', num2str(otherchannel),'\warpreg\', mouse, '_',...
    date, '_', num2str(run), '_', num2str(otherchannel), '_warpreg.sbx');
clear data1; clear data2;

tEndCW2C = toc(tStartCW2C); % ending time
fprintf('CorrectWarping2Channels in %d minute(s) and %f seconds\n.', ...
    floor((tEndCW2C-tStartCW2C)/60),rem(tEndCW2C,60));

end

