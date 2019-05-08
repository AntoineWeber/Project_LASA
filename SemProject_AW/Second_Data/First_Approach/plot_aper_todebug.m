%% function to verify the hypothesis of the first dataset.
%% load all the files

clc
clear all
close all

load('New_data.mat')
subj = 1;


%% Get usefull files

subject_name = 'iason'; thumb_model = 'rpij'; visualization = 'importancebar';
sbj_name='iason';
SetupHandBis;
calib_file = ['grsp2mat/HandModel/data/calibration/' sbj_name '/thumb_calibration_rpij'];
min_file =['grsp2mat/HandModel/data/calibration/' sbj_name '/min_glove_values'];
max_file =['grsp2mat/HandModel/data/calibration/' sbj_name '/max_glove_values'];

labels_concat = [];
% concatenate labels of different sessions
for sess=1:1:length(EMG_final{subj})
    labels_concat = [labels_concat , EMG_final{subj}{sess}.labels];
end

%% Compute aperture at the last sample of each trial
% careful when interpreting the results as some computations involve GMMs
% and hence depends on the initialization.
% sometimes it gives meaningless results.

apertures = zeros(length(kinematics_final{subj}),1);
for trial = 1:1:length(kinematics_final{subj})
    % getting the last line of the trial
    raw_jointangle = (kinematics_final{subj}{trial}.rawJointAngles(:,end))';
    calibrated_angle = getCalibratedHandAngles(raw_jointangle,calib_file,min_file,max_file);
    % 2 just to stipulate to compute distance between index and thumb. 
    [~,apertures(trial)]=preshape_criteria(calibrated_angle,h,2); 
end

%% take only data for grasping labels

new_aper = [];
new_labels = [];
for i=1:1:length(apertures)
    if labels_concat(i) ~= 2
        new_aper(end+1) = apertures(i);
        new_labels(end+1) = labels_concat(i);
    end
end

%% plot it

scatter(1:length(new_aper(new_labels==0)), new_aper(new_labels==0), 10, 'filled');
grid on; hold on
scatter(1:length(new_aper(new_labels==1)), new_aper(new_labels==1), 10, 'filled');
title('Aperture vs set labels')
legend('3-fingers grasp','full-grasp')
xlabel('trial')
ylabel('aperture')
if exist('set','var')
    clearvars set
end
set(gca,'fontsize',14)
figure
scatter(1:length(new_aper(new_labels==0)), new_aper(new_labels==0), 10, 'filled');
grid on; hold on
scatter(1:length(new_aper(new_labels==1)), new_aper(new_labels==1), 10, 'filled');
scatter(1:length(apertures(labels_concat==2)), apertures(labels_concat==2), 10, 'filled');
title('Aperture vs set labels')
legend('3-fingers grasp','full-grasp','No grasp')
xlabel('trial')
ylabel('aperture')
if exist('set','var')
    clearvars set
end
set(gca,'fontsize',14)


%% perform student t-test

aper_label1 = new_aper(new_labels==1);
aper_label0 = new_aper(new_labels==0);

[h,p] = ttest2(aper_label0, aper_label1);
