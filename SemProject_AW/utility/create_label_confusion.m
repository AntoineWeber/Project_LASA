function [array_labels] = create_label_confusion(labels)
% Function to create one-hot encoding


array_labels = zeros(length(labels), sum(unique(labels)));
for i=1:1:length(labels)
    % labels start at 0 while indices at 1
    array_labels(i,labels(i)+1) = 1;
end

array_labels = array_labels';


end

