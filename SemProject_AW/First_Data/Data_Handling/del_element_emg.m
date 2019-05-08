function [output] = del_element_emg(EMG,indices,subject)
%   Detailed explanation goes here

    for i=indices
        EMG{1,subject}.signal{1,i} = [];
        EMG{1,subject}.triggers{1,i} = [];
        EMG{1,subject}.labels{1,i} = [];
        
        EMG{1,subject}.signal = EMG{1,subject}.signal(~cellfun('isempty',EMG{1,subject}.signal)); %clearing the deleted trials
        EMG{1,subject}.triggers = EMG{1,subject}.triggers(~cellfun('isempty',EMG{1,subject}.triggers));
        EMG{1,subject}.labels = EMG{1,subject}.labels(~cellfun('isempty',EMG{1,subject}.labels));
    end
    
    output = EMG;
end