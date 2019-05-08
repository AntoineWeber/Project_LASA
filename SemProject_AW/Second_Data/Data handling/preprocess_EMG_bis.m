function [preprocessed_signals] = preprocess_EMG_bis(signals,nb_chan)

    maxVC = zeros(nb_chan, 1);
    
    % compute overall MVC
    for sess=1:1:length(signals)
        for trial=1:1:length(signals{sess}.labels)
            for chan=1:1:nb_chan
                if (max(abs(signals{sess}.signal{trial}(:,chan))) > maxVC(chan))
                    % keep only the maximum value
                    maxVC(chan) = max(abs(signals{sess}.signal{trial}(:,chan)));
                end
            end
        end
    end
    
    for sess=1:1:length(signals)
        for trial=1:1:length(signals{sess}.signal)
            % preprocess signal
            signals{sess}.signal{trial} = preprocess_signals(signals{sess}.signal{trial}, 1500, [400, 40], 20, 1, 1, maxVC);
        end
    end
    
    preprocessed_signals = signals;
    
end

