function [data] = get_aperture(trials,calib_file,min_file,max_file,h)
%Get the aperture to separate the two other different graps types to
%finalize the labels.


apertures = [];
for j=1:1:length(trials.signal)
    %if (trials.labels ~= 0)
        raw_jointangle = trials.signal{1,j}(end,:); %getting the last line
        calibrated_angle = getCalibratedHandAngles(raw_jointangle,calib_file,min_file,max_file);
        [~,aperture]=preshape_criteria(calibrated_angle,h,2); %2 just to stipulate to compute distance between index and thumb. 
        trials.apertures{1,j} = aperture;
%         apertures(j) = aperture;
    %end
end

% med = median(apertures);
% 
% for j=1:1:length(trials.signal)
%     if (apertures(j) < med)
%         trials.labels{1,j} = 1;
%     else
%         trials.labels{1,j} = 2;
%     end
% end

data = trials;

end

