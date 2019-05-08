
%% load the only cyberglove file
files = dir('hasler/cyberglove/subject_1/cyberglove_data12.txt');
output = [];

glove_last_val = [];
        
file_id = fopen(files.name, 'r');

sizeA = [24 Inf];
format_spec = ['%d ' 'raw: ' '%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d']; 
A = fscanf(file_id, format_spec, sizeA);
A = A';
glove_last_val = A(:,2:end);
output = [output; glove_last_val];

%% smooth the signals

for j=1:1:size(output,2)
    output(:,j) = smooth(output(:,j), 1000, 'loess');
end

%% compute aperture for each time sample
subject_name = 'iason'; thumb_model = 'rpij'; visualization = 'importancebar';
sbj_name='iason';
SetupHandBis;
calib_file = ['grsp2mat/HandModel/data/calibration/' sbj_name '/thumb_calibration_rpij'];
min_file =['grsp2mat/HandModel/data/calibration/' sbj_name '/min_glove_values'];
max_file =['grsp2mat/HandModel/data/calibration/' sbj_name '/max_glove_values'];


n_samples = length(output);
apertures = zeros(n_samples,1);
areas = zeros(n_samples,1);

for i=1:1:n_samples
    [areas(i),apertures(i)] = get_aperture_persample(output(i,:),calib_file,min_file,max_file,h);
end

%% load the only arduino file 
files = dir('hasler/cyberglove/subject_1/arduino_data12.txt');
ardu_last_val = []; 

file_id = fopen(files.name, 'r');
tline = fgets(file_id);
while ischar(tline)
    a = textscan(tline ,'%s');
    ardu_last_val(end+1) = str2double(a{1}{end});
    tline = fgets(file_id);
end

%% create the two trigger arrays by upsampling the arduino data

first_trigger = zeros(1,length(ardu_last_val));
second_trigger = zeros(1,length(ardu_last_val));

first_trigger(ardu_last_val == 6) = 1;
first_trigger(ardu_last_val == 10) = 1;
first_trigger(ardu_last_val == 3) = 1;
first_trigger(ardu_last_val == 15) = 1;

second_trigger(ardu_last_val == 3) = 1;
second_trigger(ardu_last_val == 15) = 1;

first_trigger = resample(first_trigger,10000*round(length(output)/length(ardu_last_val),4),10000);
second_trigger = resample(second_trigger,10000*round(length(output)/length(ardu_last_val),4),10000);

if (length(first_trigger) > length(output))
    first_trigger = first_trigger(1:length(output));
elseif (length(output) > length(first_trigger))
    output = output(1:length(first_trigger),:);
end
if (length(second_trigger) > length(output))
    second_trigger = second_trigger(1:length(output));
end

final_trigger = round(first_trigger) + 2*round(second_trigger);

%% filter the trigger to cancel noise


filtered_trigger = medfilt1(final_trigger,201);
filtered_trigger(110000:120000) = 0; %delete an unwanted trial

% final_trigger = round(first_trigger) + 2*round(second_trigger);
% final_trigger(110000:120000) = [];
% filtered_trigger = final_trigger;


%% Find the trials

rising_edges = find(diff(filtered_trigger) == 1) - 200; %200ms at 1000Hz
descending_edges_grasp = find(diff(filtered_trigger) == 2) + 200;
descending_edges_overall = find(diff(filtered_trigger) == -1) + 200;

[segmented_output, indices_grasp] = cell_trials_creation(rising_edges,descending_edges_grasp,descending_edges_overall,output,filtered_trigger);
[segmented_output.signal, segmented_output.triggers,~,~,indices_grasp] = filter_signal(segmented_output.signal,segmented_output.triggers,2,2,[],[],indices_grasp);
segmented_output = get_aperture(segmented_output,calib_file,min_file,max_file,h);

%% now plot the aperture and the respective trials found

plot(apertures)
grid on; hold on
for i=1:1:length(segmented_output.signal)
    plot(indices_grasp(2*i-1):indices_grasp(2*i), segmented_output.triggers{i}+6) 
end

k=1;
for j=2:2:length(indices_grasp)
    x_values(k) = indices_grasp(j);
    k=k+1;
end

scatter(x_values, cell2mat(segmented_output.apertures),10);
title('aperture VS trials')

%% 
figure
plot(apertures(3000:100000))
grid on; hold on
plot(filtered_trigger(3000:100000)+6)
    
%%
figure
plot(areas)
grid on; hold on
plot(filtered_trigger+6)

