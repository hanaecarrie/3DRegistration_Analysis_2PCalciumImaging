% script get zeros edges
z = 124; % t = 200;
t = 200;
h = 512; w = 796;

rightcolumns = w*ones(t,z);
bottomlines = h*ones(t,z);

for frame = 1:200
    disp(frame);
    path = 'E:\hanae_data\Microglia\registrationFiles\stackregVF42greenvolumes\time_';
    newpath = strcat(path, num2str(i), '\VF42_170428_483_time_', num2str(i), '.tif');

    for i = 1:124 % 1:200
    %     path = 'E:\hanae_data\Microglia\registrationFiles\stackregVF42greenvolumes\time_';
    %     newpath = strcat(path, num2str(i), '\VF42_170428_483_time_', num2str(i), '.tif');
    %     lastslice = imread(newpath, z);
        slice = imread(newpath,i);

        while sum(abs(slice(:,rightcolumns(frame,i)))) == 0
            rightcolumns(frame,i) = rightcolumns(frame,i) - 1;
        end
    %     disp(rightcolumns(1,i));

        while sum(abs(slice(bottomlines(frame,i),:))) == 0
            bottomlines(frame,i) = bottomlines(frame,i) - 1;
        end
    %     disp(bottomlines(1,i));
    end
end

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
