%% Perform a feature extraction on the different time windows of the trials and project it in a lower
%% dimensional space to cluster/classify them

load('EMG_final_OK.mat');
numb = 1;
Curr_EMG = EMG_final{numb};


%% Extract the features per time windows

feature_struct = {};
feature_struct.labels = Curr_EMG.labels;

labels = [];
set = [];

maxMAV = 0;
maxSC = 0;
maxWL = 0;

for i=1:1:length(Curr_EMG.signal)
    temp = segment_data(Curr_EMG.signal{i},150,50);
    for h=1:1:length(temp)
        feature_struct.features{i}{h}(1,:) = mean(abs(temp{h})); %Mean absolute value
        if max(abs(feature_struct.features{i}{h}(1,:)))>maxMAV
            maxMAV = max(abs(feature_struct.features{i}{h}(1,:)));
        end
        
        feature_struct.features{i}{h}(2,:) = sum((diff(sign(diff(temp{h},1,1)),1,1)~=0),1); %number of slope changes
        if max(abs(feature_struct.features{i}{h}(2,:)))>maxSC
            maxSC = max(abs(feature_struct.features{i}{h}(2,:)));
        end
        
        feature_struct.features{i}{h}(3,:) = sum(abs(diff(temp{h},1,1)),1); %waveform length
        if max(abs(feature_struct.features{i}{h}(1,:)))>maxWL
            maxWL = max(abs(feature_struct.features{i}{h}(3,:)));
        end
    end
end

for i=1:1:length(Curr_EMG.signal)
    temp = segment_data(Curr_EMG.signal{i},150,50);
    for h=1:1:length(temp)
        feature_struct.features{i}{h}(1,:) = feature_struct.features{i}{h}(1,:)./maxMAV;
        feature_struct.features{i}{h}(2,:) = feature_struct.features{i}{h}(2,:)./maxSC;
        feature_struct.features{i}{h}(3,:) = feature_struct.features{i}{h}(3,:)./maxWL;
        
        feature_struct.features{i}{h} = reshape(feature_struct.features{i}{h},[],1);
        set = [set, feature_struct.features{i}{h}];
        labels = [labels, Curr_EMG.labels{i}];
    end
end

set = set';
labels = labels';

%% Apply ONLY ONE PCA on all the timewindows.

array_features = [];
array_labels = [];

numb_channels = size(feature_struct.features{1}{1},2); % =1

for j=1:1:length(feature_struct.features)
    for h=1:1:length(feature_struct.features{j})
        array_features = [array_features, feature_struct.features{j}{h}];
        array_labels = [array_labels, feature_struct.labels{j}*ones(1,numb_channels)];
    end
end

array_labels = array_labels';
array_features = array_features';

[Y,mapping] = pca(array_features,0.9);

% scatter3(Y(:,1),Y(:,2), Y(:,3), 10, array_labels);

cumul_var_explained = cumsum(mapping.lambda)/(sum(mapping.lambda)); 
figure
plot(cumul_var_explained); 
grid on;
%% Visualize it

options.labels   = array_labels;
options.title    = 'Projected data';

if exist('h1','var') && isvalid(h1), delete(h1);end
h1 = ml_plot_data(Y(:,2:3),options);

%% Now try to cluster it

cluster_options.method_name = 'kernel-kmeans';
cluster_options.K           = 3;
cluster_options.kernel      = 'gauss';
cluster_options.kpar        = 1;

[result1]                   = ml_clustering(Y(:,1:2),cluster_options);

result1.title      = 'Kernel K ($3$)-Means on Original Data';
result1.plot_labels = {'$x_1$','$x_2$','$x_3$'};
if exist('hd','var') && isvalid(hd), delete(hd);end
hd = ml_plot_class_boundary(Y(:,2:3),result1);

%% Now perform one PCA per each time windows separately

numb_TW = 8;

for z=1:1:numb_TW
    array_labels = [];
    array_features = [];

    numb_channels = size(feature_struct.features{1}{1},2); % =1

    for j=1:1:length(feature_struct.features)
        if (length(feature_struct.features{j}) >= z)
            array_features = [array_features, feature_struct.features{j}{z}];
            array_labels = [array_labels, feature_struct.labels{j}*ones(1,numb_channels)];
        end
    end

    array_labels = array_labels';
    array_features = array_features';

    [Y,mapping] = pca(array_features,0.9);
%     scatter3(Y(:,1),Y(:,2), Y(:,3), 10, array_labels);
%     title(['PCA results on the first two eigenvectors of TW number ',num2str(z)]);
    cumul_var_explained = cumsum(mapping.lambda)/(sum(mapping.lambda)); 
%     figure
    plot(cumul_var_explained); %seems like 2 vectors is sufficient to represent the data
    title(['Cumulative variance of the PCA results on TW number ', num2str(z)]);
    grid on;
    figure
    
end
