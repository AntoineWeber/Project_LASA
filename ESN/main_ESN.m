% This program has as main porpuse to find a proper way to calculate the
% time window for the controler by predicting the velocity of the movement

clear all
close all
clc


%% 


for sbj=1:8
    
targetname=['subject_' num2str(sbj)];

% load data
cd ..

cd(targetname)

load EMG_block.mat

cd ..
cd working_with_sliding_tw

%%

% set the conditions

% number of dimensions
nbdimensions=15;

% number of classes
nb_class=4;

% sampling rate
fs=3000;

% time window
tw=0.2;

% delay
delay=1;

% number of features
nb_features=4;


%%

% extracting features and training and testing datasets

% window length
w_l=tw*fs;

% delay length
d_l=delay*fs;


% seperating the data according to features and time windows

%      datasets for LDA:
% trainlda:    the training dataset
% l_trlda:     the traning labels
% testlda:     the testing dataset
% l_telda:     the testing labels

%      datasets for ESN:
% trainesn:    the training dataset
% l_tresn:     the traning labels
% testesn:     the testing dataset
% l_teesn:     the testing labels

[trainesn l_tresn testesn l_teesn div]=sep_data_ESN(EMG_epoch,w_l,d_l,nb_class,nb_features,nbdimensions);


%%

%    ESN

scores=doESN(trainesn,l_tresn,testesn,l_teesn,div);



filename=['sbj' num2str(sbj) 'ESN.mat'];

save (filename,'scores')


%%



clear EMG_epoch

end



performances2=struct([]);

for i=1:8
sbj=i;

    filename=['sbj' num2str(sbj) 'ESN.mat'];

    load(filename)
    performances2{i}.scores=scores;

end


figure(1)
hold on
for i=1:8
    tmp=performances2{i}.scores{end}.score_validation(:,2);
    plot(1:length(tmp),tmp,'color',cc(i,:))
end
title('ESN- testing performances')
legend('sbj 1','sbj 2','sbj 3','sbj 4','sbj 5','sbj 6','sbj 7','sbj 8')
ylabel('(%)')
xlabel('time windows')
grid on
hold off

figure(2)
hold on
for i=1:8
    tmp=performances2{i}.scores{end}.score_train(:,2);
    plot(1:length(tmp),tmp,'color',cc(i,:))
end
title('ESN- training performances')
legend('sbj 1','sbj 2','sbj 3','sbj 4','sbj 5','sbj 6','sbj 7','sbj 8')
ylabel('(%)')
xlabel('time windows')
grid on
hold off