%% Load data - new
close all; clear all; clc;
saveResAndFigure = true;

% scriptDir = fileparts(matlab.desktop.editor.getActiveFilename); 
% subjectID = 'AUF01V01Retest';
% dataPath = split(subjectID,'V');
% rootDir = '/Volumes/users/Shuqi/NirsAutomaticityStudy/Data/';
% resSavePath = [rootDir dataPath{1} '\V' dataPath{2} '\Results\Nirs\'];
% dataPath = [rootDir dataPath{1} '\V' dataPath{2} '\NIRS\'];
% 
% if contains(rootDir, '/') %mac enviroment, replace \ with /
%     dataPath = replace(dataPath,"\","/");
%     resSavePath = replace(resSavePath,"\","/");
% end

[dataPath, ~, resSavePath, subjectID, ~] = setupDataPath('AUF03', 'V01', 'NIRS', 'NIRSV1');

% raw = nirs.core.Data.empty;
% raw(2) = data.raw; %can simply add in this way
% dataPath = 'Y:\Shuqi\NirsAutomaticityStudy\Data\AUF01\V01\NIRSRecoveryAttempt1\'
data = load([dataPath subjectID 'NirsStimDemoCleaned.mat']);
raw = data.raw;
rawFull = raw;
validTrialIdx = [2:7];
fprintf('\nIgnoring practice trial. Using index: ')
validTrialIdx
raw = raw(validTrialIdx); %ignore the practice trial

if ~isfolder(resSavePath)
    mkdir(resSavePath)
end
resSavePath
%% plot the raw data
for i=1:length(raw)
    f1 = figure('units','normalized','outerposition',[0 0 1 1]);
    raw(i).draw
    legend('Location','bestoutside')
    title(['Raw Signal Iteration ' num2str(i)])
    if saveResAndFigure
        saveas(f1, [resSavePath subjectID 'RawSignalIteration' num2str(i) '.png'])
        saveas(f1, [resSavePath subjectID 'RawSignalIteration' num2str(i) '.fig'])
    end
end

%% clean up probes
raw = updateProbeInfo(raw);

%% now processing to get Hbo/hbr
j=nirs.modules.RemoveStimless;
j=nirs.modules.OpticalDensity(j);
j=nirs.modules.Resample(j);
j=nirs.modules.BeerLambertLaw(j);
Hb=j.run(raw);
HbUntrimed = Hb;

%% trim data
j = nirs.modules.TrimBaseline;
j.preBaseline = 2;
j.postBaseline = 2;
% j.resetTime = true;
Hb = j.run(HbUntrimed);

%% plot trimmed data
close all;
for i=1:length(Hb)
    f2 = figure('units','normalized','outerposition',[0 0 1 1]);
    subplot(3,1,1);
    HbUntrimed(i).draw
    title(['Hbo Iteration ' num2str(i)])
    subplot(3,1,2);
    HbUntrimed(i).draw
    ylim([-750 500])
    legend('hide') %only need legend in top subplot
    title(['Zoomed In HBo Iteration ' num2str(i)])
    subplot(3,1,3);
    Hb(i).draw
    title(['Trimmed Hbo Iteration ' num2str(i)])
    legend('hide')
    fprintf('\nIteration %d Data range: %d',i,range(Hb(i).data,'all'))
    if saveResAndFigure
        saveas(f2, [resSavePath  subjectID 'HboTrimedSignalIteration' num2str(i) '.png'])
        saveas(f2, [resSavePath  subjectID 'HboTrimedSignalIteration' num2str(i) '.fig'])
    end
end
%% GLM
j=nirs.modules.GLM;
j.goforit=true;
SubjStats=j.run(Hb); %A ChannelStats object, with variables: stimulus x 2(hbo or hbr) x 8 (sources)


%% compare each active condition against baseline + compare walk with alphabet vs walk alone
SubjStatsVsBaselinePerTrial=SubjStats.ttest({'walk-Rest_Before_Walk'
                            'standAndAlphabet2-Rest_Before_Stand_And_Alphabet'
                            'walkAndAlphabet2-Rest_Before_Walk_And_Alphabet'
                            'standAndAlphabet3-Rest_Before_Stand_And_Alphabet_3'
                            'walkAndAlphabet3-Rest_Before_Walk_And_Alphabet_3'
                            },[],...
                           {'WalkRestCorrected','StandAndAlphabet2RC','WalkAndAlphabet2RC','StandAndAlphabet3RC','WalkAndAlphabet3RC'});
%                         last argument = condition name, if not provided
%                         use the first argument as the default; here
%                         provide name to avoid the reserved string "-" in
%                         the name for future comparison

SubjStatsDTVsSTPerTrial=SubjStatsVsBaselinePerTrial.ttest({'WalkAndAlphabet2RC-StandAndAlphabet2RC'
                            'WalkAndAlphabet3RC-StandAndAlphabet3RC'
                            'WalkAndAlphabet2RC-WalkRestCorrected'
                            'WalkAndAlphabet3RC-WalkRestCorrected'
                            },[],{'WalkAlphabet2VsStandAlphabet2','WalkAlphabet3VsStandAlphabet3','WalkAlphabet2VsWalk','WalkAlphabet3VsWalk'});
%% ROI wise by trial - condense to by detector (left/right) or overall PFC
% define some ROIs
ROI{1}=table(1,NaN,'VariableNames',{'detector','source'});
ROI{2}=table(2,NaN,'VariableNames',{'detector','source'});
tableSrcRaw=nirs.util.roiAverage(SubjStats,ROI,{'Det1','Det2'}); %conditions x 4(2dectorx2signal(hbo and hbr))
ROIc=table(NaN,NaN,'VariableNames',{'detector','source'});
tablePFCRaw=nirs.util.roiAverage(SubjStats,ROIc,{'PFC'});  

% hbo = hemoglobin, hbr = deoxy-hemoglobin
tableSrc_VsBasePerTrial=nirs.util.roiAverage(SubjStatsVsBaselinePerTrial,ROI,{'Source1','Source2'});
% Locate statisitcally significant pairs with q <= 0.05
% sigIndexDetector_VsBaseline = tableSrc_VsBasePerTrial.q <= 0.05;
% sigpairsDetector_VsBaseline = tableSrc_VsBasePerTrial(sigIndexDetector_VsBaseline,:);

%combined
tablePFC_VsBasePerTrial=nirs.util.roiAverage(SubjStatsVsBaselinePerTrial,ROIc,{'PFC'});  
% sigIndexPFC_VsBaseline = tablePFC_VsBaselinePerTrial.q <= 0.05;
% sigpairsPFC_VsBaseline = tablePFC_VsBaselinePerTrial(sigIndexPFC_VsBaseline,:);

%DT vs ST
tableSrc_DTvsSTPerTrial=nirs.util.roiAverage(SubjStatsDTVsSTPerTrial,ROI,{'Det1','Det2'});
% sigIndexDetector_DTvsST = find(tableBySrc_DTvsSTPerTrial.q <= 0.05);
% sigpairsDetector_DTvsST = tableBySrc_DTvsSTPerTrial(sigIndexDetector_DTvsST,:);

%combined
tablePFC_DTvsSTPerTrial=nirs.util.roiAverage(SubjStatsDTVsSTPerTrial,ROIc,{'PFC'});  
% sigIndexPFC_DTvsST = find(tablePFC_DTvsSTPerTrial.q <= 0.05);
% sigpairsPFC_DTvsST = tablePFC_DTvsSTPerTrial(sigIndexPFC_DTvsST,:);

%% exclude bad task
if contains(dataPath,'AUF02\V01')
    for i=1:height(SubjStats(2).variables)
      if strcmp(SubjStats(2).variables.cond(i), {'standAndAlphabet3'})
          SubjStats(2).variables{i, 4}={''}; %make it empty
      end
    end 
    
    for i=1:height(SubjStatsVsBaselinePerTrial(2).variables)
      if strcmp(SubjStatsVsBaselinePerTrial(2).variables.cond(i), {'StandAndAlphabet3RC'})
          SubjStatsVsBaselinePerTrial(2).variables{i, 4}={''}; %make it empty
      end
    end 
    
    for i=1:height(SubjStatsDTVsSTPerTrial(2).variables)
      if strcmp(SubjStatsDTVsSTPerTrial(2).variables.cond(i), {'WalkAlphabet3VsStandAlphabet3'})
          SubjStatsDTVsSTPerTrial(2).variables{i, 4}={''}; %make it empty
      end
    end 
end

%% Output channel-wise SubjStats per subject, pull all repetitions together, needs demographics data to know what trials to group together
j=nirs.modules.SubjLevelStats;
SubjStatsVsBaseline=j.run(SubjStatsVsBaselinePerTrial);
SubjStatsDTVsST=j.run(SubjStatsDTVsSTPerTrial);

%% plot the results per subject (across trials)
close all;
SubjStatsVsBaseline.draw('tstat',[],'q < 0.05') %plot q<0.05 with solid and others with dashed line
SubjStatsDTVsST.draw('tstat',[],'q < 0.05') %plot q<0.05 with solid and others with dashed line

%set up figures, add legend and save results
detectorCount = 8; %8 detectors, almost always true
legendString = cell(1,detectorCount);
for i = 1:detectorCount 
    legendString{i} = ['S' num2str(i)];
end
figHandles = findobj('Type', 'figure'); %get all open figures
for i=1:numel(figHandles)
    ax=findobj(figHandles(i),'Type','axes');
    for j=1:numel(ax)
        legend(ax(j),legendString,'Location','bestoutside');
    end
    if saveResAndFigure
        saveas(figHandles(i),[resSavePath subjectID 'Stats_' erase(ax.Title.String,' : ')])
        saveas(figHandles(i),[resSavePath subjectID 'Stats_' erase(ax.Title.String,' : ') '.png'])
    end
end

%print out the non-sig pairs for reference

%% stats per subject by ROI
% hbo = hemoglobin, hbr = deoxy-hemoglobin
%the function returns the ROIstats in a ChannelStats data structure too,
%for now not used.
[tableSrc_VsBase, ~] =nirs.util.roiAverage(SubjStatsVsBaseline,ROI,{'Source1','Source2'});
tablePFC_VsBase=nirs.util.roiAverage(SubjStatsVsBaseline,ROIc,{'PFC'});  
tableSrc_DTvsST =nirs.util.roiAverage(SubjStatsDTVsST,ROI,{'Source1','Source2'});
tablePFC_DTvsST=nirs.util.roiAverage(SubjStatsDTVsST,ROIc,{'PFC'});  

%% plot ROI results
% figure from ROIstats directly is off, manually do it
% ROIstats.draw('tstat',[],'q < 0.05') %plot q<0.05 with solid and others with dashed line
tableToPlot = {tableSrc_VsBase, tableSrc_DTvsST, tablePFC_VsBase, tablePFC_DTvsST};
condsOrdered = {{'StandAndAlphabet2RC';'StandAndAlphabet3RC';'WalkRestCorrected'; 'WalkAndAlphabet2RC';'WalkAndAlphabet3RC'},...
    {'WalkAlphabet2VsWalk';'WalkAlphabet2VsStandAlphabet2';'WalkAlphabet3VsWalk';'WalkAlphabet3VsStandAlphabet3'}};
gapBtwGroups = 1; %figure setting, gaps between groups of bar plots
close all;
for tblIdx = 1:length(tableToPlot) %first 2 sources x hbr and hbo, then 1PFC x 2 (hbr and hbo)
    if tblIdx <= 2
        groups = 4;
        xlabels = {'Source1 hbo','Source1 hbr','Source2 hbo','Source2 hbr'};
        
        if tblIdx == 1
            titleId = 'By Source (Compared to Rest Baseline)';
            saveNameId = 'VsBase_BySource';
            conds = condsOrdered{1};
        else
            titleId = 'By Source (DT vs ST)';
            saveNameId = 'DTvsST_BySource';
            conds = condsOrdered{2};
        end
    else
        groups = 2;
        xlabels = {'hbo','hbr'};
        if tblIdx == 3
            titleId = 'PFC (Compared to Rest Baseline)';
            saveNameId = 'VsBase_PFC';
            conds = condsOrdered{1};
        else
            titleId = 'PFC (DT vs ST)';
            saveNameId = 'DTvsST_PFC';
            conds = condsOrdered{2};
        end
    end
    tableByROI = tableToPlot{tblIdx};
    f = figure('units','normalized','outerposition',[0 0 1 1]);
    hold on;
    sigMarkOffset = range(tableByROI.T) * 0.03;
    for condIdx = 1:length(conds)
        dataToPlot = tableByROI(strcmp(tableByROI.Contrast,conds{condIdx}),:);
        %find x location (not the best bc the bars won't allocate the width themsevles)
        % end idx is groups * conds + groups - 1 (add gaps)
        barXLocs = condIdx:length(conds)+gapBtwGroups:groups*(length(conds)+gapBtwGroups)-1;
        bar(barXLocs, dataToPlot.T,'BarWidth', 1/(length(conds)+1));
        sigIdx = dataToPlot.q < 0.05; %logical array to index significant values
        scatter(barXLocs(sigIdx), sign(dataToPlot.T(sigIdx)) .* (abs(dataToPlot.T(sigIdx)) + sigMarkOffset),'*','k');
    end
    %xticks in the middle, 
    condIdx = 3;
    xticks(condIdx:length(conds)+1:(groups+1)*length(conds)-1);
    xticklabels(xlabels)
    graphItems = get(gca,'Children'); %last item plotted is at index 1.
    legend(graphItems([2*[length(conds):-1:1], 1]),[conds;'q < 0.05'],'Location','best'); %legend for bars and 1 astricks
    ylabel('T-stats (T-value)')
    title([subjectID ' T - stats ' titleId])
    xlim([0, groups*(length(conds)+gapBtwGroups)])
    set(findall(gcf,'-property','FontSize'),'FontSize',30)
    if saveResAndFigure
        saveas(f,[resSavePath subjectID 'Stats' saveNameId])
        saveas(f,[resSavePath subjectID 'Stats' saveNameId '.png'])
    end
end

%% save results
if saveResAndFigure
    %save the AUF01/V01/ directly, index out the NIRS/ in the end of the
    %data path
    save([dataPath(1:end-5) subjectID 'NirsStatsTables.mat'],'-regexp','SubjStats*','tablePFC*','tableSrc*');
    DTdata = GetDTDataStructure([dataPath(1:end-5) subjectID 'DTdata.mat']);
    DTdata.statsTables = load([dataPath(1:end-5) subjectID 'NirsStatsTables.mat']);
    save([dataPath(1:end-5) subjectID 'DTdata.mat'],'DTdata');
end

%% TODO from here
%for i=1:length(SubjStats);
%    SubjStats(i).draw
%    figure()
%end;
%SubjStatsDiff=SubjStats.ttest({     'Uneven-Even' 
%                                    'Even_ABC-Even'
%                                    'Even_ABC-Standing_ABC' 
%                                    'Uneven_ABC-Even'
%                                    'Uneven_ABC-Standing_ABC'},[],...
%                                    {'Ctrast1','Ctrast2','Ctrast3','Ctrast4','Ctrast5'});

% SubjStatstable=[];
% for i=1:length(SubjStats);
%   SubjStatstable=vertcat(SubjStatstable, SubjStats(i).table);
% end;
% SubjStatstable=rmmissing(SubjStatstable, 'DataVariables', {'cond'});
% nirs.createDemographicsTable(SubjStats).subject;
% id=[1:29]';
% Subjid=array2table(repelem(id,80),'VariableNames',{'Subjid'});
% SubjStatstable=[Subjid SubjStatstable];
% writetable(SubjStatstable,'SubjStats_channelw.xls','sheet',1);
% 
% SubjStatstable2=[];
% for i=1:length(SubjStats2);
%     SubjStatstable2=vertcat(SubjStatstable2, SubjStats2(i).table);
% end;
% SubjStatstable2=rmmissing(SubjStatstable2, 'DataVariables', {'cond'});
% id=nirs.createDemographicsTable(SubjStats2).subject;
% Subjid=array2table(repelem(id, 48), 'VariableNames', {'Subjid'});
% SubjStatstable2=[Subjid SubjStatstable2];
% writetable(SubjStatstable2, 'SubjStatsdiff_channelw.csv');
%                                 
% %% Group based model-- without adjustment
% j=nirs.modules.MixedEffects;
% j.formula='beta ~ -1 + cond + (1|subject)';
% GroupStats= j.run(SubjStats);
% 
% GroupStats.draw('tstat',[],'q<0.05')
% 
% %% ROI wise 2
% % define some ROIs
% j=nirs.modules.SubjLevelStats;
% SubjStats=j.run(SubjStats);
% ROI{1}=table(1,NaN,'VariableNames',{'detector','source'});
% ROI{2}=table(2,NaN,'VariableNames',{'detector','source'});
% %nirs.util.roiAverage(GroupStats,ROI,{'Det1','Det2'})
% table1=nirs.util.roiAverage(SubjStats,ROI,{'Det1','Det2'});
% 
% table1=rmmissing(table1, 'DataVariables', {'Contrast'});
% writetable(table1,'SubjStats_ROIw.xlsx','sheet',1);
% 
% %% add demographic data
% nirs.createDemographicsTable(raw)
% 
% demo = readtable('NMCM demo.xlsx');
% 
% 
% job = nirs.modules.AddDemographics;
% job.demoTable=demo;
% SubjStats = job.run(SubjStats);
% 
% %% Group based models--adjusting for demographics
% job = nirs.modules.SubjLevelStats;
% SubjStats=job.run(SubjStats);
% 
% job = nirs.modules.MixedEffects;
% job.formula='beta ~ -1 + cond + cond:Age + Sex +(1|subject)';
% G=job.run(SubjStats);
% 
% G.draw('tstat',[],'q<0.05')
% 
% 
% %% Load GUI
% nirs.viz.nirsviewer;

%%
% close all;
% for i=1:length(Hb)
%     f2 = figure('units','normalized','outerposition',[0 0 1 1]);
%     Hb(i).draw
%     title(['Hbo Iteration ' num2str(i)])
%     fprintf('\nIteration %d Data range: %d',i,range(Hb(i).data,'all'))
%     if saveResAndFigure
%         saveas(f2, [resSavePath  subjectID 'HboSignalIteration' num2str(i) '.png'])
%         saveas(f2, [resSavePath  subjectID 'HboSignalIteration' num2str(i) '.fig'])
%     end
% end
% figure is small bc of the large spike of signal at the beginning
% zoom in the figures and save a snapshot in png
% figHandles = findobj('Type', 'figure'); %get all open figures
% s=findobj('type','legend');
% delete(s);
% for i=1:numel(figHandles)
%     ax=findobj(figHandles(i),'Type','axes');
%     for axIdx=1:numel(ax)
%         ylim(ax(axIdx), [-750 500])
%     end
%     if saveResAndFigure
%         saveas(figHandles(i), [resSavePath subjectID 'HboSignalIteration' ax.Title.String(end) 'ZoomedIn.png'])
%     end
% end

%% shorten initial rest for AUF02
% event = raw(2).stimulus.values{2}
% event.dur = event.dur - 4.5;
% event.onset = event.onset + 4.5;
% event
% raw(2).stimulus(raw(2).stimulus.keys{2}) = event;
% 
% %
% event = raw(4).stimulus('Rest_Before_Walk')
% offset = 6.5;
% event.dur = event.dur - offset;
% event.onset = event.onset + offset;
% event
% raw(4).stimulus(event.name) = event;
% 
% %
% event = raw(5).stimulus('Rest_Before_Walk')
% offset = 6;
% event.dur = event.dur - offset;
% event.onset = event.onset + offset;
% event
% raw(5).stimulus(event.name) = event;
% 
% %
% event = raw(6).stimulus('Rest_Before_Walk_And_Alphabet')
% offset = 9.9;
% event.dur = event.dur - offset;
% event.onset = event.onset + offset;
% event
% raw(6).stimulus(event.name) = event;
% 
% %
% event = raw(7).stimulus('Rest_Before_Walk')
% offset = 7.9;
% event.dur = event.dur - offset;
% event.onset = event.onset + offset;
% event
% raw(7).stimulus(event.name) = event;

% rename the wrong trial <- DN work
% inCorrectTrial = raw(3).stimulus;
% renamedTrial = Dictionary();
% for entry = 1:length(inCorrectTrial.keys)
%     if strcmp(inCorrectTrial.keys{entry}, 'Rest_Before_Stand_And_Alphabet_3')
%         renamedTrial('IncorrectRest_Before_Stand_And_Alphabet_3_Rest_Before_Walk_And_Alphabet_3') = inCorrectTrial.values{entry};
%     elseif strcmp(inCorrectTrial.keys{entry}, 'standAndAlphabet3')
%         renamedTrial('IncorrectstandAndAlphabet3_walkAndAlphabet3') = inCorrectTrial.values{entry};
%     else
%         renamedTrial(inCorrectTrial.keys{entry}) = inCorrectTrial.values{entry};
%     end
% end
% raw(3).stimulus= renamedTrial;

% % % AUF01RetestV01
% event = raw(6).stimulus('Rest_Before_Walk')
% offset = 10 - event.onset;
% event.dur = event.dur - offset;
% event.onset = event.onset + offset;
% event
% raw(6).stimulus(event.name) = event;
% % 
% event = raw(7).stimulus('Rest_Before_Walk_And_Alphabet')
% offset = 10 - event.onset;
% event.dur = event.dur - offset;
% event.onset = event.onset + offset;
% event
% raw(7).stimulus(event.name) = event;
% %
% event = raw(2).stimulus('Rest_Before_Walk')
% offset = 10 - event.onset;
% event.dur = event.dur - offset;
% event.onset = event.onset + offset;
% event
% raw(2).stimulus(event.name) = event;
% %
% event = raw(3).stimulus('Rest_Before_Stand_And_Alphabet_3')
% offset = 10 - event.onset;
% event.dur = event.dur - offset;
% event.onset = event.onset + offset;
% event
% raw(3).stimulus(event.name) = event;
%
% %AUF03V03
% trialIdx=5;
% event = raw(trialIdx).stimulus('Rest_Before_Walk')
% offset = 10 - event.onset;
% event.dur = event.dur - offset;
% event.onset = event.onset + offset;
% event
% raw(trialIdx).stimulus(event.name) = event;
