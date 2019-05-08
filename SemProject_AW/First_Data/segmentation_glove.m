
%You need to be in the Spring_2018 folder.
%should take ML_toolbox out of the path
%% Clear the command window
clc
clear all
close all

%% start by reading the arduino and cyberglove files
%LONG COMPUTATION
% arduino_data = {};
% cyberglove_data = {};
% 
% n = (length(dir('hasler/cyberglove'))-2); 
% 
% for i=1:1:(length(dir('hasler/cyberglove'))-2)
%     current_subject = sprintf('subject_%d', i);
%     current_path = ['hasler/cyberglove/' current_subject];
%     temp_arduino = read_all_arduino(current_path,i);
%     temp_cyberglove = read_all_cyberglove(current_path,i);
%     arduino_data{i} = temp_arduino';
%     cyberglove_data{i} = temp_cyberglove;
% end
%%
% 
% %% The signals do not have the same sampling frequency. Align them
% %Carefull, this block is INPLACE. To get the full signal, one should rerun
% %block 1
% 
% for j=1:1:n
%     cyberglove_data{1,j} = resample(cyberglove_data{1,j}, 1000,1000*round(length(cyberglove_data{1,j})/length(arduino_data{1,j}),3));
%     %As this line does not match the signals perfectly
%     %arduino_data{1,j} = resample(arduino_data{1,j},1000,1000*round(length(arduino_data{1,j})/length(cyberglove_data{1,j}),3));
%     if (length(cyberglove_data{1,j}) > length(arduino_data{1,j}))
%         cyberglove_data{1,j} = cyberglove_data{1,j}(1:length(arduino_data{1,j}),:);
%     elseif (length(arduino_data{1,j}) > length(cyberglove_data{1,j}))
%         arduino_data{1,j} = arduino_data{1,j}(1:length(cyberglove_data{1,j}),:);
%     end
% end

load('cyberglove_data.mat');
load('arduino_data.mat');
n = 4;

%% Now Segment the data into the different trials
cyberglove_segmented = {};

subject_name = 'iason'; thumb_model = 'rpij'; visualization = 'importancebar';
sbj_name='iason';
SetupHandBis;
calib_file = ['grsp2mat/HandModel/data/calibration/' sbj_name '/thumb_calibration_rpij'];
min_file =['grsp2mat/HandModel/data/calibration/' sbj_name '/min_glove_values'];
max_file =['grsp2mat/HandModel/data/calibration/' sbj_name '/max_glove_values'];

indices_grasp = {};
for numb=1:1:n
    % delete "failure" data
%     indices_9 = find(arduino_data{numb} == 9);
%     arduino_data{numb}(indices_9) = [];
%     cyberglove_data{numb}(indices_9,:) = [];
%     indices_5 = find(arduino_data{numb} == 5);
%     arduino_data{numb}(indices_5) = [];
%     cyberglove_data{numb}(indices_5,:) = [];
    
    % Create the rest/not rest signal
    rest_signal = ones(length(arduino_data{1,numb}),1);
    
    rest_signal(arduino_data{1,numb} == 0) = 0; %rest
    rest_signal(arduino_data{1,numb} == 12) = 0;
    
    rest_signal(arduino_data{1,numb} == 3) = 3; %grasp
    rest_signal(arduino_data{1,numb} == 15) = 3;
    
    rest_signal = medfilt1(rest_signal, 21); %cancel noisy data
    
    rising_edges = find(diff(rest_signal) == 1) - 20; %200ms at 100Hz
    descending_edges_grasp = find(diff(rest_signal) == 2) + 20;
    descending_edges_overall = find(diff(rest_signal) == -1) + 20;
    
    [cyberglove_segmented{numb}, indices_grasp{numb}] = cell_trials_creation(rising_edges,descending_edges_grasp,descending_edges_overall,cyberglove_data{1,numb},rest_signal);
    
    [cyberglove_segmented{1,numb}.signal,cyberglove_segmented{1,numb}.triggers,~,~,indices_grasp{numb}] = filter_signal(cyberglove_segmented{1,numb}.signal,cyberglove_segmented{1,numb}.triggers,2,2,[],[],indices_grasp{numb});
    
    cyberglove_segmented{numb} = get_aperture(cyberglove_segmented{numb},calib_file,min_file,max_file,h);
    
    
    %look at the segmentation_emg file for further explanations
end 
