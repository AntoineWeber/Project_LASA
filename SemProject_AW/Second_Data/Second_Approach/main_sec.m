%% Load data to be segmented
clc
clear all
close all
% define subject to be analyzed
subj = 1;
% RUN THE MAIN FROM THE FIRST APPROACH TO HAVE THIS FILE.
% load data from the 1st approach.
load('New_data.mat');

% can be commented to do a per session analysis
EMG_final{subj} = concatenate_emg(EMG_final{subj}); 
Tot_EMG = EMG_final{subj};

%% Segment each signal into 3 phases
sess = 1;
Fin_EMG = {};
Fin_EMG{sess}.labels = Tot_EMG{sess}.labels;
for i=1:1:length(kinematics_final{subj})
    % compute switching between the phases for each trial
    [time1, time2, time3] = timephase(kinematics_final, subj, i);
    
    % separate data from the three phases
    Fin_EMG{sess}.signal{i}{1} = shortenEMG(Tot_EMG{sess}.signal{i},Tot_EMG{sess}.timestamps{i}, 0, time1);
    Fin_EMG{sess}.signal{i}{2} = shortenEMG(Tot_EMG{sess}.signal{i},Tot_EMG{sess}.timestamps{i}, time1, time2);
    Fin_EMG{sess}.signal{i}{3} = shortenEMG(Tot_EMG{sess}.signal{i},Tot_EMG{sess}.timestamps{i}, time2, time3);
    
end
    
%% save data

save('data_2approach','Fin_EMG');