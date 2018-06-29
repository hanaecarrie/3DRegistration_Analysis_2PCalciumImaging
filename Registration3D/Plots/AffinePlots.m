
%% DL68

zp = 15;
runs = 30002;
tt = 60;
m1 = 100;


shx = zeros(zp,tt);
shy = zeros(zp,tt);
scx = zeros(zp,tt);
scy = zeros(zp,tt);

for run = runs
for plane = 1:zp

runplane1 = run*m1 + plane;
out1 = sbxLoad('DL68','170523', runplane1, 'alignaffine');
out1 = out1.tform;
% runplane2 = run*1000 + plane;
% out2 = sbxLoad('DL68','170523', runplane2, 'alignaffine_alltform');
% out2 = out2.tform;

for t = 1:tt
    affine1 = out1{1,t};
    affine1 = affine1.T;
%     affine2 = out2{1,t};
%     affine2 = affine2.T;
    scx(plane,t) = affine1(1,1);%+affine2(1,1);
    scy(plane,t) = affine1(2,2);%+affine2(2,2);
    shx(plane,t) = affine1(2,1);%+affine2(2,1);
    shy(plane,t) = affine1(1,2);%+affine2(1,2);    
end
end
end

%% DL89

%% DL89

zp = 30;
runs = 1:6;
tt = 930;
m1 = 100;

shx1 = zeros(zp,tt,6);
shy1 = zeros(zp,tt,6);
scx1 = zeros(zp,tt,6);
scy1 = zeros(zp,tt,6);
shx2 = zeros(zp,tt,6);
shy2 = zeros(zp,tt,6);
scx2 = zeros(zp,tt,6);
scy2 = zeros(zp,tt,6);

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

%%
scy2 = reshape(scy2, [30, 6*930]);
scy1 = reshape(scy1, [30, 6*930]);
scx2 = reshape(scx2, [30, 6*930]);
scx1 = reshape(scx1, [30, 6*930]);
shx2 = reshape(shx2, [30, 6*930]);
shy1 = reshape(shy1, [30, 6*930]);
shy2 = reshape(shy2, [30, 6*930]);
shx1 = reshape(shx1, [30, 6*930]);
shx = shx1 + shx2;
shy = shy1 + shy2;
scx = scx1 .* scx2;
scy = scy1 .* scy2;

%%
imagesc(shy); colorbar; caxis([-0.01 0.01]);%caxis([0.95 1.05]);

%% DL68

shx = zeros(124,200);
shy = zeros(124,200);
scx = zeros(124,200);
scy = zeros(124,200);

pathbegin = 'E:\hanae_data\Microglia\registrationFiles\25-Apr-2018_07-51-16\affineplanes\170428_VF42_run';
    

for run = 483
for plane = 1:124

runplane1 = run*100 + plane;
% out1 = sbxLoad('DL89','171122', runplane1, 'alignaffine');
% out1 = out1.tform;
% runplane2 = run*1000 + plane;
% out2 = sbxLoad('DL89','171122', runplane2, 'alignaffine_alltform');
% out2 = out2.tform;
out3 = load(strcat(pathbegin, num2str(runplane1),  '\VF42_170428_', ...
    num2str(runplane1-1), '.alignaffine'), '-mat');
out3 = out3.tform;

for t = 1:200
%     affine1 = out1{1,t};
%     affine1 = affine1.T;
%     affine2 = out2{1,t};
%     affine2 = affine2.T;
    affine3 = out3{1,t};
    affine3 = affine3.T;
%     scx(plane,t+(run-1)*200) = affine3(1,1);%+affine2(1,1);
%     scy(plane,t+(run-1)*200) = affine3(2,2);%+affine2(2,2);
%     shx(plane,t+(run-1)*200) = affine3(2,1); %+affine2(2,1);
%     shy(plane,t+(run-1)*200) = affine3(1,2); %+affine2(1,2);    
    scx(plane,t) = affine3(1,1);%+affine2(1,1);
    scy(plane,t) = affine3(2,2);%+affine2(2,2);
    shx(plane,t) = affine3(2,1); %+affine2(2,1);
    shy(plane,t) = affine3(1,2); %+affine2(1,2);    

end
end
end

%%

mouse = 'DL89';
date = '171122';

Running = [];
for run = 1:4;
% See running state of the mouse
running = sbxSpeed(mouse, date, run);
n = 30; % average every n values
a = reshape(running,[],1); % arbitrary data
avgrun = arrayfun(@(i) mean(a(i:i+n-1)),1:n:length(a)-n+1)';
Running = cat(1,Running, avgrun);
end


