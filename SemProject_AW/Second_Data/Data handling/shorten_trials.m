function [EMGout] = shorten_trials(EMG,trial,risetime, descendtime)

    % careful : risetime and descendtime are in MS and the EMG timestamps
    % are in S
    EMGout = EMG;
    
    timestamp = EMG.timestamps{trial};
    
    % dephase the signal to 0
    timestamp = timestamp-timestamp(1);
    
    % Find the nearest value to the kinematics time stamp as considering
    % different sampling rate, not the same times are present in both files.
    
    % rising
    sorted_rise = sort(abs(timestamp - risetime/1000));
    rise_indice = find(abs(timestamp - risetime/1000) == sorted_rise(1));
    
    % descending
    sorted_descend = sort(abs(timestamp - descendtime/1000));
    descend_indice = find(abs(timestamp - descendtime/1000) == sorted_descend(1));
    
    
    EMGout.signal{trial} = EMG.signal{trial}(rise_indice:descend_indice,:);
    EMGout.triggers{trial} = EMG.triggers{trial}(rise_indice:descend_indice,:);
    EMGout.timestamps{trial} = EMG.timestamps{trial}(rise_indice:descend_indice,:);
end

