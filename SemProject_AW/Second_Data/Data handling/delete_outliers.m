function [EMGout, kinematicsout] = delete_outliers(EMG, sessions, kinematics)
    
    signal_length = [];
    
    k=1;
    % extract the lengths of the signal
    for sess=1:1:length(sessions)
        for trial=1:1:sessions(sess)
            signal_length(k) = length(EMG{sess}.signal{trial});
            k=k+1;
        end
    end
    
    % no outliers were observed being "too long". However the outliers
    % beeing too short were often around 0.7sec. Having a mean around
    % 1.3sec, I can implement a 2*sigma slack.
    cst = 2;
    % compute mean and std
    moyenne = mean(signal_length);
    deviation = std(signal_length);
    
    % delete outliers outside the defined bound
    k=1;
    check_kin = 0;
    for sess=1:1:length(sessions)
        check = 0;
        for trial=1:1:sessions(sess)
            if (signal_length(k)<(moyenne-cst*deviation) || signal_length(k)>(moyenne+cst*deviation))
                EMG{sess}.signal(trial-check) = [];
                EMG{sess}.triggers(trial-check) = [];
                EMG{sess}.timestamps(trial-check) = [];
                EMG{sess}.labels(trial-check) = [];
                kinematics(k-check_kin) = [];
                check=check+1;
                check_kin=check_kin+1;
            end
            k=k+1;
        end
    end
    
    kinematicsout = kinematics;
    EMGout = EMG;
end

