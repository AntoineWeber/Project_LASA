function [labeled_trials] = add_EMG_labels(trials)

% Only adds the "no grasp" label
    
    for i=1:1:length(trials.signal)
        if (any(diff(trials.triggers{1,i}) == 2))
            trials.labels{1,i} = NaN;
        else
            trials.labels{1,i} = 0;
        end
    end
    
    labeled_trials = trials;
end

