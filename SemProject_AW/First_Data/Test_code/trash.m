% YOU SHOULD HAVE CYBERGLOVE_SEGMENTED AND EMG_SEGMENTED IN MEMORY BEFORE
% RUNNING THIS SCRIPT.

% for h=1:1:4
    n_glove = length(cyberglove_segmented{1,1});
    mean_glove = 0;
    n_EMG = length(TEST{1,1});
    mean_EMG = 0;

    for i=1:1:n_glove
        mean_glove = mean_glove + length(cyberglove_segmented{1,1}{1,i});
    end

    for j=1:1:n_EMG
        mean_EMG = mean_EMG + length(TEST{1,1}{1,j});
    end

    mean_glove = mean_glove/n_glove;
    mean_EMG = mean_EMG/n_EMG;
% end


%%

temp = medfilt1(rest_signal,101);

plot(temp,'r')
grid on; hold on

temp = medfilt1(rest_signal,201);
plot(temp,'b')
%%

numb = 1;
[TEST{numb}.signal, TEST{numb}.triggers] = filter_signal(TEST{numb}.signal, TEST{numb}.triggers,'EMG');

%%
okkk = {};
for j=1:1:4
    signal = EMG_segmented{1,j}.signal;
    tot = [];
    for i = 1:1:length(signal)
        tot(i) = length(signal{1,i});
    end
    okkk{j} = unique(tot);
    dev(j) = std(tot);
    tot(tot==0) = [];
    moy(j) = mean(tot);
end

%%
for i = 1:1:length(descending_edges_overall)
    test(i) = (descending_edges_overall(i)-rising_edges(i))>0;
end
test(end+1) = descending_edges_overall(end) - rising_edges(end);
det = all(test)
%%

for i=91:1:91
    plot(EMG_segmented{1,2}.triggers{1,i})
    grid on; hold on
end

%%
numb = 1;
tot = []
for i=1:1:length(cyberglove_segmented{1,numb}.triggers)
    tot = [tot; cyberglove_segmented{1,numb}.triggers{1,i}];
end
plot(tot)

%%
numb = 4;
count = 0;
for i=1:1:length(cyberglove_segmented{1,numb}.signal)
    if (length(cyberglove_segmented{1,numb}.signal{1,i}) > 0)
        count = count + 1;
    end
end
count
%%
tot = [];
for i = 1:1:length(cyberglove_segmented{1,1}.apertures)
    tot(i) = cyberglove_segmented{1,1}.apertures{1,i};
end
m = median(tot)







%%

plot(EMG_segmented{1,1}.triggers{1,3})
grid on; hold on
plot(cyberglove_segmented{1,1}.triggers{1,3})


%%
plot(cybertrig(350:end))
grid on; hold on
plot(emgtrig(350:end))

% slt = emgtrig-cybertrig(1:length(emgtrig));
% figure
% plot(slt)

%%
emgtrig = [];
cybertrig = [];
j=4;

    for i=1:1:length(EMG_segmented{1,j}.triggers)
        emgtrig(i) = any(diff(EMG_segmented{1,j}.triggers{1,i}) == 2);
        cybertrig(i) = any(diff(cyberglove_segmented{1,j}.triggers{1,i}) == 2);
    end
    
    sum(emgtrig-cybertrig)
    
%% test code to check if signal aligned

emg_rising_edges = [];
cyberglove_rising_edges = [];

for numb=1:1:4

    for i=1:1:length(EMG_final{numb}.triggers)
        emg_rising_edges(i) = any(diff(EMG_final{numb}.triggers{1,i}) == 2);
    end

    for i=1:1:length(cyberglove_final{numb}.triggers)
        cyberglove_rising_edges(i) = any(diff(cyberglove_final{numb}.triggers{1,i}) == 2);
    end

    if (sum(cyberglove_rising_edges - emg_rising_edges))
        error('Signals not aligned');
    else
        disp(['All good for subject number',num2str(numb)])
    end
end
