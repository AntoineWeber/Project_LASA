function [area,aperture] = get_aperture_persample(sample,calib_file,min_file,max_file,h)
%GET_APERTURE_PERSAMPLE Summary of this function goes here
%   Detailed explanation goes here

raw_jointangle = sample;
calibrated_angle = getCalibratedHandAngles(raw_jointangle,calib_file,min_file,max_file);
[area,aperture]=preshape_criteria(calibrated_angle,h,2); %2 just to stipulate to compute distance between index and thumb. 

end

