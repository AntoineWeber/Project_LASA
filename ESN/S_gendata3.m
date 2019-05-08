clear all,
close all,

subjects = {'subject_1','subject_2','subject_3','subject_4','subject_5','subject_6','subject_7','subject_8'}; 

raw_data = [];
all_data = [];
av_trial_data = [];


dim = 15;


for sub=1:8
    
    folder_name  =[ 'C:\Users\Sahar\Desktop\Backup_Folder\EPFL_Grasping\EMG_REACH\matlab files\neuroprosthetics_data\EMG_data_TNE\', subjects{sub}];

    cd (folder_name);

    load EMG_block

    cd ../../../..
    
%     
% data1 = [];
% data2 = [];
% data3 = [];
% data4 = [];
% output1 = [];
% output2 = [];
% output3 = [];
% output4 = [];
% ex_length1 = [];
% ex_length2 = [];
% ex_length3 = [];
% ex_length4 = [];

data = [];
output = [];
ex_length = [];

train_data_cell = [];
train_output_cell = [];

test_data_cell = [];
test_output_cell = [];

ktrain = 1;
ktest = 1;
s = 1;

l = [];
for i=1:length( EMG_epoch.Obj)
    l= [l;length(EMG_epoch.Obj{i}.reach)];
end


 for j=1:min(l)
    for i=1:length( EMG_epoch.Obj)
   
       
    
            data = [data; EMG_epoch.Obj{i}.reach{j} ];
            ex_length = [ex_length length(EMG_epoch.Obj{i}.reach{j}) ];
            
  
            if (i==1) || (i==4) || (i ==7) || (i ==10)
%                 data1 = [data1; EMG_epoch.Obj{i}.reach{j} ];
%                 ex_length1 = [ex_length1 length(EMG_epoch.Obj{i}.reach{j}) ];
%                 %M = resample(M, 1000, length(M)) ;
% 
%                 output1 = [output1; ones(length(EMG_epoch.Obj{i}.reach{j}),1) zeros(length(EMG_epoch.Obj{i}.reach{j}),3) ];
%                 output = [output; ones(length(EMG_epoch.Obj{i}.reach{j}),1) zeros(length(EMG_epoch.Obj{i}.reach{j}),3) ];

                if (i==10)|| (i ==7)
                    test_data_cell{ktest,1} = zeros(length(EMG_epoch.Obj{i}.reach{j}),dim);         
                    test_output_cell{ktest,1} = zeros(length(EMG_epoch.Obj{i}.reach{j}),4);
                    test_output_cell{ktest,1} = [ones(length(EMG_epoch.Obj{i}.reach{j}),1) zeros(length(EMG_epoch.Obj{i}.reach{j}),3)];
                    test_data_cell{ktest,1} =  EMG_epoch.Obj{i}.reach{j};
                     ktest = ktest + 1;
                else
                    train_data_cell{ktrain,1} = zeros(length(EMG_epoch.Obj{i}.reach{j}),dim);         
                    train_output_cell{ktrain,1} = zeros(length(EMG_epoch.Obj{i}.reach{j}),4);
                    train_output_cell{ktrain,1} = [ones(length(EMG_epoch.Obj{i}.reach{j}),1) zeros(length(EMG_epoch.Obj{i}.reach{j}),3)];
                    train_data_cell{ktrain,1} =  EMG_epoch.Obj{i}.reach{j};
                    ktrain = ktrain+1;
                end

          end
          
          if (i==2) || (i==5) || (i == 8) || (i == 14)
%             data2 = [data2; EMG_epoch.Obj{i}.reach{j} ];
%             ex_length2 = [ex_length2 length(EMG_epoch.Obj{i}.reach{j}) ];
%             %M = resample(M, 1000, length(M)) ;
%            
%             output2 = [output2; zeros(length(EMG_epoch.Obj{i}.reach{j}),1) ones(length(EMG_epoch.Obj{i}.reach{j}),1) zeros(length(EMG_epoch.Obj{i}.reach{j}),2) ];
%             
%             output = [output; zeros(length(EMG_epoch.Obj{i}.reach{j}),1) ones(length(EMG_epoch.Obj{i}.reach{j}),1) zeros(length(EMG_epoch.Obj{i}.reach{j}),2) ];
                if (i == 8) || (i == 14)
                        test_data_cell{ktest,1} = zeros(length(EMG_epoch.Obj{i}.reach{j}),dim);         
                        test_output_cell{ktest,1} = zeros(length(EMG_epoch.Obj{i}.reach{j}),4);
                        test_output_cell{ktest,1} = [zeros(length(EMG_epoch.Obj{i}.reach{j}),1) ones(length(EMG_epoch.Obj{i}.reach{j}),1) zeros(length(EMG_epoch.Obj{i}.reach{j}),2) ];
                        test_data_cell{ktest,1} =  EMG_epoch.Obj{i}.reach{j};
                         ktest = ktest + 1;
                else
                        train_data_cell{ktrain,1} = zeros(length(EMG_epoch.Obj{i}.reach{j}),dim);         
                        train_output_cell{ktrain,1} = zeros(length(EMG_epoch.Obj{i}.reach{j}),4);
                        train_output_cell{ktrain,1} = [zeros(length(EMG_epoch.Obj{i}.reach{j}),1) ones(length(EMG_epoch.Obj{i}.reach{j}),1) zeros(length(EMG_epoch.Obj{i}.reach{j}),2) ];
                        train_data_cell{ktrain,1} =  EMG_epoch.Obj{i}.reach{j};
                        ktrain = ktrain+1;
                end
          end
          
           if (i==3) || (i==11) || (i == 12) || (i == 15)
%             data3 = [data3; EMG_epoch.Obj{i}.reach{j} ];
%             ex_length3 = [ex_length3 length(EMG_epoch.Obj{i}.reach{j}) ];
%             %M = resample(M, 1000, length(M)) ;
%            
%             output3 = [output3; zeros(length(EMG_epoch.Obj{i}.reach{j}),2) ones(length(EMG_epoch.Obj{i}.reach{j}),1) zeros(length(EMG_epoch.Obj{i}.reach{j}),1) ];
%             
%             output = [output; zeros(length(EMG_epoch.Obj{i}.reach{j}),2) ones(length(EMG_epoch.Obj{i}.reach{j}),1) zeros(length(EMG_epoch.Obj{i}.reach{j}),1) ];
                if (i == 12) || (i == 15)
                    test_data_cell{ktest,1} = zeros(length(EMG_epoch.Obj{i}.reach{j}),dim);         
                    test_output_cell{ktest,1} = zeros(length(EMG_epoch.Obj{i}.reach{j}),4);
                    test_output_cell{ktest,1} = [zeros(length(EMG_epoch.Obj{i}.reach{j}),2) ones(length(EMG_epoch.Obj{i}.reach{j}),1) zeros(length(EMG_epoch.Obj{i}.reach{j}),1) ];
                    test_data_cell{ktest,1} =  EMG_epoch.Obj{i}.reach{j};
                     ktest = ktest + 1;
                else
                    train_data_cell{ktrain,1} = zeros(length(EMG_epoch.Obj{i}.reach{j}),dim);         
                    train_output_cell{ktrain,1} = zeros(length(EMG_epoch.Obj{i}.reach{j}),4);
                    train_output_cell{ktrain,1} = [zeros(length(EMG_epoch.Obj{i}.reach{j}),2) ones(length(EMG_epoch.Obj{i}.reach{j}),1) zeros(length(EMG_epoch.Obj{i}.reach{j}),1) ];
                    train_data_cell{ktrain,1} =  EMG_epoch.Obj{i}.reach{j};
                    ktrain = ktrain+1;
                end

           end
          
           if (i==6) || (i==9) || (i == 13) || (i == 16)
%             data4 = [data4; EMG_epoch.Obj{i}.reach{j} ];
%             ex_length4 = [ex_length4 length(EMG_epoch.Obj{i}.reach{j}) ];
%             %M = resample(M, 1000, length(M)) ;
%            
%             output4 = [output4; zeros(length(EMG_epoch.Obj{i}.reach{j}),3) ones(length(EMG_epoch.Obj{i}.reach{j}),1)  ];
%             
%             output = [output; zeros(length(EMG_epoch.Obj{i}.reach{j}),3) ones(length(EMG_epoch.Obj{i}.reach{j}),1)  ];
                if (i == 13) || (i == 16)
                    test_data_cell{ktest,1} = zeros(length(EMG_epoch.Obj{i}.reach{j}),dim);         
                    test_output_cell{ktest,1} = zeros(length(EMG_epoch.Obj{i}.reach{j}),4);
                    test_output_cell{ktest,1} = [zeros(length(EMG_epoch.Obj{i}.reach{j}),3) ones(length(EMG_epoch.Obj{i}.reach{j}),1) ];
                    test_data_cell{ktest,1} =  EMG_epoch.Obj{i}.reach{j};
                     ktest = ktest + 1;
                else
                    train_data_cell{ktrain,1} = zeros(length(EMG_epoch.Obj{i}.reach{j}),dim);         
                    train_output_cell{ktrain,1} = zeros(length(EMG_epoch.Obj{i}.reach{j}),4);
                    train_output_cell{ktrain,1} = [zeros(length(EMG_epoch.Obj{i}.reach{j}),3) ones(length(EMG_epoch.Obj{i}.reach{j}),1) ];
                    train_data_cell{ktrain,1} =  EMG_epoch.Obj{i}.reach{j};
                    ktrain = ktrain+1;
                end
            
           end
           
          
        end
         
 end
   
 save_file = ['data_subject', num2str(sub),'_t2_v2']
 save ( save_file, 'train_data_cell', 'train_output_cell', 'test_data_cell', 'test_output_cell')


end




%%%%%%%%%%%%%%%%%% PCA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% mean_dataPca = mean(data);
% [coeff,score,latent] = princomp(data);
% 
% lat = latent/sum(latent);
% new_base = coeff(:,1:6)';
% 
% r = 6;
% data_pca = [];
% for i=1:(k-1)
%     d = data_cell{i,1};
%     data_pca{i,1} = zeros(length(d),r);
%     data_pca{i,1} = (new_base*d')';
% end
%     

%save data_pca_subject1_new data_pca output_cell

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
