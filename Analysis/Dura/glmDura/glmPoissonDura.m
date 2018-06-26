function [cellgroups, deviance_explained] = glmPoissonDura(mouse, date, varargin)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

    p = inputParser;
    addOptional(p, 'date', []);  % If this is set, the first input is taken as 'mouse' and simpcell files will be found. 
                                 % Otherwise, mouse should be a cell array of simpcell files
    addOptional(p, 'force', false);  % Whether to overwrite
    addOptional(p, 'runs', [2, 3, 4]);  % Which run numbers to search in for stimuli
    addOptional(p, 'testfraction', 0.33);  % Which run numbers to search in for stimuli
    addOptional(p, 'dilate', [-1, 2]);  % Seconds to dilate out from onsets of everything non-visual
    addOptional(p, 'dilate_visual', [0, 2]);  % Seconds to dilate out from visual onsets and offsets
    addOptional(p, 'downsample_t', 2);  % Which run numbers to search in for stimuli
    addOptional(p, 'basis_downsampled_frames', 2);  % The frequency of basis functions in units of downsampled frames
    addOptional(p, 'gaussian_s', 1);  % The width of the gaussian for the basis function
    addOptional(p, 'skip_zeros', false);  % Skip times when all non-analog basis functions are zero
    addOptional(p, 'server', []);  % Which server has simpcell files, if not local server
    addOptional(p, 'savepath', []);  % Save the deviance explained if savepath is set
    addOptional(p, 'include_visual', {});  % Behavioral variables to include with dilate_visual
    addOptional(p, 'include_behavior', {'dtransrms', 'dshearrms', 'dscaleml', 'dscaleap', 'runonst'});  % Behavioral variables to include with dilate (except for lick_others)
    addOptional(p, 'include_analog', {'brainmotion', 'running'});  % Analog behavioral variables to include with no dilation
    addOptional(p, 'alpha', 0.01);  % The ridge-lasso coefficient
    addOptional(p, 'standardize', true);  % clmnet options
    parse(p, varargin{:});
    p = p.Results;
    
    % Cell groups to save
    cellgroups = {'dscaleml', 'dscaleap', 'runonset', 'dtransrms', 'dshearrms'};
    
    % Get file paths
    
    % First, we have to collect all stimuli and concatenate
    behtrain = [];
    behtest = [];
    acttrain = [];
    acttest = [];
    include = [p.include_visual p.include_behavior p.include_analog];
    for run = p.runs
        behaviornames = {};
        behaviorlags = [];
        behavior = [];
        
        sc = sbxLoad(mouse, date, run, 'simpcell', p.server);
        if ~isfield(sc, 'deconvolved') || sum(sc.deconvolved(:)) == 0
            disp('ERROR: No deconvolved values.');
            return;
        end
        if ~isempty(sc)
            nrois = size(sc.deconvolved, 1);
            nframes = size(sc.deconvolved, 2);
            activity = binlast(sc.deconvolved, p.downsample_t);

            norm = gausswin(round(p.gaussian_s*1.5*(sc.framerate/p.downsample_t)));  % std of about 1 sec
            norm = norm./sum(norm);
            for roi = 1:nrois, activity(roi, :) = conv(activity(roi, :), norm, 'same'); end

%             for v = 1:length(p.include_visual)
%                 onsets = glmOnsetsVisual(sc.onsets, sc.condition, sc.trialerror, sc.codes, sc.framerate, p.include_visual{v});
%                 [basis, lags] = glmBasis(onsets, p.dilate_visual, nframes, sc.framerate, p.downsample_t, p.basis_downsampled_frames, p.gaussian_s, false);
%                 behavior = [behavior; basis];
%                 behaviorlags = [behaviorlags lags];
%                 for i = 1:size(basis, 1), behaviornames = [behaviornames p.include_visual{v}]; end
%             end

            for v = 1:length(p.include_behavior)
                transrms = sqrt(sc.transap.^2 + (sc.transml.^2));
                shearrms = sqrt(sc.shearap.^2 + (sc.shearml.^2));
                [onsets, dilation] = glmOnsetsBehavioralDura(sc.scaleml, sc.scaleap,  sc.running, transrms, shearrms, sc.framerate, nframes, p.dilate, p.include_behavior{v});
                [basis, lags] = glmBasis(onsets, dilation, nframes, sc.framerate, p.downsample_t, p.basis_downsampled_frames, p.gaussian_s, false);
                behavior = [behavior; basis];
                behaviorlags = [behaviorlags lags];
                for i = 1:size(basis, 1), behaviornames = [behaviornames p.include_behavior{v}]; end
            end

            for v = 1:length(p.include_analog)
                onsets = getfield(sc, p.include_analog{v});
                [basis, lags] = glmBasis(onsets, p.dilate, nframes, sc.framerate, p.downsample_t, p.basis_downsampled_frames, p.gaussian_s, true);
                behavior = [behavior; basis];           
                behaviorlags = [behaviorlags lags];     
                behaviornames = [behaviornames p.include_analog{v}];
            end

            nframes = size(activity, 2);
            trainframes = 1:(1 - p.testfraction)*nframes;
            testframes = length(trainframes):nframes;

            behtrain = [behtrain behavior(:, trainframes);];
            behtest = [behtest behavior(:, testframes);];
            acttrain = [acttrain activity(:, trainframes);];
            acttest = [acttest activity(:, testframes);];
        end
    end
    
    if isempty(acttrain) || isempty(behtrain) || isempty(acttest), return; end
    
    if p.skip_zeros
        badframes = sum(behtrain(1:end - length(p.include_analog), :), 1);
        goodframes = badframes > 0;
        behtrain = behtrain(:, goodframes);
        acttrain = acttrain(:, goodframes);
    end 
    
    % Make cell groups for variance explained
    groupbehaviors = [];
    for gr = 1:length(cellgroups)
        grmatch = zeros(1, length(behaviornames));
        for b = 1:length(behaviornames)
            if ~isempty(strfind(behaviornames{b}, cellgroups{gr}))
                grmatch(b) = 1;
            end
        end 
        groupbehaviors = [groupbehaviors; grmatch];
    end
        
    opts.alpha = p.alpha;  % The regularization parameter, default is 0.01
%   opts.lambda = 0.01;  % Strength of regularization
    opts.standardize = p.standardize;  % Don't know, default is true
    options = glmnetSet(opts);  % Set the options to use

    output = cell(1, nrois);
    outcoeffs = cell(1, nrois);
    openParallel();
    parfor roi = 1:nrois
        if sum(acttrain(roi, :)) == 0 || sum(isnan(acttrain(roi, :))) > 0
            output{roi} = zeros(1, length(cellgroups) + 1);
        else
            glmoutput = cvglmnet(sparse(behtrain'), acttrain(roi, :), 'poisson', ...
                options, 'deviance', [], [], false, false, true);

            coeffs = cvglmnetCoef(glmoutput);
            actpred = cvglmnetPredict(glmoutput, behtest', [], 'response');
            groupfrac = zeros(1, length(cellgroups) + 1);
            [groupfrac(1), ~, ~] = getDeviance(acttest(roi, :), actpred, nanmean(acttrain(roi, :)), 'Poisson');

            for gr = 1:length(cellgroups)
                newcoeffs = coeffs(2:end);
                newcoeffs(~groupbehaviors(gr, :)) = 0;

                if sum(newcoeffs) > 0
                    actpred = exp(squeeze(behtest')*newcoeffs + coeffs(1));
                    [groupfrac(gr+1), ~, ~] = getDeviance(acttest(roi, :), actpred, ...
                        nanmean(acttrain(roi, :)), 'Poisson');
                end
            end

            output{roi} = groupfrac;  
            outcoeffs{roi} = coeffs(2:end);
        end
    end

    %% Recombine the deviance explained
    % Clean up to remove negatives
    
    devex = zeros(nrois, length(cellgroups) + 1);
    for roi = 1:nrois, devex(roi, :) = output{roi}; end
    devex(devex(:, 1) <= 0, :) = 0;
    devex(devex < 0) = 0;
    for r = 2:length(cellgroups)+1, devex(:, r) = devex(:, r)./devex(:, 1); end
    devex(isnan(devex)) = 0;
    deviance_explained = devex;
    
    coefficients = zeros(length(outcoeffs), length(outcoeffs{1}));
    for i = 1:length(outcoeffs)
        if ~isempty(outcoeffs{i})
            coefficients(i, :) = outcoeffs{i};
        end
    end
    
    pars = p;
    if p.force || ~isempty(p.savepath)
        save(p.savepath, 'cellgroups', 'deviance_explained', 'behaviornames', 'behaviorlags', 'coefficients', 'pars');
    end
end

