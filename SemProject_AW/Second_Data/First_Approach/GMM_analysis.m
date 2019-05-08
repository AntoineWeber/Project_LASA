%%%%%%%%%%%
clc
close all


load('New_data.mat');
subj = 1;

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
    
    for i=1:1:length(Curr_EMG{sess}.signal)
        % 0.2s timewindows with 50ms overlap
        temp = segment_data(Curr_EMG{sess}.signal{i},300,75); 
        
        for h=1:1:length(temp)
            % Mean absolute value
            feature_struct{sess}.features{i}{h}(1,:) = mean(abs(temp{h})); 
            if max(abs(feature_struct{sess}.features{i}{h}(1,:)))>maxMAV
                % keep maximum observed value
                maxMAV = max(abs(feature_struct{sess}.features{i}{h}(1,:)));
            end

            % number of slope changes
            feature_struct{sess}.features{i}{h}(2,:) = sum((diff(sign(diff(temp{h},1,1)),1,1)~=0),1); 
            if max(abs(feature_struct{sess}.features{i}{h}(2,:)))>maxSC
                % keep maximum observed value
                maxSC = max(abs(feature_struct{sess}.features{i}{h}(2,:)));
            end

            % waveform length
            feature_struct{sess}.features{i}{h}(3,:) = sum(abs(diff(temp{h},1,1)),1); 
            if max(abs(feature_struct{sess}.features{i}{h}(3,:)))>maxWL
                % keep maximum observed value
                maxWL = max(abs(feature_struct{sess}.features{i}{h}(3,:)));
            end
           
        end
    end

    for i=1:1:length(Curr_EMG{sess}.signal)
        temp = segment_data(Curr_EMG{sess}.signal{i},300,75);
        for h=1:1:length(temp)
            feature_struct{sess}.features{i}{h}(1,:) = feature_struct{sess}.features{i}{h}(1,:)./maxMAV;
            feature_struct{sess}.features{i}{h}(2,:) = feature_struct{sess}.features{i}{h}(2,:)./maxSC;
            feature_struct{sess}.features{i}{h}(3,:) = feature_struct{sess}.features{i}{h}(3,:)./maxWL;

            % concatenate the features to create a single features vector
            % per time window.
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

%% Separate train/test
train_data = {};
test_data = {};
train_labels = {};
test_labels = {};
trainrat = 0.6;

% compute embedding using 60% of the total data simulating a training set.
for sess = 1:1:length(Curr_EMG)
    p = randperm(length(labels{sess}));
    frontier = round(length(labels{sess})*trainrat);

    train_data{sess} = set{sess}(p(1:frontier),:);
    test_data{sess} = set{sess}(p(frontier:end),:);

    train_labels{sess} = labels{sess}(p(1:frontier));
    test_labels{sess} = labels{sess}(p(frontier:end));
end

%% Visualise the results

sess = 1;

train_labels_plot = train_labels{sess}+1;
test_labels_plot = test_labels{sess}+1;
% compute embedding
[sLDA, WLDA, M, WPCA]=mylda(train_data{sess},train_labels_plot);


% project data
train_proj = (train_data{sess}-M)*WPCA*WLDA;
test_proj = (test_data{sess}-M)*WPCA*WLDA;
gscatter(train_proj(:,1), train_proj(:,2), train_labels_plot);
title('Train ground truth');
legend('Power grasp','Thumb-2 fingers','No grasp');
figure
gscatter(test_proj(:,1), test_proj(:,2), test_labels_plot);
title('Test ground truth');
legend('Power grasp','Thumb-2 fingers','No grasp');

%% fit the GMM models ONE FOR ALL TIME WINDOWS

how_many_comp = 2;
nb_classes = sum(unique(train_labels{sess}));
options = statset('MaxIter',500);

% compute the gmm components per grasp type
GMModel1 = fitgmdist(train_proj(train_labels{sess}==0,:),how_many_comp);
GMModel2 = fitgmdist(train_proj(train_labels{sess}==1,:),how_many_comp);
GMModel3 = fitgmdist(train_proj(train_labels{sess}==2,:),how_many_comp);

% create the functions
func1 = @(x,y) pdf(GMModel1,[x y]);
func2 = @(x,y) pdf(GMModel2,[x y]);
func3 = @(x,y) pdf(GMModel3,[x y]);

if exist('set','var')
    clearvars set
end

% observe the contours of the gaussians
gscatter(train_proj(:,1),train_proj(:,2), train_labels_plot);
hold on;
fcontour(func1,[-1 1 -0.3 0.3],'LineWidth',1.5);
fcontour(func2,[-1 1 -0.3 0.3],'LineWidth',1.5);
fcontour(func3,[-1 1 -0.3 0.3],'LineWidth',1.5);
legend('Power grasp','Thumb-2 fingers','No grasp','pdf Power grasp','pdf thumb-2 fingers','pdf No grasp');
set(gca,'fontsize',12);
grid on;
figure

% Compute scores

values = zeros(1,nb_classes);
train_computed_labels = zeros(length(train_proj),1);
test_computed_labels = zeros(length(test_proj),1);

% keep value having the maximum probability
for i=1:1:length(train_proj)
    values(1) = func1(train_proj(i,1),train_proj(i,2));
    values(2) = func2(train_proj(i,1),train_proj(i,2));
    values(3) = func3(train_proj(i,1),train_proj(i,2));
    [~,train_computed_labels(i)] = max(values);
end
for i=1:1:length(test_proj)
    values(1) = func1(test_proj(i,1),test_proj(i,2));
    values(2) = func2(test_proj(i,1),test_proj(i,2));
    values(3) = func3(test_proj(i,1),test_proj(i,2));
    [~,test_computed_labels(i)] = max(values);
end

% compute scores
score_train = sum(train_labels_plot == train_computed_labels)/length(train_proj);
score_test = sum(test_labels_plot == test_computed_labels)/length(test_proj);
    
disp(['GMM performance : Test accuracy = ',num2str(score_test*100),'% with a train/test ration of ',num2str(100*trainrat),'%']);
disp(['GMM performance : Train accuracy = ',num2str(score_train*100),'% with a train/test ration of ',num2str(100*trainrat),'%']);

% create one-hot encoding
train_predicted_bis = create_label_confusion(train_computed_labels-1);
test_predicted_bis = create_label_confusion(test_computed_labels-1);
train_truth = create_label_confusion(train_labels_plot-1);
test_truth = create_label_confusion(test_labels_plot-1);

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
figure

gscatter(train_proj(:,1), train_proj(:,2), train_computed_labels);
set(gca,'fontsize',14)
title('train computed labels');
legend('Power grasp','Thumb-2 fingers','No grasp');
figure

gscatter(test_proj(:,1), test_proj(:,2), test_computed_labels);
set(gca,'fontsize',14)
title('test computed labels');
legend('Power grasp','Thumb-2 fingers','No grasp');

%% Visualize the results

sess = 1;

gscatter(train_proj(:,1), train_proj(:,2), train_labels_plot);
title('Train ground truth');
legend('Power grasp','Thumb-2 fingers','No grasp');
figure

gscatter(test_proj(:,1), test_proj(:,2), test_labels_plot);
title('Test ground truth');
legend('Power grasp','Thumb-2 fingers','No grasp');
figure

gscatter(train_proj(:,1), train_proj(:,2), train_computed_labels);
title('train computed labels');
legend('Power grasp','Thumb-2 fingers','No grasp');
figure

gscatter(test_proj(:,1), test_proj(:,2), test_computed_labels);
title('test computed labels');
legend('Power grasp','Thumb-2 fingers','No grasp');
%% See the results of the single classifier evaluated on every time windows

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sess = 1; % Define the session to be analyzed %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

how_many_comp = 1;
numb_TW = 6; %6TW representing 0.95seconds
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
   
    % create the mixtures using data from all the time windows
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
    % project the data
    train_data = (train_data-M)*WPCA*WLDA;
    % compute mixtures
    GMModel1 = fitgmdist(train_data(train_labels==0,:),how_many_comp);
    GMModel2 = fitgmdist(train_data(train_labels==1,:),how_many_comp);
    GMModel3 = fitgmdist(train_data(train_labels==2,:),how_many_comp);
    % create functions
    func1 = @(x,y) pdf(GMModel1,[x y]);
    func2 = @(x,y) pdf(GMModel2,[x y]);
    func3 = @(x,y) pdf(GMModel3,[x y]);
    
    % now evaluate it per time window
    for n=1:1:numb_TW
        train_data = [];
        train_labels = [];
        test_data = [];
        test_labels = [];
        
        % extract train and test set
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

        % initialize variables
        score_test_0 = 0;
        score_test = 0;
        score_test_1 = 0;
        score_test_2 = 0;

        values = zeros(1,nb_classes);
        train_computed_labels = zeros(length(train_data),1);
        test_computed_labels = zeros(length(test_data),1);
        
        % compute scores
        for i=1:1:length(train_data)
            values(1) = func1(train_data(i,1),train_data(i,2));
            values(2) = func2(train_data(i,1),train_data(i,2));
            values(3) = func3(train_data(i,1),train_data(i,2));
            [~,train_computed_labels(i)] = max(values);
        end
        % -1 so that it starts at 0
        train_computed_labels = train_computed_labels - 1;
        
        % train score
        score_train = sum(train_labels == train_computed_labels);
        
        % test score per grasp type
        for i=1:1:length(test_data)
            values(1) = func1(test_data(i,1),test_data(i,2));
            values(2) = func2(test_data(i,1),test_data(i,2));
            values(3) = func3(test_data(i,1),test_data(i,2));
            [~,test_computed_labels(i)] = max(values);
            % -1 so that it starts at 0
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

        success_rate_test_0(cross,n) = 100*score_test_0/length(find(test_labels==0));
        success_rate_train_glob(cross,n) = 100*score_train/length(train_labels);
        success_rate_test_glob(cross,n) = 100*score_test/length(test_labels);
        success_rate_test_1(cross,n) = 100*score_test_1/length(find(test_labels==1));
        success_rate_test_2(cross,n) = 100*score_test_2/length(find(test_labels==2));
    end
end

% plot sections

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
title('Single GMM classifier')

figure
bounds = cat(3,repmat(st_deviation_train',[1,2]),repmat(st_deviation_test',[1,2]));
boundedline(time,[mean(success_rate_train_glob);mean(success_rate_test_glob)], bounds,'alpha');
grid on; 
legend('Train, all', 'Test, all');
xlabel('Time [ms]')
ylabel('Success rate (%)')
title('Single GMM classifier')

%% ONE GMM CLASSIFIER PER TW

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sess = 1; % Define the session to be analyzed %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

how_many_comp = 1;
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


% compute classifier per time window
for n=1:1:numb_TW
    data = [];
    labels = [];

    % extract data of the given time window
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
    
    % crossvalidate
    for cross = 1:1:nblock
        train_data = [];
        train_labels = [];
        test_data = [];
        test_labels = [];
        
        % extract train and test set
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

        % compute mixtures
        GMModel1 = fitgmdist(train_data(train_labels==0,:),how_many_comp);
        GMModel2 = fitgmdist(train_data(train_labels==1,:),how_many_comp);
        GMModel3 = fitgmdist(train_data(train_labels==2,:),how_many_comp);
        % create functions
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
        % -1 so that it starts at 0
        train_computed_labels = train_computed_labels - 1;
        
        score_train = sum(train_labels == train_computed_labels);
        
        % test score per grasp type
        for i=1:1:length(test_data)
            values(1) = func1(test_data(i,1),test_data(i,2));
            values(2) = func2(test_data(i,1),test_data(i,2));
            values(3) = func3(test_data(i,1),test_data(i,2));
            [~,test_computed_labels(i)] = max(values);
            % -1 so that it starts at 0
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

            gscatter(train_data(:,1), train_data(:,2), train_computed_labels);
            title(['train computed labels for TW number ', num2str(n)]);
            legend('Power grasp','Thumb-2 fingers','No grasp');
            figure

            gscatter(test_data(:,1), test_data(:,2), test_computed_labels);
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

% plot section

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
title('GMM classifier per Time Window')

figure
bounds = cat(3,repmat(st_deviation_train',[1,2]),repmat(st_deviation_test',[1,2]));
boundedline(time,[mean(success_rate_train_glob);mean(success_rate_test_glob)], bounds,'alpha');
grid on; hold on
legend('Train, all', 'Test, all');
xlabel('Time [ms]')
ylabel('Success rate (%)')
title('GMM classifier per Time Window')