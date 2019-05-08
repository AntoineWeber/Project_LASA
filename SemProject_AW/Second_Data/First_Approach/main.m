clc
clear all
close all


% EMG sampled at 1500Hz and cyberglove+rest at 110Hz
% label vector noted during the experiment
labels = {};

%label 0 : power grasp
%label 1 : thumb-2-fingers grasp
%label 2 : no grap

%-1 for that the labels start at 0
labels{1}{1} = [1,2,3,1,2,3,1,2,2,1,3,2,1,3,2,1,3,2,3,1,3] - 1;
labels{1}{2} = [3,1,2,1,3,2,2,3,1,3,2,2,3,3,1,1,3,2,1,3,1] - 1;
labels{1}{3} = [3,1,2,2,1,3,3,2,3,1,3,2,1,1,1,3,2,3,2,1,1] - 1;
labels{1}{4} = [2,2,2,2] - 1;
%% Read the files, choose the subject to analyse here
subj = 1;
numb_channels = 8;

% load raw data
for sess=1:1:(length(dir('antoine/recordings/sbj1_20180419/emg'))-2)
    EMG_signals{subj}{sess} = load(sprintf('antoine/recordings/sbj1_20180419/emg/session_%d', sess));
end

for trial=1:1:(length(dir('antoine/recordings/sbj1_20180419/kinematics'))-2)
    kinematics_signal{subj}{trial} = load(sprintf('antoine/recordings/sbj1_20180419/kinematics/trial%d', trial));
end


%% Segment the trials and assign labels

% segment data using manual trigger
EMG_segmented{subj} = create_trials(EMG_signals,subj,numb_channels);
for sess=1:1:length(labels{subj})
    EMG_segmented{subj}{sess}.labels = labels{subj}{sess};
end


%% Preprocess the signal

EMG_preprocessed{subj} = preprocess_EMG_bis(EMG_segmented{subj},numb_channels);

%last session of subject 1 is actually not a session, only 4 more
%measurements. Hence concatenating this "session" into the 3rd
if subj==1
    EMG_preprocessed{subj}{3}.signal = [EMG_preprocessed{subj}{3}.signal, EMG_preprocessed{subj}{4}.signal];
    EMG_preprocessed{subj}{3}.triggers = [EMG_preprocessed{subj}{3}.triggers, EMG_preprocessed{subj}{4}.triggers];
    EMG_preprocessed{subj}{3}.timestamps = [EMG_preprocessed{subj}{3}.timestamps, EMG_preprocessed{subj}{4}.timestamps];
    EMG_preprocessed{subj}{3}.labels = [EMG_preprocessed{subj}{3}.labels, EMG_preprocessed{subj}{4}.labels];
    EMG_preprocessed{subj}(4) = [];
end

%% Take only the part of the signal which is relevant

%uncomment to perform a fast cutting of the signal (not taking kinematics into account)
%EMG_final{subj} = cut_signal_fast(EMG_segmented{subj});


labels_final{subj} = labels{subj};
if subj==1 %concatenate session 3 and 4 as session 4 is not really a session 
    labels_final{subj}{3} = [labels{subj}{3}, labels{subj}{4}];
    labels_final{subj}(4) = []; 
end

length_sessions = [];
for i=1:1:length(labels_final{subj})
    % find the length of each session to locate the right kinematics
    length_sessions(i) = length(labels_final{subj}{i});
end

% compute the average and std max height of the trials
max_height = compute_max_height(kinematics_signal{subj},length_sessions);

% cut the signal using the kinematics
[EMG_cutted{subj}, kinematics_cutted{subj}] = cut_signal_robust(EMG_preprocessed{subj}, kinematics_signal{subj}, length_sessions, max_height, labels_final{subj});

%% Delete outliers

% considering the lengths of the signals.
[EMG_final{subj}, kinematics_final{subj}] = delete_outliers(EMG_cutted{subj}, length_sessions, kinematics_cutted{subj});


%% Save the data

save('New_data','EMG_final','kinematics_final');

