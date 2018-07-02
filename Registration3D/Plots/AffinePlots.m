%% Script plot affine shifts for DL89
% On Megatron server

% Parameters
zp = 30;
runs = 1:6;
tt = 930;
m1 = 100;

% Initialize shear and scale matrix
shx1 = zeros(zp,tt,6);
shy1 = zeros(zp,tt,6);
scx1 = zeros(zp,tt,6);
scy1 = zeros(zp,tt,6);
shx2 = zeros(zp,tt,6);
shy2 = zeros(zp,tt,6);
scx2 = zeros(zp,tt,6);
scy2 = zeros(zp,tt,6);

% Read shifts in .alignaffine files
for run = runs
for plane = 1:zp

runplane1 = run*m1 + plane;
if exist(sbxPath('DL89','171122', runplane1, 'alignaffine'),'file')
    out1 = sbxLoad('DL89','171122', runplane1, 'alignaffine');
    out1 = out1.tform;
    for t = 1:tt
    affine1 = out1{1,t};
    affine1 = affine1.T;
    scx1(plane,t,run) = affine1(1,1);
    scy1(plane,t,run) = affine1(2,2);
    shx1(plane,t,run) = affine1(2,1);
    shy1(plane,t,run) = affine1(1,2);
    end
else
    scx1(plane,:,run) = 1;
    scy1(plane,:,run) = 1;
    shx1(plane,:,run) = 0;
    shy1(plane,:,run) = 0;
end

runplane2 = run*100 + plane;
if exist(sbxPath('DL89','171122', runplane2, 'alignaffine_alltform'),'file')
    out2 = sbxLoad('DL89','171122', runplane2, 'alignaffine_alltform');
    out2 = out2.tform;
    for t = 1:tt
    affine2 = out2{1,t};
    affine2 = affine2.T;
    scx2(plane,t,run) = affine2(1,1);
    scy2(plane,t,run) = affine2(2,2);
    shx2(plane,t,run) = affine2(2,1);
    shy2(plane,t,run) = affine2(1,2);  
    end
else
    scx2(plane,:,run) = 1;
    scy2(plane,:,run) = 1;
    shx2(plane,:,run) = 0;
    shy2(plane,:,run) = 0;
end

end
end

% Reshape matrix into the right 2d format
scy2 = reshape(scy2, [30, 6*930]);
scy1 = reshape(scy1, [30, 6*930]);
scx2 = reshape(scx2, [30, 6*930]);
scx1 = reshape(scx1, [30, 6*930]);
shx2 = reshape(shx2, [30, 6*930]);
shy1 = reshape(shy1, [30, 6*930]);
shy2 = reshape(shy2, [30, 6*930]);
shx1 = reshape(shx1, [30, 6*930]);

% Add shifts (linear algrebra property)
shx = shx1 + shx2;
shy = shy1 + shy2;
scx = scx1 .* scx2;
scy = scy1 .* scy2;

% plot heatmaps for shear and scale in x and y
figure; imagesc(shy); colorbar; caxis([-0.01 0.01]);
figure; imagesc(shx); colorbar; caxis([-0.01 0.01]);
figure; imagesc(scx); colorbar; caxis([0.975 1.025]);
figure; imagesc(scy); colorbar; caxis([0.975 1.025]);


