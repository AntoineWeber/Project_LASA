%% Utility script to compute the statistics to verify if setting the onset of the motion
%% using a distance threshold is acceptable
%% Read the files, choose the subject to analyse here
clc
clear all
close all


subj = 1;

% load the kinematics of all the trials
for trial=1:1:(length(dir('antoine/recordings/sbj1_20180419/kinematics'))-2)
    kinematics_signal{subj}{trial} = load(sprintf('antoine/recordings/sbj1_20180419/kinematics/trial%d', trial));
end

%% Compute mean initial y coord

ycoordini = [];

% take the initial position of the hand being where it is at rest.
% take the unprocessed file to make sure the hand is at rest.
for trial=1:1:length(kinematics_signal{subj})
    ycoordini(trial) = kinematics_signal{subj}{trial}.handPosition(3,1);
end

% display results
disp(['average first y coord : ',num2str(mean(ycoordini)),' [m] and std first y coord : ', num2str(std(ycoordini)),' [m]']);