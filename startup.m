% Rohan's Startup file Matlab Megatron

addpath(genpath('D:\Analysis_scripts\Dropbox\AndermannLab\users\ramesh'));
addpath(genpath('D:\Analysis_scripts\Dropbox\AndermannLab\users\arthur'));
addpath(genpath('D:\Analysis_scripts\Dropbox\AndermannLab\users\hanae'));

% startupMA
ijroot = 'C:\Program Files (x86)\ImageJ_OLD';  % your ImageJ root directory
svnroot = 'D:\Analysis_scripts\Dropbox\AndermannLab\users\andermann\mouselab';
svncore = fullfile(svnroot,'core');
cd(svncore);
coreSetup(svnroot,ijroot,'mandermann');

% default folder
cd('D:\Analysis_scripts\Dropbox\AndermannLab\users\hanae');
clear all