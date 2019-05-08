function [area,aperture] = get_aperture_persample(sample,calib_file,min_file,max_file,h)

% Computing the aperture of a given sample.
raw_jointangle = sample;
calibrated_angle = getCalibratedHandAngles(raw_jointangle,calib_file,min_file,max_file);
% 2 just to stipulate to compute distance between index and thumb. 
[area,aperture]=preshape_criteria(calibrated_angle,h,2); 

end

