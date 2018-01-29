%% Plot running state VS ZShifts

clear all;
close all;
clc;

addpath(genpath('D:\Analysis_scripts\Dropbox\AndermannLab\users\arthur'));
startup;

% Choose datafile
mouse = 'DL68'; 
date = '170523';
nbrun = 3;

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
%zshift = smooth(zshift);
%fftzshift = fft(zshift);
%fftzshift(abs(fftzshift)<22)=0;
%zshift = abs(ifft(fftzshift));
%windowWidth = 51;
%polynomialOrder = 5;
%zshift = sgolayfilt(zshift, polynomialOrder, windowWidth);
%Fs = 30;
%zshift = zshift - zshift(1);
%[z,p,k] = besself(10,0.6);          % Bessel analog filter design
%[zd,pd,kd] = bilinear(z,p,k,Fs); 
%[num,deno] = zp2tf(z,p,k); 
%zshift = filter(num, deno, zshift);
%zshift = smoothdata(zshift, 'gaussian', 10);
%zshift = smooth(abs(B));
%zshift = sgolayfilt(zshift, 5, 31);
%zshift = smooth(smooth(smooth(ZShifts)));
[envHigh, envLow] = envelope(zshift,2,'peak');
envMean = (envHigh+envLow)/2;
envMean = smooth(envMean);

 newampl = ZShifts-mean(ZShifts);
 [envHigh2, envLow2] = envelope(newampl,2,'peak');
 envMean2 = (envHigh2+envLow2)/2;
 for i =1:1860
     if (envHigh2(i)-envLow2(i))<0.4
         flatz = flatz + 
         newampl(i) = newampl(i-1);
     end
 end

figure;
yyaxis left; plot(x, run);
xlabel('time (min)'); ylabel('arbitrary unit'); axis([1 30 -2 18]);
yyaxis right; plot(x, newampl)%, x, (ZShifts-mean(ZShifts)), 'k');
ylabel('Z level index (no unit)'); axis([1 30 -1.2 1.2]);
graphtitle = strcat('mouse:', mouse, ', date:', date,...
    ', run:', num2str(nbrun));
title(graphtitle);
legend('running state', 'Z shift');

%% Save comparison videos

clear all;
savingpathunreg = 'E:\hanae_data\alextry2\mouseDL68_date170523_run4\noregistration\';

    for i = 1:14
        
        title_z1 = strcat(savingpathunreg, 'zlevel', num2str(i),...
            '_1860volumes_11PPR_5PFC_BF3_KF0_35_RVI1_1.mat');
        title_z2 = strcat(savingpathunreg, 'zlevel', num2str(i),...
            '_1860volumes_11PPR_5PFC_BF3_KF0_35_RVI1_2.mat');
        title_z3 = strcat(savingpathunreg, 'zlevel', num2str(i),...
            '_1860volumes_11PPR_5PFC_BF3_KF0_35_RVI1_3.mat');
        title_z4 = strcat(savingpathunreg, 'zlevel', num2str(i),...
            '_1860volumes_11PPR_5PFC_BF3_KF0_35_RVI1_4.mat');
        load(title_z1); load(title_z2); load(title_z3); load(title_z4);
        seq = cat(3, seq_1, seq_2, seq_3, seq_4);
        seqblur = imgaussfilt(seq, 0.75);
        %seqblur = mat2gray(double(seqblur(:,:,:)));
        
        title = strcat(savingpathunreg, 'zlevel', num2str(i),...
            '_1860volumes_11PPR_5PFC_BF3_KF035_RVI1_blur.avi');
        WriteVideo(title, seqblur);  
      
    end

