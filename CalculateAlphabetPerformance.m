%% find user sequence
close all; clc; clear all;
load('C:\Users\SHL187\OneDrive - University of Pittsburgh\SML\Projects\fNIR Project\Code_NIRS_Automaticity\Data\SubjectTaskAlphabetRandomizationOrder.mat')
userID = input('Input user ID (number part only): ');
taskOrder = taskOrders(userID, :);
alphabet = alphabetOrder(userID,:);

%%
if alphabet==1 %'A'
    all_events = [2 4 3 1 5;4 3 2 1 5;3 1 2 4 5; 3 2 4 5 1;3 4 1 2 5;2 3 5 4 1];
    startingLetter = double('A');
else %B
   all_events= [7 8 3 6 9; 8 3 7 6 9; 3 6 7 8 9; 3 7 8 9 6; 3 8 6 7 9; 7 3 9 8 6]; 
   startingLetter = double('B');
end
%1 = stand and alphabet A, 2 = walk and alphabet A, 3 = walk, 4 = stand and
%alphabet 3 A, 5 = walk and alphabet 3 A; 6 = stand and alphabet B, 7 = walk and alphabet B, 8 = stand and
%alphabet 3B, 9 = walk and alphabet 3B
correctCounts = nan(6,4); %trial x task
trialIdx = 1;
for i = taskOrder
    curr_seq = all_events(i,:);
    alphabetGenerated = []; %all caps letter, A=65, Z=90
    curr_seq_idx = 1;
    for task = curr_seq
        if task == 3
            continue
        end
        if task == 1
            alphabetGenerated = input('Input participant generated alphabet for stand and alphabet A (no space): ','s');
        elseif task == 2
            alphabetGenerated = input('Input participant generated alphabet for walk and alphabet A (no space): ','s');
        elseif task == 4
            alphabetGenerated = input('Input participant generated alphabet for stand and alphabet 3A (no space): ','s');
        elseif task == 5
            alphabetGenerated = input('Input participant generated alphabet for walk and alphabet 3A (no space): ','s');
        elseif task == 6
            alphabetGenerated = input('Input participant generated alphabet for stand and alphabet B (no space): ','s');
        elseif task == 7
            alphabetGenerated = input('Input participant generated alphabet for walk and alphabet B (no space): ','s');
        elseif task == 8
            alphabetGenerated = input('Input participant generated alphabet for stand and alphabet 3B (no space): ','s');
        elseif task == 9
            alphabetGenerated = input('Input participant generated alphabet for walk and alphabet 3B (no space): ','s');
        end
        alphabetGenerated = double(alphabetGenerated);
        correct = double(alphabetGenerated(1)) == startingLetter; %'B'
        alphabetSpace = diff(alphabetGenerated);
        if ismember([1,2,6,7],task) %every 2 letters
            correct = correct + sum(alphabetSpace == 2);
        else %every 3 letters
            correct = correct + sum(alphabetSpace == 3);
        end
        correctCounts(trialIdx,curr_seq_idx) = correct;
        curr_seq_idx = curr_seq_idx+1;
    end
    trialIdx = trialIdx+1;
end

