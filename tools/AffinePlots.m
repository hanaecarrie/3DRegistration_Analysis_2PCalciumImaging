
%% DL68

shx = zeros(14,7440);
shy = zeros(14,7440);
scx = zeros(14,7440);
scy = zeros(14,7440);

for run = 1:3
for plane = 1:14

runplane1 = run*100 + plane;
out1 = sbxLoad('DL68','170523', runplane1, 'alignaffine');
out1 = out1.tform;
runplane2 = run*1000 + plane;
out2 = sbxLoad('DL68','170523', runplane2, 'alignaffine_alltform');
out2 = out2.tform;

for t = 1:1860
    affine1 = out1{1,t};
    affine1 = affine1.T;
    affine2 = out2{1,t};
    affine2 = affine2.T;
    scx(plane,t+(run-1)*1860) = affine1(1,1);%+affine2(1,1);
    scy(plane,t+(run-1)*1860) = affine1(2,2);%+affine2(2,2);
    shx(plane,t+(run-1)*1860) = affine1(2,1)+affine2(2,1);
    shy(plane,t+(run-1)*1860) = affine1(1,2)+affine2(1,2);    
end
end
end

%% DL89


%% DL68

shx = zeros(29,3720);
shy = zeros(29,3720);
scx = zeros(29,3720);
scy = zeros(29,3720);

for run = 1:4
for plane = 1:29

runplane1 = run*100 + plane;
out1 = sbxLoad('DL89','171122', runplane1, 'alignaffine');
out1 = out1.tform;
runplane2 = run*1000 + plane;
out2 = sbxLoad('DL89','171122', runplane2, 'alignaffine_alltform');
out2 = out2.tform;

for t = 1:930
    affine1 = out1{1,t};
    affine1 = affine1.T;
    affine2 = out2{1,t};
    affine2 = affine2.T;
    scx(plane,t+(run-1)*930) = affine1(1,1);%+affine2(1,1);
    scy(plane,t+(run-1)*930) = affine1(2,2);%+affine2(2,2);
    shx(plane,t+(run-1)*930) = affine1(2,1)+affine2(2,1);
    shy(plane,t+(run-1)*930) = affine1(1,2)+affine2(1,2);    
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


