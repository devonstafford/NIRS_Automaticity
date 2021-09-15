adaptDataPre=load('/Users/mac/OneDrive - University of Pittsburgh/SML/Projects/fNIR Project/Code_NIRS_Automaticity/data/S04_MarcelaV03params.mat');
adaptDataPre = adaptDataPre.adaptData;
adaptDataPre.plotAvgTimeCourse(adaptDataPre,'netContributionNorm2');
adaptDataPre.plotAvgTimeCourse(adaptDataPre,'singleStanceSpeedFastAbsANK');

adaptDataIntervention=load('/Users/mac/OneDrive - University of Pittsburgh/SML/Projects/fNIR Project/Code_NIRS_Automaticity/data/S04_MarcelaV05params.mat');
adaptDataIntervention = adaptDataIntervention.adaptData;
adaptDataIntervention.plotAvgTimeCourse(adaptDataIntervention,'netContributionNorm2')

%%
% temp = rand(10,3);
% for i = 1:10
%     fprintf('[%d,%d,%d];\n',temp(i,1),temp(i,2),temp(i,3))
% end
%% Add conditions (should only need to do it once)
close all; clear all; clc;
datapath = 'Data/S08/S08V02';
adaptData=load([datapath 'params.mat']);
adaptData = adaptData.adaptData;
adaptData.plotAvgTimeCourse(adaptData,'netContributionNorm2')

rawAdaptData = adaptData;
intervention = true;

if intervention
    adaptData = AddingConditionsNirs(adaptData, 'TMMidThenAdapt', 'Adaptation1', true, 'First switching block of adaptation');
    adaptData = AddingConditionsNirs(adaptData, 'Adaptation1', 'Post1', false, 'First switching block of post adaptation');
    oldNames = {'TMMidThenAdapt'};
    newNames = {'TM base'};
    for blocks = [2,3,4]
        blocks
        adaptData = AddingConditionsNirs(adaptData, ['SwitchAdaptation' num2str(blocks)], ['Adaptation' num2str(blocks)], true, ['No.' num2str(blocks) 'switching block of adaptation']);
        adaptData = AddingConditionsNirs(adaptData, ['Adaptation' num2str(blocks)], ['Post' num2str(blocks)], false, ['No.' num2str(blocks) 'switching block of post-adaptation']);
        oldNames{end+1} = ['SwitchAdaptation'  num2str(blocks)];
        newNames{end+1} = ['SwitchTMTiedMid'  num2str(blocks)];
    end
    adaptData = AddingConditionsNirs(adaptData, 'AdaptationLast' , 'Adaptation5', true, 'No.5 switching block of adaptation');
    oldNames{end+1} = 'AdaptationLast'
    newNames{end+1} = 'SwitchTMTiedMid5'

    changeCondName([datapath 'NewConditions'],oldNames,newNames)
else
    adaptData = AddingConditionsNirs(adaptData, 'MidThenAdapt', 'Adaptation', true);
    changeCondName([datapath 'NewConditions'],{'OG', 'MidThenAdapt'},{'OG base','TM base'})
end

save([datapath 'NewConditionsparams.mat'],'adaptData','-v7.3');

%% reload clean data, set up result folder
close all; clc;
adaptData = load([datapath 'NewConditionsparams.mat']);
adaptData = adaptData.adaptData;
adaptDataRaw = adaptData;
%TODO: split pos and neg short
resDir = [datapath 'Result/'];
if not(isfolder(resDir))
    mkdir(resDir)
end
saveResAndFigure = true;

%% remove bad strides
adaptData.plotAvgTimeCourse(adaptData,{'netContributionNorm2','singleStanceSpeedFastAbsANK','singleStanceSpeedSlowAbsANK'})
title('Before removing bad strides')
adaptData = adaptData.removeBadStrides;
adaptData.plotAvgTimeCourse(adaptData,{'netContributionNorm2','singleStanceSpeedFastAbsANK','singleStanceSpeedSlowAbsANK'})
title('After removing bad strides')

adaptData.removeBias(); %FIXME: data loss after removing bias
adaptData.plotAvgTimeCourse(adaptData,{'netContributionNorm2','singleStanceSpeedFastAbsANK','singleStanceSpeedSlowAbsANK'})
title('After removing bias')

adaptData.plotAvgTimeCourse(adaptData,{'netContributionNorm2'})


%%
params = {'spatialContributionNorm2','stepTimeContributionNorm2','velocityContributionNorm2','netContributionNorm2'}
% params = {'spatialContributionNorm2','stepTimeContributionNorm2','velocityContributionNorm2','netContributionNorm2',...
%     'spatialContribution','stepTimeContribution','velContribution'};

for p = params
    idx = strcmp(adaptData.data.labels,p);
    dsc = adaptData.data.description(idx);
    if ~ isempty(dsc)
        fprintf('%s: %s\n',p{1},dsc{1})
    else
        fprintf('%s: \n',p{1})
    end
end

%% Find SS
ss_strides = 40; %ignore last 5
ignoreLast = 5;
if intervention
    switchBlocks = 1:5;
    lateConditions = cell(1,length(switchBlocks));
    earlyConditions = cell(1,length(switchBlocks));
    for s = switchBlocks
        lateConditions{s} = ['Adaptation' num2str(s)];
        earlyConditions{s} = ['Post' num2str(s)];
    end
    earlyConditions{end} = 'OGPost'; %replace the last one as OG post
    earlyConditions{end+1} = 'TMPost';
    earlyConditions = [earlyConditions lateConditions];
else
    lateConditions = {'Adaptation'};
    earlyConditions = {'OGPost0','TMMidPost','Adaptation'}; %post + early adapt
end
lateConditions
earlyConditions
%% find ss data
ssData = nan(length(lateConditions),length(params));
tmBaseData = nan(1,length(params));
ogBaseData = nan(1,length(params));
idx = 1;
for p = params
    for c = 1:length(lateConditions)
        data=adaptData.getParamInCond(p,lateConditions{c});
        ssData(c,idx)=nanmean(data((end-ss_strides-ignoreLast):(end-ignoreLast-1),:));   
    end
    idx = idx+1;
end

%% plot ss data
f = figure();
for i =1:4
    subplot(2,2,i)
    bar(ssData(:,i))
    title(params{i})
    xticklabels(lateConditions)
end
sgtitle('Steady States (biased)'); 
saveas(f, [resDir 'SS.png'])
saveas(f, [resDir 'SS.fig'])

%% Find early data
early_strides = 5;
ignoreFirst = 1;

earlyData = nan(length(earlyConditions),length(params));
rowIdx = 1;
colIdx = 1;
for p = params
    for cond = earlyConditions
        data=adaptData.getParamInCond(p,cond);
        earlyData(rowIdx, colIdx)=nanmean(data(ignoreFirst:ignoreFirst + early_strides-1,:));
        rowIdx = rowIdx+1;
    end
    rowIdx = 1;
    colIdx = colIdx + 1;
end
if intervention
    postData = earlyData(1:length(switchBlocks)+1,:) %FIXME: missing data here
    earlyAdaData = earlyData(length(switchBlocks)+2:end,:);
else
    postData = earlyData(1:2,:)
    earlyAdaData = earlyData(3,:)
end
deltaAdapt = ssData - earlyAdaData %post missing data
% clear earlyData

%% compute adaptation rate
SmoothType='Whole, BW=20, first not before raw min';
minStrides = 10; %has to be larger than this to be count as ada rate (avoid early determination)
%FIXME: maybe need to find the value based on the data (see what carly did)
ssThreshold = nan(size(ssData)); %conditions x params
stride2SS = nan(size(ssData));

for c = 1:length(lateConditions)
    adaptationData = adaptData.getParamInCond(params,lateConditions{c});
    adaptationDataSmoothed=bin_dataV1(adaptationData,20); 

    for i = 1:size(ssData,2)
        if ssData(c,i) <= 0
            ssThreshold(c,i) = deltaAdapt(c,i) * 0.632 + earlyAdaData(c,i);
        else
            ssThreshold(c,i) = ssData(c,i) * 0.632;
        end
        t=find(adaptationDataSmoothed(:,i)>=ssThreshold(c,i));
        t=t(t > minStrides); %shouldn't happen in the first 20 strides (avoid immature identification)
        stride2SS(c,i) = min(t);
    end
end

%% plot post data, delta adapt
dataToPlot = {deltaAdapt, ssData, stride2SS};
titles = {'Delta Adapt (SS - earlyAdapt)', 'Steady States (unbiased)','Adaptation Rate (strides to steady state)'};
saveTitle = {'DeltaAdapt','SS','AdaptationRateBar'};
for dIdx = 1:length(dataToPlot)
    data = dataToPlot{dIdx};
    f = figure('Position', get(0, 'Screensize'));
    for i =1:4
        subplot(2,2,i)
        bar(data(:,i))
        title(params{i})
        xticklabels(lateConditions)
    end
    sgtitle(titles{dIdx}); 
    
    if saveResAndFigure
        saveas(f, [resDir saveTitle{dIdx} '.png'])
        saveas(f, [resDir saveTitle{dIdx} '.fig'])
    end
end

%%
f1 = figure();
for i =1:4
    subplot(2,2,i)
    bar(postData(:,i))
    title(params{i})
    xticklabels(earlyConditions(1:6))
end
sgtitle('After effects (first 5 strides, biased)'); 

if saveResAndFigure
    saveas(f1, [resDir 'PostAE.png'])
    saveas(f1, [resDir 'PostAE.fig'])
end
%% plot adaptation rate
close all; clc;
beginIndex = nan(1,length(lateConditions));
endIndx = nan(1,length(lateConditions));
for pIdx = 1:length(params)
    removeBias = true;
    fig = adaptDataRaw.plotAvgTimeCourse(adaptDataRaw,...
        params(pIdx),...
        adaptDataRaw.metaData.conditionName,20,...
        [],[],[],[],0,removeBias);
    hold on;
    
    for cIdx = 1:length(lateConditions)
        if pIdx == 1
            beginIndex(cIdx) = input(['What is the index of 1st point in ' lateConditions{cIdx} ' :']);
            endIndx(cIdx) = input(['What is the index of last point in ' lateConditions{cIdx} ' :']);
        end
%         adaBeginningIdex = 509;
        % FIXME: this is not good. (eyeballing)
        xline = xlim;
        xline = xline(1):beginIndex(cIdx) +stride2SS(cIdx, pIdx);
        yline = ylim;
        yline = yline(1):0.005:ssThreshold(cIdx, pIdx);
        
        plot(xline, ssThreshold(cIdx, pIdx) * ones(1,length(xline)),'r--','LineWidth',2,'DisplayName','0.632*SS')
        plot((beginIndex(cIdx) +stride2SS(cIdx,pIdx))* ones(1,length(yline)), yline,'k--','LineWidth',2,'DisplayName',sprintf('AdaptRate:%d',stride2SS(cIdx,pIdx)))
        xline = xlim;
        xline = xline(1):endIndx(cIdx);
        plot(xline, ssData(cIdx,pIdx)* ones(1,length(xline)),'r-.','LineWidth',2,'DisplayName','SS')
    end
    title(['Smoothed ' params{pIdx} ' with Adaptation Rate (estimated location)'])
    
    if saveResAndFigure
        saveas(fig, [resDir 'AdaptationRate' params{pIdx} '.png'])
        saveas(fig, [resDir 'AdaptationRate' params{pIdx} '.fig'])
    end
end

%% save outcome measures
resData = [deltaAdapt; ssData; postData; stride2SS];
resData = array2table(resData);
resData.Properties.VariableNames = params;
resData.Properties.RowNames = {'deltaAdapt','SS','OGPost','TMPost','AdaptationRate'};
resData

if saveResAndFigure
    outcomeMeasures = resData;
    save([resDir 'OutcomeMeasures'], 'outcomeMeasures');
end

% %TODOs:
% 4. proper plotting of the rate of ada (see carly's code + use her code)
% 5. compute or find the other parameteres and do forgetting computation

%%
% trialMarkerFlag=[0 0 0];
% removeBias = true;
% % (adaptDataList,params,conditions,binwidth,trialMarkerFlag,indivFlag,indivSubs,
% % colorOrder,biofeedback,removeBiasFlag,labels,filterFlag,plotHandles,alignEnd,alignIni)
% adaptDataRaw.plotAvgTimeCourse(adaptDataRaw,...
%     {'netContributionNorm2','singleStanceSpeedFastAbsANK'},...
%     adaptData.metaData.conditionName,20,...
%     trialMarkerFlag,[],[],[],0,removeBias)
% %%
% params = {'spatialContributionNorm2','stepTimeContributionNorm2','velocityContributionNorm2','netContributionNorm2'};
% results=getResultsSMART(DumbTester7,params,groups,0);
