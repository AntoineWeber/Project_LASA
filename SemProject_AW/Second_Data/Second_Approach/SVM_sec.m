%% Load the data

clc
clear all
close all

% load data for the second approach
load('data_2approach.mat');

%% Extract features
% consider 3 phases
nb_phase = 3;

feature_struct = {};
set = {};
labels = {};

for sess=1:1:length(Fin_EMG)
    
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
    
    % compute features per TW
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
    
    % now divide the features by their respective MVC
    for i=1:1:length(Fin_EMG{sess}.signal)
        for phase=1:1:nb_phase
            temp = segment_data(Fin_EMG{sess}.signal{i}{phase},300,75); 
            for h=1:1:length(temp)
                feature_struct{sess}.features{i}{phase}{h}(1,:) = feature_struct{sess}.features{i}{phase}{h}(1,:)./maxMAV;
                feature_struct{sess}.features{i}{phase}{h}(2,:) = feature_struct{sess}.features{i}{phase}{h}(2,:)./maxSC;
                feature_struct{sess}.features{i}{phase}{h}(3,:) = feature_struct{sess}.features{i}{phase}{h}(3,:)./maxWL;

                % concatenate features into 1 vector per TW
                feature_struct{sess}.features{i}{phase}{h} = reshape(feature_struct{sess}.features{i}{phase}{h},[],1);
                temp_set{phase} = [temp_set{phase}; feature_struct{sess}.features{i}{phase}{h}'];
                temp_labels{phase} = [temp_labels{phase}; Fin_EMG{sess}.labels(i)];
            end
        end
    end
    
    set{sess} = temp_set;
    labels{sess} = temp_labels;
    
end

%% Create embedding
% mix all the phases to take data from everywhere
data = {};
target = {};
for sess=1:1:length(Fin_EMG)
    data{sess} = [];
    target{sess} = [];
    for phase=1:1:nb_phase
        data{sess} = [data{sess}; set{sess}{phase}];
        target{sess} = [target{sess}; labels{sess}{phase}];
    end
end

train_data_tot = {};
test_data_tot = {};
train_labels_tot = {};
test_labels_tot = {};
trainrat = 0.6;

% take 60% of the data to compute embedding
for sess = 1:1:length(Fin_EMG)
        p = randperm(length(target{sess}));
        frontier = round(length(target{sess})*trainrat);

        train_data_tot{sess} = data{sess}(p(1:frontier),:);
        test_data_tot{sess} = data{sess}(p(frontier:end),:);

        train_labels_tot{sess} = target{sess}(p(1:frontier));
        test_labels_tot{sess} = target{sess}(p(frontier:end));
end

sess = 1;
% compute embedding with train data
[sLDA, WLDA, M, WPCA]=mylda(train_data_tot{sess},train_labels_tot{sess}+1);



%% Apply SVM per phase
%Define session to be analyzed
sess=1;
nblock = 5;

res_test = [];
res_train = [];
success_rate_test_0 =  [];
success_rate_test_1 =  [];
success_rate_test_2 =  [];

% one classifier per phase
for phase=1:1:nb_phase
    
    % split the data of each phase in 5 folds
    [split_data,split_labels] = split_featured_data(set{sess}{phase},labels{sess}{phase},0,0,0,nblock,true);
    
    % crossvalidate
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
        test_labels = split_labels{cross};
        
        % project data
        train_data = (train_data-M)*WPCA*WLDA;
        test_data = (test_data-M)*WPCA*WLDA;
        
        % compute model
        % if LIBSM not installed, will raise an error here.
        model = svmtrain(train_labels, train_data, ['-s 0 -t 2 -g 1 -c 1000']);
        [predicted_label_train,acc_train, prob_estimate_train] = svmpredict(train_labels, train_data, model);
        [predicted_label_test, acc_test, prob_estimate_test] = svmpredict(test_labels,test_data, model);
        
        
        
        % compute scores
        res_train(phase,cross) = acc_train(1);
        res_test(phase,cross) = acc_test(1);
        success_rate_test_0(phase,cross) = 100*sum((predicted_label_test == 0) & (test_labels == 0))/length(find(test_labels==0));
        success_rate_test_1(phase,cross) = 100*sum((predicted_label_test == 1) & (test_labels == 1))/length(find(test_labels==1));
        success_rate_test_2(phase,cross) = 100*sum((predicted_label_test == 2) & (test_labels == 2))/length(find(test_labels==2));

    
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