numb_TW = 15;
numb_f = 5;

values_train = [];
values_test = [];

for i=1:1:numb_f
    for j=1:1:numb_TW
        values_train(i,j) = scores{1}{i}.score_train(j,2);
        values_test(i,j) = scores{1}{i}.score_validation(j,2);
    end
end

values_test = mean(values_test,1);
values_train = mean(values_train,1);

time = [300,550,800,1050,1300,1550];
plot(time,values_test)
grid on; hold on
plot(time,values_train)
title('Accuracy of an ESN through all the time windows')
xlabel('Time Window');
ylabel('Accuracy [%]')