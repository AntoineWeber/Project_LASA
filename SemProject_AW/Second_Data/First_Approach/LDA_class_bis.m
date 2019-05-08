%% Try performing LDA using 3 features
% load the data

clc
close all

load('New_data.mat');
subj = 1;

%% concatenate all the sessions
% can be commented to do a per session analysis

EMG_final{subj} = concatenate_emg(EMG_final{subj}); 
Curr_EMG = EMG_final{subj};

%% extract features
feature_struct = {};
set = {};
labels = {};

for sess=1:1:length(Curr_EMG)

    feature_struct{sess}.labels = Curr_EMG{sess}.labels;
    feature_struct{sess}.features = {};

    temp_labels = [];
    temp_set = [];

    % variable to contain the MVC
    maxMAV = 0;
    maxSC = 0;
    maxWL = 0;
    
    for i=1:1:length(Curr_EMG{sess}.signal)
        % 0.2s timewindows with 50ms overlap
        temp = segment_data(Curr_EMG{sess}.signal{i},300,75); 
        
        for h=1:1:length(temp)
            % Mean absolute value
            feature_struct{sess}.features{i}{h}(1,:) = mean(abs(temp{h})); 
            if max(abs(feature_struct{sess}.features{i}{h}(1,:)))>maxMAV
                % store max observed value
                maxMAV = max(abs(feature_struct{sess}.features{i}{h}(1,:)));
            end
            
            % number of slope changes
            feature_struct{sess}.features{i}{h}(2,:) = sum((diff(sign(diff(temp{h},1,1)),1,1)~=0),1); 
            if max(abs(feature_struct{sess}.features{i}{h}(2,:)))>maxSC
                % store max observed value
                maxSC = max(abs(feature_struct{sess}.features{i}{h}(2,:)));
            end
            
            % waveform length
            feature_struct{sess}.features{i}{h}(3,:) = sum(abs(diff(temp{h},1,1)),1); 
            if max(abs(feature_struct{sess}.features{i}{h}(3,:)))>maxWL
                % store max observed value
                maxWL = max(abs(feature_struct{sess}.features{i}{h}(3,:)));
            end
        end
    end

    
    % divide features by their respective MVC
    for i=1:1:length(Curr_EMG{sess}.signal)
        temp = segment_data(Curr_EMG{sess}.signal{i},300,75);
        for h=1:1:length(temp)
            feature_struct{sess}.features{i}{h}(1,:) = feature_struct{sess}.features{i}{h}(1,:)./maxMAV;
            feature_struct{sess}.features{i}{h}(2,:) = feature_struct{sess}.features{i}{h}(2,:)./maxSC;
            feature_struct{sess}.features{i}{h}(3,:) = feature_struct{sess}.features{i}{h}(3,:)./maxWL;

            % concatenate the features into 1 vector for each time window
            feature_struct{sess}.features{i}{h} = reshape(feature_struct{sess}.features{i}{h},[],1);
            temp_set = [temp_set, feature_struct{sess}.features{i}{h}];
            temp_labels = [temp_labels, Curr_EMG{sess}.labels(i)];
        end
    end

    temp_set = temp_set';
    temp_labels = temp_labels';
    
    set{sess} = temp_set;
    labels{sess} = temp_labels;
end


%% separate train and test sets
train_data = {};
test_data = {};
train_labels = {};
test_labels = {};

% take 60% of the total data to compute embedding with the train set
for sess = 1:1:length(Curr_EMG)
    p = randperm(length(labels{sess}));
    trainrat = 0.6; % 60% train 40% test
    frontier = round(length(labels{sess})*trainrat);

    train_data{sess} = set{sess}(p(1:frontier),:);
    test_data{sess} = set{sess}(p(frontier:end),:);

    train_labels{sess} = labels{sess}(p(1:frontier));
    test_labels{sess} = labels{sess}(p(frontier:end));
end

%% Now compute the LDA classifier and test accuracy
%% for all the time windows at once

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sess = 1; % Define the session to be analyzed %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


train_labels_sess = train_labels{sess};
test_labels_sess = test_labels{sess};

%LDA
Model = fitcdiscr(train_data{sess},train_labels_sess,'DiscrimType','linear');

score_test = 0;
score_train = 0;


train_predicted = [];
test_predicted = [];

% compute train score
for i=1:length(train_labels_sess)
   hit = predict(Model,train_data{sess}(i,:));
   train_predicted(end+1) = hit;
   if hit==train_labels_sess(i)
       score_train = score_train + 1;
   end
end

% compute test score
for i=1:length(test_labels_sess)
   hit = predict(Model,test_data{sess}(i,:)); 
   test_predicted(end+1) = hit;
   if hit==test_labels_sess(i)
       score_test = score_test + 1;
   end
end

% create one-hot encoding 
train_predicted_bis = create_label_confusion(train_predicted');
test_predicted_bis = create_label_confusion(test_predicted');

train_truth = create_label_confusion(train_labels_sess);
test_truth = create_label_confusion(test_labels_sess);

% compute score
success_rate_test = 100*score_test/length(test_labels_sess);
success_rate_train_glob = 100*score_train/length(train_labels_sess);

disp(['LDA performance : Test accuracy = ',num2str(success_rate_test),'% with a train/test ration of ',num2str(100*trainrat),'%']);
disp(['LDA performance : Train accuracy = ',num2str(success_rate_train_glob),'% with a train/test ration of ',num2str(100*trainrat),'%']);
if exist('set','var')
    clearvars set
end
plotconfusion(train_truth, train_predicted_bis);
set(gca,'fontsize',14)
set(findobj(gca,'type','text'),'fontsize',14) 
figure
plotconfusion(test_truth,test_predicted_bis);
set(gca,'fontsize',14)
set(findobj(gca,'type','text'),'fontsize',14) 

%% Visualize the data

sess = 1;

% the labels should start at 1 here
train_labels_plot = train_labels_sess+1;
test_labels_plot = test_labels_sess+1;
% compute LDA embedding
[sLDA WLDA M WPCA]=mylda(train_data{sess},train_labels_plot);

% project data
train_proj = (train_data{sess}-M)*WPCA*WLDA;
test_proj = (test_data{sess}-M)*WPCA*WLDA;

% observe data
gscatter(train_proj(:,1), train_proj(:,2), train_labels_plot);
set(gca,'fontsize',14)
title('Train ground truth');
legend('Power grasp','Thumb-2 fingers','No grasp');
figure

gscatter(test_proj(:,1), test_proj(:,2), test_labels_plot);
set(gca,'fontsize',14)
title('Test ground truth');
legend('Power grasp','Thumb-2 fingers','No grasp');
figure

gscatter(train_proj(:,1), train_proj(:,2), train_predicted);
set(gca,'fontsize',14)
title('train computed labels');
legend('Power grasp','Thumb-2 fingers','No grasp');
figure

gscatter(test_proj(:,1), test_proj(:,2), test_predicted);
set(gca,'fontsize',14)
title('test computed labels');
legend('Power grasp','Thumb-2 fingers','No grasp');

%% Evalutate one single LDA classifier on all the time windows

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

%not actually used
trainrat = 0.5;
testrat = 0;
valrat = 0.1;

labels_tot = {};
data_tot = {};

% separate the data of each time windows in 5 blocks
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
    % compute model using data from all the time windows
    Model = fitcdiscr(train_data,train_labels,'DiscrimType','linear');
    
    % now compute score per time windows
    for n=1:1:numb_TW
        train_data = [];
        train_labels = [];
        test_data = [];
        test_labels = [];
        score_test_0 = 0;
        score_train = 0;
        score_test = 0;
        score_test_1 = 0;
        score_test_2 = 0;
        
        % extract train and test data per time window
        for i=1:1:nblock
            if i==cross
                continue
            else
                train_data = [train_data; data_tot{n}{i}];
                train_labels = [train_labels; labels_tot{n}{i}'];
            end
        end
        test_data = data_tot{n}{cross};
        test_labels = labels_tot{n}{cross};

        train_predicted = [];
        test_predicted = [];
        
        % compute prediction
        for i=1:length(train_labels)
            hit = predict(Model,train_data(i,:));
            train_predicted(end+1) = hit;
            if hit==train_labels(i)
                score_train = score_train + 1;
            end
        end

        % for the test labels, compute prediction per grasp type and
        % overall
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
        
        % compute final scores
        success_rate_test_0(cross,n) = 100*score_test_0/length(find(test_labels==0));
        success_rate_train_glob(cross,n) = 100*score_train/length(train_labels);
        success_rate_test_glob(cross,n) = 100*score_test/length(test_labels);
        success_rate_test_1(cross,n) = 100*score_test_1/length(find(test_labels==1));
        success_rate_test_2(cross,n) = 100*score_test_2/length(find(test_labels==2));
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
title('Single LDA classifier')
set(gca,'fontsize',14)
figure

grid on;
legend('Train, all', 'Test, all');
xlabel('Time [ms]')
ylabel('Success rate (%)')
title('Single LDA classifier')
set(gca,'fontsize',14)
bounds = cat(3,repmat(st_deviation_train',[1,2]),repmat(st_deviation_test',[1,2]));
boundedline(time,[mean(success_rate_train_glob);mean(success_rate_test_glob)], bounds,'alpha');

%% LDA CLASSIFIER PER TIME WINDOW

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
    
    % crossvalidate per time window
    for cross = 1:1:nblock
        train_data = [];
        train_labels = [];
        test_data = [];
        test_labels = [];
        
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

        % compute LDA classifier
        %LDA
        Model = fitcdiscr(train_data,train_labels,'DiscrimType','linear');

        score_test_0 = 0;
        score_train = 0;
        score_test = 0;
        score_test_1 = 0;
        score_test_2 = 0;

        train_predicted = [];
        test_predicted = [];
        
        % compute train score
        for i=1:length(train_labels)
            hit = predict(Model,train_data(i,:));
            train_predicted(end+1) = hit;
            if hit==train_labels(i)
                score_train = score_train + 1;
            end
        end

        % compute test score per grasp type and overall
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


        %comment if you do not want the plots of labeled projected points
        if cross == 1
            train_labels_plot = train_labels+1;
            test_labels_plot = test_labels+1;
            [sLDA WLDA M WPCA]=mylda(train_data,train_labels_plot);
            train_proj = (train_data-M)*WPCA*WLDA;
            test_proj = (test_data-M)*WPCA*WLDA;
            
            gscatter(train_proj(:,1), train_proj(:,2), train_labels_plot);
            title(['Train ground truth for TW number ', num2str(n)]);
            legend('Power grasp','Thumb-2 fingers','No grasp');
            figure

            gscatter(test_proj(:,1), test_proj(:,2), test_labels_plot);
            title(['Test ground truth for TW number ', num2str(n)]);
            legend('Power grasp','Thumb-2 fingers','No grasp');
            figure

            gscatter(train_proj(:,1), train_proj(:,2), train_predicted);
            title(['train computed labels for TW number ', num2str(n)]);
            legend('Power grasp','Thumb-2 fingers','No grasp');
            figure

            gscatter(test_proj(:,1), test_proj(:,2), test_predicted);
            title(['test computed labels for TW number ', num2str(n)]);
            legend('Power grasp','Thumb-2 fingers','No grasp');
            figure
        end

        success_rate_test_0(cross,n) = 100*score_test_0/length(find(test_labels==0));
        success_rate_train_glob(cross,n) = 100*score_train/length(train_labels);
        success_rate_test_glob(cross,n) = 100*score_test/length(test_labels);
        success_rate_test_1(cross,n) = 100*score_test_1/length(find(test_labels==1));
        success_rate_test_2(cross,n) = 100*score_test_2/length(find(test_labels==2));

    end
end

%plot definition

st_deviation_test_0 = std(success_rate_test_0);
st_deviation_train = std(success_rate_train_glob);
st_deviation_test = std(success_rate_test_glob);
st_deviation_test_1 = std(success_rate_test_1);
st_deviation_test_2 = std(success_rate_test_2);

bounds = cat(3,repmat(st_deviation_train',[1,2]),repmat(st_deviation_test_0',[1,2]),repmat(st_deviation_test_1',[1,2]),repmat(st_deviation_test_2',[1,2]));
time = [200,350,500,650,800,950];
boundedline(time,[mean(success_rate_train_glob);mean(success_rate_test_0);mean(success_rate_test_1);mean(success_rate_test_2)], bounds,'alpha');
grid on; hold on
legend('Train, all', 'Test, power grasp', 'Test, thumb-2 fingers', 'Test, no grasp');
xlabel('Time [ms]')
ylabel('Success rate (%)')
title('LDA classifier per Time Window')

figure
bounds = cat(3,repmat(st_deviation_train',[1,2]),repmat(st_deviation_test',[1,2]));
boundedline(time,[mean(success_rate_train_glob);mean(success_rate_test_glob)], bounds,'alpha');
grid on;
legend('Train, all', 'Test, all');
xlabel('Time [ms]')
ylabel('Success rate (%)')
title('LDA classifier per Time Window')



