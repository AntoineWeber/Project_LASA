
 tic


clear all; 

% time_window = S_stat();

for sub=6:6%8
    file = ['data_subject', num2str(sub),'_t2_v2']
%     load data_subject6_new;

    load(file);


    score_test = [];
    score_train = [];
    score_validation = [];


    for j=10:10:100
        disp('Generating data ............');
        percentage = j;

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
        inputSequence = train_data_cell;
        outputSequence = train_output_cell;
        % 
        % 
        % nbtraining = length(inputSequence);
        % nbtraining_step = floor(nbtraining/10);







        for i=1:length(train_data_cell)
            s = floor(length(train_data_cell{i})*percentage/100);
            trainInputSequence{i,1} = train_data_cell{i}(1:s,:);
            trainOutputSequence{i,1} = train_output_cell{i}(1:s,:);
        end

        for i=1:length(test_data_cell)
            s = floor(length(test_data_cell{i})*percentage/100);
            testInputSequence{i,1} = test_data_cell{i}(1:s,:);
            testOutputSequence{i,1} = test_output_cell{i}(1:s,:);
        end

    %     trainInputSequence = train_data_cell;
    %     testInputSequence  = test_data_cell;
    %     trainOutputSequence = train_output_cell;
    %     testOutputSequence = test_output_cell;


        %%%% generate an esn 
        disp('Generating ESN ............');
        nInternalUnits = 100;
        nInputUnits =  size(inputSequence{1},2);   
        nOutputUnits =  size(outputSequence{1},2); 


        esn = generate_esn(nInputUnits, nInternalUnits, nOutputUnits, 'spectralRadius',1,'learningMode', 'offline_multipleTimeSeries', 'reservoirActivationFunction', 'tanh','outputActivationFunction', 'identity','inverseOutputActivationFunction','identity', 'type','plain_esn'); 
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

        predictedTrainOutput = [];
        for i=1:length(trainInputSequence)
            predictedTrainOutput{i} = zeros(length(trainInputSequence{i})-nForgetPoints, size(outputSequence{1},2));
            predictedTrainOutput{i} = test_esn(trainInputSequence{i}, trainedEsn, nForgetPoints);
        end



        predictedTestOutput = [];
        for i=1:length(testOutputSequence)
            predictedTestOutput{i} = zeros(length(testInputSequence{i})-nForgetPoints, size(outputSequence{1},2));  
            predictedTestOutput{i} = test_esn(testInputSequence{i},  trainedEsn, nForgetPoints) ; 
        end


        [all_output_test, av_predicteTestdOutput, success_rate_test, av_confidence_all_test, std_confidence_all_test, av_max_conf_test, std_max_conf_test] = S_classify(predictedTestOutput, testOutputSequence, 3);
        [all_output_train, av_predictedTrainOutput, success_rate_train, av_confidence_all_train, std_confidence_all_train, av_max_conf_train, std_max_conf_train] = S_classify(predictedTrainOutput, trainOutputSequence, 3);

        score_train = [score_train; percentage success_rate_train av_confidence_all_train std_confidence_all_train av_max_conf_train std_max_conf_train]
        score_validation = [score_validation; percentage success_rate_test av_confidence_all_test std_confidence_all_test av_max_conf_test std_max_conf_test]

    end

  
    save_file = [file, '_score'];
%     save score_train_3_1_sub6_2 score_train score_validation
    save (save_file, 'score_train', 'score_validation')

end

toc

