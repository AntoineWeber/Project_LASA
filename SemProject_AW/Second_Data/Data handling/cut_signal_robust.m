function [EMG_out, kinematics_out] = cut_signal_robust(EMG, kinematics,sessions, max_height, labels)

% Remember that the movement was performed along the y axis ! y being the
% second line of the hand position.

%max_height being a tuple with mean and cov of maximum height per session

%THE KINEMATICS : TIME IS IN MS:
%EMG :  TIME IS IN S

%CAREFULL THE ROWS ARE DEFINED : 1ST ROW = X COORD
%                                2ND ROW = Z COORD
%                                3RD ROW = Y COORD

%Hopefully the starting of the motion can be defined whenever the hand
%crosses 0 as coordinates for the y axis

%If the trial is a grasp,use the height to define the offset, if it is not
%a grasp, use the maximum of the y value
    
    EMG_out = EMG;
    kinematics_out = kinematics;
    
    time_per_trial = zeros(length(kinematics),1);
    
    with_0 = [0, sessions];
    maxheight = zeros(2,length(sessions));
    sizes = cumsum(with_0);
    
    height_to_track = zeros(length(sessions),1);
    for j=1:1:length(sessions)
        height_to_track(j) = max_height(1,j) - 2/3*max_height(2,j);
    end
    
    k = 1;
    for sess=1:1:length(sessions)
        for trial=1:1:sessions(sess) 
            if (labels{sess}(trial) ~= 2)
                rise = find(kinematics{k}.handPosition(3,:) >= 0);
                % here cannot use simply the maximum value along the z axis as it would be
                % too late
                descend = find(kinematics{k}.handPosition(2,:) >= height_to_track(sess));
                % take 10 samples before and after, being approx 91ms before as fz =
                % 110 Hz
                rising_edges = rise(1) - 10; 
                descending_edges = descend(1) + 10;
            else
                rise = find(kinematics{k}.handPosition(3,:) >= 0);
                descend = find(kinematics{k}.handPosition(3,:) == max(kinematics{k}.handPosition(3,:)));
                rising_edges = rise(1) - 10;
                descending_edges = descend(1) + 10;
            end
            
            % offset to the beginning of the trial
            time_to_rise = kinematics{k}.timestamp(rising_edges) - kinematics{k}.timestamp(1);
            % offset between beginning and end of the trial
            time_to_descend = kinematics{k}.timestamp(descending_edges) - kinematics{k}.timestamp(1);
            
            kinematics_out{k} = shorten_kinematics(kinematics{k}, rising_edges, descending_edges);
            
            EMG_out{sess} = shorten_trials(EMG_out{sess},trial,time_to_rise, time_to_descend);
            
            k=k+1;
        end
    end
end

