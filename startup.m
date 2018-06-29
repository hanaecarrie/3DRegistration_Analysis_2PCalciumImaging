% STARTUP FILE

% Rohan's Startup file Matlab Megatron
addpath(genpath('D:\Analysis_scripts\Dropbox\AndermannLab\users\ramesh'));
addpath(genpath('D:\Analysis_scripts\Dropbox\AndermannLab\users\arthur'));
addpath(genpath('D:\Analysis_scripts\Dropbox\AndermannLab\users\hanae'));

% startupMA
ijroot = 'C:\Program Files (x86)\ImageJ_OLD'; % your ImageJ root directory
svnroot = ...
    'D:\Analysis_scripts\Dropbox\AndermannLab\users\andermann\mouselab';
svncore = fullfile(svnroot,'core');
cd(svncore);
coreSetup(svnroot,ijroot,'mandermann');

% default folder
cd('D:\Analysis_scripts\Dropbox\AndermannLab\users\hanae\3DRegistration_Analysis_2PCalciumImaging\');
clear all
dbstop if error;

% Set Colors
com.mathworks.services.Prefs.setBooleanPref('ColorsUseSystem',0);
com.mathworks.services.Prefs.setColorPref('ColorsBackground',java.awt.Color(0.25,0.25,0.25));
com.mathworks.services.Prefs.setColorPref('ColorsText',java.awt.Color(1,0.97,0.92));
com.mathworks.services.Prefs.setColorPref('Colors_M_Comments',java.awt.Color(0.47,0.67,0.19));
com.mathworks.services.Prefs.setColorPref('Colors_M_Keywords',java.awt.Color(0.8,0.88,0.97));
com.mathworks.services.Prefs.setColorPref('Colors_M_Strings',java.awt.Color(1,0.6,0.78));
com.mathworks.services.Prefs.setColorPref('Colors_M_Warnings',java.awt.Color(255/255,140/255,0/255));
com.mathworks.services.Prefs.setColorPref('Colors_M_Errors',java.awt.Color(178/255,34/255,34/255));
% com.mathworks.services.Prefs.setColorPref('ColorsMLintAutoFixBackground', j(colors.autofix_highlight));
