function [cell_array] = create_trials(EMG_file,subj,nb_chan)

    cell_array = {};
    % iterate on all the sessions
    for sess = 1:1:length(EMG_file{subj})
        raw_EMG = [];
        
        
        time = EMG_file{subj}{sess}.Data{1};
        
        for j=2:1:(nb_chan+1)
            raw_EMG(:,(j-1)) = EMG_file{subj}{sess}.Data{j};
        end
        
        trig = EMG_file{subj}{sess}.Data{10};
        
        % detect rising and descending edges of the manual triggers
        rising_edges = find(diff(trig) == 1);
        descending_edges = find(diff(trig) == -1);

        if (length(rising_edges) ~= length(descending_edges))
            error('Trial not correctly defined')
        else
            for trials=1:1:length(rising_edges)
                cell_array{sess}.signal{trials} = raw_EMG(rising_edges(trials):descending_edges(trials),:);
                cell_array{sess}.triggers{trials} = trig(rising_edges(trials):descending_edges(trials));
                cell_array{sess}.timestamps{trials} = time(rising_edges(trials):descending_edges(trials));
            end
        end
    end
end