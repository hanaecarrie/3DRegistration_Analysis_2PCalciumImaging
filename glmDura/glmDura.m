function [out, myout] = glmDura(mouse, date, run, verbose)
%UNTITLED14 Summary of this function goes here
%   Detailed explanation goes here

    if nargin < 4, verbose = true; end

    sigma = 1.96;
    downsample_framerate = 4;
    display_time = [-5 5];%[-1 4];%
    off_for_sec = 5; % Keep off for a certain number of seconds
    binarize_behavior = false;
    % Possible behaviors: transml, transap, dtransml, dtransap,
    % scaleml, scaleap, dscaleml, dscaleap, ddscaleml, ddscaleap
    % shearml, shearap, dshearml, dshearap
    % speed, runonst
    include_behaviors = {... 'dtransml', 'dtransap', ...
        'dtransrms', ...
        'dshearrms', ...
        'dscaleml', 'dscaleap', ...
        ... 'ddscaleml', 'ddscaleap', ...
        ... 'dshearml', 'dshearap', ...
        ... 'speed', ...
        'runonst'};
    hwhm_pix = 2;
    gauss_sz = 30;
    use_deconvolved = false;
    
    % Calculated parameters
    if verbose, disp('Loading file...'); end
    sc = sbxLoad(mouse, date, run(1), 'simpcell');     
    if length(run) > 1
        fields = fieldnames(sc);
        for r  = 2:length(run)
            sc_r = sbxLoad(mouse, date, run(r), 'simpcell');
            for i = 1:numel(fields)
                if i ~= 14
                sc.(fields{i}) = cat(2, sc.(fields{i}), sc_r.((fields{i})));
                end
            end
        end
    end
    sc.framerate = sc.framerate(1);
 
    
    if verbose, disp('Loading registration...'); end
    mot = registrationDecomposition(mouse, date, run);
    motshearml = mot.shearml;
    motshearap = mot.shearap;
    mottransml = reshape(mot.transml, 1, length(mot.transml));
    mottransap = reshape(mot.transap, 1, length(mot.transap));
    motscaleml = mot.scaleml;
    motscaleap = mot.scaleap;
    
    % Get alternate scale if possible
    % DL67_170402_001.alignaffine_alltform
    
    % Prepare binning and filter parameters
    highpassfilter = designfilt('highpassiir', ...
        'PassbandFrequency', 0.1, 'StopbandFrequency',0.01, ...
        'PassbandRipple',0.2, 'StopbandAttenuation',60, ...
        'SampleRate', sc.framerate);
    bandpassfilter = designfilt('bandpassiir', 'FilterOrder', 20, ...
        'HalfPowerFrequency1',0.1,'HalfPowerFrequency2',10, ...
        'SampleRate', sc.framerate);
    x = linspace(-gauss_sz/2, gauss_sz/2, gauss_sz);
    gaussfilter = exp(-x.^ 2/(2*hwhm_pix^2));
    gaussfilter = gaussfilter/sum(gaussfilter); % Normalize filter to 1
    bin = round(sc.framerate/downsample_framerate);
    
    % Get all behavioral parameters
    if verbose, disp('Getting behavior...'); end
    if binarize_behavior
        scaleml = behavioralOnset(motscaleml, sc.framerate, sigma, ...
            off_for_sec, downsample_framerate);
        scaleap = behavioralOnset(motscaleap, sc.framerate, sigma, ...
            off_for_sec, downsample_framerate);
        transml = behavioralOnset(reshape(mottransml, [1, length(mottransml)]), ...
            sc.framerate, sigma, off_for_sec, downsample_framerate);
        transap = behavioralOnset(reshape(mottransap, [1, length(mottransap)]), ...
            sc.framerate, sigma, off_for_sec, downsample_framerate);
        shearml = behavioralOnset(motshearml, sc.framerate, sigma, ...
            off_for_sec, downsample_framerate);
        shearap = behavioralOnset(motshearap, sc.framerate, sigma, ...
            off_for_sec, downsample_framerate);
        runonst = behavioralOnset(sbxSpeed(mouse, date, run), sc.framerate, ...
            sigma, off_for_sec, downsample_framerate);
    else
        % Scale, velocity of scale, acceleration of scale
        scaleml = dst(filtfilt(bandpassfilter, motscaleml(1:end-1)), bin);
        scaleap = dst(filtfilt(bandpassfilter, motscaleap(1:end-1)), bin);
        scaleml = scaleml - mean(scaleml(150:end));
        scaleap = scaleap - mean(scaleap(150:end));
        scaleml(1:150) = 0; scaleap(1:150) = 0;
        mxmx = 6*max(std(scaleml(gauss_sz:end-gauss_sz)), std(scaleap(gauss_sz:end-gauss_sz)));
        scaleml = scaleml/mxmx; scaleml(scaleml > 1) = 1; scaleml(scaleml < -1) = -1;
        scaleap = scaleap/mxmx; scaleap(scaleap > 1) = 1; scaleap(scaleap < -1) = -1;

        gfiltml = conv(motscaleml, gaussfilter, 'same');
        dscaleml = dst(diff(gfiltml), bin);
        gfiltap = conv(motscaleap, gaussfilter, 'same');
        dscaleap = dst(diff(gfiltap), bin);
        mxmx = 6*max(std(dscaleml(gauss_sz:end-gauss_sz)), std(dscaleap(gauss_sz:end-gauss_sz)));
        dscaleml = dscaleml/mxmx; dscaleml(dscaleml > 1) = 1; dscaleml(dscaleml < -1) = -1;
        dscaleap = dscaleap/mxmx; dscaleap(dscaleap > 1) = 1; dscaleap(dscaleap < -1) = -1;
        
        dscalemp = 0.7*(dscaleml - dscaleap);
        dscalema = 0.7*(dscaleml + dscaleap);
        
        ddscaleml = dst([diff(conv(diff(gfiltml), gaussfilter, 'same')) 0], bin);
        ddscaleap = dst([diff(conv(diff(gfiltap), gaussfilter, 'same')) 0], bin);
        mxmx = 6*max(std(ddscaleml(gauss_sz:end-gauss_sz)), std(ddscaleap(gauss_sz:end-gauss_sz)));
        ddscaleml = ddscaleml/mxmx; ddscaleml(ddscaleml > 1) = 1; ddscaleml(ddscaleml < -1) = -1;
        ddscaleap = ddscaleap/mxmx; ddscaleap(ddscaleap > 1) = 1; ddscaleap(ddscaleap < -1) = -1;
        
        % Translation, velocity of translation
        transml = dst(filtfilt(bandpassfilter, mottransml(1:end-1)), bin);
        transap = dst(filtfilt(bandpassfilter, mottransap(1:end-1)), bin);
        transml = transml - mean(transml);
        transap = transap - mean(transap);
        mxmx = 6*max(std(transml(gauss_sz:end-gauss_sz)), std(transap(gauss_sz:end-gauss_sz)));
        transml = transml/mxmx; transml(transml > 1) = 1; transml(transml < -1) = -1;
        transap = transap/mxmx; transap(transap > 1) = 1; transap(transap < -1) = -1;
        
        gfiltml = conv(mottransml, gaussfilter, 'same');
        dtransml = dst(diff(gfiltml), bin);
        gfiltap = conv(mottransap, gaussfilter, 'same');
        dtransap = dst(diff(gfiltap), bin);
        mxmx = 6*max(std(dtransml(gauss_sz:end-gauss_sz)), std(dtransap(gauss_sz:end-gauss_sz)));
        dtransml = dtransml/mxmx; dtransml(dtransml > 1) = 1; dtransml(dtransml < -1) = -1;
        dtransap = dtransap/mxmx; dtransap(dtransap > 1) = 1; dtransap(dtransap < -1) = -1;
        
        ddtransml = dst([diff(diff(gfiltml)) 0], bin);
        ddtransap = dst([diff(diff(gfiltap)) 0], bin);
        mxmx = 6*max(std(ddtransml(gauss_sz:end-gauss_sz)), std(ddtransap(gauss_sz:end-gauss_sz)));
        ddtransml = ddtransml/mxmx; ddtransml(ddtransml > 1) = 1; ddtransml(ddtransml < -1) = -1;
        ddtransap = ddtransap/mxmx; ddtransap(ddtransap > 1) = 1; ddtransap(ddtransap < -1) = -1;
        
        dtransrms = sqrt(dtransml.*dtransml + dtransap.*dtransap);
        mxmx = 6*std(dtransrms(gauss_sz:end-gauss_sz));
        dtransrms = dtransrms/mxmx; dtransrms(dtransrms > 1) = 1; dtransrms(dtransrms < -1) = -1;
        
        % Shear, velocity of shear
        shearml = dst(filtfilt(bandpassfilter, motshearml(1:end-1)), bin);
        shearap = dst(filtfilt(bandpassfilter, motshearap(1:end-1)), bin);
        shearml = shearml - mean(shearml(150:end));
        shearap = shearap - mean(shearap(150:end));
        shearml(1:150) = 0; shearap(1:150) = 0;
        mxmx = 6*max(std(shearml(gauss_sz:end-gauss_sz)), std(shearap(gauss_sz:end-gauss_sz)));
        shearml = shearml/mxmx; shearml(shearml > 1) = 1; shearml(shearml < -1) = -1;
        shearap = shearap/mxmx; shearap(shearap > 1) = 1; shearap(shearap < -1) = -1;
        
        gfiltml = conv(motshearml, gaussfilter, 'same');
        dshearml = dst(diff(gfiltml), bin);
        gfiltap = conv(motshearap, gaussfilter, 'same');
        dshearap = dst(diff(gfiltap), bin);
        mxmx = 6*max(std(dshearml(gauss_sz:end-gauss_sz)), std(dshearap(gauss_sz:end-gauss_sz)));
        dshearml = dshearml/mxmx; dshearml(dshearml > 1) = 1; dshearml(dshearml < -1) = -1;
        dshearap = dshearap/mxmx; dshearap(dshearap > 1) = 1; dshearap(dshearap < -1) = -1;
        
        dshearrms = sqrt(dshearml.*dshearml + dshearap.*dshearap);
        mxmx = 6*std(dshearrms(gauss_sz:end-gauss_sz));
        dshearrms = dshearrms/mxmx; dshearrms(dshearrms > 1) = 1; dshearrms(dshearrms < -1) = -1;
        
        % Speed (velocity of position)
        gfiltspeed = conv(sbxSpeed(mouse, date, run), gaussfilter, 'same');
        speed = dst(gfiltspeed, bin);
        speed = speed(1:end-1)/max(speed(gauss_sz:end-gauss_sz));
        
        % Running onset/intracranial pressure spikes
        runonst = behavioralOnset(sbxSpeed(mouse, date, run), sc.framerate, ...
            sigma, off_for_sec);
        runonst = double(runonst);
        runonst = dst(conv(runonst, gaussfilter, 'same'), bin);
        runonst = runonst - min(runonst);
        runonst = runonst/max(runonst);
    end
    
    behavior = [];
    for ib = 1:length(include_behaviors)
        behavior = [behavior eval(include_behaviors{ib})'];
    end
    
    if verbose, disp('Correlating behavior'); end
    corrs = zeros(size(behavior, 2), size(behavior, 2));
    for i = 1:size(behavior, 2)
        for j = 1:size(behavior, 2)
            if i ~= j
                cc = corrcoef(behavior(gauss_sz:end-gauss_sz, i), behavior(gauss_sz:end-gauss_sz, j));
                corrs(i, j) = cc(1, 2);
            end
        end
    end
    
    % Reshape for input to GLM
    behavior = reshape(behavior, size(behavior, 1), 1, size(behavior, 2));
    behavior = behavior(gauss_sz:end - gauss_sz, :, :);
    settings = struct('inputsamplerate', sc.framerate/bin, ... % fps ./ ds_value
        'time', [1000*display_time(1) 1000*display_time(2)], ... % window of time to analyze
        'runstats', 0, ...
        'removeOnset', 0);
        
    % Iterate through cells and run GLM
    
    if verbose, disp('Running GLM'); end
    disp(size(sc.dff, 1));
    myout = struct;
    myout.diff = zeros(size(sc.dff, 1), 40);
    myout.absdiff = zeros(size(sc.dff, 1), 40);
    
    for c = 1:size(sc.dff, 1)
        if use_deconvolved
            cdata = dst(sc.deconvolved(c, :), bin);
        else
            cdata = dst(sc.dff(c, :), bin);
        end
        cdata = cdata(1:length(scaleml));
        
%         figure;
%         plot(cdata);
%         title(sprintf('Trace of ROI %i', c));
        
        % Correct edges
         cdata = cdata(gauss_sz:end - gauss_sz);
        % behavior = behavior(gauss_sz:end - gauss_sz, :, :);

%         figure;
%         plot(5*cdata(30:end-30));
%         hold on;
%         for i = 1:size(behavior, 3)
%             plot(behavior(30:end-30, :, i) - i);
%         end
        
        out = glm(cdata', behavior, settings);
        
        figure;
        plot(out.time/1000.0, out.kernel);
        legend(include_behaviors);
        xlabel('Time (s)');
        ylabel('Filter');
        title(sprintf('Filters of ROI %i', c));
%         pause();

        % save dscaleap vs dpscaleml
        if c == 1; myout.time = out.time/1000.0; end;
        mydscaleml = out.kernel(:,3)';
        mydscaleap = out.kernel(:,4)';
        myout.diff(c, :) = abs(mydscaleml - mydscaleap);
        myout.absdiff(c,:) = abs(abs(mydscaleml) - abs(mydscaleap));
        
    end
    
    figure;
    imagesc(corrs);
    colorbar();
    title('Behavior var correlations');
    set(gca, 'XTick', 1:length(include_behaviors), 'XTickLabel', include_behaviors);
    set(gca, 'YTick', 1:length(include_behaviors), 'YTickLabel', include_behaviors);
    
    figure;
    scaleml = dst(diff(motscaleml), bin);
        scaleap = dst(diff(motscaleap), bin);
        
    angles = atan2(scaleap, scaleml);
    ds = sqrt(scaleml.*scaleml + scaleap.*scaleap);
    ds = log(ds);
    h = polar(angles, ds, '.');
    set(h, 'markersize', 10);
        
%     scatter(scaleml./(ds).*log2(ds)./ds, scaleap.*log2(ds)./ds);
%     xlabel('Medioposterior');
%     ylabel('Medioanterior');
%     title('Scale along ML-AP and ML+AP axes');
    
    figure;
    hold on;
    for ib = 1:size(behavior, 3)
        plot(behavior(:, 1, ib) + ib);
    end
    legend(include_behaviors);

end

