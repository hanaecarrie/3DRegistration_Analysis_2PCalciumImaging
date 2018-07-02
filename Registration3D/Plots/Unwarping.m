%%  Script unwarping shifts analysis

clear all;
clc;

%% load data

pathRWred = 'E:\hanae_data\Microglia\regdata\VF42_FOV2\VF42_170428_248_red\VF42_170428_248_1\ShiftsRow\RowShiftsW';
pathCWred = 'E:\hanae_data\Microglia\regdata\VF42_FOV2\VF42_170428_248_red\VF42_170428_248_1\ShiftsColumn\ColumnShiftsW';
pathRWgreen = 'E:\hanae_data\Microglia\regdata\VF42_FOV2\VF42_170428_248\VF42_170428_483_0\ShiftsRow\RowShiftsW';
pathCWgreen = 'E:\hanae_data\Microglia\regdata\VF42_FOV2\VF42_170428_248\VF42_170428_483_0\ShiftsColumn\ColumnShiftsW';
RWred = load(pathRWred);
RWred = RWred.RowShiftsW;
CWred = load(pathCWred);
CWred = CWred.ColumnShiftsW;
RWgreen = load(pathRWgreen);
RWgreen = RWgreen.RowShiftsW;
CWgreen = load(pathCWgreen);
CWgreen = CWgreen.ColumnShiftsW;
pathfitR = 'E:\hanae_data\Microglia\calibration\Rfit';
pathfitC = 'E:\hanae_data\Microglia\calibration\Cfit';
Rfit = load(pathfitR);
Rfit = Rfit.fit1;
Cfit = load(pathfitC);
Cfit = Cfit.fit2;
pathFredC = 'E:\hanae_data\Microglia\registrationFiles\Fred\11-Jun-2018_13-49-44\VF42_170428_248\rightcolumns';
pathFredR = 'E:\hanae_data\Microglia\registrationFiles\Fred\11-Jun-2018_13-49-44\VF42_170428_248\bottomlines';
rightcolumns = load(pathFredC);
rightcolumns = rightcolumns.rightcolumns;
bottomlines = load(pathFredR);
bottomlines = bottomlines.bottomlines;

%% set colors

red = [0.8500 0.3300 0.1000];
green = [0.4700 0.6700 0.1900];

%% columns

CWgreen(CWgreen >0) = 0;
CWred(CWred >0) = 0;

h = figure;
minenv = min(CWgreen); maxenv = max(CWgreen);
CWgreenmean = mean(CWgreen, 1);
x = 1:124; 
h(1) = plot(x, CWgreenmean, 'Color', green, 'Linewidth', 1.5);
hold on;
x = [x,fliplr(x)];        % repeat x values
yy = [minenv, fliplr(maxenv)];   % vector of upper & lower boundaries
h(2) = fill(x,yy, green, 'LineStyle','none');
% fill area defined by x & yy in blue
alpha(h(2), 0.5);
axis([1 124 -110 0]);


minenv = min(CWred); maxenv = max(CWred);
CWredmean = mean(CWred, 1);
x = 1:124; 
h(3) = plot(x, CWredmean,  'Color', red, 'Linewidth', 1.5);  
x = [x,fliplr(x)];        % repeat x values
yy = [minenv, fliplr(maxenv)];   % vector of upper & lower boundaries
h(4) = fill(x,yy, red,'LineStyle','none');
% fill area defined by x & yy in blue
alpha(h(4), 0.3);
axis([1 124 -110 0]);

path = sbxPath('VF42', '170428', 248, 'sbx');
info = sbxInfo(path);
minopt = info.otparam(1); maxopt = info.otparam(2);
xopt = linspace(minopt, maxopt, 124);
polynome = polyval(Cfit.coeff, xopt);
h(5) = plot(xopt*124/(maxopt-minopt), polynome, 'b', 'Linewidth', 1.5);
axis([1 124 -110 0]);

meanFred = mean(rightcolumns(2:end,1:end),1);
meanFred = meanFred + abs(min(abs(meanFred)));
meanFred(meanFred>0) =0;
meanFred(1:3) = 0;
h(6) = plot(meanFred, 'k', 'Linewidth', 1.5);
axis([1 124 -110 0]);

legend('mean shifts green channel', 'green min-max envolope',...
    'mean shifts red channel', 'red min-max envelope', 'Calibration',... 
    'mean shifts with affine', 'Location', 'southwest');
xlabel('plane number from down to top (no unit)');
ylabel('pixel shift (no unit)');

title('Column Shifts across planes');
view([90 -90]);


%% columns per method

% 1A
h1A = figure;
minenv = min(CWgreen); maxenv = max(CWgreen);
CWgreenmean = mean(CWgreen, 1);
x = 1:124; 
h1A(1) = plot(x, CWgreenmean, 'Color', green, 'Linewidth', 1.5);
hold on;
x = [x,fliplr(x)];        % repeat x values
yy = [minenv, fliplr(maxenv)];   % vector of upper & lower boundaries
h1A(2) = fill(x,yy, green, 'LineStyle','none');    % fill area defined by x & yy in blue
alpha(h1A(2), 0.5);
axis([1 124 -110 0]);

legend('method 1A', 'envelope 1A');
xlabel('plane number from down to top (no unit)');
ylabel('pixel shift (no unit)');

title('Column Shifts across planes');
view([90 -90]);

% 1B
h1B = figure;
minenv = min(CWred); maxenv = max(CWred);
CWredmean = mean(CWred, 1);
x = 1:124; 
h1B(1) = plot(x, CWredmean,  'Color', red, 'Linewidth', 1.5);  
hold on;
x = [x,fliplr(x)];        % repeat x values
yy = [minenv, fliplr(maxenv)];   % vector of upper & lower boundaries
h1B(2) = fill(x,yy, red,'LineStyle','none');    % fill area defined by x & yy in blue
alpha(h1B(2), 0.3);
axis([1 124 -110 0]);
legend('method 1B', 'envelope 1B');
xlabel('plane number from down to top (no unit)');
ylabel('pixel shift (no unit)');
title('Column Shifts across planes');
view([90 -90]);

% 3

h3 = figure;
path = sbxPath('VF42', '170428', 248, 'sbx');
info = sbxInfo(path);
minopt = info.otparam(1); maxopt = info.otparam(2);
xopt = linspace(minopt, maxopt, 124);
polynome = polyval(Cfit.coeff, xopt);
h3(1) = plot(xopt*124/(maxopt-minopt), polynome, 'b', 'Linewidth', 1.5);
axis([1 124 -110 0]);
legend('method 3');
xlabel('plane number from down to top (no unit)');
ylabel('pixel shift (no unit)');
title('Column Shifts across planes');
view([90 -90]);

% 2

h2 = figure;
meanFred = mean(rightcolumns(2:end,1:end),1);
meanFred = meanFred + abs(min(abs(meanFred)));
meanFred(meanFred>0) =0;
meanFred(1:3) = 0;
h2(1) = plot(meanFred, 'k', 'Linewidth', 1.5);
axis([1 124 -110 0]);
legend('method 2');
xlabel('plane number from down to top (no unit)');
ylabel('pixel shift (no unit)');
title('Column Shifts across planes');
view([90 -90]);


%% row 

RWgreen(RWgreen >0) = 0;
RWred(RWred >0) = 0;

f = figure;
minenv = min(RWgreen); maxenv = max(RWgreen);
RWgreenmean = mean(RWgreen, 1);
x = 1:124; 
f(1) = plot(x, RWgreenmean, 'Color', green, 'Linewidth', 1.5);
hold on;
x = [x,fliplr(x)];        % repeat x values
yy = [minenv, fliplr(maxenv)];   % vector of upper & lower boundaries
f(2) = fill(x,yy, green, 'LineStyle','none');    % fill area defined by x & yy in blue
alpha(f(2), 0.5);
axis([1 124 -120 0]);

minenv = min(RWred); maxenv = max(RWred);
RWredmean = mean(RWred, 1);
x = 1:124; 
f(3) = plot(x, RWredmean,  'Color', red, 'Linewidth', 1.5);  
x = [x,fliplr(x)];        % repeat x values
yy = [minenv, fliplr(maxenv)];   % vector of upper & lower boundaries
f(4) = fill(x,yy, red,'LineStyle','none');    % fill area defined by x & yy in blue
alpha(f(4), 0.3);
axis([1 124 -120 0]);

path = sbxPath('VF42', '170428', 248, 'sbx');
info = sbxInfo(path);
minopt = info.otparam(1); maxopt = info.otparam(2);
xopt = linspace(minopt, maxopt, 124);
x = 1:124; 
polynome = polyval(Rfit.coeff, xopt);
f(5) = plot(xopt*124/(maxopt-minopt), polynome, 'b', 'Linewidth', 1.5);
axis([1 124 -120 0]);

meanFred2 = nanmean(bottomlines(2:end,1:end),1);
meanFred2(1) = 0; 
meanFred2 = meanFred2 + abs(min(abs(meanFred2(2:end))));
f(6) = plot(meanFred2, 'k', 'Linewidth', 1.5);
axis([1 124 -130 0]);

legend('mean shifts green channel', 'green min-max envolope',...
    'mean shifts red channel', 'red min-max envelope', 'Calibration',...
    'mean shifts with affine',...
    'Location', 'southwest');
xlabel('plane number from down to top (no unit)');
ylabel('pixel shift (no unit)');

title('Row Shifts across planes');
view([90 -90]);


%% row per method

% 1A
f1A = figure;
minenv = min(RWgreen); maxenv = max(RWgreen);
RWgreenmean = mean(RWgreen, 1);
x = 1:124; 
f1A(1) = plot(x, RWgreenmean, 'Color', green, 'Linewidth', 1.5);
hold on;
x = [x,fliplr(x)];        % repeat x values
yy = [minenv, fliplr(maxenv)];   % vector of upper & lower boundaries
f1A(2) = fill(x,yy, green, 'LineStyle','none');    % fill area defined by x & yy in blue
alpha(f1A(2), 0.5);
axis([1 124 -110 0]);

legend('method 1A', 'envelope 1A');
xlabel('plane number from down to top (no unit)');
ylabel('pixel shift (no unit)');

title('Row Shifts across planes');
view([90 -90]);

% 1B
f1B = figure;
minenv = min(RWred); maxenv = max(RWred);
RWredmean = mean(RWred, 1);
x = 1:124; 
f1B(1) = plot(x, RWredmean,  'Color', red, 'Linewidth', 1.5);  
hold on;
x = [x,fliplr(x)];        % repeat x values
yy = [minenv, fliplr(maxenv)];   % vector of upper & lower boundaries
f1B(2) = fill(x,yy, red,'LineStyle','none');    % fill area defined by x & yy in blue
alpha(f1B(2), 0.3);
axis([1 124 -110 0]);
legend('method 1B', 'envelope 1B');
xlabel('plane number from down to top (no unit)');
ylabel('pixel shift (no unit)');
title('Row Shifts across planes');
view([90 -90]);

% 3

f3 = figure;
path = sbxPath('VF42', '170428', 248, 'sbx');
info = sbxInfo(path);
minopt = info.otparam(1); maxopt = info.otparam(2);
xopt = linspace(minopt, maxopt, 124);
polynome = polyval(Rfit.coeff, xopt);
f3(1) = plot(xopt*124/(maxopt-minopt), polynome, 'b', 'Linewidth', 1.5);
axis([1 124 -110 0]);
legend('method 3');
xlabel('plane number from down to top (no unit)');
ylabel('pixel shift (no unit)');
title('Row Shifts across planes');
view([90 -90]);

% 2

f2 = figure;
meanFred = mean(bottomlines(2:end,1:end),1);
meanFred = meanFred + abs(min(abs(meanFred)));
meanFred(meanFred>0) =0;
meanFred(1:3) = 0;
f2(1) = plot(meanFred, 'k', 'Linewidth', 1.5);
axis([1 124 -110 0]);
legend('method 2');
xlabel('plane number from down to top (no unit)');
ylabel('pixel shift (no unit)');
title('Row Shifts across planes');
view([90 -90]);

%% Across time Columns

CWbin = zeros(20,124);
for i = 1:20
    CWbin(i,:) = mean(CWgreen((i-1)*10+1:i*10,:));
end
CWbin(CWbin>0) = 0;
g = figure;
N = 20;
C = repmat(linspace(1,0.1,N).',1,3);
C = linspecer(N);
axes('ColorOrder',C,'NextPlot','replacechildren')
x = 1:124; 
plot(x, CWbin(1:end,1:end));
axis([1 100 -40 0]);
legend('00:00-01:20', '01:20-02:40', '02:40-04:00', '04:00-05:20', ...
    '05:20-06:40', '06:40-08:00','08:00-09:20','09:20-10:40',...
    '10:40-12:00','12:00-13:20','13:20-14:40','14:40-16:00',...
    '16:00-17:20','17:20-18:40','18:40-20:00','20:00-21:20',...
    '21:20-22:40','22:40-24:00','24:00-25:20','25:20-26:40');
%ylabel('number of cropped pixels');
xlabel('plane number');
title('mouseVF42 date170428 run248 - unwarping across time - X');
view([90 -90]);

%% Across time Rows

RWbin = zeros(20,124);
for i = 1:20
    RWbin(i,:) = mean(RWgreen((i-1)*10+1:i*10,:));
end
RWbin(RWbin>0) = 0;
h = figure;
N = 20;
C = repmat(linspace(1,0.1,N).',1,3);
C = linspecer(N);
axes('ColorOrder',C,'NextPlot','replacechildren')
x = 1:124; 
plot(x, RWbin(1:end,1:end));
axis([1 124 -90 0]);
legend('00:00-01:20', '01:20-02:40', '02:40-04:00', '04:00-05:20', ...
    '05:20-06:40', '06:40-08:00','08:00-09:20','09:20-10:40',...
    '10:40-12:00','12:00-13:20','13:20-14:40','14:40-16:00',...
    '16:00-17:20','17:20-18:40','18:40-20:00','20:00-21:20',...
    '21:20-22:40','22:40-24:00','24:00-25:20','25:20-26:40');
xlabel('plane number');
title('mouseVF42 date170428 run248 - unwarping across time - Y');
view([90 -90]);


