function [Train, Test, Validation] = split_data(EMG_final,trainRatio,valRatio,testRatio)

%SPLIT_DATA Randomly partitions a dataset into train/test/validation
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[trainInd,valInd,testInd] = divideblock(length(EMG_final.labels),trainRatio,valRatio,testRatio);

Train = {};
Test = {};
Validation = {};

Train.signal = EMG_final.signal(trainInd);
Train.labels = EMG_final.labels(trainInd);

Test.signal = EMG_final.signal(testInd);
Test.labels = EMG_final.labels(testInd);

Validation.signal = EMG_final.signal(valInd);
Validation.labels = EMG_final.labels(valInd);

end

