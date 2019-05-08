function [output] = read_all_cyberglove(path,check)
%READ_ALL_CYBERGLOVE Summary of this function goes here
%   Detailed explanation goes here
    
    files = dir([[path '/cyberglove_data*.txt']]);
    output = [];
    
    for i=1:1:length(files)
%         glove_ts = [];
        glove_last_val = [];
        
        file_id = fopen(files(i).name, 'r');

        sizeA = [24 Inf];
        format_spec = ['%d ' 'raw: ' '%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d']; 
        A = fscanf(file_id, format_spec, sizeA);
        A = A';
%         glove_ts = A(:,1);
        glove_last_val = A(:,2:end);
        output = [output; glove_last_val];
        
        fprintf('Subject number %d : CYBERGLOVE : File number %d has been processed (%d/%d) \n',check,i,i,length(files));
    end
end

