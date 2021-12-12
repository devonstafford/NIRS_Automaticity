close all; clear all; clc;
dataPath = 'Y:\Shuqi\NirsAutomaticityStudy\Data\AUF03\V04\';
saveResAndFigure = false;
subjectID = 'AUF03V04';
% Find the DTdata data structure, find task orders to populate the DTdata
[DTdata, DTdataRowNameMap] = GetDTDataStructure([dataPath subjectID 'DTdata.mat']); 
raw = load([dataPath 'Nirs\' subjectID 'NirsStimulusCleaned.mat']);
raw = raw.raw;

%% populate event times, and calculate speed and alphabet rate
for i=1:length(raw)
    figure('units','normalized','outerposition',[0 0 1 1]);
    raw(i).draw
end
stimTable = nirs.createStimulusTable(raw);

for task = 1:length(DTdata.data.Properties.RowNames)
    for trialIdx = 1:6
        DTdata.data.trialTime(task,trialIdx) = stimTable{trialIdx,DTdata.data.Properties.RowNames{task}}.dur;
    end
end

% calculate alphabet rate and walk speed
DTdata.data.walkSpeed = DTdata.data.walkDist ./ DTdata.data.trialTime;
DTdata.data.alphabetRate = DTdata.data.alphabetCount ./ DTdata.data.trialTime;

%% plot the results
close all;
for rateToPlot = 1:2 %1=walkSpeed, 2= cognitive Perf
    f = figure('units','normalized','outerposition',[0.05 0.05 0.95 0.95]);
    subplot(1, 3, [1 2])
    if rateToPlot == 1 %walk speed
        validIdx = contains(DTdata.data.Properties.RowNames,{'walk','walkAndAlphabet3','walkAndAlphabet2'});
        dataToPlot = DTdata.data.walkSpeed(validIdx,:);
        ylabelString = 'Gait Speed (m/s)';
        titleString1 = 'Gait Speed per Trial';
        titleString2 = 'Average Gait Speed';
        saveTitle = 'GaitSpeed';
    else
        validIdx = contains(DTdata.data.Properties.RowNames,{'standAndAlphabet2','walkAndAlphabet2','standAndAlphabet3','walkAndAlphabet3'});
        dataToPlot = DTdata.data.alphabetRate(validIdx,:);
        ylabelString = 'Alphabet Performance (correct alphabet / s)';
        titleString1 = 'Cognitive Task Performance per Trial';
        titleString2 = 'Average Cognitive Task Performance';
        saveTitle = 'CognitivePerf';
    end
    bar(dataToPlot) 
    xticklabels(erase(erase(DTdata.data.Properties.RowNames(validIdx),'And'),'bet'))
    legend('Trial 1','Trial 2','Trial 3','Trial 4','Trial 5','Trial 6','Location','bestoutside')
    ylabel(ylabelString)
    title(titleString1)

    % f = figure('Position', get(0, 'Screensize'));
    subplot(1, 3, 3)
    avgPerf = mean(dataToPlot,2);
    bar(avgPerf)
    stdBarHeight = std(dataToPlot,0,2); %2nd arg is weight, 0 means equal weight
    xticklabels(erase(erase(DTdata.data.Properties.RowNames(validIdx),'And'),'bet'))
    % ylabel('Alphabet Performance (correct alphabet / s)')
    hold on
    er = errorbar(1:length(avgPerf),avgPerf,stdBarHeight,stdBarHeight);    
    er.Color = [0 0 0];                            
    er.LineStyle = 'none';  
    legend('Avg','SD');%,'Location','bestoutside')
    title(titleString2)
    xtickangle(45)
    set(findall(gcf,'-property','FontSize'),'FontSize',19)
    if saveResAndFigure
        saveDir = [dataPath 'Results\Nirs\'];
        if ~exist(saveDir,'dir')
            mkdir(saveDir)
        end
        saveas(f,[saveDir subjectID saveTitle])
        saveas(f,[saveDir subjectID saveTitle '.png'])
    end
end
%% save data
save([dataPath subjectID 'DTdata.mat'],'DTdata')

