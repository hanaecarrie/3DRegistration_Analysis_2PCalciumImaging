function sbxPreprocessMicroglia(mouse, date, varargin)
%SBXPREPROCESS A pipeline function to:
%   1. Align multiple runs to the first chunk of a single run
%   2. PCA Clean, optionally
%   3. Save aligned SBX
%   4. Load in a movie of all of runs and segment using either PCA/ICA or
%       nonnegative matrix factorization
%   5. Save the output for cell-clicking via the online cell clicker
%   6. Save reference TIFFs

    p = inputParser;
    % ---------------------------------------------------------------------
    % Most important variables
    addOptional(p, 'target', []);  % Target run to align to, default runs(1)
    addOptional(p, 'job', false);  % Set to true if run as a batch, blocks user interaction
    addOptional(p, 'pupil', true);  % Extract pupil diameter if possible
    addOptional(p, 'runs', []);  % Defaults to sbxRuns
    % addOptional(p, 'server', []);  % Add in the server name as a string
    addOptional(p, 'force', false);  % Overwrite files if they exist
    addOptional(p, 'pmt', 0, @isnumeric);  % Which PMT to use for analysis, 0-green, 1-red
    addOptional(p, 'axons', false);  % Whether or not to preprocess as axons rather than cells
    addOptional(p, 'extraction', 'pcaica');  % or 'nmf', or 'none', Whether to use constrained non-negative matrix factorization or PCA/ICA
    addOptional(p, 'testimages', false);  % Whether to use generate alignment and stimulus test images
    addOptional(p, 'pcaclean', false);  % Whether or not to PCA clean
    addOptional(p, 'objective', 'nikon16x');  % The objective used (from which we can calculate cellhalfwidth)
    
    % ---------------------------------------------------------------------
    % Specific variables
    % PCA Cleaning
    addOptional(p, 'pcaclean_pcs', 2000);  % Number of principal components to use for PCA cleaning
    addOptional(p, 'pcabinxy', 2);  % Bin in x and y before running PCA cleaning, correcting for it afterwards
    addOptional(p, 'pcainterlace', 2);  % How much to interlace for PCA cleaning
    addOptional(p, 'pcaclean_demonsreg', false);  % use demonsreg movie for pcaclean
    
    % PCA/ICA ROI Extraction
    addOptional(p, 'npcs', 1000, @isnumeric);  % The number of principal components to keep
                                               % WARNING: Divided by 4 for axons
    addOptional(p, 'firstpctokeep', 4, @isnumeric);
    addOptional(p, 'temporal_weight', 0.1, @isnumeric);  % The temporal (versus spatial) weight for PCA. Default from Schnitzer was 0.5
    addOptional(p, 'smoothing_width', 2, @isnumeric);  % Standard deviation of Gaussian smoothing kernel (pixels)
                                                       % WARNING: Divided by 2 for axons
    addOptional(p, 'spatial_threshold_sd', 2, @isnumeric);  % Threshold for the spatial filters in standard deviations. Default from Schnitzer was 5
    
    % NMF ROI Extraction
    addOptional(p, 'cellhalfwidth', [], @isnumeric);  % The half-width of a cell, default 2.5
    addOptional(p, 'mergethreshold', 0.8, @isnumeric);  % The threshold above which to merge neighboring ROIs
    addOptional(p, 'patchsize', [], @isnumeric);  % The size of a patch for NMF, can be calculated from cellhalfwidth
    addOptional(p, 'ncomponents', 40, @isnumeric);  % The number of cells to find in a patch. For advanced users only, otherwise leave unset
    
    % General ROI Extraction
    addOptional(p, 'minarea', [], @isnumeric);  % The minimum area of a cell to accept for NMF, default 7
    addOptional(p, 'maxarea', [], @isnumeric);  % The maximum area of a cell to accept for NMF, default 500
    addOptional(p, 'overlap', 0.9, @isnumeric);  % The maximum overlap to allow, combined with crosscorr
    addOptional(p, 'crosscorr', 0.9, @isnumeric);  % The maximum cross-correlation to allow between overlapping ROIs, combined with overlap
    
    % Other
    addOptional(p, 'extract_from_pcaclean', true);  % If PCA cleaning, extract ROIs from the PCA cleaned movie
    addOptional(p, 'save_refpmt', true);  % If refpmt is different from pmt, then save the sbxreg file if true
    addOptional(p, 'chunksize', 1000, @isnumeric);  % The number of frames per parallel chunk
    addOptional(p, 'downsample_t', 1, @isnumeric);  % The number of frames to downsample for cell extraction
                                                    % WARNING: Will automatically be doubled for bidirectional data 
    addOptional(p, 'downsample_xy', [], @isnumeric);  % The maximum cross-correlation to allow between overlapping ROIs, combined with overlap, default 2
    addOptional(p, 'edges', []);  % The edges of the image to be removed before ROI extraction. Will be set to sbxRemoveEdges if empty
    
    % Alignment
    addOptional(p, 'refedges', []);  % The edges of the image to be removed before alignment. Will be set to edges if empty
    addOptional(p, 'refpmt', [], @isnumeric);  % Which PMT to use for registration, 0-green, 1-red
    addOptional(p, 'refsize', 10, @isnumeric);  % Set the number of frames from which we make the reference
    addOptional(p, 'refoffset', 10, @isnumeric);  % The offset in frames for the reference image, accounts for weirdness in the first few frames
    addOptional(p, 'align_tbin_s', 0, @isnumeric);  % How many seconds to bin in time for affine alignment only (DFT is every frame)
    addOptional(p, 'highpass_sigma', 5, @isnumeric);  % Size of the Gaussian blur to be subtracted from a downsampled image
    addOptional(p, 'ref_downsample_xy', [], @isnumeric);  % Pixels to downsample in xy, will be set to downsample_xy if empty
    addOptional(p, 'nomovetarget', false);  %Use period of immobility equal to refsize for making target
    addOptional(p, 'align_from_pcaclean', false);  %
    addOptional(p, 'align_stackreg', false);  % use stackreg to perform translational registration only
    addOptional(p, 'align_demonsreg', false);  % use demonsreg to perform local warp registration only
    addOptional(p, 'align_from_xyreg', false);  % further align an already xy registered movie
    addOptional(p, 'align_from_sbxreg', false);  % further align an already turboreg'ed movie
    addOptional(p, 'aligntype', 'affine');  % If using sbxAlignAffineDFT, can be set to 'affine' or 'translation'
    addOptional(p, 'xrunpmt', []); % PMT to use for xrun alignment in sbxStackReg
    
    if length(varargin) == 1 && iscell(varargin{1}), varargin = varargin{1}; end
    parse(p, varargin{:});
    p = p.Results;

    %% Clean up inputs based on data about the file and force into a list 
    %  of .sbx files (so that this function can easily be duplicated for
    %  paths only
    
    if isempty(p.runs), p.runs = sbxRuns(mouse, date); end
    runs = p.runs;

    sbxpaths = {};
    movpaths = {};
    for r = 1:length(runs)
        sbxpath = sbxPath(mouse, date, runs(r), 'sbx');
        sbxAlignAffineDFT({sbxpath}, 'tbin', 0, 'refsize', p.refsize, ...
            'refoffset', p.refoffset, 'save_title', '_alltform');
        sbxSaveAlignedSBX(sbxpath);
        sbxpaths{end+1} = sbxPath(mouse, date, runs(r), 'sbx');
        movpaths{end+1} = sbxPath(mouse, date, runs(r), 'sbx');
    end
    
    %% Clean up the rest of the inputs
    
    if isempty(sbxpaths), return; end
    info = sbxInfo(sbxpaths{1});

    if isempty(p.target), p.target = runs(1); end
    if isempty(p.refpmt) || p.refpmt < 0, p.refpmt = p.pmt; end
    
    if ~isempty(p.objective)
        if isfield(info.config, 'magnification_list')
            zoom = str2num(info.config.magnification_list(info.config.magnification));
        else
            zoom = info.config.magnification;
        end
        [chw, mina, maxa, dxy] = sbxCellSize(p.objective, zoom, p.cellhalfwidth);
        if isempty(p.cellhalfwidth), p.cellhalfwidth = chw; end
        if isempty(p.minarea), p.minarea = mina; end
        if isempty(p.maxarea), p.maxarea = maxa; end
        if isempty(p.downsample_xy), p.downsample_xy = dxy; end
    end
    
    if info.scanmode ~= 1, p.downsample_t = p.downsample_t*2; end
    chunksize = ceil(p.chunksize/p.downsample_t)*p.downsample_t;
    
    if isempty(p.edges), p.edges = sbxRemoveEdges(sbxpaths{1}); end
    if isempty(p.refedges), p.refedges = p.edges; end
    

    
    %% Extract ROIs
    
    path = sbxpaths{end};
    if ~strcmpi(p.extraction, 'none') 
        savepath = sprintf('%s.ica', path(1:end-4));
            
        icaguidata = sbxExtractROIs(movpaths, savepath, p.edges, 'type', p.extraction, 'force', p.force, ...
            'axons', p.axons, 'downsample_t', p.downsample_t, 'downsample_xy', p.downsample_xy, ...
            'chunksize', chunksize, 'npcs', p.npcs, 'temporal_weight', p.temporal_weight, ...
            'smoothing_width', p.smoothing_width, 'spatial_threshold_sd', p.spatial_threshold_sd, ...
            'cellhalfwidth', p.cellhalfwidth, 'mergethreshold', p.mergethreshold, 'patchsize', p.patchsize, 'ncomponents', p.ncomponents, ...
            'minarea', p.minarea, 'maxarea', p.maxarea, 'overlap', p.overlap, 'crosscorr', p.crosscorr,'firstpctokeep',p.firstpctokeep);

        icaguidata.pars = p;
        save(savepath, 'icaguidata', '-v7.3');
        
        % Make it clickable by the javascript functions
        processForJavascript(mouse, date, runs, p.force, p.axons);
    end

    %% Follow-up with optional images for checking
    
    if p.pupil
        if ~p.job
            sbxPupilMasks(mouse, date, runs);
        end
        
        sbxPupils(mouse, date, runs);
    end
    
    if p.testimages
        for r = 1:length(runs)
            sbxFirstLast(mouse, date, runs(r), p.refsize, p.pmt);
            sbxStimulusTiff(mouse, date, runs(r), p.pmt);
        end

        sbxAlignAffineTest(mouse, date, runs, p.refpmt);
    end
end

