%% Plot running state VS ZShifts

clear all;
close all;
clc;

addpath(genpath('D:\Analysis_scripts\Dropbox\AndermannLab\users\arthur'));
startup;

% Choose datafile
mouse = 'DL68'; 
date = '170523';
nbrun = 1;

% See running state of the mouse
running = sbxSpeed(mouse, date, nbrun);

n = 15; % average every n values
a = reshape(running,[],1); % arbitrary data
avgrun = arrayfun(@(i) mean(a(i:i+n-1)),1:n:length(a)-n+1)';
%avgrun = running(1:15:end);
% the averaged vector

%%
% load zshift
pathzshift = strcat('E:\hanae_data\alextry2\mouse', mouse, '_date',...
    date, '_run', num2str(nbrun), '\Alexregistration\ZShifts.mat');
load(pathzshift);

x = linspace(1, 1800, 1860);
x = x/60;
run = abs(avgrun);
zshift = (ZShifts)-mean(ZShifts);
zshift = wden(zshift,'modwtsqtwolog','s','mln',4,'sym4');
%zshift(840:1140) = smooth(zshift(840:1140));
%zshift = smooth(zshift);
% N = length(zshift);
% fftzshift = fft(zshift);
% xdft = fftzshift/sqrt(N);
% figure; plot(zshift); axis([0 2000 -0.8 1.2]);
% xdft(abs(xdft)<0.35)=0;
% figure; plot(abs(fftshift(xdft)));
% zshift = smooth((sqrt(N)*ifft((xdft))));
% figure; plot(zshift); axis([0 2000 -0.8 1.2]);
% windowWidth = 27;
% polynomialOrder = 5;
%zshift = smooth(zshift, 'gaussian', 10);
%zshift = sgolayfilt(zshift, polynomialOrder, windowWidth);
% Fs = 10;
% %zshift = zshift - zshift(1);
% [z,p,k] = besself(10,0.7);          % Bessel analog filter design
% [zd,pd,kd] = bilinear(z,p,k,Fs); 
% [num,deno] = zp2tf(z,p,k); 
% zshift = filter(num, deno, zshift);
%zshift = smoothdata(zshift, 'gaussian', 10);
%zshift = smooth(abs(B));
%zshift = sgolayfilt(zshift, 5, 31);
%zshift = smooth(smooth(smooth(ZShifts)));
%[envHigh, envLow] = envelope(zshift,2,'peak');
%envMean = (envHigh+envLow)/2;
%envMean = (envMean);
%zshift = envMean;

%  newampl = ZShifts-mean(ZShifts);
%  [envHigh2, envLow2] = envelope(newampl,2,'peak');
%  envMean2 = (envHigh2+envLow2)/2;
%  for i =1:1860
%      if (envHigh2(i)-envLow2(i))<0.4
%          flatz = flatz + 
%          newampl(i) = newampl(i-1);
%      end
%  end

figure;
yyaxis left; plot(x, run);
xlabel('time (min)'); ylabel('arbitrary unit'); axis([1 30 -2 18]);
yyaxis right; plot(x, zshift);
ylabel('Z level index (no unit)'); axis([1 30 -1.2 1.2]);
graphtitle = strcat('mouse:', mouse, ', date:', date,...
    ', run:', num2str(nbrun));
title(graphtitle);
legend('running state', 'Z shift');

