% Generate randomization orders
res = nan(22,6);
for i = 1:22
    res(i,:)=randperm(6,6);
end
res

alphabetOrder = randi(2,22,1);

%% Generate print out of task alphabet
alphabetOrderNum = alphabetOrder';
for a = alphabetOrderNum
    if a == 1
        disp('A')
    else
        disp('B')
    end
end

%% Generate print out of task order
clc
for i = 1:22
    fprintf('%d %d %d %d %d %d\n',res(i,:))
end

%% Generate page sequences to use at printers
close all; clear all;
clc
load('C:\Users\SHL187\OneDrive - University of Pittsburgh\SML\Projects\fNIR Project\Code_NIRS_Automaticity\Data\SubjectTaskAlphabetRandomizationOrder.mat')
userID = input('Input user ID (number part only)');
visitNumber = input('Visit number: (1 or 4)');
pageOrder = taskOrders(userID, :);
if visitNumber == 4
    alphabet = alphabetOrder(userID,2);
else
    alphabet = alphabetOrder(userID,1);
end
if alphabet == 1 %start with A
    pageOrder = pageOrder + 3; %first task (task order 1) is on page 4
    pageOrder = [3,pageOrder]; %familiarizationTrial
else %start with B
    pageOrder = pageOrder + 11; %first task (task order 1) is on page 12
    pageOrder = [11, pageOrder];%familiarizationTrial
end
pageOrder = [1, pageOrder];

% print out page to use in printers
pageOrderPrintOut = [];
for p = pageOrder
    pageOrderPrintOut = [pageOrderPrintOut,num2str(p),','];
end
pageOrderPrintOut(end) = [];
disp(pageOrderPrintOut)

    