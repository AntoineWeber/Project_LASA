function [out_EMG] = cut_nose_tail(EMG,tocut)
%CUT_NOSE_TAIL Summary of this function goes here
%   Detailed explanation goes here

for n=1:1:length(EMG)
    for i=1:1:length(EMG{n}.signal)
        EMG{n}.signal{i} = EMG{n}.signal{i}(tocut+1:end, :); %cut the nose
        EMG{n}.signal{i} = EMG{n}.signal{i}(1:(end-tocut), :); %cut the tail
        
        EMG{n}.triggers{i} = EMG{n}.triggers{i}(tocut+1:end, :); %cut the nose
        EMG{n}.triggers{i} = EMG{n}.triggers{i}(1:(end-tocut), :); %cut the tail
    end
end

out_EMG = EMG;
        
end

