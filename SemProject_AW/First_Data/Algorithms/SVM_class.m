%% Try performing SVM using 3 features
clc
clear all
close all

load('EMG_final_ok.mat');
numb = 1;
Curr_EMG = EMG_final{numb};

%% extract features

feature_struct = {};
feature_struct.labels = Curr_EMG.labels;

labels = [];
set = [];

for i=1:1:length(Curr_EMG.signal)
    temp = segment_data(Curr_EMG.signal{i},150,50);
    for h=1:1:length(temp)
        feature_struct.features{i}{h}(1,:) = mean(abs(temp{h})); %Mean absolute value
        feature_struct.features{i}{h}(2,:) = sum((diff(sign(diff(temp{h},1,1)),1,1)~=0),1); %number of slope changes
        feature_struct.features{i}{h}(3,:) = sum(abs(diff(temp{h},1,1)),1); %waveform length
        
        feature_struct.features{i}{h} = feature_struct.features{i}{h}./std(feature_struct.features{i}{h},0,2); %normalize
        feature_struct.features{i}{h} = reshape(feature_struct.features{i}{h}',[],1); %assessing TW per TW
        set = [set ; feature_struct.features{i}{h}'];
        labels = [labels ; Curr_EMG.labels{i}];
    end
end
%% separate train and test sets
p = randperm(length(labels));
trainrat = 0.8;
frontier = round(length(labels)*trainrat);

train_data = set(p(1:frontier),:);
test_data = set(p(frontier:end),:);

train_labels = labels(p(1:frontier));
test_labels = labels(p(frontier:end));

%% Compute and grid search the optimal SVM classifier
accuracies = [];

c_values = [0.1, 1, 10, 100, 1000];
eps_values = [0.0001, 0.001, 0.01, 0.1, 1];
gamma_values = [0, 1/10, 1/7, 1/5, 1/3];

for c=c_values
    for eps=eps_values
        for gamma=gamma_values
            model = svmtrain(train_data, train_labels, ['-s 0 -t 2 -g ' num2str(gamma) ' -c ' num2str(c) ' -e ' num2str(eps)]);
            [~, acc, ~] = svmpredict(test_labels, test_data, model);
            accuracies(end+1) = acc(1);
        end
    end
end

