function [array_labels] = create_label_confusion(labels)
%CREATE_LABEL_CONFUSION Summary of this function goes here
%   Detailed explanation goes here


array_labels = zeros(length(labels), sum(unique(labels)));
for i=1:1:length(labels)
    array_labels(i,labels(i)+1) = 1;
end

array_labels = array_labels';


end

