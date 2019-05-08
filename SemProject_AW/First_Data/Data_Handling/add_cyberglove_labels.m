function [labels] = add_cyberglove_labels(trials)
%ADD_CYBERGLOVE_LABELS Summary of this function goes here
%   Detailed explanation goes here

temp = cell2mat(trials.labels);
indices_zero = find(temp == 0);

apertures = cell2mat(trials.apertures);
apertures(indices_zero) = NaN;

med = nanmedian(apertures);

for j=1:1:length(trials.signal)
    if (~isnan(apertures(j)))
        if (apertures(j) < med)
            trials.labels{1,j} = 1;
        else
            trials.labels{1,j} = 2;
        end
    end
end

labels = trials.labels;

end

