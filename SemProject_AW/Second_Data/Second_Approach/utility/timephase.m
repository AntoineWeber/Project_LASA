function [t1, t2, t3] = timephase(kine, subj, ind)
% Function finding the frontiers of the 3 phases

    kine_hand = kine{subj}{ind}.handPosition(3,:);
    % compute the velocity
    kine_hand = medfilt1(diff(kine_hand),50);
    
    % find the maximum velocity
    [~,i1] = max(kine_hand);
    
    % find the velocity under the threshold set by hand
    xss = find(kine_hand < 0.4e-3);
    k=1;
    
    % make sure the velocity found is not inside the phase 1
    while 1
        k=k+1;
        if xss(k) > i1
            i2 = xss(k);
            break
        end
    end
    
    % output the time offset of the three phases
    t1 = kine{subj}{ind}.timestamp(i1) - kine{subj}{ind}.timestamp(1);
    t2 = kine{subj}{ind}.timestamp(i2) - kine{subj}{ind}.timestamp(1);
    t3 = kine{subj}{ind}.timestamp(end) - kine{subj}{ind}.timestamp(1);
    
end

