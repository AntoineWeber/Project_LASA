clear all,
close all,

subjects = {'subject_1','subject_2','subject_3','subject_4','subject_5','subject_6','subject_7','subject_8'}; 

raw_data = [];
all_data = [];
av_trial_data = [];


dim = 15;


for l=1:1
    l
    folder_name  =[ 'C:\Users\Sahar\Desktop\Backup_Folder\EPFL_Grasping\EMG_REACH\matlab files\neuroprosthetics_data\EMG_data_TNE\', subjects{l}];

    cd (folder_name);

    load EMG_block

    cd ../../../..
    
    
data1 = [];
data2 = [];
data3 = [];
data4 = [];
output1 = [];
output2 = [];
output3 = [];
output4 = [];
ex_length1 = [];
ex_length2 = [];
ex_length3 = [];
ex_length4 = [];

data = [];
output = [];
ex_length = [];

data_cell = [];
output_cell = [];
k = 1;
s = 1;

l = [];
for i=1:length( EMG_epoch.Obj)
    l= [l;length(EMG_epoch.Obj{i}.reach)];
end


 for j=1:min(l)
    for i=1:length( EMG_epoch.Obj)
   
       
    
            data = [data; EMG_epoch.Obj{i}.reach{j} ];
            ex_length = [ex_length length(EMG_epoch.Obj{i}.reach{j}) ];
            
            data_cell{k,1} = zeros(length(EMG_epoch.Obj{i}.reach{j}),dim);
            data_cell{k,1} =  EMG_epoch.Obj{i}.reach{j};
            
            output_cell{k,1} = zeros(length(EMG_epoch.Obj{i}.reach{j}),4);
             
            
         
            if (i==1) || (i==4) || (i ==7) || (i ==10)
                data1 = [data1; EMG_epoch.Obj{i}.reach{j} ];
                ex_length1 = [ex_length1 length(EMG_epoch.Obj{i}.reach{j}) ];
                %M = resample(M, 1000, length(M)) ;

                output1 = [output1; ones(length(EMG_epoch.Obj{i}.reach{j}),1) zeros(length(EMG_epoch.Obj{i}.reach{j}),3) ];
                output = [output; ones(length(EMG_epoch.Obj{i}.reach{j}),1) zeros(length(EMG_epoch.Obj{i}.reach{j}),3) ];
                output_cell{k,1} = [ones(length(EMG_epoch.Obj{i}.reach{j}),1) zeros(length(EMG_epoch.Obj{i}.reach{j}),3)];

          end
          
          if (i==2) || (i==5) || (i == 8) || (i == 14)
            data2 = [data2; EMG_epoch.Obj{i}.reach{j} ];
            ex_length2 = [ex_length2 length(EMG_epoch.Obj{i}.reach{j}) ];
            %M = resample(M, 1000, length(M)) ;
           
            output2 = [output2; zeros(length(EMG_epoch.Obj{i}.reach{j}),1) ones(length(EMG_epoch.Obj{i}.reach{j}),1) zeros(length(EMG_epoch.Obj{i}.reach{j}),2) ];
            
            output = [output; zeros(length(EMG_epoch.Obj{i}.reach{j}),1) ones(length(EMG_epoch.Obj{i}.reach{j}),1) zeros(length(EMG_epoch.Obj{i}.reach{j}),2) ];
            output_cell{k,1} = [zeros(length(EMG_epoch.Obj{i}.reach{j}),1) ones(length(EMG_epoch.Obj{i}.reach{j}),1) zeros(length(EMG_epoch.Obj{i}.reach{j}),2) ];
          end
          
           if (i==3) || (i==11) || (i == 12) || (i == 15)
            data3 = [data3; EMG_epoch.Obj{i}.reach{j} ];
            ex_length3 = [ex_length3 length(EMG_epoch.Obj{i}.reach{j}) ];
            %M = resample(M, 1000, length(M)) ;
           
            output3 = [output3; zeros(length(EMG_epoch.Obj{i}.reach{j}),2) ones(length(EMG_epoch.Obj{i}.reach{j}),1) zeros(length(EMG_epoch.Obj{i}.reach{j}),1) ];
            
            output = [output; zeros(length(EMG_epoch.Obj{i}.reach{j}),2) ones(length(EMG_epoch.Obj{i}.reach{j}),1) zeros(length(EMG_epoch.Obj{i}.reach{j}),1) ];
            output_cell{k,1} = [zeros(length(EMG_epoch.Obj{i}.reach{j}),2) ones(length(EMG_epoch.Obj{i}.reach{j}),1) zeros(length(EMG_epoch.Obj{i}.reach{j}),1) ];
            
           end
          
           if (i==6) || (i==9) || (i == 13) || (i == 16)
            data4 = [data4; EMG_epoch.Obj{i}.reach{j} ];
            ex_length4 = [ex_length4 length(EMG_epoch.Obj{i}.reach{j}) ];
            %M = resample(M, 1000, length(M)) ;
           
            output4 = [output4; zeros(length(EMG_epoch.Obj{i}.reach{j}),3) ones(length(EMG_epoch.Obj{i}.reach{j}),1)  ];
            
            output = [output; zeros(length(EMG_epoch.Obj{i}.reach{j}),3) ones(length(EMG_epoch.Obj{i}.reach{j}),1)  ];
            output_cell{k,1} = [zeros(length(EMG_epoch.Obj{i}.reach{j}),3) ones(length(EMG_epoch.Obj{i}.reach{j}),1) ];
            
           end
           k = k+1;
        end
         
    end

end




%%%%%%%%%%%%%%%%%% PCA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mean_dataPca = mean(data);
[coeff,score,latent] = princomp(data);

lat = latent/sum(latent);
new_base = coeff(:,1:6)';

r = 6;
data_pca = [];
for i=1:(k-1)
    d = data_cell{i,1};
    data_pca{i,1} = zeros(length(d),r);
    data_pca{i,1} = (new_base*d')';
end
    
save data_subject1_new data_cell output_cell
save data_pca_subject1_new data_pca output_cell

% data_pca = new_base*data';
% data_pca = data_pca';


% %%%%%%%%%%% plot projected data according to classes %%%%%
% figure(1), hold on,
% for i=1:length(data_pca)
%     if sum( output(i,:)==[1 0 0 0]) == 4
%         color = '*r';
%     else if sum( output(i,:)==[0 1 0 0]) == 4
%             color = '+g';
%         else if sum( output(i,:)==[0 0 1 0]) ==4
%                 color = 'ob';
%             else color = '-k';
%             end
%         end
%     end
%     
%     plot3(data_pca(i,1), data_pca(i,2),data_pca(i,3),color), hold on
% end
