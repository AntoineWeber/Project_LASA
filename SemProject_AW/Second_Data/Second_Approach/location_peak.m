%% Load files
clc
clear all
close all
subj = 1;

% load data from the first approach,
% RUN THE MAIN FROM THE FIRST APPROACH TO HAVE THIS FILE.
load('New_data.mat');

% concatenate the sessions
EMG_final{subj} = concatenate_emg(EMG_final{subj});

% load useful files
subject_name = 'iason'; thumb_model = 'rpij'; visualization = 'importancebar';
sbj_name='iason';
SetupHandBis;
calib_file = ['grsp2mat/HandModel/data/calibration/' sbj_name '/thumb_calibration_rpij'];
min_file =['grsp2mat/HandModel/data/calibration/' sbj_name '/min_glove_values'];
max_file =['grsp2mat/HandModel/data/calibration/' sbj_name '/max_glove_values'];

%% compute the threshold between phase 1 and 2
time1 = [];
time2 = [];
time3 = [];

% compute switching between phase 1 and 2.
for i=1:1:length(kinematics_final{subj})
    [time1(i), ~, ~] = timephase(kinematics_final, subj, i);
end

%%  compute max aperture per trial
% careful when interpreting the results as some computations involve GMMs
% and hence depends on the initialization.

aper = {};

% for each trial, compute the location of the max aperture and the
% threshold between phase 1 and 2.
for trial=1:1:length(kinematics_final{subj})
    tmp_aper = [];
    for col = 1:1:size(kinematics_final{subj}{trial}.rawJointAngles,2)
        tmp_aper(end+1) = get_aperture_persample(kinematics_final{subj}{trial}.rawJointAngles(:,col)',calib_file,min_file,max_file,h);
    end
    % smoothen the signal
    tmp_aper = medfilt1(tmp_aper,10);
    aper{trial}.signal = tmp_aper;
    [aper{trial}.maxval,aper{trial}.maxind] = max(tmp_aper);
    aper{trial}.label = EMG_final{subj}{1}.labels(trial);
    aper{trial}.timetomax = kinematics_final{subj}{trial}.timestamp(aper{trial}.maxind) - kinematics_final{subj}{trial}.timestamp(1);
    aper{trial}.thresh = time1(trial);
end

%% now compute statistics
timepower = [];
timethumb = [];
timeno = [];

timethreshpower = [];
timethreshthumb = [];
timethreshno = [];


% compute thresholds per grasp type
for trial = 1:1:length(aper)
    switch aper{trial}.label
        case 0
            timepower(end+1) = aper{trial}.timetomax;
            timethreshpower(end+1) = time1(trial);      
        case 1
            timethumb(end+1) = aper{trial}.timetomax;
            timethreshthumb(end+1) = time1(trial);
        case 2
            timeno(end+1) = aper{trial}.timetomax;
            timethreshno(end+1) = time1(trial);
    end
end

%time is in ms
decisionpower = mean(timepower) - mean(timethreshpower);
decisionthumb = mean(timethumb) - mean(timethreshthumb);
decisionno = mean(timeno) - mean(timethreshno);

if decisionpower > 0
    disp('On average the biggest aperture of the power grasp is inside the 2nd phase')
else
    disp('On average the biggest aperture of the power grasp is inside the 1st phase')
end

if decisionthumb > 0
    disp('On average the biggest aperture of the thumb-2 fingers grasp is inside the 2nd phase')
else
    disp('On average the biggest aperture of the thumb-2 fingers grasp is inside the 1st phase')
end

if decisionno > 0
    disp('On average the biggest aperture of the no grasp is inside the 2nd phase')
else
    disp('On average the biggest aperture of the no grasp is inside the 1st phase')
end

    