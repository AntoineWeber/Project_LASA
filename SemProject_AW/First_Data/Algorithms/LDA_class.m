%% Try performing LDA using 3 features
clc
clear all
close all

load('EMG_final_OK.mat');
numb = 1;
Curr_EMG = EMG_final{numb};

%% extract features

feature_struct = {};
feature_struct.labels = Curr_EMG.labels;

labels = [];
set = [];

maxMAV = 0;
maxSC = 0;
maxWL = 0;

for i=1:1:length(Curr_EMG.signal)
    temp = segment_data(Curr_EMG.signal{i},150,50);
    for h=1:1:length(temp)
        feature_struct.features{i}{h}(1,:) = mean(abs(temp{h})); %Mean absolute value
        if max(abs(feature_struct.features{i}{h}(1,:)))>maxMAV
            maxMAV = max(abs(feature_struct.features{i}{h}(1,:)));
        end
        
        feature_struct.features{i}{h}(2,:) = sum((diff(sign(diff(temp{h},1,1)),1,1)~=0),1); %number of slope changes
        if max(abs(feature_struct.features{i}{h}(2,:)))>maxSC
            maxSC = max(abs(feature_struct.features{i}{h}(2,:)));
        end
        
        feature_struct.features{i}{h}(3,:) = sum(abs(diff(temp{h},1,1)),1); %waveform length
        if max(abs(feature_struct.features{i}{h}(1,:)))>maxWL
            maxWL = max(abs(feature_struct.features{i}{h}(3,:)));
        end
    end
end

for i=1:1:length(Curr_EMG.signal)
    temp = segment_data(Curr_EMG.signal{i},150,50);
    for h=1:1:length(temp)
        feature_struct.features{i}{h}(1,:) = feature_struct.features{i}{h}(1,:)./maxMAV;
        feature_struct.features{i}{h}(2,:) = feature_struct.features{i}{h}(2,:)./maxSC;
        feature_struct.features{i}{h}(3,:) = feature_struct.features{i}{h}(3,:)./maxWL;
        
        feature_struct.features{i}{h} = reshape(feature_struct.features{i}{h},[],1);
        set = [set, feature_struct.features{i}{h}];
        labels = [labels, Curr_EMG.labels{i}];
    end
end

set = set';
labels = labels';


%% separate train and test sets
p = randperm(length(labels));
trainrat = 0.8;
frontier = round(length(labels)*trainrat);

train_data = set(p(1:frontier),:);
test_data = set(p(frontier:end),:);

train_labels = labels(p(1:frontier));
test_labels = labels(p(frontier:end));

%% Now compute the LDA classifier and test accuracy for a binary grasp not grasp classification
%all the time windows at once

% train_labels(find(train_labels == 2)) = 1; %BINARY
% test_labels(find(test_labels==2)) = 1;

Model = fitcdiscr(train_data,train_labels);

score_test = 0;
score_train = 0;


train_predicted = [];
test_predicted = [];

for i=1:length(train_labels)
   hit = predict(Model,train_data(i,:));
   train_predicted(end+1) = hit;
   if hit==train_labels(i)
       score_train = score_train + 1;
   end
end


for i=1:length(test_labels)
   hit = predict(Model,test_data(i,:)); 
   test_predicted(end+1) = hit;
   if hit==test_labels(i)
       score_test = score_test + 1;
   end
end

train_predicted = create_label_confusion(train_predicted');
test_predicted = create_label_confusion(test_predicted');

train_truth = create_label_confusion(train_labels);
test_truth = create_label_confusion(test_labels);

success_rate_test = 100*score_test/length(test_labels);
success_rate_train = 100*score_train/length(train_labels);

disp(['LDA performance : Test accuracy = ',num2str(success_rate_test),'% with a train/test ration of ',num2str(100*trainrat),'%']);
disp(['LDA performance : Train accuracy = ',num2str(success_rate_train),'% with a train/test ration of ',num2str(100*trainrat),'%']);

plotconfusion(train_truth, train_predicted);
figure
plotconfusion(test_truth,test_predicted);

%% Visualize the data

[LTrans,Lambda] = eig(Model.BetweenSigma,Model.Sigma,'chol');
[Lambda,sorted] = sort(diag(Lambda),'descend'); 
LTrans = LTrans(:,sorted);
LTrans = LTrans(:,1);

X_projected = Model.XCentered*LTrans;
scatter(X_projected, ones(1,length(X_projected)), 10, train_labels)


%% Binary LDA classifier per TW

numb_TW = 6;
trainrat = 0.8;
success_rate_test =  [];
success_rate_train = [];

for crossvalid = 1:1:5
    for n=1:1:numb_TW
        data = [];
        labels = [];

        for i=1:1:length(feature_struct.features)
            if (length(feature_struct.features{i}) >= n)
                data = [data, feature_struct.features{i}{n}];
                labels = [labels, feature_struct.labels{i}];
            end
        end

        data = data';
        labels = labels';

        p = randperm(length(labels));
        frontier = round(length(labels)*trainrat);

        train_data = data(p(1:frontier),:);
        test_data = data(p(frontier:end),:);

        train_labels = labels(p(1:frontier));
        test_labels = labels(p(frontier:end));

         train_labels(find(train_labels == 2)) = 1; %BINARY
         test_labels(find(test_labels==2)) = 1;

        Model = fitcdiscr(train_data,train_labels);

        score_test = 0;
        score_train = 0;

        train_predicted = [];
        test_predicted = [];

        for i=1:length(train_labels)
           hit = predict(Model,train_data(i,:));
           train_predicted(end+1) = hit;
           if hit==train_labels(i)
               score_train = score_train + 1;
           end
        end


        for i=1:length(test_labels)
           hit = predict(Model,test_data(i,:)); 
           test_predicted(end+1) = hit;
           if hit==test_labels(i)
               score_test = score_test + 1;
           end
        end

        train_predicted = create_label_confusion(train_predicted');
        test_predicted = create_label_confusion(test_predicted');

        train_truth = create_label_confusion(train_labels);
        test_truth = create_label_confusion(test_labels);


        success_rate_test(crossvalid,n) = 100*score_test/length(test_labels);
        success_rate_train(crossvalid,n) = 100*score_train/length(train_labels);

        %plotconfusion(test_truth,test_predicted);
    end
end

st_deviation_test = std(success_rate_test);
st_deviation_train = std(success_rate_train);

errorbar(mean(success_rate_train), st_deviation_train);
grid on; hold on
errorbar(mean(success_rate_test), st_deviation_test);
legend('Success rate train set', 'Success rate test set');
xlabel('Time Window')
ylabel('Success rate (%)')
title('LDA Binary classifier grasp/no-grasp on all the Time Windows')


