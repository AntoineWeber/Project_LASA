function [signal_short] = shortenEMG(signal,timestamp, t1, t2)
% takes only the signal between the interval wanted
% Careful as the sampling frequency was not the same.

    % consider the offset of the trial
    timestamp = timestamp-timestamp(1);
    
    %rising
    sorted_rise = sort(abs(timestamp - t1/1000));
    rise_indice = find(abs(timestamp - t1/1000) == sorted_rise(1));
    
    %descending
    sorted_descend = sort(abs(timestamp - t2/1000));
    descend_indice = find(abs(timestamp - t2/1000) == sorted_descend(1));
    
    signal_short = signal(rise_indice:descend_indice,:);
end

