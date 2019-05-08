function [EMG_aligned, cyberglove_aligned,indices] = align_signals(EMG, cyberglove,indices)
    
    %This code is dirty. However to accurately align the signals, I had to do
    %it by hand, as there was no other options.

    subj1 = [60,88,347,382];
    subj2_cyber = [43,199,198,225,225,222,223,224,225,322];
    subj3 = [110,122,128,134,146,235];
    subj4 = [48,59,100,137,349,396];

    cyberglove = del_element_cyber(cyberglove, subj1, 1);
    cyberglove = del_element_cyber(cyberglove, subj2_cyber, 2);
    cyberglove = del_element_cyber(cyberglove, subj3, 3);
    cyberglove = del_element_cyber(cyberglove, subj4, 4);

    %subject 2 was more like a mess
    subj2_emg = [92,222,223,224,225];
    EMG = del_element_emg(EMG, subj2_emg, 2);
    
    %
    indices_1 = indices{1};
    for j=1:1:length(subj1)
        indices_1((2*subj1(j)-1):2*subj1(j)) = [];
    end
    indices{1} = indices_1;
    %
    indices_2 = indices{2};
    for j=1:1:length(subj2_cyber)
        indices_2((2*subj2_cyber(j)-1):2*subj2_cyber(j)) = [];
    end
    indices{2} = indices_2;
    %
    indices_3 = indices{3};
    for j=1:1:length(subj3)
        indices_3((2*subj3(j)-1):2*subj3(j)) = [];
    end
    indices{3} = indices_3;
    %
    indices_4 = indices{4};
    for j=1:1:length(subj4)
        indices_4((2*subj4(j)-1):2*subj4(j)) = [];
    end
    indices{4} = indices_4;
    %
    
    EMG_aligned = EMG;
    cyberglove_aligned = cyberglove;
end


