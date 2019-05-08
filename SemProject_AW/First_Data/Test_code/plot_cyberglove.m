
n = 1; %number of the subject
trials = cyberglove_segmented{1,n};
subject_name = 'iason'; thumb_model = 'rpij'; visualization = 'importancebar';
sbj_name='iason';
SetupHandBis;
calib_file = ['grsp2mat/HandModel/data/calibration/' sbj_name '/thumb_calibration_rpij'];
min_file =['grsp2mat/HandModel/data/calibration/' sbj_name '/min_glove_values'];
max_file =['grsp2mat/HandModel/data/calibration/' sbj_name '/max_glove_values'];
apertures = [];
triggerzz = [];

%p = number of the trial
p = 70;

%On average trials of subject 1 make sense. However, for the other 2
%subjects, some weirds things happen (stedy signal f.ex)

%The downsampling HAVE a negative impact on the glove file. Why more on
%subject >=2 ?
% numb = 20;
% for p = 1:1:numb
    for l=1:1:length(trials.signal{1,p})
        raw_jointangle = trials.signal{1,p}(l,:);
        calibrated_angle = getCalibratedHandAngles(raw_jointangle,calib_file,min_file,max_file);
        [~,aperture]=preshape_criteria(calibrated_angle,h,2);
        apertures = [apertures; aperture];
    end
    triggerzz = [triggerzz; trials.triggers{1,p}];
% end

plot(apertures);
grid on; hold on
plot(triggerzz);


%some results gave straight line for the apertures... Maybe because of the
%no grasp ?

%%
%Same type of code but plotting random moments of the raw cyberglove file.
%To see if the resampling has a big impact

%load('cyberglove_data.mat');
subject_name = 'iason'; thumb_model = 'rpij'; visualization = 'importancebar';
sbj_name='iason';
SetupHandBis;
calib_file = ['grsp2mat/HandModel/data/calibration/' sbj_name '/thumb_calibration_rpij'];
min_file =['grsp2mat/HandModel/data/calibration/' sbj_name '/min_glove_values'];
max_file =['grsp2mat/HandModel/data/calibration/' sbj_name '/max_glove_values'];
apertures = [];
n = 1; %number of the subject
begin = 1;
ending = 100000;

for i=begin:1:ending
    raw_jointangle = cyberglove_data{1,n}(i,:);
    calibrated_angle = getCalibratedHandAngles(raw_jointangle,calib_file,min_file,max_file);
    [~,aperture]=preshape_criteria(calibrated_angle,h,2);
    apertures(i) = aperture;
end

plot(apertures(begin:1:ending));
