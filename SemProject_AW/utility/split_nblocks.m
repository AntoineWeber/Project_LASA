function [Train_blocks] = split_nblocks(Train,n)
    % split the data given as input into 5 blocks to perform
    % crossvalidation
    
    % shuffle
    permu = randperm(length(Train.signal));
    
    % block size
    unitsize = round(length(permu)/n);
    
    Train_blocks = {};
    
    % define the n blocks
    for j=1:1:n-1
        Train_blocks{j}.signal = Train.signal(permu((j-1)*unitsize+1:j*unitsize));
        Train_blocks{j}.labels = Train.labels(permu((j-1)*unitsize+1:j*unitsize));
    end
    
    Train_blocks{n}.signal = Train.signal(permu((n-1)*unitsize+1:end));
    Train_blocks{n}.labels = Train.labels(permu((n-1)*unitsize+1:end));
end

