function [EMG_output] = filter_outliers(EMG_input,labels,penaltymin,penaltymax)
% USED ONLY FOR FIRST DATA. NOT USED ANYMORE

% function deleting outliers in the data considering only the length of the
% signal. the output of the function only keeps signal having a length
% inside mean +-penalty*std.
    EMG_output = {};
    tot = [];
    for i = 1:1:length(signal)
        tot(i) = length(signal{1,i});
    end
    
    thresh = std(tot);
    moy = mean(tot);
    
    to_erase = [];
    k=1;
    for i = 1:1:length(signal)
        if length(signal{1,i})<(moy-penaltymin*thresh) || length(signal{1,i})>(moy+penaltymax*thresh)
            signal{1,i} = [];
            triggers{1,i} = [];
            to_erase(k) = i;
            k=k+1;
        end
    end
    
    signal = signal(~cellfun('isempty',signal)); %clearing the deleted trials
    triggers = triggers(~cellfun('isempty',triggers));
    
    filtered_labels = [0];
    filtered_apertures = [0];
    if (exist('labels','var'))
        if ~isempty(labels)
            labels = labels(~cellfun('isempty',triggers));
            filtered_labels = labels;
        end
    end
    
    if (exist('apertures','var'))
        if ~isempty(apertures)
            apertures = apertures(~cellfun('isempty',triggers));
            filtered_apertures = apertures;
        end
    end
    
    %section added only to plot the triggers when plotting the aperture
    %over time
    if (exist('indices','var'))
        for j=1:1:length(to_erase)
            indices((2*to_erase(j)-1):2*to_erase(j)) = -1;
        end
        to_delete = (indices==-1);
        indices(to_delete) = [];
        filtered_indices = indices;
    end
    
    filtered_sign = signal;
    filtered_trig = triggers;
end

