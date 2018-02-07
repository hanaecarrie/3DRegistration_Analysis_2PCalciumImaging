%% Save comparison videos

clear all;
savingpathunreg = ...
    'E:\hanae_data\alextry2\mouseDL89_date171122_run1\noregistration\';

    for i = 1:29
        
        title_z1 = strcat(savingpathunreg, 'zlevel', num2str(i),...
            '_930volumes_BF1_KF095_RVI1_1.mat');
        title_z2 = strcat(savingpathunreg, 'zlevel', num2str(i),...
            '_930volumes_BF1_KF095_RVI1_2.mat');
%         title_z3 = strcat(savingpathunreg, 'zlevel', num2str(i),...
%             '_1860volumes_11PPR_5PFC_BF3_KF0_35_RVI1_3.mat');
%         title_z4 = strcat(savingpathunreg, 'zlevel', num2str(i),...
%             '_1860volumes_11PPR_5PFC_BF3_KF0_35_RVI1_4.mat');
        load(title_z1); load(title_z2);% load(title_z3); load(title_z4);
        seq = cat(3, seq_1, seq_2);%, seq_3, seq_4);
        seqblur = imgaussfilt(seq, 0.75);
        %seqblur = mat2gray(double(seqblur(:,:,:)));
        
        title = strcat(savingpathunreg, 'zlevel', num2str(i),...
            '_930volumes_BF1_KF095_RVI1_blur.avi');
        WriteVideo(title, seqblur);  
      
    end
