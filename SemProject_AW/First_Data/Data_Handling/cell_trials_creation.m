function [cell_array,indices] = cell_trials_creation(beginindices,endindicesgrasp,endindicesoverall,signals,rest_signal)

%WORKING


% function creating an array containing the different trials.

%If there is more rising edges, forget the last ones.
%If there is more descending edges, forget the first ones.
%Otherwise, the rising and descending edges were not coherent (misaligned)


    if (length(beginindices) > length(endindicesoverall)) %cyberglove subject 1 is in this situation. However correctly handled
        beginindices = beginindices(1:length(endindicesoverall));
    elseif (length(endindicesoverall) > length(beginindices)) %actually never is in this situation
        nbegin = length(beginindices);
        nend = length(endindicesoverall);
        endindicesoverall = endindicesoverall((nend-nbegin+1):end,:);
    end

    cell_array = {};
    cell_array.signal = {};
    cell_array.triggers = {};
    endindicesgrasp(end+1) = inf;
    k = 1; 
    indices = [];
    %Assuming the closest descending edge is the truth (to differentiate grasp with no grasp as i don't have any trigger
    %to detect the no grasp)
    %hard part was to align the signals.
    for i=1:1:length(beginindices)
        if (endindicesgrasp(k)-beginindices(i) < endindicesoverall(i)-beginindices(i))
            cell_array.signal{i} = signals([beginindices(i):endindicesgrasp(k)],:);
            cell_array.triggers{i} = rest_signal(beginindices(i):endindicesgrasp(k));
            indices(end+1) = beginindices(i);
            indices(end+1) = endindicesgrasp(k);
            k = k+1;
        else
            cell_array.signal{i} = signals([beginindices(i):endindicesoverall(i)],:);
            cell_array.triggers{i} = rest_signal(beginindices(i):endindicesoverall(i));
            indices(end+1) = beginindices(i);
            indices(end+1) = endindicesoverall(i);
    end
end