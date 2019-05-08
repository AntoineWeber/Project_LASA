function [kinematicsout] = shorten_kinematics(kinematics, rise, descend)
    
    % function to shorten all the fields of the kinematics given a start
    % and an end indice.
    
    field = fieldnames(kinematics);
    kinematicsout = kinematics;
    
    for i=1:1:length(field)
        temp = kinematics.(field{i});
        kinematicsout.(field{i}) = temp(:,rise:descend);
    end
end

