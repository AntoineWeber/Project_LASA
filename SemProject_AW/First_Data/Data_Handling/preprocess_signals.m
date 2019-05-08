function [emg_pp] = preprocess_signals(data, sr, bandpass_f, lowpass_f, normalize, rectify, mvc)
%PREPROCESS_SIGNALS Filters and rectifies signals. First removes the mean
%value from the signals. Then applies band-pass filtering (high-pass
%and low-pass Butterworth 7th order filters. The signals are subsequently
%rectified and a low pass filter is applied. Finally, the signals are
%normalized using the MVC measurement.
%
%   input -----------------------------------------------------------------
%      
%       o data : (N x D), signal of N samples and D channels
%
%       o sr : (1 x 1), sampling rate
%
%       o bandpass_f : (2 x 1), cut-off frequencies of the band-pass filter
%                               (lower and upper)
%
%       o lowpass_f : (1 x 1), cut-off frequency of the low-pass filter
%
%       o normalize : boolean, indicating if the data should be normalized
%
%       o rectify : boolean, indicating if the data should be rectified
%
%       o mvc : (D x 1), the Maximum Volunteered Contraction (MVC) value 
%                        for each muscle
%
%
%   output ----------------------------------------------------------------
%
%       o emg_pp : (N x D), processed signals of N samples and D channels
%

% High pass frequency
coff_bp_h   = bandpass_f(1);
coff_bp_l   = bandpass_f(2);

% Low pass frequency
coff_lp  = lowpass_f; 


%% Detrend
data_new = detrend(data, 'constant');

%% Band-pass filtering
% High pass
Wn = (coff_bp_l * 2) / sr;
if Wn > 1.0
    Wn = 0.99;
end

[B, A] = butter(7, Wn, 'high'); %Butterworth 7th order
data_h = filtfilt(B, A, data_new);       

% Low pass
Wn = (coff_bp_h * 2) / sr;
if Wn > 1.0
    Wn=0.99;
end

[B, A] = butter(7, Wn, 'low'); %Butterworth 7th order
data_hl = filter(B, A, data_h);       

 
%% Rectification
if rectify
    data_rect = abs(data_hl);
else
    data_rect = data_hl;
end

%% Low pass filtering
coff_h = coff_lp;
Wn = (coff_h * 2) / sr;
if Wn > 1.0
    Wn = 0.99;
end

[B, A] = butter(7, Wn); % Butterworth 7th order

emg_pp = filter(B, A, data_rect);

%% Normalization
if normalize
    for i=1:size(emg_pp, 2)
        emg_pp(:,i) = emg_pp(:,i) / mvc(i);
    end
end

end
