raw = load([scriptDir '/Data/S06/V01/S06V01M0102.mat']);
%only the 2nd one is valid
raw = raw.raw(2,1);
%%  V1 for S06
stimulusClean = Dictionary();
% stimulusClean('Connected1') = raw.stimulus('Connected1');
% connectTime = raw.stimulus.values{1,2}.onset;
% stimulusClean('Connected2') = nirs.design.StimulusEvents('Connected2',connectTime(1),[1],[1]);
% stimulusClean('Connected3') = nirs.design.StimulusEvents('Connected3',connectTime(2),[1],[1]);
% stimulusClean('Connected4') = nirs.design.StimulusEvents('Connected4',connectTime(2),[1],[1]);
% stimulusClean('Connected5') = raw.stimulus('Connected5');
% stimulusClean('Connected6') = raw.stimulus('Connected6');
% stimulusClean('Trial_End') = nirs.design.StimulusEvents('Trial_End',raw.stimulus.values{1,5}.onset,1*ones(6,1),1*ones(6,1));
onsettime = [121.100000000000;267.500000000000;391.100000000000;649.400000000000;901.700000000000;1046.80000000000];
stimulusClean('Stand_and_Alphabet_B') = nirs.design.StimulusEvents('Stand_and_Alphabet_B',onsettime,[1;1;1;1;1;1],[1;1;1;1;1;1]);
stimulusClean('Walk') = nirs.design.StimulusEvents('Walk',raw.stimulus.values{1,10}.onset,1*ones(6,1),1*ones(6,1));
stimulusClean('Walk_and_Alphabet_B') = nirs.design.StimulusEvents('Walk_and_Alphabet_B',raw.stimulus.values{1,11}.onset,1*ones(6,1),1*ones(6,1));
% stimulusClean('Rest') = raw.stimulus('Rest');

restBeforeWalk = [21.1;208.5;452.1; 669.4;843.9; 1.0669e3];
stimulusClean('RestBeforeWalk') = nirs.design.StimulusEvents('RestBeforeWalk',restBeforeWalk,1*ones(6,1),1*ones(6,1));

restBeforeStandAlphabet = [101.1;247.4;371.1;629.4;881.7;1.0268e3];
stimulusClean('RestBeforeStandAlphabet') = nirs.design.StimulusEvents('RestBeforeStandAlphabet',restBeforeStandAlphabet,1*ones(6,1),1*ones(6,1));

restBeforeWalkAlphabet = [59.9;287.5;411.1;589.3;803.9;1.1058e3];
stimulusClean('RestBeforeWalkAlphabet') = nirs.design.StimulusEvents('RestBeforeWalkAlphabet',restBeforeWalkAlphabet,1*ones(6,1),1*ones(6,1));

raw.stimulus = stimulusClean;

%% Clean up stimulus V2

standAlphaTime = [121.100000000000;267.500000000000;391.100000000000;649.400000000000;901.700000000000;1046.80000000000];
walkTime = raw.stimulus.values{1,10}.onset;
walkAlphaTime = raw.stimulus.values{1,11}.onset;
restBeforeWalk = [21.1;208.5;452.1; 669.4;843.9; 1.0669e3];
restBeforeStandAlphabet = [101.1;247.4;371.1;629.4;881.7;1.0268e3];
restBeforeWalkAlphabet = [59.9;287.5;411.1;589.3;803.9;1.1058e3];

allEventTime = [standAlphaTime;walkTime;walkAlphaTime; restBeforeWalk; restBeforeStandAlphabet; restBeforeWalkAlphabet];
allRest = raw.stimulus.values{1,6}.onset;
lastRest = setdiff(allRest, allEventTime);
allTime = [allEventTime; lastRest];

allTimeLabels = [sprintfc('standAlphaTime%d',1:6), sprintfc('walkTime%d',1:6),sprintfc('walkAlphaTime%d',1:6),sprintfc('restBeforeWalk%d',1:6),...
    sprintfc('restBeforeStandAlphabet%d',1:6),sprintfc('restBeforeWalkAlphabet%d',1:6),sprintfc('lastRest%d',1:6)]';
[allTimeSorted,sortIndex] = sort(allTime);
sortedLabels = allTimeLabels(sortIndex);

stimulusName = {'Stand_and_Alphabet_B','Walk','Walk_and_Alphabet_B','RestBeforeWalk','RestBeforeStandAlphabet','RestBeforeWalkAlphabet'};
stimulusTimeVarName = {'standAlphaTime','walkTime','walkAlphaTime','restBeforeWalk','restBeforeStandAlphabet','restBeforeWalkAlphabet'};
stimulusClean = Dictionary();
for es_string = 1:6
    idx = find(contains(sortedLabels,stimulusTimeVarName{es_string}));
    eventDuration = [];
    for i = 1:6
        currLabel = sortedLabels{idx(i)};
        nextLabel = sortedLabels{idx(i)+1}; 
        currEventTimeList = eval(currLabel(1:end-1));
        nextEventTimeList = eval(nextLabel(1:end-1));
        eventDuration = [eventDuration; nextEventTimeList(str2num(nextLabel(end))) - currEventTimeList(str2num(currLabel(end)))];
    end    
    stimulusClean(stimulusName{es_string}) = nirs.design.StimulusEvents(stimulusName{es_string},currEventTimeList,eventDuration,[1;1;1;1;1;1]);
end
raw.stimulus = stimulusClean;

%% clean S08, remove the bad trials
raw = load([scriptDir '/Data/S08/V01/S08V01M01.mat']);
raw = raw.raw;
raw.stimulus.keys
connect3val = raw.stimulus('Connected3')
connect3time = connect3val.onset

%% remove the repeated trials first then fill in the duration
%initial visualization
figure()
raw(1).draw

allEventTime = [];
allTimeLabels = [];
for i = raw.stimulus.keys
    val = raw.stimulus(i);
    onsetTime = val.onset;
    allEventTime = [allEventTime; val.onset];
    sprintfc([i{1} '%d'],1:length(onsetTime))
    allTimeLabels = [allTimeLabels, sprintfc([i{1} '%d'],1:length(onsetTime))];
end

[allTimeSorted,sortIndex] = sort(allEventTime);
sortedLabels = allTimeLabels(sortIndex);
%trial 3 is the problematic one
connectIdx = find(contains(sortedLabels,'Connected3'));

%fix the labels for all future occurances to stay within 1-6
for i = connectIdx(1):connectIdx(2)-1
    wrongLabel = sortedLabels{i};
    idxesContainCurrLabel = find(~cellfun(@isempty,regexp(sortedLabels,['^' wrongLabel(1:end-1) '[0-9]'])))
    wrongIdx = str2num(wrongLabel(end));
    for j = wrongIdx+1:length(idxesContainCurrLabel)
        labelToCorrect = sortedLabels{idxesContainCurrLabel(j)}
        sortedLabels{idxesContainCurrLabel(j)} = [labelToCorrect(1:end-1) num2str(j-1)];
        sortedLabels{idxesContainCurrLabel(j)}
    end
end

%remove the extra ones (bad trial)
sortedLabels(connectIdx(1):connectIdx(2)-1) = [];
allTimeSorted(connectIdx(1):connectIdx(2)-1) = [];

%the main event that we care about
eventKeyIdx = [8,9,10,11,13,14];
stimulusClean = Dictionary();
for es_string = eventKeyIdx
    idx = find(~cellfun(@isempty,regexp(sortedLabels,['^' raw.stimulus.keys{es_string} '[0-9]'])));
    eventDuration = allTimeSorted(idx+1) - allTimeSorted(idx);  
    stimulusClean(raw.stimulus.keys{es_string}) = nirs.design.StimulusEvents(raw.stimulus.keys{es_string},allTimeSorted(idx),eventDuration,[1;1;1;1;1;1]);
end
raw.stimulus = stimulusClean;

figure()
raw(1).draw

save([scriptDir '/Data/S08/V01/S08V01M01Clean.mat'], 'raw')

%% subject S07, random rest before strings and longer durations than expected
