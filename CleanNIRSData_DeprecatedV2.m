%% general flow, load the data, plot the original data 
close all; clear all; clc
dataPath = 'Y:\Shuqi\NirsAutomaticityStudy\Data\AUF03\V01Nirs\';
subjectID = 'AUF03';
raw = load([dataPath subjectID 'NirsRaw.mat']);
raw = raw.raw;
for i=1:length(raw)
    figure('units','normalized','outerposition',[0 0 1 1]);
    raw(i).draw
end
rawOriginal = raw;

%% clean valid trials. Add durations of each event and save the cleaned data
f = figure();
cols = 3;
rows = 2;
pltIdx = 1;
durationCheck = nan(6,10);
validIdx = 3:8;%change index here, corresponding measurement index
for trialIdx = validIdx 
    %2nd argument: starting alphabet
    %last argument: how many iterations per measurement file, usually 1, previous pilot data = 6.
    raw(trialIdx) = addStimulusDuration(rawOriginal(trialIdx), 'B', 1);
    subplot(rows,cols,pltIdx)
    raw(trialIdx).draw
    for i = 1:10
        durationCheck(pltIdx, i) = raw(trialIdx).stimulus.values{1,i}.dur;
    end
    pltIdx = pltIdx+1;
end
durationCheck
raw = raw(validIdx);
save([dataPath subjectID 'NirsStimulusCleaned.mat'],'raw')
saveas(f,[dataPath subjectID 'NirsStimulusCleanedFig'])

%% Special handling
%Tasks with C had extra conditions, remove them
raw = rawOriginal(4);
dataEventStrings=cell(1,length(raw.stimulus.values));
for i = 1:length(raw.stimulus.values)
    dataEventStrings{i} = raw.stimulus.values{i}.name;
end
stimulusLastRest = raw.stimulus.values{strcmp(dataEventStrings,'LastRest')};
stimulus = raw.stimulus.values{strcmp(dataEventStrings,'Rest_Before_Walk')};
stimulus.onset(6)=[]; %extra: remove
stimulus.dur(6) = [];
stimulus.amp(6) = [];
raw.stimulus('Rest_Before_Walk')= stimulus; %assign the updated stimulus back to the raw data
stimulus = raw.stimulus.values{strcmp(dataEventStrings,'Walk')};
stimulus.onset(6)=[]; %extra: remove
stimulus.dur(6) = [];
stimulus.amp(6) = [];
raw.stimulus('Walk')= stimulus; %assign the updated stimulus back to the raw data
rawOriginal(4) = raw;
figure();
rawOriginal(4).draw
