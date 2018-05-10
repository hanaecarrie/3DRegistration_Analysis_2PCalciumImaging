
% affine from channel green
affine = cell(1,200);
for i = 1:124
pathgreen = strcat('E:\hanae_data\Microglia\registrationFiles\25-Apr-2018_07-51-16_greenchannel\affineplanes\170428_VF42_run', num2str(48300+i), '\VF42_170428_', num2str(48300+i-1),'.alignaffine') ;
aafine = load(pathgreen, '-mat');
if i == 1
affine = aafine.tform;
else
affine = cat(1, affine, aafine.tform);
end
end

%%

volumereg3 = sbxReadPMT('VF42_170428_483_volumereg3red.sbx');
volumereg3 = reshape(volumereg3, [512, 796, 124, 200]);
info = sbxInfo('VF42_170428_483_volumereg3red.sbx');
saveSBXfilesPerPlane('VF42_170428_483_volumereg3red.sbx', 'VF42', '170428', 483, volumereg3, 100, ...
    'E:\hanae_data\Microglia\registrationFiles\25-Apr-2018_07-51-16_redchannel\affineplanes\');

%%
voltrans = zeros(512, 796, 124, 200);
voltrans = uint16(voltrans);

openParallel();
parfor i = 1:124
    disp(i)
    path = strcat('E:\hanae_data\Microglia\registrationFiles\25-Apr-2018_07-51-16_redchannel\affineplanes\170428_VF42_run', num2str(48300+i), '\VF42_170428_', num2str(48300+i-1),'.sbx') ;
    transplane = sbxReadPMT(path);
    for t = 1:200
        transplane(:,:,t) = imwarp(transplane(:,:,t), affine{i,t},...
            'OutputView', imref2d(size(transplane(:, :, t))));
            voltrans(:,:,i,t) = transplane(:,:,t);
    end
    sbxWrite(strcat('E:\hanae_data\Microglia\registrationFiles\25-Apr-2018_07-51-16_redchannel\affineplanes\170428_VF42_run', num2str(48300+i), '\VF42_170428_', num2str(48300+i-1),'_regbis.sbx'), transplane, sbxInfo(path));
end

%%

for i = 1:124
    pathplane = strcat('E:\hanae_data\Microglia\registrationFiles\25-Apr-2018_07-51-16_redchannel\affineplanes\170428_VF42_run', num2str(48300+i), '\');
    saveVolumeRegistration(pathplane, squeeze(voltrans(:,:,i,:)), 'planebis', ...
        'VF42', '170428', 483, 1, 'tif');
end

%%

newvolumeregaffine = zeros(512, 796, 200, 124);
newvolumeregaffine = uint16(newvolumeregaffine);

for i = 1:124
    pathplane = strcat('E:\hanae_data\Microglia\registrationFiles\25-Apr-2018_07-51-16_redchannel\affineplanes\170428_VF42_run', num2str(48300+i), '\VF42_170428_', num2str(48300+i-1),'_reg.sbx');
    plane = sbxReadPMT(pathplane);
    newvolumeregaffine(:,:,:,i) = plane;
end
newvolumeregaffine = permute(newvolumeregaffine, [1,2,4,3]);



