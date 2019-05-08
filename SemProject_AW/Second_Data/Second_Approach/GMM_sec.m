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
    
    % compute features per grasp type and keep MVC
    for trial=1:1:length(Fin_EMG{sess}.signal)
        for phase=1:1:nb_phase
            % careful : for gmm, I had to implement slightly smaller time windows
            % to ensure that enough data points of each grasp type was
            % present to compute the gaussians. If one tries to use 200ms
            % time windows, an error will pop up.
            temp = segment_data(Fin_EMG{sess}.signal{trial}{phase},250,75); 
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
    
    % divide each features by their MVC.
    for i=1:1:length(Fin_EMG{sess}.signal)
        for phase=1:1:nb_phase
            temp = segment_data(Fin_EMG{sess}.signal{i}{phase},250,75); 
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

%% Create embedding
% concatenate data from all the phases to take data from everywhere to
% compute embedding.
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

% compute embedding with 60% of the data representing the train set.
for sess = 1:1:length(Fin_EMG)
        p = randperm(length(target{sess}));
        frontier = round(length(target{sess})*trainrat);

        train_data_tot{sess} = data{sess}(p(1:frontier),:);
        test_data_tot{sess} = data{sess}(p(frontier:end),:);

        train_labels_tot{sess} = target{sess}(p(1:frontier));
        test_labels_tot{sess} = target{sess}(p(frontier:end));
end

sess = 1;
% compute embedding
[sLDA, WLDA, M, WPCA]=mylda(train_data_tot{sess},train_labels_tot{sess}+1);


%% Apply GMM per phase
%Define session to be analyzed
sess=1;
nblock = 5;

how_many_comp = 1;
nb_classes = 3;

res_test = [];
res_train = [];

% one classifier per phase
for phase=1:1:nb_phase
    
    % split data in 5 folds
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
        
        % compute mixtures per grasp type
        GMModel1 = fitgmdist(train_data(train_labels==0,:),how_many_comp);
        GMModel2 = fitgmdist(train_data(train_labels==1,:),how_many_comp);
        GMModel3 = fitgmdist(train_data(train_labels==2,:),how_many_comp);
        % create associated functions
        func1 = @(x,y) pdf(GMModel1,[x y]);
        func2 = @(x,y) pdf(GMModel2,[x y]);
        func3 = @(x,y) pdf(GMModel3,[x y]);
        
        % initializations
        score_test_0 = 0;
        score_test = 0;
        score_test_1 = 0;
        score_test_2 = 0;

        values = zeros(1,nb_classes);
        train_computed_labels = zeros(length(train_data),1);
        test_computed_labels = zeros(length(test_data),1);

        % train score
        for i=1:1:length(train_data)
            values(1) = func1(train_data(i,1),train_data(i,2));
            values(2) = func2(train_data(i,1),train_data(i,2));
            values(3) = func3(train_data(i,1),train_data(i,2));
            [~,train_computed_labels(i)] = max(values);
        end
        % -1 for the labels to start at 0
        train_computed_labels = train_computed_labels - 1;
        
        score_train = sum(train_labels == train_computed_labels);
        
        % test score per grasp type
        for i=1:1:length(test_data)
            values(1) = func1(test_data(i,1),test_data(i,2));
            values(2) = func2(test_data(i,1),test_data(i,2));
            values(3) = func3(test_data(i,1),test_data(i,2));
            [~,test_computed_labels(i)] = max(values);
            % -1 for the labels to start at 0
            test_computed_labels(i) = test_computed_labels(i) - 1;
            switch test_computed_labels(i)
                case 0
                    if test_computed_labels(i) == test_labels(i)
                        score_test_0 = score_test_0 + 1;
                        score_test = score_test + 1;
                    end
                case 1
                    if test_computed_labels(i) == test_labels(i)
                        score_test_1 = score_test_1 + 1;
                        score_test = score_test + 1;
                    end
                case 2
                    if test_computed_labels(i) == test_labels(i)
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