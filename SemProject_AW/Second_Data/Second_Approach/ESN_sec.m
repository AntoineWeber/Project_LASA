%% Load the data

clc
clear all
close all

% load data for the second approach
load('data_2approach');
numb = 1;
n=1;
nb_phase = 3;

test_rate = [];
scores = {};
err_test = {};
err_train = {};
con_test = {};
con_train = {};

%% Split the data

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sess = 1; % Define the session to be analyzed %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% one classifier per phase
for phase = 1:1:nb_phase
    Curr_EMG = {};
    Curr_EMG{sess}.labels = Fin_EMG{sess}.labels;
    % extract data from the current phase
    for p=1:1:length(Fin_EMG{sess}.signal)
        Curr_EMG{sess}.signal{p} = Fin_EMG{sess}.signal{p}{phase};
    end

    % split in 5 folds
    nblock = 5;
    [Train_block] = split_nblocks(Curr_EMG{sess},nblock);

    %% Extract all the time windows and crossvalidate the ESN train/test.

    Windowsize = 300;
    overlap = 75;
    nb_classes = 3;


    % 5-fold crossvalidation
    for f_fold=1:1:nblock 

        train_data = {};
        train_labels = {};
        test_data = {};
        test_labels = {};
        k = 0;
        
        % extract train and test data
        for h=1:1:nblock
            if (h==f_fold)
                continue
            end
            ntrain = length(Train_block{1,h}.labels);
            for i=1:1:ntrain
                k = k+1;
                temp_lab = Train_block{1,h}.labels(i);
                [temp_sig,num] = segment_data(Train_block{1,h}.signal{1,i}, Windowsize, overlap);
                train_data{k} = temp_sig;
                % create one-hot encoding
                train_labels{k} = create_struct_label(num, temp_lab, Windowsize, nb_classes);
            end
        end

        ntest = length(Train_block{1,f_fold}.labels);
        for i=1:1:ntest
            temp_lab = Train_block{1,f_fold}.labels(i);
            [temp_sig,num] = segment_data(Train_block{1,f_fold}.signal{1,i}, Windowsize, overlap);
            test_data{i} = temp_sig;
            % create one-hot encoding
            test_labels{i} = create_struct_label(num, temp_lab, Windowsize, nb_classes);
        end

        train_data = train_data';
        test_data = test_data';
        train_labels = train_labels';
        test_labels = test_labels';
        
        % To make sure to take all the TW per phase
        numb_TW = 5; 
        nb_hidden = 200;
        spectralradius = 0.9;

        [scores{phase}{f_fold}, err_test{phase}{f_fold}, err_train{phase}{f_fold},con_test{phase}{f_fold},con_train{phase}{f_fold}] = doESN_single(train_data,train_labels,test_data,test_labels,nb_hidden,phase,spectralradius);
        disp(['Crossvalidation number ',num2str(f_fold),'/',num2str(nblock),' for phase number ',num2str(phase),'/',num2str(nb_phase),' done']);
    end
end
% plot section

values_train = [];
values_test = [];


for i=1:1:3
    for j=1:1:nblock
        values_train(i,j) = scores{i}{j}.score_train(2);
        values_test(i,j) = scores{i}{j}.score_validation(2);
    end
end

boxplot(values_train', 'Labels',{'Phase 1', 'Phase 2', 'Phase 3'})
grid on
title('train')
ylabel('Accuracy [%]')
set(gca,'fontsize',14)
figure
boxplot(values_test', 'Labels',{'Phase 1', 'Phase 2', 'Phase 3'})
grid on
title('test')
ylabel('Accuracy [%]')
if exist('set','var')
    clearvars set
end
set(gca,'fontsize',14)