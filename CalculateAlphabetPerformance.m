%% find user sequence
close all; clc; clearvars;
% subjectID = 'AUF01V01';
% dataPath = split(subjectID,'V');
% dataPath = ['Y:\Shuqi\NirsAutomaticityStudy\Data\' dataPath{1} '\V' dataPath{2} '\'];
[dataPath, ~, ~, subjectID, visitNum] = setupDataPath('AUF01', 'V01', '', 'walkDistFigure');

%% Find or create the DTdata data structure, find task orders to populate the DTdata
[DTdata, DTdataRowNameMap] = GetDTDataStructure([dataPath subjectID 'DTdata.mat']); %if exists one load it TODO

if visitNum == 4
    visitNum = 2; %column 2
end

userID = str2num(subjectID(3:5)); %after the AUF
scriptDir = fileparts(matlab.desktop.editor.getActiveFilename);
load([scriptDir '/Data/SubjectTaskAlphabetRandomizationOrderRetest.mat'])
taskOrder = taskOrders(userID, :);
alphabet = alphabetOrder(userID,visitNum);
%%
if alphabet==1 %'A'
    all_events = [2 4 3 1 5;4 3 2 1 5;3 1 2 4 5; 3 2 4 5 1;3 4 1 2 5;2 3 5 4 1];
    startingLetter = double('A');
    DTdata.startingAlphabet = 'A';
elseif alphabet == 2 %B
   all_events= [7 8 3 6 9; 8 3 7 6 9; 3 6 7 8 9; 3 7 8 9 6; 3 8 6 7 9; 7 3 9 8 6]; 
   startingLetter = double('B');
   DTdata.startingAlphabet = 'B';
end
%if none of the above option, should error out

%1 = stand and alphabet A, 2 = walk and alphabet A, 3 = walk, 4 = stand and
%alphabet 3 A, 5 = walk and alphabet 3 A; 6 = stand and alphabet B, 7 = walk and alphabet B, 8 = stand and
%alphabet 3B, 9 = walk and alphabet 3B
allAlphabeteGenerated = readcell([dataPath subjectID 'Alphabet.xlsx']);
trialIdx = 1;
for i = taskOrder
    curr_seq = all_events(i,:);
    alphabetGenerated = []; %all caps letter, A=65, Z=90
    taskIdx = 2; %skip row 1 = header
    for task = curr_seq
        if task == 3
            continue
        end
        alphabetGenerated = allAlphabeteGenerated{taskIdx, trialIdx};
        taskIdx = taskIdx + 1;
        if task == 1
            fprintf('stand and alphabet 2A: %s\n', alphabetGenerated); %input('Input participant generated alphabet (no space, all caps) for stand and alphabet 2A: ','s');
        elseif task == 2
            fprintf('walk and alphabet 2A: %s\n', alphabetGenerated); 
            %alphabetGenerated = input('Input participant generated alphabet (no space, all caps) for walk and alphabet 2A (no space): ','s');
        elseif task == 4
            fprintf('stand and alphabet 3A: %s\n', alphabetGenerated); 
            %alphabetGenerated = input('Input participant generated alphabet (no space, all caps) for stand and alphabet 3A (no space): ','s');
        elseif task == 5
            fprintf('walk and alphabet 3A: %s\n', alphabetGenerated); 
            %alphabetGenerated = input('Input participant generated alphabet (no space, all caps) for walk and alphabet 3A (no space): ','s');
        elseif task == 6
            fprintf('stand and alphabet 2B: %s\n', alphabetGenerated); 
            %alphabetGenerated = input('Input participant generated alphabet (no space, all caps) for stand and alphabet 2B (no space): ','s');
        elseif task == 7
            fprintf('walk and alphabet 2B: %s\n', alphabetGenerated); 
            %alphabetGenerated = input('Input participant generated alphabet (no space, all caps) for walk and alphabet 2B (no space): ','s');
        elseif task == 8
            fprintf('stand and alphabet 3B: %s\n', alphabetGenerated);
            %alphabetGenerated = input('Input participant generated alphabet (no space, all caps) for stand and alphabet 3B (no space): ','s');
        elseif task == 9
            fprintf('walk and alphabet 3B: %s\n', alphabetGenerated); 
            %alphabetGenerated = input('Input participant generated alphabet (no space, all caps) for walk and alphabet 3B (no space): ','s');
        end
        alphabetGenerated = double(alphabetGenerated);
        correct = double(alphabetGenerated(1)) == startingLetter; %'B'
        restartedLetter = find(diff(alphabetGenerated) < 0);
        if restartedLetter %reached end and restarted from A-C
            for restartIdx = restartedLetter
                alphabetGenerated(restartIdx+1:end)= alphabetGenerated(restartIdx+1:end)+26;
            end
        end
        alphabetSpace = diff(alphabetGenerated);
        if any(ismember([1,2,6,7],task)) %every 2 letters
            correct = correct + sum(alphabetSpace == 2);
        else %every 3 letters
            correct = correct + sum(alphabetSpace == 3);
        end
        DTdata.data{DTdataRowNameMap(task),'alphabetCount'}(trialIdx) = correct;
        DTdata.data{DTdataRowNameMap(task),'alphabetGenerated'}{trialIdx} = alphabetGenerated;
    end
    trialIdx = trialIdx+1;
end

%%
save([dataPath subjectID 'DTdata.mat'],'DTdata')

%% fix data
% DTdata = subjDTdata;
% curr = DTdata.data.alphabetCount;
% shifted = [nan(4,1) curr(1:4,1:5);nan(1,6)];
% DTdata.data.alphabetCount = shifted;
% 
% curr = DTdata.data.alphabetGenerated;
% shifted = [cell(4,1) curr(1:4,1:5);cell(1,6)];
% DTdata.data.alphabetGenerated = shifted;


