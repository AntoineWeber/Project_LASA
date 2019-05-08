function [filtered_emg] = preprocess_EMG(input_emg)
%PREPROCESS_EMG is a function preoprocessing the signals but considering
%the data and not the length of the signal.
%     
%     windowSize = 25; %Moving average filter
%     b = (1/windowSize)*ones(1,windowSize);
%     a = 1;
%     mask = [1; 2; 4; 8; 16; 8; 4; 2; 1];
%     mask = mask/(norm(mask)^2);
    
    numb_channels = size(input_emg{1}.signal{1}, 2);
    
    
    for numb = 1:1:length(input_emg)
        maxVC = zeros(numb_channels, 1);
        for i=1:1:length(input_emg{1,numb}.labels)
%             moy = mean(input_emg{numb}.signal{i});
%             input_emg{numb}.signal{i} = input_emg{numb}.signal{i} - moy; %CENTER
%             
%             input_emg{numb}.signal{i} = conv2(mask, input_emg{numb}.signal{i}); %gaussian convolution
%             input_emg{1,numb}.signal{1,i} = filter(b,a,input_emg{1,numb}.signal{1,i}); %moving average filter
%             
%             input_emg{1,numb}.signal{1,i} = abs(input_emg{1,numb}.signal{1,i}./max(abs(input_emg{1,numb}.signal{1,i}))); 
%             
%             input_emg{1,numb}.signal{1,i} = envelope(input_emg{1,numb}.signal{1,i}); %keeping the envelope
%             
%             dev = std(input_emg{numb}.signal{i});
%             input_emg{numb}.signal{i} = input_emg{numb}.signal{i}./dev;

            for j=1:1:numb_channels
                if max(abs(input_emg{numb}.signal{i}(:,j))) > maxVC(j)
                    maxVC(j) = max(abs(input_emg{numb}.signal{i}(:,j)));
                end
            end
        end
           
        for i=1:1:length(input_emg{1,numb}.labels)
            input_emg{1,numb}.signal{1,i} = preprocess_signals(input_emg{1,numb}.signal{1,i}, 512, [400, 40], 20, 1, 1, maxVC);
        end
    end
    
    filtered_emg = input_emg;
    
end

