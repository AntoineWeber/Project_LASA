function [EMGout] = concatenate_emg(EMGin)

    % concatenate data from all the sessions into the first one.
    EMGout = EMGin;
    for sess = 2:1:length(EMGin)
        EMGout{1}.signal = [EMGout{1}.signal, EMGout{sess}.signal];
        EMGout{1}.triggers = [EMGout{1}.triggers, EMGout{sess}.triggers];
        EMGout{1}.timestamps = [EMGout{1}.timestamps, EMGout{sess}.timestamps];
        EMGout{1}.labels = [EMGout{1}.labels, EMGout{sess}.labels];
    end
    
    EMGout(2:1:length(EMGin)) = [];
end

