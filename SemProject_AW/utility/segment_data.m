function [seg_signal,n_windows] = segment_data(signal, window_size_ts, overlap_size_ts)
%SEGMENT_DATA Segments the specified signal using a sliding time window.
%
%   input------------------------------------------------------------------
%       o signal : (M x N) array, signal made of M samples
%
%       o ts_window_size : (1 x 1), number of timesteps per window
%
%       o ts_overlap_size : (1 x 1), number of overlapping timesteps
%
%   output-----------------------------------------------------------------
%       o seg_signal : (m x W) array, segmented signal made of m samples
%                      (size of the time windows) and W segments.
%

% parameters
n_samples = length(signal);
windows_shift_ts = (window_size_ts - overlap_size_ts);
n_windows = floor(n_samples / windows_shift_ts) - 1;

seg_signal = {};

% segment signal
for ii=1:n_windows
    start_ts = (ii-1) * windows_shift_ts + 1;
    end_ts = start_ts + window_size_ts - 1;
    seg_signal{ii} = signal(start_ts:end_ts, :);
end

seg_signal = seg_signal';

end

