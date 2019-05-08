
    tic

% Version 1.0, April 30, 2006
% Copyright: Fraunhofer IAIS 2006 / Patent pending
% Revision 1, H. Jaeger, Feb 23, 2007
% Revision 2, H. Jaeger, Aug 17, 2007

clear all; 
load data_subject8_new;
% load data_subject1+2;
% load data_cell;
%%%% generate the training data

% inputSequence = [];
% outputSequence = [];
% for i=1:3
%     load (['data_subject',num2str(i)]);
%     inputSequence = [inputSequence; data_cell];
%     outputSequence = [outputSequence; output_cell];
% end

% 
disp('Generating data ............');


% 
% len = length(data_cell);
% Set1 = data_cell(1:floor(len/4),1);
% Set2 = data_cell(floor(len/4)+1:2*floor(len/4),1);
% Set3 = data_cell(2*floor(len/4)+1:3*floor(len/4),1);
% Set4 = data_cell(3*floor(len/4)+1:4*floor(len/4),1);
% 
% oSet1 = output_cell(1:floor(len/4),1);
% oSet2 = output_cell(floor(len/4)+1:2*floor(len/4),1);
% oSet3 = output_cell(2*floor(len/4)+1:3*floor(len/4),1);
% oSet4 = output_cell(3*floor(len/4)+1:4*floor(len/4),1);
% 
% testinput = [Set2;Set4];
% testoutput = [oSet2;oSet4];
% 
% inputSequence = [Set1;Set3];
% outputSequence = [oSet1;oSet3];




%  inputSequence = data_pca;
inputSequence = test_data_cell;
outputSequence = test_output_cell;
% 
% 
% nbtraining = length(inputSequence);
% nbtraining_step = floor(nbtraining/10);






score_test = [];
score_train = [];
score_validation = [];

trainInputSequence = test_data_cell;
testInputSequence  = train_data_cell;
trainOutputSequence = test_output_cell;
testOutputSequence = train_output_cell;

%%%%%%%%%%%%%%%%%%%%% 10-fold cross-validation %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% for n = 1:1
%     %%%% split the data into train and test
%     if n==1
%         trainInputSequence = inputSequence((n-1)*nbtraining_step+1:(10-n)*nbtraining_step,1);
%         testInputSequence  = inputSequence(9*nbtraining_step+1:10*nbtraining_step,1);
%         trainOutputSequence = outputSequence((n-1)*nbtraining_step+1:(10-n)*nbtraining_step,1);
%         testOutputSequence =  outputSequence(9*nbtraining_step+1:10*nbtraining_step,1);
%     else if n==2
%             trainInputSequence = inputSequence(1*nbtraining_step+1:(10)*nbtraining_step,1);
%             testInputSequence  = inputSequence(0*nbtraining_step+1:1*nbtraining_step,1);
%             trainOutputSequence = outputSequence((1)*nbtraining_step+1:(10)*nbtraining_step,1);
%             testOutputSequence =  outputSequence(0*nbtraining_step+1:1*nbtraining_step,1);
%             
%         else if n<10
%             trainInputSequence = [inputSequence((n-1)*nbtraining_step+1:10*nbtraining_step,1); inputSequence(0*nbtraining_step+1:(n-2)*nbtraining_step,1)] ;
%             testInputSequence  = inputSequence((n-2)*nbtraining_step+1:(n-1)*nbtraining_step,1);
%             trainOutputSequence = [outputSequence((n-1)*nbtraining_step+1:10*nbtraining_step,1); outputSequence(0*nbtraining_step+1:(n-2)*nbtraining_step,1)] ;
%             testOutputSequence =  outputSequence((n-2)*nbtraining_step+1:(n-1)*nbtraining_step,1);
%             else if n==10
%                     trainInputSequence = [inputSequence(9*nbtraining_step+1:(10)*nbtraining_step,1); inputSequence(1*nbtraining_step+1:8*nbtraining_step,1)] ;
%                     testInputSequence  = inputSequence(8*nbtraining_step+1:9*nbtraining_step,1);
%                     trainOutputSequence = [outputSequence(9*nbtraining_step+1:(10)*nbtraining_step,1);outputSequence(1*nbtraining_step+1:8*nbtraining_step,1)] ;
%                     testOutputSequence =  outputSequence(8*nbtraining_step+1:9*nbtraining_step,1);
%                 end
%             end
%             
%         end
%     end

    %%%% generate an esn 
    disp('Generating ESN ............');
    nInternalUnits = 100;
    nInputUnits =  size(inputSequence{1},2);   
    nOutputUnits =  size(outputSequence{1},2); 

%     esn = generate_esn(nInputUnits, nInternalUnits, nOutputUnits, 'spectralRadius',0.5,'inputScaling',[0.1;0.1],'inputShift',[0;0], 'teacherScaling',[0.3],'teacherShift',[-0.2],'feedbackScaling', 0, 'type', 'plain_esn'); 
%     esn = generate_esn(nInputUnits, nInternalUnits, nOutputUnits, 'spectralRadius',1,'learningMode', 'offline_multipleTimeSeries', 'reservoirActivationFunction', 'tanh',...
%         'outputActivationFunction', 'identity','inverseOutputActivationFunction','identity', 'type','plain_esn'); 

esn = generate_esn(nInputUnits, nInternalUnits, nOutputUnits, 'spectralRadius',1,'learningMode', 'offline_multipleTimeSeries', 'reservoirActivationFunction', 'tanh','outputActivationFunction', 'identity','inverseOutputActivationFunction','identity', 'type','plain_esn'); 


    %%% VARIANTS YOU MAY WISH TO TRY OUT
    % (Comment out the above "esn = ...", comment in one of the variants
    % below)

    % % Use a leaky integrator ESN
    % esn = generate_esn(nInputUnits, nInternalUnits, nOutputUnits, ...
    %     'spectralRadius',0.5,'inputScaling',[0.1;0.1],'inputShift',[0;0], ...
    %     'teacherScaling',[0.3],'teacherShift',[-0.2],'feedbackScaling', 0, ...
    %     'type', 'leaky_esn'); 
    % 
    % % Use a time-warping invariant ESN (makes little sense here, just for
    % % demo's sake)
    % esn = generate_esn(nInputUnits, nInternalUnits, nOutputUnits, ...
    %     'spectralRadius',0.5,'inputScaling',[0.1;0.1],'inputShift',[0;0], ...
    %     'teacherScaling',[0.3],'teacherShift',[-0.2],'feedbackScaling', 0, ...
    %     'type', 'twi_esn'); 

    % % Do online RLS learning instead of batch learning.
    % esn = generate_esn(nInputUnits, nInternalUnits, nOutputUnits, ...
    %       'spectralRadius',0.4,'inputScaling',[0.1;0.5],'inputShift',[0;1], ...
    %       'teacherScaling',[0.3],'teacherShift',[-0.2],'feedbackScaling',0, ...
    %       'learningMode', 'online' , 'RLS_lambda',0.9999995 , 'RLS_delta',0.000001, ...
    %       'noiseLevel' , 0.00000000) ; 

    esn.internalWeights = esn.spectralRadius * esn.internalWeights_UnitSR;

    %%%% train the ESN

    disp('Training ESN ............');

    nForgetPoints = 100 ; % discard the first 100 points
    [trainedEsn stateMatrix] = train_esn(trainInputSequence, trainOutputSequence, esn, nForgetPoints) ; 



    %%%% save the trained ESN
    save_esn(trainedEsn, 'esn_subject'); 

    %%%% plot the internal states of 4 units
    nPoints = 2000 ; 
    plot_states(stateMatrix,[1 2 3 4], nPoints, 1, 'traces of first 4 reservoir units') ; 



    % compute the output of the trained ESN on the training and testing data,
    % discarding the first nForgetPoints of each
    disp('Testing ESN ............');



    % trainInputSequence2 = [];
    % trainOutputSequence2 = [];

    predictedTrainOutput = [];
    for i=1:length(trainInputSequence)
    %     trainInputSequence2 = [trainInputSequence2; trainInputSequence{i}];
    %     trainOutputSequence2 = [ trainOutputSequence2;  trainOutputSequence{i}];
        predictedTrainOutput{i} = zeros(length(trainInputSequence{i})-nForgetPoints, size(outputSequence{1},2));
        predictedTrainOutput{i} = test_esn(trainInputSequence{i}, trainedEsn, nForgetPoints);
    end

    
    %  testInputSequence2 = [];
    %  testOutputSequence2 = [];
    predictedTestOutput = [];
    for i=1:length(testOutputSequence)
    %     testInputSequence2  = [ testInputSequence2;  testInputSequence{i}];
    %     testOutputSequence2 =  [testOutputSequence2; testOutputSequence{i}];
        predictedTestOutput{i} = zeros(length(testInputSequence{i})-nForgetPoints, size(outputSequence{1},2));  
        predictedTestOutput{i} = test_esn(testInputSequence{i},  trainedEsn, nForgetPoints) ; 
    end


    % predictedTrainOutput = test_esn(trainInputSequence2, trainedEsn, nForgetPoints);
    % predictedTestOutput = test_esn(testInputSequence2,  trainedEsn, nForgetPoints) ; 

    % % create input-output plots
    % nPlotPoints = length(trainInputSequence2)-nForgetPoints ; 
    % nPlotPoints2 = length(testInputSequence2)-nForgetPoints ; 
    % plot_sequence(trainOutputSequence2(nForgetPoints+1:end,:), predictedTrainOutput, nPlotPoints,'training: teacher sequence (red) vs predicted sequence (blue)'); title('training set');
    % plot_sequence(testOutputSequence2(nForgetPoints+1:end,:), predictedTestOutput, nPlotPoints2, 'testing: teacher sequence (red) vs predicted sequence (blue)') ; title('test set');
    % 
    % %%%%compute NRMSE training error
    % 
    % trainError = compute_NRMSE(predictedTrainOutput, trainOutputSequence2); 
    % disp(sprintf('train NRMSE = %s', num2str(trainError)));
    % 
    % %%%%compute NRMSE testing error
    % testError = compute_NRMSE(predictedTestOutput, testOutputSequence2); 
    % disp(sprintf('test NRMSE = %s', num2str(testError)));


    % create input-output plots

    % for i=1:10
    %     plot_sequence(trainOutputSequence{i}(nForgetPoints+1:end,:), predictedTrainOutput{i}, length(trainOutputSequence{i})-nForgetPoints,'training: teacher sequence (red) vs predicted sequence (blue)'); title('training set');
    %     plot_sequence(testOutputSequence{i}(nForgetPoints+1:end,:), predictedTestOutput{i}, length(testOutputSequence{i})-nForgetPoints, 'testing: teacher sequence (red) vs predicted sequence (blue)') ; title('test set');
    % end


    [all_output_test, av_predicteTestdOutput, success_rate_test] = S_classify(predictedTestOutput, testOutputSequence, 3);
    [all_output_train, av_predictedTrainOutput, success_rate_train] = S_classify(predictedTrainOutput, trainOutputSequence, 3);

    score_train = [score_train; success_rate_train]
    score_validation = [score_validation; success_rate_test]
    
    
    
%      predictedTestOutput_set = [];
%     for i=1:length(testoutput)
%         predictedTestOutput_set{i} = zeros(length(testinput{i})-nForgetPoints, size(testoutput{1},2));  
%         predictedTestOutput_set{i} = test_esn(testinput{i},  trainedEsn, nForgetPoints) ; 
%     end
%     [av_predicteTestdOutput_set, success_rate_test_set] = S_classify(predictedTestOutput_set, testoutput, 3);
%     score_test = [score_test; success_rate_test_set]
    
    toc

% end



