function affine_transforms = sbxAlignStackReg3D(target_mov_path, varargin)
%SBXALIGNTURBOREGCORE aligns a file (given by path) using ImageJ's StackReg
%   NOTE: hardcoded path to ImageJ.

    p = inputParser;
    addOptional(p, 'startframe', 1);  % The frame to start reading from if not xrun
    addOptional(p, 'nframes', 124);  % Number of frames to read if not xrun
    addOptional(p, 'mov_path', []);  % Path to an sbx movie to be read if not xrun
    addOptional(p, 'binframes', 1);  % Bin frames in time
    addOptional(p, 'binxy', 1);  % How much to bin in xy
    addOptional(p, 'pmt', 0, @isnumeric);  % REMEMBER, PMT is 0-indexed
    addOptional(p, 'edges', [0, 0, 0, 0]);  % The edges to be removed
    if length(varargin) == 1 && iscell(varargin{1}), varargin = varargin{1}; end
    parse(p, varargin{:});
    p = p.Results;

    % Hardcoded path to ImageJ
    imageJ_path = getImageJPath();
    
    data = sbxReadPMT(p.mov_path, p.startframe - 1, p.nframes, p.pmt);

    % Get the standard edge removal and bin by bin
    data = data(p.edges(3)+1:end-p.edges(4), p.edges(1)+1:end-p.edges(2), :);
    data = binxy(data, p.binxy);

    % Bin if necessary
    if p.binframes > 1, data = bint(data, p.binframes); end
    [y, x, ~] = size(data);

    % Set the correct number of frames
    if size(data, 3) ~= p.nframes
        disp(sprintf('WARNING: frame size difference of %i, %i', ...
            p.nframes, size(data, 3)));
        p.nframes = min(p.nframes, size(data, 3));
    end
    affine_transforms = cell(1, p.nframes);

    % Get the save location
    temp_dir = fileparts(target_mov_path);
    [~, temp_name, ~] = fileparts(p.mov_path);
    temp_name = sprintf('%s\\%s_%i_', temp_dir, temp_name, p.startframe);
    macro_temp_path = [temp_name 'macro.ijm'];
    output_temp_path = [temp_name 'output.txt'];
    finished_temp_path = [temp_name 'done.txt'];
    mov_temp_path = [temp_name 'temp.tiff'];

    % Delete the finishing marker if necessary
    if exist(finished_temp_path), delete(finished_temp_path); end

    % Write the tiff of the images to be registered
    writetiff(data, mov_temp_path, class(data));
  
    % Create the text for the ImageJ macro
  
    macro_text = ['setBatchMode(true); ' ...
        'fo = File.open("' output_temp_path '"); ' ...
        'open("' target_mov_path + ".tiff" '"); ' ...
        'rename("data"); '...
        'selectWindow("data"); ' ...
        'run("StackReg ", "Rigid Body"); '...
        'save("' target_mov_path + ".tiff" '"); '...
        'close(); ' ...
        'File.close(fo); ' ...
        'fp = File.open("' finished_temp_path '"); ' ...
        'print(fp, "a"); ' ...
        'File.close(fp); ' ...
        'setBatchMode(false); ' ...
        'eval("script", "System.exit(0);"); '];
  
     macro_text = strrep(macro_text, '\', '\\');
        
    % Save macro
    fo = fopen(macro_temp_path, 'wt');
    fprintf(fo, '%s', macro_text);
    fclose(fo);
    
    % Run Stackreg
    while ~exist(macro_temp_path), pause(1); end
    pause(5);
    status = system(sprintf('"%s" --headless -macro %s', ...
        imageJ_path, macro_temp_path));
    
    % Wait until the "done" file has been created and then clean up
    while ~exist(finished_temp_path), pause(1); end
    delete(macro_temp_path);
    delete(mov_temp_path);
    delete(finished_temp_path);
    
    % Read the output of the macro
%     fo = fopen(output_temp_path, 'r');
%     tform = fscanf(fo, '%f %f %f %f %f %f')';
%     fclose(fo);
%     delete(output_temp_path);
%     tform = reshape(tform, 6, size(tform, 2)/6);
%     
%     midbin = floor(p.binframes/2);
% 
%     for i = 1:length(affine_transforms)
%         affine_transforms{i*p.binframes-midbin} = affine2d([1 0 0; 0 1 0; (targets(1) - tform(1, i)) (targets(2) - tform(4, i)) 1]);
%         affine_transforms{i*p.binframes-midbin}.T(3, 1) = affine_transforms{i*p.binframes-midbin}.T(3, 1)*p.binxy;
%         affine_transforms{i*p.binframes-midbin}.T(3, 2) = affine_transforms{i*p.binframes-midbin}.T(3, 2)*p.binxy;
%     end
%     
end

