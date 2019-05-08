%% Clear the workspace
% The code is written in a way to avoid inplaces. Such a method allow one
% to avoid recomputing the variables from scratch when an error has been reported.


%Run the segmentation_glove first
clc
close all

%% Load the path and data, assuming in the "Spring 2018" folder. Add the Hasler folder in the path.
% 
% path = './nccr/subject_';
% Data_subject1 = load_data_hasler([path '1']);
% Data_subject2 = load_data_hasler([path '2']);
% Data_subject3 = load_data_hasler([path '3']);
% Data_subject4 = load_data_hasler([path '4']);
% tot_struct = [Data_subject1, Data_subject2, Data_subject3, Data_subject4];
%
% 
% %% Create a structure containing the different signals
% 
% l = length(tot_struct);
% numb_channels = size(tot_struct(1).signal_emg,2);
% EMG = {};
% temp = {};
% 
% for i=1:1:l
%     temp.signal = [];
%     temp.triggers = [];
%     for j=1:2:numb_channels
%         temp.signal = [temp.signal, (tot_struct(i).signal_emg(:,j) - tot_struct(i).signal_emg(:,j+1))];
%     end
%     temp.triggers = tot_struct(i).triggers;
%     
%     EMG = [EMG, temp];
% end
% %% Create the trials cells for each subjects
% for numb=1:1:l
%     
%     % filter the triggers
%     new_triggers = zeros(length(EMG{1,numb}.triggers), 1);
%     for ii=1:length(EMG{1,numb}.triggers)
%         bit1 = bitget(int8(EMG{1,numb}.triggers(ii)), 1);
%         bit2 = bitget(int8(EMG{1,numb}.triggers(ii)), 2);
%         bit3 = bitget(int8(EMG{1,numb}.triggers(ii)), 3);
%         new_triggers(ii) = double(bitset(new_triggers(ii), 3, bit2));
%         new_triggers(ii) = double(bitset(new_triggers(ii), 2, bit3));
%         new_triggers(ii) = double(bitset(new_triggers(ii), 1, bit1));
%     end
% 
%     EMG{1,numb}.triggers = new_triggers;
% 
%     for k=1:length(EMG{1,numb}.triggers)
%         bit1 = bitget(int8(EMG{1,numb}.triggers(k)), 1);
%         bit2 = bitget(int8(EMG{1,numb}.triggers(k)), 2);
%         bit3 = bitget(int8(EMG{1,numb}.triggers(k)), 3);
%         EMG{1,numb}.triggers(k) = double(bitset(EMG{1,numb}.triggers(k), 4, bitxor(bit1, bitxor(bit2, bit3))));
%     end
% end
load('EMG.mat');
l = 4;

%%
for numb=1:1:l

    % delete "failure" data
%     indices_9 = find(EMG{numb}.triggers == 9);
%     EMG{numb}.triggers(indices_9) = [];
%     EMG{numb}.signal(indices_9,:) = [];
%     indices_5 = find(EMG{numb}.triggers == 5);
%     EMG{numb}.triggers(indices_5) = [];
%     EMG{numb}.signal(indices_5,:) = [];
    
    % Create the rest/not rest signal

    rest_signal = ones(length(EMG{1,numb}.triggers),1);
    rest_signal(EMG{1,numb}.triggers == 0) = 0; %rest
    rest_signal(EMG{1,numb}.triggers == 12) = 0;
    
    rest_signal(EMG{1,numb}.triggers == 3) = 3; %grasp
    rest_signal(EMG{1,numb}.triggers == 15) = 3;
    
    rest_signal = medfilt1(rest_signal, 201); %medial filter to cancel the noise. HAS TO BE AN ODD ORDER (otherwise loose edges)
    

    rising_edges = find(diff(rest_signal) == 1) - 100; %200ms before @ 500Hz
    descending_edges_grasp = find(diff(rest_signal) == 2) + 100; %200ms after @ 500Hz
    
    descending_edges_overall = find(diff(rest_signal) == -1) + 100; %200ms after @ 500Hz
    plus = find(diff(rest_signal) == -3) + 100;
    descending_edges_overall = [descending_edges_overall; plus];
    descending_edges_overall = sort(descending_edges_overall);
    
    %Subject number 2 has at one point a jump from 3 to 0. This
    %consequently shifts all the descending edges as it was not detected.
    %(yes, it was wonderfull debugging to find this)

    [EMG_segmented{numb}] = cell_trials_creation(rising_edges,descending_edges_grasp,descending_edges_overall,EMG{1,numb}.signal,rest_signal);
    
    [EMG_segmented{numb}.signal, EMG_segmented{numb}.triggers] = filter_signal(EMG_segmented{numb}.signal, EMG_segmented{numb}.triggers,2,2);
    EMG_segmented{numb} = add_EMG_labels(EMG_segmented{numb});    
end
%had to keep nearly all the data to be able to align them easily
[EMG_final, cyberglove_final, indices_grasp] = align_signals(EMG_segmented, cyberglove_segmented, indices_grasp);
for numb=1:1:l
    EMG_final{numb}.apertures = cyberglove_final{numb}.apertures;
end

for k=1:1:n
    cyberglove_final{k}.labels = EMG_final{k}.labels;
    EMG_final{1,k}.labels = add_cyberglove_labels(cyberglove_final{k});
end


EMG_final = shorten_nograsp(EMG_final);

%filtered are already aligned, re-filtering outliers
%[EMG_final{2}.signal, EMG_final{2}.triggers, EMG_final{2}.labels, EMG_final{2}.apertures] = filter_signal(EMG_final{2}.signal, EMG_final{2}.triggers,1/2,2,EMG_final{2}.labels,EMG_final{numb}.apertures);
for numb=1:1:l
    [EMG_final{numb}.signal, EMG_final{numb}.triggers, EMG_final{numb}.labels, EMG_final{numb}.apertures] = filter_signal(EMG_final{numb}.signal, EMG_final{numb}.triggers,1/2,1/2,EMG_final{numb}.labels,EMG_final{numb}.apertures);
    [cyberglove_final{numb}.signal, cyberglove_final{numb}.triggers,~,~,indices_grasp{numb}] = filter_signal(cyberglove_final{numb}.signal, cyberglove_final{numb}.triggers,2/3,2/3,[],[],indices_grasp{numb});
end

EMG_final = preprocess_EMG(EMG_final);

[EMG_final] = cut_nose_tail(EMG_final, 25);

%clearvars -except EMG_final
