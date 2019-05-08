function [struct_labels] = create_struct_label(numb_windows, label, Windowsize, numb_classes)
    % function creating the label structure to match the definition
    % inside the ESN function.
    
    struct_labels = {};
    
    temporary = zeros(1,numb_classes);
    temporary(label+1) = 1; %labels start at 0
    temporary = repmat(temporary,Windowsize,1);
    
    for i=1:1:numb_windows
        struct_labels{i} = temporary;
    end
    
    struct_labels = struct_labels';
end

