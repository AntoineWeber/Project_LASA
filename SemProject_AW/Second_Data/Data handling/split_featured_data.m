function [splitted_data, splitted_labels] = split_featured_data(data,labels,trainrat,valrat,testrat,nblock,boole)
%SPLIT_FEATURED_DATA Summary of this function goes here
%   Labels must be either 0,1 or 2. Otherwise the sectionning is not done
%   correctly
    

    if nargin == 6
        boole = true;
    else
        boole = false;
    end
    
    splitted_data = {};
    splitted_labels = {};
    % number of different labels
    nb_label = length(unique(labels));
    
    % random permutation
    permu = randperm(length(labels));
    
    % block size
    unitsize = round(length(permu)/nblock);
    
    %making sure to shuffle the data before
    shuffle_data = data(permu,:);
    shuffle_labels = labels(permu);
 
    % added this block to check the balancing of the labels when separating
    % in folders
    if boole
        for j=1:1:nblock-1
            ind = 1;
            % filling the data vector sequentially with the different
            % labels. if 3 classes and unitsize of 7 -> this part only
            % fills 6 slots
            for k=1:1:round(unitsize/nb_label)
                for label = [0,1,2]
                    indice = find(shuffle_labels == label);

                    splitted_data{j}(ind,:) = shuffle_data(indice(1),:);
                    splitted_labels{j}(ind) = shuffle_labels(indice(1));

                    shuffle_data(indice(1),:) = [];
                    shuffle_labels(indice(1)) = [];
                    ind=ind+1;
                end
            end
            % now the resting indices are taken randomly (maximum 2 !)
            for k=1:1:mod(unitsize, nb_label)
                label = randi([0,2]);
                indice = find(shuffle_labels == label);

                splitted_data{j}(ind,:) = shuffle_data(indice(1),:);
                splitted_labels{j}(ind) = shuffle_labels(indice(1));

                shuffle_data(indice(1),:) = [];
                shuffle_labels(indice(1)) = [];

                ind=ind+1;
            end
        end

        splitted_data{nblock} = shuffle_data;
        splitted_labels{nblock} = shuffle_labels';
        
    else % if no balancing is needed
        for j=1:1:nblock-1
            splitted_data{j} = shuffle_data((j-1)*unitsize+1:j*unitsize,:);
            splitted_labels{j} = shuffle_labels((j-1)*unitsize+1:j*unitsize,:);
        end
        splitted_data{nblock} = shuffle_data((nblock-1)*unitsize+1:end,:);
        splitted_labels{nblock} = shuffle_labels((nblock-1)*unitsize+1:end,:);
    end
    
end

