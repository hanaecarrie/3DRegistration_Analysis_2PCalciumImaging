function [frames, dilation] = glmOnsetsBehavioralDura(licking, ensure, quinine, framerate, nframes, dilate, behavior)
%GLMONSETSVISUAL Return a list of visual-event onsets in frames based on
%   behavior name from a simpcell file.
    
    % Available names
    % include_visual = {'lick_onsets', 'lick_others', 'ensure', 'quinine'};
    
    dilation = dilate;
    frames = [];
    
    name = strsplit(behavior, '_');
    if length(name) == 1
        if strcmpi(name{1}, 'ensure')
            frames = ensure;
        elseif strcmpi(name{1}, 'quinine')
            frames = quinine;
        end
    else
        if strcmpi(name{1}, 'lick')
            lickbout = zeros(1, nframes);
            lickbout(licking) = 1;
            lickboutconv = zeros(1, 2*round(framerate) - 1);
            lickboutconv(round(length(lickboutconv)/2):end) = 1;
            lickbout = conv(lickbout, lickboutconv, 'same');
            lickbout(lickbout > 0) = 1;
            lickbout = uint16(find(diff(lickbout) > 0) + 1);
            
            if strcmpi(name{2}, 'onsets')
                frames = lickbout;
            else
                frames = setdiff(licking, lickbout);
                dilation = [0, 0];
            end
        end
    end
end

