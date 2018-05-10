function [] = CorrectWarping2Channels(inputpath, outputpath,...
    mouse, date, run, channel, blurfactor, edges, chunck)
% CorrectWarping2Channels Compute, apply and return xy shifts 
% along the z axis for a given volume
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

tStart = tic; % starting time

% load 2 channels
data1 = sbxReadPMT(inputpath, 0, 372, channel);
if channel == 0
    otherchannel = 1;
    
elseif channel == 1
    otherchannel = 0;
else
    error("channel should be equal to 0 or 1");
end
data2 = sbxReadPMT(inputpath, 0, 372, otherchannel);
info = sbxInfo(inputpath); % get info
if info.otparam(3) ~= (info.max_idx-1) % if multiple volumes
    % reshape data into 4D format
%     data1 = reshape(data1, [size(data1,1),size(data1,2),...
%         info.otparam(3),floor(size(data1,3)/info.otparam(3))]);
    data1 = reshape(data1, [size(data1,1),size(data1,2),...
        info.otparam(3),3]);
    data2 = reshape(data2, [size(data2,1),size(data2,2),...
        info.otparam(3),3]); % TEST
    % data2 = reshape(data2, size(data1));
    times = size(data1, 4); % get number of volumes
else
    times = 1; % set number of volumes to 1 if single volume
end
nbplanes = size(data1, 3); % get number of planes
data1 = data1(edges(1)+1:end-edges(2),edges(3)+1:end-edges(4),:,:);
% crop data
data2 = data2(edges(1)+1:end-edges(2),edges(3)+1:end-edges(4),:,:);
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
% pad XXX

% saving wrapreg results after creating directory (if necessary)
if ~exist(outputpath, 'dir')
    mkdir(outputpath);
end
saveVolumeRegistration(outputpath, ...
    data1, 'wrapreg', mouse, date, run, channel, chunck);
saveVolumeRegistration(outputpath, ...
    data2, 'wrapreg', mouse, date, run, otherchannel, chunck);
% saving shifts after creating directory (if necessary)
if ~exist(strcat(outputpath, 'RowShifts\'), 'dir')
    mkdir(outputpath, 'RowShifts\');
end
if ~exist(strcat(outputpath, 'ColumnShifts\'), 'dir')
    mkdir(outputpath, 'ColumnShifts\');
end
save(strcat(outputpath, '\RowShifts\RowShiftsW'), 'RowShiftsW');
save(strcat(outputpath, '\ColumnShifts\ColumnShiftsW'), 'ColumnShiftsW');

tEnd = toc(tStart); % ending time
fprintf('CorrectWarping2Channels in %d minutes and %f seconds\n.', ...
    floor((tEnd-tStart)/60),rem(tEnd,60));

end

