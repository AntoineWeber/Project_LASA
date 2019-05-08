function [shorten_EMG] = shorten_nograsp(EMG_sig)
%SHORTEN_NOGRASP Summary of this function goes here
%   Detailed explanation goes here
    
    for numb=1:1:length(EMG_sig)
        for j=1:1:length(EMG_sig{1,numb}.signal)
            if (EMG_sig{1,numb}.labels{1,j} == 0)
                milieu = round(length(EMG_sig{1,numb}.signal{1,j})/2);
                EMG_sig{1,numb}.signal{1,j} = EMG_sig{1,numb}.signal{1,j}(1:milieu,:);
            end
        end
    end
    
    shorten_EMG = EMG_sig;
end

