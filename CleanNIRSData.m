%% general flow, load the data, plot the original data 
dataPath = 'Y:\Shuqi\Nirs1VisitTM\ShuqiTest\Nirs\';
subjectID = 'ShuqiTest';
raw = load([dataPath subjectID 'NirsRaw.mat']);
raw = raw.raw;
for i=1:length(raw)
    figure();
    raw(i).draw
end
rawOriginal = raw;

%% clean valid trials. Add durations of each event and save the cleaned data
addStimulusDuration(rawOriginal(3),'B', [dataPath subjectID 'NirsCleaned_Pre']);
addStimulusDuration(rawOriginal(4),'C', [dataPath subjectID 'NirsCleaned_Post']);

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
