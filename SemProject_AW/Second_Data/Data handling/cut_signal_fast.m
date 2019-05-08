function [EMG_cut] = cut_signal_fast(EMG)
% I know that the reaching intention to the cup should be around 2.5seconds.
% Hence I keep only this part of the signal knowing the sampling
% rate was 1500Hz


% One should not use this function but the cut_signal_robust function.

% 2.5 seconds at 1500Hz equals to 2700 samples
    to_keep = 3750;

    for sess=1:1:length(EMG)
        for trials=1:1:length(EMG{sess}.signal)
            EMG{sess}.signal{trials} = EMG{sess}.signal{trials}(1:to_keep,:);
        end
    end
    
    EMG_cut = EMG;
end

