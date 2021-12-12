adaptDataV2=load('Y:\Shuqi\NirsAutomaticityStudy\Data\AUF03\V02\AUF03V02params.mat');
adaptDataV2 = adaptDataV2.adaptData;
adaptDataV2.plotAvgTimeCourse(adaptDataV2,'netContributionNorm2');
adaptDataV2.plotAvgTimeCourse(adaptDataV2,'singleStanceSpeedFastAbsANK');

adaptDataV3=load('Y:\Shuqi\NirsAutomaticityStudy\Data\AUF03\V03\AUF03V03params.mat');
adaptDataV3 = adaptDataV3.adaptData;
adaptDataV3.plotAvgTimeCourse(adaptDataV3,'netContributionNorm2')

%%
% temp = rand(10,3);
% for i = 1:10
%     fprintf('[%d,%d,%d];\n',temp(i,1),temp(i,2),temp(i,3))
% end
%% Add conditions (should only need to do it once)
close all; clear all; clc;
datapath = 'Y:\Shuqi\NirsAutomaticityStudy\Data\AUF03\V04\AUF03V04';
adaptData=load([datapath 'params.mat']);
adaptData = adaptData.adaptData;
adaptData.plotAvgTimeCourse(adaptData,'netContributionNorm2')

rawAdaptData = adaptData;
vNum = split(datapath,'\');
vNum = vNum{6};
if contains(vNum, {'2','4'})
    intervention = false;
else
    intervention = true;
end

if intervention
    adaptData = AddingConditionsNirs(adaptData, 'MidAdaptation1', 'Adaptation1', true, 'First switching block of adaptation');
    adaptData = AddingConditionsNirs(adaptData, 'Adaptation1', 'Post1', false, 'First switching block of post adaptation');
    oldNames = {'MidAdaptation1'};
    newNames = {'TMbase'};
    for blocks = [2,4] %[2,3,4]
        blocks
        adaptData = AddingConditionsNirs(adaptData, ['SwitchAdaptation' num2str(blocks)], ['Adaptation' num2str(blocks)], true, ['No.' num2str(blocks) 'switching block of adaptation']);
        adaptData = AddingConditionsNirs(adaptData, ['Adaptation' num2str(blocks)], ['Post' num2str(blocks)], false, ['No.' num2str(blocks) 'switching block of post-adaptation']);
        oldNames{end+1} = ['SwitchAdaptation'  num2str(blocks)];
        newNames{end+1} = ['TMTiedMid'  num2str(blocks)];
    end
    adaptData = AddingConditionsNirs(adaptData, 'LastAdaptation' , 'Adaptation5', true, 'No.5 switching block of adaptation');
    oldNames{end+1} = 'LastAdaptation';
    newNames{end+1} = 'TMTiedMid5';
    %TODO: fix this
    adaptData = AddingConditionsNirs(adaptData, 'TMMid2', 'PosShort', true);
    adaptData = AddingConditionsNirs(adaptData, 'TMMid3', 'NegShort', true);
    oldNames = [oldNames, {'TMMid2','TMMid3'}]
    newNames = [newNames,{'TMTiedMid6','TMTiedMid7'}]
    save([datapath 'params.mat'],'adaptData','-v7.3');
    changeCondName(datapath,oldNames,newNames)
else
    adaptData = AddingConditionsNirs(adaptData, 'TMMidThenAdapt', 'Adaptation', true);
    adaptData = AddingConditionsNirs(adaptData, 'PosShort', 'PosShortSplit', true);
    adaptData = AddingConditionsNirs(adaptData, 'NegShort', 'NegShortSplit', true);
    save([datapath 'params.mat'],'adaptData','-v7.3');
    changeCondName(datapath,{'TMMidThenAdapt','PosShort','PosShortSplit','NegShort','NegShortSplit'},{'TM base','TMMid2','PosShort','TMMid3','NegShort'})

end


%% reload clean data, set up result folder
close all; clc;
adaptData = load([datapath 'params.mat']);
adaptData = adaptData.adaptData;
adaptDataRaw = adaptData;
%TODO: split pos and neg short
resDir = [datapath 'Result\'];
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

adaptData = adaptData.removeBias(); %FIXME: had to fix the TR code to TM, the changes are very subtle
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
    switchBlocks = [1 2 4 5];%1:5;
    lateConditions = cell(1,length(switchBlocks));
    earlyConditions = cell(1,length(switchBlocks));
    idx = 1;
    for s = switchBlocks
        lateConditions{idx} = ['Adaptation' num2str(s)];
        earlyConditions{idx} = ['Post' num2str(s)];
        idx = idx+1;
    end
    earlyConditions{end} = 'OGPost'; %replace the last one as OG post
    earlyConditions{end+1} = 'TMPost';
    earlyConditions = [earlyConditions lateConditions];
else
    lateConditions = {'Adaptation'};
    earlyConditions = {'OGPost','TMPost','Adaptation'}; %post + early adapt
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
sgtitle('Steady States');  %unbiased
if saveResAndFigure
    saveas(f, [resDir 'SS.png'])
    saveas(f, [resDir 'SS.fig'])
end

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
%             ssThreshold(c,i) = deltaAdapt(c,i) * 0.632 + earlyAdaData(c,i);
            shiftAmount = abs(min(adaptationDataSmoothed(:,i)));
            shiftedData = adaptationDataSmoothed + shiftAmount;
            ssThreshold(c,i) = (ssData(c,i) + shiftAmount) * 0.632;
            t=find(shiftedData(:,i)>=ssThreshold(c,i));
            ssThreshold(c,i) = ssThreshold(c,i)  - shiftAmount;
            
            %compare outputs using previous vs new methods
            compv1 = deltaAdapt(c,i) * 0.632 + earlyAdaData(c,i);
            comptv1 = find(adaptationDataSmoothed(:,i)>=compv1);
            comptv1 = comptv1(comptv1>minStrides);
            comptv1 = min(comptv1);
            comptv2=t(t > minStrides); %shouldn't happen in the first 20 strides (avoid immature identification)
            comptv2 = min(comptv2);
            fprintf('Shift Data Stride2SS: %d. Use deltaAdapt find Stride2SS: %d\n',comptv2,comptv1);
        else
            ssThreshold(c,i) = ssData(c,i) * 0.632;
            t=find(adaptationDataSmoothed(:,i)>=ssThreshold(c,i));
        end
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
    f = figure('units','normalized','outerposition',[0 0 1 1]);%('Position', get(0, 'Screensize'));
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
f1 = figure('units','normalized','outerposition',[0 0 1 1]);%('Position', get(0, 'Screensize'));
for i =1:4
    subplot(2,2,i)
    bar(postData(:,i))
    title(params{i})
    xticklabels(earlyConditions)
end
sgtitle('After effects (first 5 strides)'); 

if saveResAndFigure
    saveas(f1, [resDir 'PostAE.png'])
    saveas(f1, [resDir 'PostAE.fig'])
end
%% plot adaptation rate
clc;
beginIndex = nan(1,length(lateConditions));
endIndx = nan(1,length(lateConditions));
for pIdx = 1:length(params)
    removeBias = true;
    fig = adaptData.plotAvgTimeCourse(adaptData,...
        params(pIdx),...
        adaptData.metaData.conditionName,5,...
        [],[],[],[],0,removeBias);
    hold on;
    
    for cIdx = 1:length(lateConditions)
        if pIdx == 1
%             trialNum = adaptData.metaData.trialsInCondition{strcmp(adaptData.metaData.conditionName,lateConditions{cIdx})};
%             columnIdxForTrialNum=find(compareListsNested({'Trial'},adaptData.data.labels));

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
    legend('Location','northeastoutside')
    set(gcf,'Units','Normalized','OuterPosition',[0.1 0.1 0.9 0.9])
    if saveResAndFigure
        saveas(fig, [resDir 'AdaptationRate' params{pIdx} '.png'])
        saveas(fig, [resDir 'AdaptationRate' params{pIdx} '.fig'])
    end
end

%% save outcome measures
resData = [deltaAdapt; ssData; stride2SS; postData]; %Data format: nan(length(lateConditions),length(params))
resData = array2table(resData);
resData.Properties.VariableNames = params;
rowNames = {};
if intervention
    for i = {'deltaAdapt','SS','AdaptationRate'}
        for j = lateConditions
            rowNames{end+1} = [i{1} j{1}];
        end
    end
    for i = 1:length(switchBlocks)+1 %additional TM post for washout
        rowNames{end+1} = earlyConditions{i};
    end
    resData.Properties.RowNames = rowNames;
else
    resData.Properties.RowNames = {'deltaAdapt','SS','AdaptationRate','OGPost','TMPost'};
end
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

%% Compare V04-V01
close all; clear all; clc;
datapath = 'Y:\Shuqi\NirsAutomaticityStudy\Data\AUF03';
adaptDataPre=load([datapath '\V02\AUF03V02params.mat']);
adaptDataPost=load([datapath '\V04\AUF03V04params.mat']);
outcomePre=load([datapath '\V02\AUF03V02Result\OutcomeMeasures.mat']);
outcomePost=load([datapath '\V04\AUF03V04Result\OutcomeMeasures.mat']);
outcomeTraining=load([datapath '\V03\AUF03V03Result\OutcomeMeasures.mat']);
outcomePre = outcomePre.outcomeMeasures;
outcomePost = outcomePost.outcomeMeasures;
outcomeTraining = outcomeTraining.outcomeMeasures;

%OGPost = switching
close all
vars = {'OGPost','TMPost','AdaptationRate','SS'};
for var = vars
    f = figure('units','normalized','outerposition',[0 0 1 1]);%('Position', get(0, 'Screensize'));
    for col = 1:4
        subplot(2,2,col);
        bar(1, outcomePre{var{1},col});
        hold on;
%         bar(2, outcomeTraining{var{1},col});
        bar(2, outcomePost{var{1},col});
        title(outcomePre.Properties.VariableNames{col})
    end
    legend({'Pre','Post'})
    sgtitle(var{1})
end

% %OGPost = switching
% f = figure('Position', get(0, 'Screensize'));
% for col = 1:4
%     subplot(2,2,col);
%     bar(1, outcomePre{'OGPost',col});
%     hold on;
%     bar(2, outcomePost{'OGPost',col});
%     bar(3, outcomePost{'OGPost',col});
%     bar(4, outcomePost{'OGPost',col});
%     bar(5, outcomePost{'OGPost',col});
%     bar(6, outcomePost{'OGPost',col});
%     title(outcomePre.Properties.VariableNames{col})
% end
% legend({'Pre','Post'})

% dataToPlot = {deltaAdapt, ssData, stride2SS};
% titles = {'Delta Adapt (SS - earlyAdapt)', 'Steady States (unbiased)','Adaptation Rate (strides to steady state)'};
% saveTitle = {'DeltaAdapt','SS','AdaptationRateBar'};
% for dIdx = 1:length(dataToPlot)
%     data = dataToPlot{dIdx};
%     f = figure('Position', get(0, 'Screensize'));
%     for i =1:4
%         subplot(2,2,i)
%         bar(data(:,i))
%         title(params{i})
%         xticklabels(lateConditions)
%     end
%     sgtitle(titles{dIdx}); 
%     
%     if saveResAndFigure
%         saveas(f, [resDir saveTitle{dIdx} '.png'])
%         saveas(f, [resDir saveTitle{dIdx} '.fig'])
%     end
% end
