%% Run all the scripts and keep only results
clc
clear all
close all

% compute SVM and keep results per TW
SVM_analysis;
SVM_mean_test = mean(success_rate_test_glob); 
SVM_std_test = std(success_rate_test_glob); 

% compute LDA and keep results per TW
LDA_class_bis;
LDA_mean_test = mean(success_rate_test_glob); 
LDA_std_test = std(success_rate_test_glob); 

% compute GMM and keep results per TW
GMM_analysis;
GMM_mean_test = mean(success_rate_test_glob); 
GMM_std_test = std(success_rate_test_glob); 

% compute ESN and keep results per TW
ESN_class_perTW_bis;
close all
ESN_mean_test = test;
ESN_std_test = std_test;

% Plot the results

time = [200,350,500,650,800,950];
means = [SVM_mean_test;LDA_mean_test;GMM_mean_test;ESN_mean_test];
bounds = cat(3,repmat(SVM_std_test',[1,2]),repmat(LDA_std_test',[1,2]),repmat(GMM_std_test',[1,2]),repmat(ESN_std_test',[1,2]));
boundedline(time,means,bounds,'alpha');
grid on; hold on

if exist('set','var')
    clearvars set
end
set(gca,'fontsize',14);

legend('SVM test results','LDA test results','GMM test results','ESN test results');
title('All different test results');
xlabel('Time [ms]');
ylabel('Accuracy [%]')
set(findall(gca, 'Type', 'Line'),'LineWidth',2);