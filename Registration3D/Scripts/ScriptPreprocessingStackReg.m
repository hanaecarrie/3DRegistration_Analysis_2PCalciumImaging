% sbxStackReg preprocessing against wraping

savepath = 'E:\hanae_data\Microglia\registrationFiles\stackreg VF42 green volumes\';
for times = 1:200
saveVolumeRegistration(savepath, squeeze(volume(:,:,:, times)), strcat('time_', num2str(times)), 'VF42', ...
'170428', 483, 1);
end
%%
edges = [60, 80, 10, 20];
path = 'E:\hanae_data\Microglia\registrationFiles\test\time_';
%for times = 1:200
times = 1;
newpath = strcat(path, num2str(times), '\VF42_170428_483_time_', num2str(times));
xyshifts = zeros(124,4);
ch = 124; nbchunck = floor(124/ch);
for chunck = 1:nbchunck % chunck size 31
ref = sbxReadPMT(strcat(newpath, '.sbx'));
ref = ref(edges(3)+1:end-edges(4),edges(1)+1:end-edges(2),1);%(chunck-1)*ch+ch/2);
xyshifts(1+(chunck-1)*ch:chunck*ch,:) = sbxAlignStackReg(strcat(newpath, '.sbx'), 1+(chunck-1)*ch, ch, ref, 'pmt', 0);
end
%%
sbxStackReg({strcat(newpath, '.sbx')}, 'edges', edges, 'refsize', 4, 'refoffset', 4);
xyshifts = load('E:\hanae_data\Microglia\registrationFiles\test\time_1\VF42_170428_483_time_1.alignxy', '-mat');
xyshifts = xyshifts.trans;
xyregmov = sbxApplyStackReg(newpath, 1, 124, xyshifts, 0);


%%
for i = 1;
    disp(i);
    path = 'E:\hanae_data\Microglia\registrationFiles\test\time_';
    mov_path = strcat(path, num2str(i), '\VF42_170428_483_time_', num2str(i), '.sbx');
    target_mov_path = strcat(path, num2str(i), '\VF42_170428_483_time_', num2str(i));
    affinetransstackreg = sbxAlignStackReg3D(target_mov_path, 'nframes', 124, 'mov_path', mov_path, 'edges', edges);
end

%%
save(strcat(newpath, '_stackreg'), 'xyshifts');
sbxWrite(strcat(strcat(path, num2str(times), '\VF42_170428_483_time_', num2str(times), '_stackreg9')), xyregmov, sbxInfo(newpath));
saveVolumeRegistration('E:\hanae_data\Microglia\registrationFiles\stackreg VF42 green volumes\time_56\', xyregmov, 'stackreg9', 'VF42', '170428', 483, 1, 'tif');
% end

%%
stackregvol = [];
path = 'E:\hanae_data\Microglia\registrationFiles\stackreg VF42 green volumes\time_';
for times = 1:200
    disp(times);
    newpath = strcat(path, num2str(times), '\VF42_170428_483_time_', num2str(times), '_stackreg.sbx');
    if times == 1
        stackregvol = sbxReadPMT(newpath);
    else
        stackregvol = cat(4, stackregvol, sbxReadPMT(newpath));
    end
end

%% 
saveVolumeRegistration(savepath, stackregvol, 'stackregvol', 'VF42', ...
'170428', 483, 10);

%% remove edges



