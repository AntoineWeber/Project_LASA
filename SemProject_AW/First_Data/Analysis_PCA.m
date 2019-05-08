%% Load the Data

clc
clear all
close all

load('EMG_final_myfilter_no2ndfilter.mat');

numb = 1; %Subject to be evaluated
Curr_EMG = EMG_final{1,numb};

%% Try dividing a signal to see features

% signal1 = EMG_final{1,numb}.signal{1,10};
% signal2 = Curr_EMG.signal{1,10};
% 
% divid = 150; %tune
% 
% aver = [];
% for i=1:1:8
%     current1 = signal1(:,i)/max(abs(signal1(:,i)));
%     factor1 = floor(length(current1)/divid);
%     
%     current2 = signal2(:,i)/max(abs(signal2(:,i)));
%     factor2 = floor(length(current2)/divid);
%     
%     for j=1:1:factor1
%         aver1(j) = mean(current1(((j-1)*divid+1):j*divid));
%     end
%     for j=1:1:factor2
%         aver2(j) = mean(current2(((j-1)*divid+1):j*divid));
%     end
%     plot(aver1);
%     grid on; hold on
%     plot(aver2);
% end
%% Apply PCA

data = [];
labels = [];
min = inf;
TimeWindow = 150;

% for i=1:1:length(Curr_EMG.signal)
%     if(length(Curr_EMG.signal{1,i}) < min)
%         min = length(Curr_EMG.signal{1,i});
%     end
% end

for i=1:1:length(Curr_EMG.signal)
    data = [data, Curr_EMG.signal{1,i}(1:TimeWindow,1)];
    labels = [labels ; Curr_EMG.labels{1,i}];
end

data = data';

X = pca(data,3);

scatter3(X(:,1)/max(X(:,1)), X(:,2)/max(X(:,2)), X(:,3)/max(X(:,3)), 10, labels);
