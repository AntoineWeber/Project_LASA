%% Code to implement one single ESN classifier for all the time windows
%% Load the data

clc
close all

load('New_data.mat');
numb = 1;
n=1;

test_rate = [];
scores = {};
err_test = {};
err_train = {};
con_test = {};
con_train = {};

% concatenate all the data from all the different sessions
% can be commented to do a per session analysis
EMG_final{numb} = concatenate_emg(EMG_final{numb}); 
Curr_EMG = EMG_final{numb};


%% Split the data

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sess = 1; % Define the session to be analyzed %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% divide data in 5 folds

nblock = 5;

[Train_block] = split_nblocks(Curr_EMG{sess},nblock);

%% Extract all the time windows and crossvalidate the ESN train/test.

% 300 samples being 200ms at 1500Hz
Windowsize = 300;
overlap = 75;
nb_classes = 3;

for f_fold=1:1:nblock %5-fold crossvalidation

    train_data = {};
    train_labels = {};
    test_data = {};
    test_labels = {};
    k = 0;

    % create the matrix containing the different train and test data,
    % considering the current fold.
    for h=1:1:nblock
        if (h==f_fold)
            continue
        end
        ntrain = length(Train_block{1,h}.labels);
        for i=1:1:ntrain
            k = k+1;
            temp_lab = Train_block{1,h}.labels(i);
            %segment the data into the time windows
            [temp_sig,num] = segment_data(Train_block{1,h}.signal{1,i}, Windowsize, overlap);
            train_data{k} = temp_sig;
            %create the one-hot encoding for the labels
            train_labels{k} = create_struct_label(num, temp_lab, Windowsize, nb_classes);
        end
    end

    % Take the remaining fold for testing
    ntest = length(Train_block{1,f_fold}.labels);
    for i=1:1:ntest
        temp_lab = Train_block{1,f_fold}.labels(i);
        [temp_sig,num] = segment_data(Train_block{1,f_fold}.signal{1,i}, Windowsize, overlap);
        test_data{i} = temp_sig;
        test_labels{i} = create_struct_label(num, temp_lab, Windowsize, nb_classes);
    end

    train_data = train_data';
    test_data = test_data';
    train_labels = train_labels';
    test_labels = test_labels';

    % select number of time windows for the algorithms to extract.
    numb_TW = 6; 
    nb_hidden = 250;
    spectralradius = 0.9;

    [~, ~, ~, ~, ~] = doESN_single(train_data,train_labels,test_data,test_labels,nb_hidden,numb,spectralradius);
    [scores{numb}{f_fold}, err_test{numb}{f_fold}, err_train{numb}{f_fold},con_test{numb}{f_fold},con_train{numb}{f_fold}] = doESN_perTW(train_data,train_labels,test_data,test_labels,numb_TW,nb_hidden,numb,spectralradius,'test');
    disp(['Crossvalidation number ',num2str(f_fold),'/',num2str(nblock),' for Subject number ',num2str(numb),'/',num2str(n),' done']);
end
%% plot section
values_train = [];
values_test = [];

for i=1:1:nblock
    for j=1:1:numb_TW
        values_train(i,j) = scores{1}{i}.score_train(j,2);
        values_test(i,j) = scores{1}{i}.score_validation(j,2);
    end
end

test = mean(values_test,1);
std_test = std(values_test,1);
train = mean(values_train,1);
std_train = std(values_train,1);
bounds = cat(3,repmat(std_train',[1,2]),repmat(std_test',[1,2]));
time = [200,350,500,650,800,950];
boundedline(time,[train;test],bounds,'alpha');
grid on;

legend('train data','test data')
xlabel('Time [ms]');
ylabel('Accuracy [%]')

if exist('set','var')
    clearvars set
end
set(gca,'fontsize',12)