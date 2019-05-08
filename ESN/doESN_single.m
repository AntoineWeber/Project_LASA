% This function applies an Echo- State- Network to the data



function [Scores,errortest,errortrain,Con_Matrix_test,Con_Matrix_train]=doESN_single(trainesn,l_tresn,testesn,l_teesn,nb_hidden,numb,spectralradius)


score_test = [];
score_train = [];
score_validation = [];


disp('Generating data ............');

performances=struct([]);

errortrain=struct([]);
errortest=struct([]);
test_time=struct([]);
testtimestd=struct([]);
Con_Matrix_test=struct([]);

Con_Matrix_train=struct([]);

% seperate the data

%[trainInputSequence trainOutputSequence testInputSequence testOutputSequence]=sepdata(data,div,ml,stdl,i);

trainInputSequence=struct([]);
trainOutputSequence=struct([]);
testInputSequence=struct([]);
testOutputSequence=struct([]);
k = 0;

%Put all the time windows of all the trials in the input sequence to train
%a single ESN
for j=1:length(trainesn)
    for h=1:length(trainesn{j})
         k = k+1;
         trainInputSequence{k}=trainesn{j}{h};
         trainOutputSequence{k}=l_tresn{j}{h};
    end
end

k=0;
for j=1:length(testesn)
    for h=1:length(testesn{j})
        k = k+1;
        testInputSequence{k}=testesn{j}{h};
        testOutputSequence{k}=l_teesn{j}{h};
    end
end

i=1;


% generate an esn 

%disp('Generating ESN ............');
nInternalUnits = nb_hidden; 
nInputUnits =  size(trainInputSequence{1},2);   
nOutputUnits =  size(trainOutputSequence{1},2); 

esn = generate_esn(spectralradius, nInputUnits, nInternalUnits, nOutputUnits, 'spectralRadius',1,'learningMode', 'offline_multipleTimeSeries', 'reservoirActivationFunction', 'tanh','outputActivationFunction', 'identity','inverseOutputActivationFunction','identity', 'type','plain_esn'); 
esn.internalWeights = esn.spectralRadius * esn.internalWeights_UnitSR;


% train ESN

%disp('Training ESN ............');

nForgetPoints = 1 ; % discard the first point
[trainedEsn stateMatrix] = train_esn(trainInputSequence', trainOutputSequence', esn, nForgetPoints) ; 


% save the trained ESN
save_esn(trainedEsn, 'esn_subject'); 

% plot the internal states of 4 units
%    nPoints = 2000 ; 
%    plot_states(stateMatrix,[1 2 3 4], nPoints, 1, 'traces of first 4 reservoir units') ; 


%disp('Testing ESN ............');

predictedTrainOutput = [];
for j=1:length(trainInputSequence)
    predictedTrainOutput{j} = zeros(length(trainInputSequence{j})-nForgetPoints, size(trainOutputSequence{1},2));
    predictedTrainOutput{j} = test_esn(trainInputSequence{j}, trainedEsn, nForgetPoints);
end

%calc_time=zeros(length(testOutputSequence),1);

predictedTestOutput = [];
for j=1:length(testOutputSequence)
    predictedTestOutput{j} = zeros(length(testInputSequence{j})-nForgetPoints, size(trainOutputSequence{1},2));
   % tic
    predictedTestOutput{j} = test_esn(testInputSequence{j},  trainedEsn, nForgetPoints) ; 
   % calc_time(j)=toc;
end
% test_time{i}=sum(calc_time)/length(testOutputSequence);
% testtimestd{i}=std(calc_time);

[~, ~, success_rate_test, av_confidence_all_test, std_confidence_all_test, av_max_conf_test, std_max_conf_test, errortest{i},Con_Matrix_test{i}] = S_classify2(predictedTestOutput, testOutputSequence, 3, i, 'test');
[~, ~, success_rate_train, av_confidence_all_train, std_confidence_all_train, av_max_conf_train, std_max_conf_train, errortrain{i},Con_Matrix_train{i}] = S_classify2(predictedTrainOutput, trainOutputSequence, 3, i, 'train');

score_train = [score_train; i success_rate_train av_confidence_all_train std_confidence_all_train av_max_conf_train std_max_conf_train];
score_validation = [score_validation; i success_rate_test av_confidence_all_test std_confidence_all_test av_max_conf_test std_max_conf_test];
%disp(['TimeWindow ',num2str(i),'/',num2str(div),' processed for Subject number ',num2str(numb)]);

performances{i}.score_train=score_train;
performances{i}.score_validation=score_validation;

Scores=performances{i};

end