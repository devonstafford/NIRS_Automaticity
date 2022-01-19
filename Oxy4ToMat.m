%% set up pat to load and save data
close all; clear all; clc;

%provide the folder where the .oxy4 files are located
% dataPath = 'Y:\Shuqi\NirsAutomaticityStudy\Data\AUF01\V04\NIRS\';
% dataPath = 'C:\Users\shl187\OneDrive - University of Pittsburgh\SML\Projects\fNIR Project\Code_NIRS_Automaticity\Data\AUF01\V01NirsOxy5';
% subjectID = 'AUF01V01';

[dataPath, ~, ~, subjectID, ~] = setupDataPath('AUF02', 'V01', 'NIRS', '')
testDate = datetime('12-Jan-2022'); %inputdlg('Test date(DD-Mon-YYYY, e.g., 01-Jan-2001):');
testerName = 'SL';%inputdlg('Tester Name (Initials):');
startingAlphabet = 'B';
%% Load data, needs the Oxysoft as a COM-interface
raw = nirs.io.loadDirectory(dataPath, {'subject'})

%% index out the valid trials
validIdx = [5,8:13];%change index here, corresponding measurement index
rawFull = raw;
raw = raw(validIdx);
FileValidPaths = cell(1,length(raw));
for i = 1:length(raw)
    FileValidPaths{i} = raw(i).description;
end
FileValidPaths'
%% plot to visualize the data and stimulus encoding
f = figure('units','normalized','outerposition',[0 0 1 1]);
cols = 3;
rows = ceil(length(raw)/cols);
for i=1:length(raw)
    subplot(rows,cols,i)
    raw(i).draw
    raw(i).description
    raw(i).stimulus.keys
    if i ~= length(raw)
        s=findobj('type','legend');
        delete(s)
    end
end
saveas(f, [dataPath subjectID 'NirsRawFig']);
%% save the converted data
% if length(raw) == 1 %if only one file save as the same name but as .mat
%     save([raw.description(1:end-5)], 'raw')
% else %if has more than 1 oxy4 files, save as the overall subjectIDVisitNumber, e.g. S01V01.mat
%     save([scriptDir '\Data\' subjectFolderName '\' visitNumber '\' subjectFolderName visitNumber], 'raw')
% end
save([dataPath subjectID 'NirsRaw'],'raw')

%% Clean the current data by adding stimulus durations
% close all; clear all; clc
% dataPath = 'Y:\Shuqi\NirsAutomaticityStudy\Data\AUF03\V01\Nirs\';
% subjectID = 'AUF03V01';
% raw = load([dataPath subjectID 'NirsRaw.mat']);
% raw = raw.raw;
% for i=1:length(raw)
%     figure('units','normalized','outerposition',[0 0 1 1]);
%     raw(i).draw
% end
rawOriginal = raw;

%% clean valid trials. Add durations of each event and save the cleaned data
f = figure('units','normalized','outerposition',[0 0 1 1]);
cols = 3;
rows = ceil(length(raw)/cols);
pltIdx = 1;
durationCheck = nan(length(raw),10);
for trialIdx = 1:length(raw) 
    %2nd argument: starting alphabet
    %last argument: how many iterations per measurement file, usually 1, previous pilot data = 6.
    raw(trialIdx) = addStimulusDuration(rawOriginal(trialIdx), startingAlphabet, 1);
    subplot(rows,cols,pltIdx)
    raw(trialIdx).draw
    for i = 1:10
        durationCheck(pltIdx, i) = raw(trialIdx).stimulus.values{1,i}.dur;
    end
    pltIdx = pltIdx+1;
    if trialIdx ~= length(raw)
        s=findobj('type','legend');
        delete(s)
    end
end
durationCheck
saveas(f,[dataPath subjectID 'NirsStimulusCleanedFig'])

%% populate demographics data
for i = 1:length(raw)
    demographicMap = Dictionary({'subject','Trial','Date','file','Tester'},{subjectID,['Trial ' num2str(i-1)],testDate,testerName,raw(i).description}); 
    if i == 1
        demographicMap('Trial') = 'Practice';
    end
    raw(i).demographics = demographicMap;
end
nirs.createDemographicsTable(raw)
% demographic_tbl.subject = demographic_tbl.ID;
% demographicMap('subject') = repmat(subjectID, length(raw),1);
% files = cell(length(raw),1);
% iterations = cell(length(raw),1);
% for i = 1:length(raw)
%     files{i} = raw(i).description;
%     iterations{i} = ['Trial ' num2str(i-1)];
% %     raw(i).demographics('subject') = subjectID;
% end
% iterations{1} = 'Practice';
% demographicMap('Iteration') = iterations;
% testDate = datetime(testDate);
% testDate = repmat(testDate, length(raw),1);
% demographicMap('Date') = testDate;
% demographicMap('Tester') = repmat(testerName, length(raw), 1);

% j=nirs.modules.AddDemographics;
% j.demoTable=demographicMap;
% raw=j.run(raw);

%% save data
save([dataPath subjectID 'NirsStimDemoCleaned.mat'],'raw')

%% remove short scans, shouldn't do that, all stimulus is 20s only.
% j=nirs.modules.RemoveShortScans;
% j.mintime=60; %in seconds
% j=nirs.modules.KeepStims(j);
% raw=j.run(raw);

%% Special handling
%Tasks with C had extra conditions, remove them
% raw = rawOriginal(4);
% dataEventStrings=cell(1,length(raw.stimulus.values));
% for i = 1:length(raw.stimulus.values)
%     dataEventStrings{i} = raw.stimulus.values{i}.name;
% end
% stimulusLastRest = raw.stimulus.values{strcmp(dataEventStrings,'LastRest')};
% stimulus = raw.stimulus.values{strcmp(dataEventStrings,'Rest_Before_Walk')};
% stimulus.onset(6)=[]; %extra: remove
% stimulus.dur(6) = [];
% stimulus.amp(6) = [];
% raw.stimulus('Rest_Before_Walk')= stimulus; %assign the updated stimulus back to the raw data
% stimulus = raw.stimulus.values{strcmp(dataEventStrings,'Walk')};
% stimulus.onset(6)=[]; %extra: remove
% stimulus.dur(6) = [];
% stimulus.amp(6) = [];
% raw.stimulus('Walk')= stimulus; %assign the updated stimulus back to the raw data
% rawOriginal(4) = raw;
% figure();
% rawOriginal(4).draw
