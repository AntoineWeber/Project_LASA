%% Load files
clc
clear all
close all

load('Full_aperture_plots.mat');
load('cyberglove_data.mat')

subject_name = 'iason'; thumb_model = 'rpij'; visualization = 'importancebar';
sbj_name='iason';
SetupHandBis;
calib_file = ['grsp2mat/HandModel/data/calibration/' sbj_name '/thumb_calibration_rpij'];
min_file =['grsp2mat/HandModel/data/calibration/' sbj_name '/min_glove_values'];
max_file =['grsp2mat/HandModel/data/calibration/' sbj_name '/max_glove_values'];

%% compute per subject (LONG)
n = length(cyberglove_data);

for numb=1:1:1
    n_samples = length(cyberglove_data{numb});
    apertures = zeros(n_samples,1);
    
    for i=1:1:n_samples
        apertures(i) = get_aperture_persample(cyberglove_data{numb}(i,:),calib_file,min_file,max_file,h);
    end
    
    plot(apertures(1:10000))
    grid on; hold on
    
    for i=1:1:length(cyberglove_final{numb}.signal)
        plot(indices_grasp{numb}(2*i-1):indices_grasp{numb}(2*i), cyberglove_final{numb}.triggers{i} + 6) 
    end
    
    figure
    disp(['Subject number ',num2str(numb),' processed'])
end
