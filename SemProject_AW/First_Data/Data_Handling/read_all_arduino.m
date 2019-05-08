function [ardu_last_val] = read_all_arduino(path,check)
%READ_ALL_ARDUINO Summary of this function goes here
%   Detailed explanation goes here

    files = dir([[path '/arduino_data*.txt']]);
    ardu_last_val = []; % last messag
    
    for i=1:1:length(files)
%         ardu_ts = []; % timestamps

        file_id = fopen(files(i).name, 'r');
        tline = fgets(file_id);
        while ischar(tline)
            a = textscan(tline ,'%s');
%             ardu_ts(end+1) = str2double(a{1}{1});
            ardu_last_val(end+1) = str2double(a{1}{end});
            tline = fgets(file_id);
        end
        
        fprintf('Subject number %d : ARDUINO : File number %d has been processed (%d/%d) \n',check,i,i,length(files));
    end
end
