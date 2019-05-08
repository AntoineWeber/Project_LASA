function [output] = del_element_cyber(cyberglove, indices, subject)
%DEL_ELEMENT_cyber Summary of this function goes here
%   Detailed explanation goes here

    for i=indices
        cyberglove{1,subject}.signal{1,i} = [];
        cyberglove{1,subject}.triggers{1,i} = [];
        cyberglove{1,subject}.apertures{1,i} = [];
        cyberglove{1,subject}.labels{1,i} = [];
        
        cyberglove{1,subject}.signal = cyberglove{1,subject}.signal(~cellfun('isempty',cyberglove{1,subject}.signal)); %clearing the deleted trials
        cyberglove{1,subject}.triggers = cyberglove{1,subject}.triggers(~cellfun('isempty',cyberglove{1,subject}.triggers));
        cyberglove{1,subject}.apertures = cyberglove{1,subject}.apertures(~cellfun('isempty',cyberglove{1,subject}.apertures));
        cyberglove{1,subject}.labels = cyberglove{1,subject}.labels(~cellfun('isempty',cyberglove{1,subject}.labels));
    end
    
    output = cyberglove;
end

