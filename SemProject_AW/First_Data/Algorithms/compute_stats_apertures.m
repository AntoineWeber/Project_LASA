clc
clear all
close all


load('EMG_final_OK.mat');
numb = 1;
Curr_EMG = EMG_final{numb};

%% First plot the different apertures and labels assigned

labels = [];
apertures = [];

k = 0;
for i=1:1:length(Curr_EMG.apertures) %avoid labels 0 as the aperture has no sense here
    if Curr_EMG.labels{i} ~= 0
        k=k+1;
        labels(k) = Curr_EMG.labels{i};
        apertures(k) = Curr_EMG.apertures{i};
    end
end
        
scatter([1:length(apertures)], apertures, 20, labels,'filled');
grid on;
figure

percentage_label1 = length(labels(find(labels==1)))/length(labels);
percentage_label2 = length(labels(find(labels==2)))/length(labels);

%looks like it's not optimal at all. 9cm grasps should not be grasp type
%number 2.

%% Now perform statistical computations

aper_grasp1 = [];
aper_grasp2 = [];

for i=1:1:length(apertures)
    if labels(i) == 1
        aper_grasp1(end+1) = apertures(i);
    else
        aper_grasp2(end+1) = apertures(i);
    end
end

mean_1 = mean(aper_grasp1);
std_1 = std(aper_grasp1);

mean_2 = mean(aper_grasp2);
std_2 = std(aper_grasp2);

errorbar(mean_1, std_1);
grid on; hold on
errorbar(mean_2, std_2);
scatter([1 1], [mean_1 mean_2], 30,'filled')
legend('Mean and std of apertures of grasp 1', 'Mean and std of apertures of grasp 2');
%set(gca,'XLim',[0.5 1.5],'YLim',[5 15])

[h, p] = ttest(aper_grasp1(1:length(aper_grasp2)), aper_grasp2);

if h 
    disp('Null hypothesis rejected')
end
