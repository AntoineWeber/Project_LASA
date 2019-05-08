%% Load the data

clc
clear all
close all

% load data for the second approach
load('data_2approach.mat');

%% Extract features

% define number of phases
nb_phase = 3;

feature_struct = {};
set = {};
labels = {};

for sess=1:1:length(Fin_EMG)
    
    % initializations
    feature_struct{sess}.labels = Fin_EMG{sess}.labels;
    feature_struct{sess}.features = {};

    temp_labels = {};
    temp_set = {};
    
    for b=1:1:nb_phase
        temp_labels{b} = [];
        temp_set{b} = [];
    end
    

    maxMAV = 0;
    maxSC = 0;
    maxWL = 0;
    
    % compute features per tw and keep maximum value
    for trial=1:1:length(Fin_EMG{sess}.signal)
        for phase=1:1:nb_phase
            % same time window definition
            temp = segment_data(Fin_EMG{sess}.signal{trial}{phase},300,75); 
            for h=1:1:length(temp)
                % Mean absolute value
                feature_struct{sess}.features{trial}{phase}{h}(1,:) = mean(abs(temp{h})); 
                if max(abs(feature_struct{sess}.features{trial}{phase}{h}(1,:)))>maxMAV
                    % keep maximum observed value
                    maxMAV = max(abs(feature_struct{sess}.features{trial}{phase}{h}(1,:)));
                end
                % number of slope changes
                feature_struct{sess}.features{trial}{phase}{h}(2,:) = sum((diff(sign(diff(temp{h},1,1)),1,1)~=0),1); 
                if max(abs(feature_struct{sess}.features{trial}{phase}{h}(2,:)))>maxSC
                    % keep maximum observed value
                    maxSC = max(abs(feature_struct{sess}.features{trial}{phase}{h}(2,:)));
                end

                % waveform length
                feature_struct{sess}.features{trial}{phase}{h}(3,:) = sum(abs(diff(temp{h},1,1)),1); 
                if max(abs(feature_struct{sess}.features{trial}{phase}{h}(3,:)))>maxWL
                    % keep maximum observed value
                    maxWL = max(abs(feature_struct{sess}.features{trial}{phase}{h}(3,:)));
                end
            end
        end
    end
    
    % divide each features by their MVC
    for i=1:1:length(Fin_EMG{sess}.signal)
        for phase=1:1:nb_phase
            temp = segment_data(Fin_EMG{sess}.signal{i}{phase},300,75);
            for h=1:1:length(temp)
                feature_struct{sess}.features{i}{phase}{h}(1,:) = feature_struct{sess}.features{i}{phase}{h}(1,:)./maxMAV;
                feature_struct{sess}.features{i}{phase}{h}(2,:) = feature_struct{sess}.features{i}{phase}{h}(2,:)./maxSC;
                feature_struct{sess}.features{i}{phase}{h}(3,:) = feature_struct{sess}.features{i}{phase}{h}(3,:)./maxWL;

                % concatenate features into 1 single vector per TW
                feature_struct{sess}.features{i}{phase}{h} = reshape(feature_struct{sess}.features{i}{phase}{h},[],1);
                temp_set{phase} = [temp_set{phase}; feature_struct{sess}.features{i}{phase}{h}'];
                temp_labels{phase} = [temp_labels{phase}; Fin_EMG{sess}.labels(i)];
            end
        end
    end
    
    set{sess} = temp_set;
    labels{sess} = temp_labels;
    
end

%% Apply LDA per phase
%Define session to be analyzed
sess=1;
nblock = 5;

res_test = [];
res_train = [];
success_rate_test_0 =  [];
success_rate_test_1 =  [];
success_rate_test_2 =  [];

% one classifier per phase.
for phase=1:1:nb_phase
    
    % split data into 5 folds
    [split_data,split_labels] = split_featured_data(set{sess}{phase},labels{sess}{phase},0,0,0,nblock,true);
    
    for cross=1:1:nblock
        train_data = [];
        train_labels = [];
        test_data = [];
        test_labels = [];

        % extract train and test data
        for i=1:1:nblock
            if i==cross
                continue
            else
                train_data = [train_data; split_data{i}];
                train_labels = [train_labels; split_labels{i}];
            end
        end
        test_data = split_data{cross};
        test_labels = split_labels{cross}';

        %LDA
        Model = fitcdiscr(train_data,train_labels,'DiscrimType','linear');
        
        score_test_0 = 0;
        score_train = 0;
        score_test = 0;
        score_test_1 = 0;
        score_test_2 = 0;


        train_predicted = [];
        test_predicted = [];

        % train score
        for i=1:length(train_labels)
           hit = predict(Model,train_data(i,:));
           train_predicted(end+1) = hit;
           if hit==train_labels(i)
               score_train = score_train + 1;
           end
        end

        % test score per grasp type
        for i=1:length(test_labels)
           hit = predict(Model,test_data(i,:)); 
           test_predicted(end+1) = hit;
           switch test_labels(i)
               case 0
                   if hit==test_labels(i)
                       score_test_0 = score_test_0 + 1;
                       score_test = score_test + 1;
                   end
               case 1
                   if hit==test_labels(i)
                       score_test_1 = score_test_1 + 1;
                       score_test = score_test + 1;
                   end
               case 2
                   if hit==test_labels(i)
                       score_test_2 = score_test_2 + 1;
                       score_test = score_test + 1;
                   end
           end
        end
        
        res_train(phase,cross) = 100*score_train/length(train_labels);
        res_test(phase,cross) = 100*score_test/length(test_labels);
        success_rate_test_0(phase,cross) = 100*score_test_0/length(find(test_labels==0));
        success_rate_test_1(phase,cross) = 100*score_test_1/length(find(test_labels==1));
        success_rate_test_2(phase,cross) = 100*score_test_2/length(find(test_labels==2));
    
    end
end

% plot section

moy_train = mean(res_train, 2);
std_train = std(res_train,0,2);
moy_test = mean(res_test, 2);
std_test = std(res_test,0,2);

boxplot(res_train', 'Labels',{'Phase 1', 'Phase 2', 'Phase 3'})
grid on
title('train')
ylabel('Accuracy [%]')
if exist('set','var')
    clearvars set
end
set(gca,'fontsize',14)
figure
boxplot(res_test', 'Labels',{'Phase 1', 'Phase 2', 'Phase 3'})
grid on
title('test')
ylabel('Accuracy [%]')
set(gca,'fontsize',14)