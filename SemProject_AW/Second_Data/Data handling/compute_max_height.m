function [maxheight] = compute_max_height(kinematics,length_sess)

    % returns an array where rows represent mean and std of maximum value
    % along z axis and each column is for one session
    
    with_0 = [0, length_sess];
    maxheight = zeros(2,length(length_sess));
    % rows = means
    % columns = std
    sizes = cumsum(with_0);

    % compute mean and std of the max reached height
    for sess=1:1:length(length_sess)
        
        maxx = [];
        k = 1;
        for trial=(sizes(sess)+1):1:sizes(sess+1)
            maxx(k) = max(kinematics{trial}.handPosition(2,:));
            k = k+1;
        end

        maxheight(1,sess) = mean(maxx);
        maxheight(2,sess) = std(maxx);
    end
    
end

