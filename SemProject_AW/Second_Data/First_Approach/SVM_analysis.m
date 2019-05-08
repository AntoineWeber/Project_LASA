%% Load data and concatenate sessions.
clc
close all


load('New_data.mat');
subj = 1;

% concatenate the sessions
% can be commented to do a per session analysis
EMG_final{subj} = concatenate_emg(EMG_final{subj}); 
Curr_EMG = EMG_final{subj};

%% Extract Features

feature_struct = {};
set = {};
labels = {};

for sess=1:1:length(Curr_EMG)

    feature_struct{sess}.labels = Curr_EMG{sess}.labels;
    feature_struct{sess}.features = {};

    temp_labels = [];
    temp_set = [];

    maxMAV = 0;
    maxSC = 0;
    maxWL = 0;
    
    % this loop is used to compute the MVC 
    for i=1:1:length(Curr_EMG{sess}.signal)
        % segment the signal into time windows
        temp = segment_data(Curr_EMG{sess}.signal{i},300,75); %0.2s timewindows with 50ms overlap
        
        for h=1:1:length(temp)
            % Mean absolute value
            feature_struct{sess}.features{i}{h}(1,:) = mean(abs(temp{h}));
            % keep the maximum observed value
            if max(abs(feature_struct{sess}.features{i}{h}(1,:)))>maxMAV
                maxMAV = max(abs(feature_struct{sess}.features{i}{h}(1,:)));
            end
            
            % number of slope changes
            feature_struct{sess}.features{i}{h}(2,:) = sum((diff(sign(diff(temp{h},1,1)),1,1)~=0),1); 
            % keep the maximum observed value
            if max(abs(feature_struct{sess}.features{i}{h}(2,:)))>maxSC
                maxSC = max(abs(feature_struct{sess}.features{i}{h}(2,:)));
            end
            
            % waveform length
            feature_struct{sess}.features{i}{h}(3,:) = sum(abs(diff(temp{h},1,1)),1); 
            if max(abs(feature_struct{sess}.features{i}{h}(3,:)))>maxWL
                % keep the maximum observed value
                maxWL = max(abs(feature_struct{sess}.features{i}{h}(3,:)));
            end
        end
    end

    % now divide each features of each signal by it's MVC
    for i=1:1:length(Curr_EMG{sess}.signal)
        temp = segment_data(Curr_EMG{sess}.signal{i},300,75);
        for h=1:1:length(temp)
            feature_struct{sess}.features{i}{h}(1,:) = feature_struct{sess}.features{i}{h}(1,:)./maxMAV;
            feature_struct{sess}.features{i}{h}(2,:) = feature_struct{sess}.features{i}{h}(2,:)./maxSC;
            feature_struct{sess}.features{i}{h}(3,:) = feature_struct{sess}.features{i}{h}(3,:)./maxWL;

            % concatenate everything to form a vector of features per time
            % window
            feature_struct{sess}.features{i}{h} = reshape(feature_struct{sess}.features{i}{h},[],1);
            % matrices containing data
            temp_set = [temp_set, feature_struct{sess}.features{i}{h}];
            temp_labels = [temp_labels, Curr_EMG{sess}.labels(i)];
        end
    end

    temp_set = temp_set';
    temp_labels = temp_labels';
    
    set{sess} = temp_set;
    labels{sess} = temp_labels;
end

%% Separate train/test
train_data = {};
test_data = {};
train_labels = {};
test_labels = {};
trainrat = 0.6; % 60%

% take randomly 60% of tota data to represent the training data and compute
% embedding with this data.
for sess = 1:1:length(Curr_EMG)
    p = randperm(length(labels{sess}));
    frontier = round(length(labels{sess})*trainrat);

    train_data{sess} = set{sess}(p(1:frontier),:);
    test_data{sess} = set{sess}(p(frontier:end),:);

    train_labels{sess} = labels{sess}(p(1:frontier));
    test_labels{sess} = labels{sess}(p(frontier:end));
end

%% Using SVM in the original space is not a good idea. Try finding a nice subspace using DR

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%% Choose the session to work with%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sess = 1;

% the labels should start at 1 for the mylda function.
train_labels_plot = train_labels{sess}+1;
test_labels_plot = test_labels{sess}+1;

% compute LDA embedding using the mylda function
[sLDA, WLDA, M, WPCA]=mylda(train_data{sess},train_labels_plot);

% project data into the embedding
% M and WPCA are actually 0 and 1 respectively.
train_proj = (train_data{sess}-M)*WPCA*WLDA;
test_proj = (test_data{sess}-M)*WPCA*WLDA;
% plot results
gscatter(train_proj(:,1), train_proj(:,2), train_labels_plot);
title('Train ground truth');
legend('Power grasp','Thumb-2 fingers','No grasp');
figure
gscatter(test_proj(:,1), test_proj(:,2), test_labels_plot);
title('Test ground truth');
legend('Power grasp','Thumb-2 fingers','No grasp');

%% Train a SVM classifier for all the time windows

% train the svm classifier using the training data
% here no crossvalidation to only plot the conf matrix.
% if LIBSVM not installed, error will raise here
model = svmtrain(train_labels{sess}, train_proj, ['-s 0 -t 2 -c 100']);

[predicted_label_train,acc_train, prob_estimate_train] = svmpredict(train_labels{sess}, train_proj, model);
[predicted_label_test, acc_test, prob_estimate_test] = svmpredict(test_labels{sess},test_proj, model);

disp(['SVM performance : Test accuracy = ',num2str(acc_test(1)),'% with a train/test ration of ',num2str(100*trainrat),'%']);
disp(['SVM performance : Train accuracy = ',num2str(acc_train(1)),'% with a train/test ration of ',num2str(100*trainrat),'%']);

% create one-hot encoding.
% labels should start at 0
train_predicted_bis = create_label_confusion(predicted_label_train);
test_predicted_bis = create_label_confusion(predicted_label_test);
train_truth = create_label_confusion(train_labels_plot-1);
test_truth = create_label_confusion(test_labels_plot-1);

if exist('set','var')
    clearvars set
end

% plot the confusion matrices
plotconfusion(train_truth, train_predicted_bis);
set(gca,'fontsize',14)
set(findobj(gca,'type','text'),'fontsize',14) 
figure
plotconfusion(test_truth,test_predicted_bis);
set(gca,'fontsize',14)
set(findobj(gca,'type','text'),'fontsize',14)
figure

gscatter(train_proj(:,1), train_proj(:,2), predicted_label_train);
set(gca,'fontsize',14)
title('train computed labels');
legend('Power grasp','Thumb-2 fingers','No grasp');
figure

gscatter(test_proj(:,1), test_proj(:,2), predicted_label_test);
set(gca,'fontsize',14)
title('test computed labels');
legend('Power grasp','Thumb-2 fingers','No grasp');

%% Visualize the results

sv = full(model.SVs);
plot(sv(:,1),sv(:,2),'ko','MarkerSize', 10);
hold on

gscatter(train_proj(:,1),train_proj(:,2),predicted_label_train);
title('Computed train labels')
legend('Support Vectors','Power grasp','Thumb-2 fingers','No grasp')
h = 0.02;
[X1,X2] = meshgrid(min(train_proj(:,1)):h:max(train_proj(:,1)),min(train_proj(:,2)):h:max(train_proj(:,2)));
tobeplot = [X1(:), X2(:)];
[~,~,grid2plot] = svmpredict(ones(length(tobeplot),1),tobeplot, model);
scoreGrid = reshape(grid2plot(:,1),size(X1,1),size(X2,2));
contour(X1,X2,scoreGrid);
scoreGrid = reshape(grid2plot(:,2),size(X1,1),size(X2,2));
contour(X1,X2,scoreGrid);
scoreGrid = reshape(grid2plot(:,3),size(X1,1),size(X2,2));
contour(X1,X2,scoreGrid);
colorbar;
set(gca,'fontsize',12)
%% Crossvalidate a single classifier for all time windows, evaluated per time windows
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sess = 1; % Define the session to be analyzed %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

numb_TW = 6; %6TW representing 0.95 seconds
success_rate_test_0 =  [];
success_rate_train_glob = [];
success_rate_test_glob = [];
success_rate_test_1 =  [];
success_rate_test_2 =  [];
nblock = 5;
nb_classes = sum(unique(train_labels_plot));

%not actually used
trainrat = 0.5;
testrat = 0;
valrat = 0.1;

labels_tot = {};
data_tot = {};

% separate the data of each time windows in 5 folds
for n=1:1:numb_TW
    data = [];
    labels = [];
    
    for i=1:1:length(feature_struct{sess}.features)
        if (length(feature_struct{sess}.features{i}) >= n)
            data = [data, feature_struct{sess}.features{i}{n}];
            labels = [labels, feature_struct{sess}.labels(i)];
        end
    end

    data = data';
    labels = labels';
    
    [data_tot{n},labels_tot{n}] = split_featured_data(data,labels,trainrat,valrat,testrat,nblock);
end

% crossvalidate
for cross = 1:1:nblock
    train_data = [];
    train_labels = [];
    test_data = [];
    test_labels = [];
   
    % this loop is only to compute the classifier using data from all the
    % time windows.
    for n=1:1:numb_TW
        for i=1:1:nblock
            if i==cross
                continue
            else
                train_data = [train_data; data_tot{n}{i}];
                train_labels = [train_labels; labels_tot{n}{i}'];
            end
        end
    end
    % project data and compute classifier with projected data.
    % hyperparameters found through grid search.
    train_data = (train_data-M)*WPCA*WLDA;
    % if LIBSVM not installed, error will raise here
    model = svmtrain(train_labels, train_data, ['-s 0 -t 2 -c 100']);
    
    % now test it per time window
    for n=1:1:numb_TW
        train_data = [];
        train_labels = [];
        test_data = [];
        test_labels = [];
        
        % load train and test data per time window
        for i=1:1:nblock
            if i==cross
                continue
            else
                train_data = [train_data; data_tot{n}{i}];
                train_labels = [train_labels; labels_tot{n}{i}'];
            end
        end
        test_data = data_tot{n}{cross};
        test_labels = labels_tot{n}{cross}';
        
        % project data
        train_data = (train_data-M)*WPCA*WLDA;
        test_data = (test_data-M)*WPCA*WLDA;
        
        % compute score
        [predicted_label_train,acc_train, prob_estimate_train] = svmpredict(train_labels, train_data, model);
        [predicted_label_test, acc_test, prob_estimate_test] = svmpredict(test_labels,test_data, model);

        success_rate_test_0(cross,n) = 100*sum((predicted_label_test == 0) & (test_labels == 0))/length(find(test_labels==0));
        success_rate_test_1(cross,n) = 100*sum((predicted_label_test == 1) & (test_labels == 1))/length(find(test_labels==1));
        success_rate_test_2(cross,n) = 100*sum((predicted_label_test == 2) & (test_labels == 2))/length(find(test_labels==2));
        success_rate_train_glob(cross,n) = acc_train(1);
        success_rate_test_glob(cross,n) = acc_test(1);

    end
end

% plot section

st_deviation_test_0 = std(success_rate_test_0);
st_deviation_train = std(success_rate_train_glob);
st_deviation_test = std(success_rate_test_glob);
st_deviation_test_1 = std(success_rate_test_1);
st_deviation_test_2 = std(success_rate_test_2);

bounds = cat(3,repmat(st_deviation_train',[1,2]),repmat(st_deviation_test_0',[1,2]),repmat(st_deviation_test_1',[1,2]),repmat(st_deviation_test_2',[1,2]));

time = [200,350,500,650,800,950];
boundedline(time,[mean(success_rate_train_glob);mean(success_rate_test_0);mean(success_rate_test_1);mean(success_rate_test_2)], bounds,'alpha');
grid on;
legend('Train, all', 'Test, power grasp', 'Test, thumb-2 fingers', 'Test, no grasp');
xlabel('Time [ms]')
ylabel('Success rate (%)')
title('Single SVM classifier')

figure
bounds = cat(3,repmat(st_deviation_train',[1,2]),repmat(st_deviation_test',[1,2]));
boundedline(time,[mean(success_rate_train_glob);mean(success_rate_test_glob)], bounds,'alpha');
grid on;
legend('Train, all', 'Test, all');
xlabel('Time [ms]')
ylabel('Success rate (%)')
title('Single SVM classifier')

%% Implement SVM per TW

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sess = 1; % Define the session to be analyzed %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

numb_TW = 6; %6TW representing 0.95 seconds
success_rate_test_0 =  [];
success_rate_train_glob = [];
success_rate_test_glob = [];
success_rate_test_1 =  [];
success_rate_test_2 =  [];
nblock = 5;
nb_classes = sum(unique(train_labels_plot));

%not actually used
trainrat = 0.5;
testrat = 0;
valrat = 0.1;


% train one classifier per time window
for n=1:1:numb_TW
    data = [];
    labels = [];
    
    % extract data of the current time window
    for i=1:1:length(feature_struct{sess}.features)
        if (length(feature_struct{sess}.features{i}) >= n)
            data = [data, feature_struct{sess}.features{i}{n}];
            labels = [labels, feature_struct{sess}.labels(i)];
        end
    end

    data = data';
    labels = labels';
    
    % do not implement a validation set.
    [split_data,split_labels] = split_featured_data(data,labels,trainrat,valrat,testrat,nblock);
    
    % now crossvalidate per time window
    for cross = 1:1:nblock
        train_data = [];
        train_labels = [];
        test_data = [];
        test_labels = [];
        
        % extract train and test data.
        for i=1:1:nblock
            if i==cross
                continue
            else
                train_data = [train_data; split_data{i}];
                train_labels = [train_labels; split_labels{i}'];
            end
        end
        test_data = split_data{cross};
        test_labels = split_labels{cross}';

        % project data
        train_data = (train_data-M)*WPCA*WLDA;
        test_data = (test_data-M)*WPCA*WLDA;

        % train model
        model = svmtrain(train_labels, train_data, ['-s 0 -t 2 -g 1 -c 1000']);
        [predicted_label_train,acc_train, prob_estimate_train] = svmpredict(train_labels, train_data, model);
        [predicted_label_test, acc_test, prob_estimate_test] = svmpredict(test_labels,test_data, model);

        %comment if you do not want the plots of labeled projected points
        if cross == 1          
            gscatter(train_data(:,1), train_data(:,2), train_labels);
            title(['Train ground truth for TW number ', num2str(n)]);
            legend('Power grasp','Thumb-2 fingers','No grasp');
            figure

            gscatter(test_data(:,1), test_data(:,2), test_labels);
            title(['Test ground truth for TW number ', num2str(n)]);
            legend('Power grasp','Thumb-2 fingers','No grasp');
            figure

            gscatter(train_data(:,1), train_data(:,2), predicted_label_train);
            title(['train computed labels for TW number ', num2str(n)]);
            legend('Power grasp','Thumb-2 fingers','No grasp');
            figure

            gscatter(test_data(:,1), test_data(:,2), predicted_label_test);
            title(['test computed labels for TW number ', num2str(n)]);
            legend('Power grasp','Thumb-2 fingers','No grasp');
            figure
        end
        
        % compute score
        success_rate_test_0(cross,n) = 100*sum((predicted_label_test == 0) & (test_labels == 0))/length(find(test_labels==0));
        success_rate_test_1(cross,n) = 100*sum((predicted_label_test == 1) & (test_labels == 1))/length(find(test_labels==1));
        success_rate_test_2(cross,n) = 100*sum((predicted_label_test == 2) & (test_labels == 2))/length(find(test_labels==2));
        success_rate_train_glob(cross,n) = acc_train(1);
        success_rate_test_glob(cross,n) = acc_test(1);

    end
end

% plot section

st_deviation_test_0 = std(success_rate_test_0);
st_deviation_train = std(success_rate_train_glob);
st_deviation_test = std(success_rate_test_glob);
st_deviation_test_1 = std(success_rate_test_1);
st_deviation_test_2 = std(success_rate_test_2);

bounds = cat(3,repmat(st_deviation_train',[1,2]),repmat(st_deviation_test_0',[1,2]),repmat(st_deviation_test_1',[1,2]),repmat(st_deviation_test_2',[1,2]));
time = [200,350,500,650,800,950];
boundedline(time,[mean(success_rate_train_glob);mean(success_rate_test_0);mean(success_rate_test_1);mean(success_rate_test_2)], bounds,'alpha');
grid on;
legend('Train, all', 'Test, power grasp', 'Test, thumb-2 fingers', 'Test, no grasp');
xlabel('Time [ms]')
ylabel('Success rate (%)')
title('SVM classifier per Time Window')
figure

bounds = cat(3,repmat(st_deviation_train',[1,2]),repmat(st_deviation_test',[1,2]));
boundedline(time,[mean(success_rate_train_glob);mean(success_rate_test_glob)], bounds,'alpha');
grid on;
legend('Train, all', 'Test, all');
xlabel('Time [ms]')
ylabel('Success rate (%)')
title('SVM classifier per Time Window')