% script get zeros edges
z = 124; % t = 200;
t = 200;
h = 512; w = 796;

rightcolumns = w*ones(t,z);
bottomlines = h*ones(t,z);

path = '\\Megatron\e\hanae_data\Microglia\registrationFiles\11-Jun-2018_13-49-44\VF42_170428_248\VF42_170428_248_1\datareg_0\VF42_170428_248_0_datareg_0.sbx';
    vol = sbxReadPMT(path);
    vol = reshape(vol, [512, 796, 124, 200]);
%%

for frame = 1:200
    disp(frame);
    
    for i = 1:124 % 1:200
    %     path = 'E:\hanae_data\Microglia\registrationFiles\stackregVF42greenvolumes\time_';
    %     newpath = strcat(path, num2str(i), '\VF42_170428_483_time_', num2str(i), '.tif');
    %     lastslice = imread(newpath, z);
        slice = vol(:,:,i,frame);
        
        A = mat2gray(sum(abs(slice')));
        [IA,JA] = find(A(1,100:end)<0.2);
        if ~isempty(JA)
        bottomlines(frame,i) = JA(1);
        else
            bottomlines(frame,i) = 512;
        end
        
        B = mat2gray(sum(abs(slice)));
        [IB,JB] = find(B(1,100:end)<0.2);
        if ~isempty(JB)
        rightcolumns(frame,i) = JB(1);
        else
            rightcolumns(frame,i) = 796;
        end
%         
%         while sum(abs(slice(:,rightcolumns(frame,i)))) < 100
%             rightcolumns(frame,i) = rightcolumns(frame,i) - 1;
%         end
%         disp(rightcolumns(frame,i));
% 
%         while sum(abs(slice(bottomlines(frame,i),:))) < 100
%             bottomlines(frame,i) = bottomlines(frame,i) - 1;
%         end
%          disp(bottomlines(frame,i));
    end
end

%%

mask = slicetest > 300; % Mask is bright stuff.
% Fill in the body
mask = imfill(mask, 'holes'); % Mask is whole solid body.
% OR it in with the zeros
mask = mask | (slicetest == 0); % Mask now includes pure zeros.
% Extract pixels that are not masked
darkNonZeroOutsidePixels = slicetest(~mask);

%%
volume = zeros(512, 796, 200, 124);
for i = 1:200
    disp(i);
    
    path = 'E:\hanae_data\Microglia\registrationFiles\stackregVF42greenvolumes\time_';
    newpath = strcat(path, num2str(i), '\VF42_170428_483_time_', num2str(i), '.tif');
    for j = 1:124
    volume(:,:,i,j) = imread(newpath, j);
    end
end

volume = permute(volume, [1,2,4,3]);
volume = volume(10:400,40:700,:,:);
saveVolumeRegistration('E:\hanae_data\Microglia\registrationFiles\stackregVF42greenvolumes\',...
    volume,'volumecrop','VF42','170428',483,10);


%%

height = zeros(1, 200);
width = zeros(1, 200);
