%% Load the data

load('EMG_final_ok');

test_rate = [];
n = length(EMG_final);
for numb=1:1:1
    Curr_EMG = EMG_final{1,numb};

    %% Split the data

    % divide the 70% into 5 sets and crossvalidate

    trainrat = 0.8;
    testrat = 0;
    valrat = 0.2;
    nblock = 5;

    [Train,Test,Validation] = split_data(Curr_EMG,trainrat, valrat, testrat);
    [Train_block] = split_nblocks(Train,nblock);

    %% Extract all the time windows and crossvalidate the ESN train/test.

    Windowsize = 150;
    overlap = 50;
    nb_classes = 3;

    for f_fold=1:1:nblock %5-fold crossvalidation

        train_data = {};
        train_labels = {};
        test_data = {};
        test_labels = {};
        k = 0;

        for h=1:1:nblock
            if (h==f_fold)
                continue
            end
            ntrain = length(Train_block{1,h}.labels);
            for i=1:1:ntrain
                k = k+1;
                temp_lab = Train_block{1,h}.labels{1,i};
                [temp_sig,num] = segment_data(Train_block{1,h}.signal{1,i}, Windowsize, overlap);
                train_data{k} = temp_sig;
                train_labels{k} = create_struct_label(num, temp_lab, Windowsize, nb_classes);
            end
        end

        ntest = length(Train_block{1,f_fold}.labels);
        for i=1:1:ntest
            temp_lab = Train_block{1,f_fold}.labels{1,i};
            [temp_sig,num] = segment_data(Train_block{1,f_fold}.signal{1,i}, Windowsize, overlap);
            test_data{i} = temp_sig;
            test_labels{i} = create_struct_label(num, temp_lab, Windowsize, nb_classes);
        end

        train_data = train_data';
        test_data = test_data';
        train_labels = train_labels';
        test_labels = test_labels';

        numb_TW = 8; %Can be tuned
        nb_hidden = 400;
        spectralradius = 0.9;

        [scores{f_fold}, err_test{f_fold}, err_train{f_fold}] = doESN_single(train_data,train_labels,test_data,test_labels,nb_hidden,numb,spectralradius);
        disp(['Crossvalidation number ',num2str(f_fold),'/',num2str(nblock),' for Subject number ',num2str(numb),'/',num2str(n),' done']);
    end

%     test_success_rate_av = 0;
%     for i=1:1:nblock
%         test_success_rate_av = test_success_rate_av + 1/nblock * scores{i}.score_validation(end,2);
%     end
%     
%     test_rate(numb) = test_success_rate_av;
end

% scatter((1:4),test_rate);
% grid on; hold on
% title(['Averaged success rate on test set for the 4 different subjects using a single NN with a Spectral radius of: ',num2str(spectralradius),' and ',num2str(nb_hidden),' hidden units']);