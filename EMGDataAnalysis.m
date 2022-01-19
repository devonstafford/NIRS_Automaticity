%This file will run EMG regressions and plot checkerboards.
% 
% 1)load data; 
% 2)plot checkboards for all relevant epochs, save figures, can be turned
% off by setting plotAllEpoch to false
% 3)plot checkboards for regression related epoch (regressors), save figures, 
%run regression and save the model results.
% - can plot and run regression for both indidual subjects or group subjects (set by plotGroup flag or when there are more than 1 subjects provided),
% turn off individual subjects plotting by setting to false
% The results are saved under dataPath/Results/EMG/


%temporary rename conditions for ctr 02 to make OG1 the OG base 
% changeCondName('CTR_05','TM fast','TM tied 1')
% changeCondName('CTR_02_2','TM tied 4','TM slow')

%% set script parameters, SHOULD CHANGE/CHECK THIS EVERY TIME.
clear; close all; clc;
subjectID = {'AUF01','AUF03'};
visitNum = 'V02';

saveResAndFigure = false;
plotAllEpoch = false;
plotIndSubjects = true;
plotGroup = true;

% Set up data loading and saving path
if contains(visitNum, {'V02','V04'})
    intervention = false;
elseif contains(visitNum, {'V03'})
    intervention = true;
end
n_subjects = size(subjectID,2);
scriptDir = fileparts(matlab.desktop.editor.getActiveFilename); 
dataPath = cell(1,n_subjects);
resDir = cell(1,n_subjects);
for i = 1:n_subjects
    dataPath{i} = ['X:\Shuqi\NirsAutomaticityStudy\Data\' subjectID{i} '\' visitNum '\' subjectID{i} visitNum 'params.mat'];
    resDir{i} = ['X:\Shuqi\NirsAutomaticityStudy\Data\' subjectID{i} '\' visitNum '\Results\EMGV2\' ];
    subjectID{i} = [subjectID{i} visitNum];
end
%always prepare it but will only be used if plot group results
resDir{end+1} = ['X:\Shuqi\NirsAutomaticityStudy\Data\GroupResults\Group2Sub\EMGV2\' visitNum '\'];

if plotGroup
    groupID=['2Sub' visitNum];
end

dataPath'
resDir'
if contains(scriptDir, '/') %mac enviroment, replace \ with /
    dataPath = replace(dataPath,"\","/");
    dataPath = replace(dataPath,'X:','/Volumes/Research');
    resDir = replace(resDir,"\","/");
    resDir = replace(resDir,'X:','/Volumes/Research');
end
groupSummMethod = 'nanmedian';
%% load and prep data
normalizedTMFullAbrupt=adaptationData.createGroupAdaptData(dataPath);
normalizedTMFullAbrupt = normalizedTMFullAbrupt.removeBadStrides;

ss =normalizedTMFullAbrupt.adaptData{1}.data.getLabelsThatMatch('^Norm');
s2 = regexprep(ss,'^Norm','dsjrs');
normalizedTMFullAbrupt=normalizedTMFullAbrupt.renameParams(ss,s2);

muscleOrder={'TA', 'PER', 'SOL', 'LG', 'MG', 'BF', 'SEMB', 'SEMT', 'VM', 'VL', 'RF', 'TFL', 'GLU', 'HIP'};
n_muscles = length(muscleOrder);

ep=defineEpochNirs(intervention, 'nanmean'); %avg across strides, and mean across subjects

refEp=ep(strcmp(ep.Properties.ObsNames,'TMBase'),:); 
refEp.Properties.ObsNames{1}=['Ref: ' refEp.Properties.ObsNames{1}];
if intervention
    lateAdaEp = ep(strcmp(ep.Properties.ObsNames,'Adaptation5_{SS}'),:);
else
    lateAdaEp = ep(strcmp(ep.Properties.ObsNames,'Adaptation_{SS}'),:);
end

newLabelPrefix=([strcat('f',muscleOrder) strcat('s',muscleOrder)]); %To display fast and slow
newLabelPrefix = strcat(newLabelPrefix,'_s');
normalizedTMFullAbrupt = normalizedTMFullAbrupt.normalizeToBaselineEpoch(newLabelPrefix,refEp);
ll=normalizedTMFullAbrupt.adaptData{1}.data.getLabelsThatMatch('^Norm');
l2=regexprep(regexprep(ll,'^Norm',''),'_s','s');
normalizedTMFullAbrupt=normalizedTMFullAbrupt.renameParams(ll,l2);
newLabelPrefix = regexprep(newLabelPrefix,'_s','s');

%% plot epochs
if plotAllEpoch
    plotEp = ep(1:16,:); %exclude the middle transitions.
    for i = 1:n_subjects
        if plotGroup
            adaptDataSubject = normalizedTMFullAbrupt;
            figSavePath = resDir{end};
            figureSaveId = groupID;
        else
            adaptDataSubject = normalizedTMFullAbrupt.adaptData{1, i}; 
            figSavePath = resDir{i};
            figureSaveId = subjectID{i};
        end
        adaptDataSubject = normalizedTMFullAbrupt.adaptData{1, i}; 

        fh=figure('Units','Normalized','OuterPosition',[0 0 1 1]);
        ph=tight_subplot(1,length(plotEp)+1,[.03 .005],.04,.04);
        flip=true;

        adaptDataSubject.plotCheckerboards(newLabelPrefix,refEp,fh,ph(1,1),[],flip, groupSummMethod); %plot TMBase reference
        adaptDataSubject.plotCheckerboards(newLabelPrefix,plotEp(:,:),fh,ph(1,2:length(plotEp)+1),refEp,flip, groupSummMethod); %plot TR base reference
        adaptDataSubject.plotCheckerboards(newLabelPrefix,plotEp(8,:),fh,ph(1,9),lateAdaEp,flip, groupSummMethod);%plot the early Post - late Ada block

        set(ph(:,1),'CLim',[-1 1]);
        set(ph(:,2:end),'YTickLabels',{},'CLim',[-1 1]);
        set(ph,'FontSize',8)
        pos=get(ph(1,end),'Position');
        axes(ph(1,end))
        colorbar
        set(ph(1,end),'Position',pos);
        set(gcf,'color','w');

        if (saveResAndFigure)
            if not(isfolder(figSavePath))
                mkdir(figSavePath)
            end
            saveas(fh, [figSavePath figureSaveId '_AllEpochCheckerBoard.png'])
            saveas(fh, [figSavePath figureSaveId '_AllEpochCheckerBoard']) 
        end
        
        if plotGroup
            break
        end
    end
end

%% plot subsets of epochs: AE with context specific baseline correction
%AE only pertains to session 1 and long protocols.
OGBaseEp = ep(strcmp(ep.Properties.ObsNames,'OGBase'),:);
% refEpTR = defineReferenceEpoch('TRbase',ep);
OGPostEarlyEp = ep(strcmp(ep.Properties.ObsNames,'OGPost_{Early}'),:);
TMPostEarlyEp = ep(strcmp(ep.Properties.ObsNames,'TMPost_{Early}'),:);
OGPostLateEp = ep(strcmp(ep.Properties.ObsNames,'OGPost_{Late}'),:);
TMPostLateEp = ep(strcmp(ep.Properties.ObsNames,'TMPost_{Late}'),:);
for flip = [1,2] %2 legs separate first (flip = 1) and then asymmetry (flip = 2)
%     the flip asymmetry plots average of summation and the average of
%     asymmetry.
    for i = 1:n_subjects
        if plotGroup
            adaptDataSubject = normalizedTMFullAbrupt;
            figureSaveId = groupID;
        else
            adaptDataSubject = normalizedTMFullAbrupt.adaptData{1, i}; 
            figureSaveId = subjectID{i};
        end

        fh=figure('Units','Normalized','OuterPosition',[0 0 1 1]);
        ph=tight_subplot(1,6,[.03 .005],.04,.04);
        
        adaptDataSubject.plotCheckerboards(newLabelPrefix,OGBaseEp,fh,ph(1,1),[],flip, groupSummMethod); %plot OG base
        adaptDataSubject.plotCheckerboards(newLabelPrefix,refEp,fh,ph(1,2),[],flip, groupSummMethod); %plot TMbase
        % plot after effects with no baseline removal
        adaptDataSubject.plotCheckerboards(newLabelPrefix,OGPostEarlyEp,fh,ph(1,3),[],flip, groupSummMethod); 
        adaptDataSubject.plotCheckerboards(newLabelPrefix,TMPostEarlyEp,fh,ph(1,4),[],flip, groupSummMethod); 
        adaptDataSubject.plotCheckerboards(newLabelPrefix,OGPostLateEp,fh,ph(1,5),[],flip, groupSummMethod); 
        adaptDataSubject.plotCheckerboards(newLabelPrefix,TMPostLateEp,fh,ph(1,6),[],flip, groupSummMethod); 
                
        set(ph(:,1),'CLim',[-1 1]);
        set(ph(:,2:end),'YTickLabels',{},'CLim',[-1 1]);
        set(ph,'FontSize',8)
        pos=get(ph(1,end),'Position');
        axes(ph(1,end))
        colorbar
        set(ph(1,end),'Position',pos);
        set(gcf,'color','w');

        if (saveResAndFigure)
            if plotGroup
                figSavePath = resDir{end};
            else
                figSavePath = resDir{i};
            end
            if not(isfolder(figSavePath))
                mkdir(figSavePath)
            end
            if flip == 1
                saveas(fh, [figSavePath figureSaveId '_CheckerBoard_AE_NoBase.png'])
                saveas(fh, [figSavePath figureSaveId '_CheckerBoard_AE_NoBase'])
            else
                saveas(fh, [figSavePath figureSaveId '_CheckerBoard_AE_NoBase_Asym.png'])
                saveas(fh, [figSavePath figureSaveId '_CheckerBoard_AE_NoBase_Asym'])
            end
        end
        
        if plotGroup %exist the loop now
            break
        end
    end
end

%% Prepare data for regressor checkerboards and prepare common epochs
% prepare subjects to plot, make a list potentially combining ind and group
% subjects. this simplifies code repitition to handle group and individual
% subjects plotting.
subjectsToPlot = {};
subjectsToPlotID = {};
subjectsToPlotResDirs = {};
if plotIndSubjects
    subjectsToPlot = normalizedTMFullAbrupt.adaptData;
    subjectsToPlotID = subjectID;
    subjectsToPlotResDirs = resDir(1:end-1);
%     [subjectsToPlotResDirs{1:n_subjects}] = deal(resDir); %repeat resdir n_subjects times for saving
end
if length(subjectID) > 1 || plotGroup
    subjectsToPlot{end+1} = normalizedTMFullAbrupt;
    subjectsToPlotID{end+1} = groupID;
    subjectsToPlotResDirs{end+1} = resDir{end};
end

%set up common epochs
epPosShortEarly = ep(strcmp(ep.Properties.ObsNames,'PosShort'),:);
epTMPrePosShort = ep(strcmp(ep.Properties.ObsNames,'TMPrePosS_{La}'),:);
epNegShortEarly = ep(strcmp(ep.Properties.ObsNames,'NegShort'),:);
epTiedBeforeNegShort = ep(strcmp(ep.Properties.ObsNames,'TMPreNegS_{La}'),:);

%sanity check, none of the output should be empty
epCheck = whos('*ep*');
epCheck = [epCheck; whos('*Ep*')];
for epc = 1:numel(epCheck)
    if (any(epCheck(epc).size == 0))
        warning(['\nFound empty epoch. Please fix epoch: ', epCheck(epc).name])
    end
end

%% remove bad muscles before regression analysis
%if one condition exists in one subject only will get nan for the other
%subject, and median will use the subject that has data, which is the
%desirable behavior

badSubjID = {'AUF03V02', 'AUF03V04', 'AUF03V03'}; %badSubj and muscle are index matched, if want to remove group, put group ID here
badMuscles = {{'fMGs','sHIPs'},{'fMGs','sHIPs'},{'fMGs','sHIPs'}}; %labels in group ID will be removed for all regression and AE computations; 
% badSubjID = {'AUF03V02', 'AUF03V04', 'AUF03V03',groupID}; %example to remove labels for the whole group
% badMuscles = {{'fMGs','sHIPs'},{'fMGs','sHIPs'},{'fMGs','sHIPs'},{}}; 
% badSubjID = {'2SubV02'}; %badSubj and muscle are index matched, if want to remove group, put group ID here
% badMuscles = {{'fMGs'}}; %labels in group ID will be removed for all regression and AE computations; 

% other labels will only set the data for that subject as nan which will not be included in median computation later
symmetricLabelPrefix = repmat({newLabelPrefix},length(subjectsToPlotID),1);
newLabelPrefixPerSubj = repmat({newLabelPrefix},length(subjectsToPlotID),1);
description = 'Removed fMG and sHIP from AUF03 (Individual removed completely), group data used other subject to get median for these two muscles';
for idxToRemove = 1:numel(badSubjID)
%     if plotIndSubjects
        for subjIdx = 1:numel(subjectsToPlotID)
            if strcmp(subjectsToPlotID{subjIdx}, badSubjID{idxToRemove})
                badMuscleNames = badMuscles{idxToRemove};
                fprintf('Remaining labels for subject: %s\n', subjectsToPlotID{subjIdx})
                symmetricLabelPrefix(subjIdx,:) = {removeBadMuscleIndex(badMuscleNames,newLabelPrefix,true)};
                newLabelPrefixPerSubj(subjIdx,:) = {removeBadMuscleIndex(badMuscleNames,newLabelPrefix)};
                break;
            end
%         end
    end
    if plotGroup
        subjIdx = find(contains(subjectsToPlot{end}.ID, badSubjID{idxToRemove}));
        if ~isempty(subjIdx)
            badSubj = subjectsToPlot{end}.adaptData{subjIdx};
            for i = 1:numel(badMuscles{idxToRemove})
                badDataIdx=find(contains(badSubj.data.labels, {[badMuscles{idxToRemove}{i}, ' ']}));
                badSubj.data.Data(:,badDataIdx) = nan;
                disp(['Removing (Setting NaN) of ' badMuscles{idxToRemove}{i} ' from Subject: ' badSubj.subData.ID])
            end
            subjectsToPlot{end}.adaptData{subjIdx} = badSubj;
        end
    end
end


%% find scalar after effects
if ~intervention
 
flip = 1;
AEScalar = nan(length(subjectsToPlot),2); %columns: AE1, AE2
cosWithCorrespondingBase = nan(length(subjectsToPlot),2); %columns: AE1, AE2
for i = 1:length(subjectsToPlot)
    %plot and find scalar AE for each transition
    fh=figure('Units','Normalized','OuterPosition',[0 0 1 1]);
    ph=tight_subplot(1,3,[.03 .005],.04,.04);
    Data = cell(1,3); %in order: AE for trans 1 and for trans 2
    [~,~,~,Data{1},~] = subjectsToPlot{i}.plotCheckerboards(newLabelPrefixPerSubj{i,:},OGBaseEp,fh,ph(1,1),[],flip, groupSummMethod);
    [~,~,~,Data{2},~] = subjectsToPlot{i}.plotCheckerboards(newLabelPrefixPerSubj{i,:},OGPostEarlyEp,fh,ph(1,2),[],flip, groupSummMethod);
    [~,~,~,Data{3},~] = subjectsToPlot{i}.plotCheckerboards(newLabelPrefixPerSubj{i,:},OGPostEarlyEp,fh,ph(1,3),OGBaseEp,flip, groupSummMethod);
    title('AE1(OGPost - OGBase)')
    
    fh2=figure('Units','Normalized','OuterPosition',[0 0 1 1]);
    ph2=tight_subplot(1,3,[.03 .005],.04,.04);
    Data2 = cell(1,3); %in order: AE for trans 1 and for trans 2
    [~,~,~,Data2{1},~] = subjectsToPlot{i}.plotCheckerboards(newLabelPrefixPerSubj{i,:},refEp,fh,ph2(1,1),[],flip, groupSummMethod); 
    [~,~,~,Data2{2},~] = subjectsToPlot{i}.plotCheckerboards(newLabelPrefixPerSubj{i,:},TMPostEarlyEp,fh,ph2(1,2),[],flip, groupSummMethod); 
    [~,~,~,Data2{3},~] = subjectsToPlot{i}.plotCheckerboards(newLabelPrefixPerSubj{i,:},TMPostEarlyEp,fh,ph2(1,3),refEp,flip, groupSummMethod); 
    title('AE2(TMPost - TMBase)')
    eval(['groupSumFun=@(x) ' groupSummMethod '(x,4);']);
    AEScalar(i,1) = norm(groupSumFun(Data{3}));
    AEScalar(i,2) = norm(groupSumFun(Data2{3}));
    plotsToScale = {ph, ph2};
    for subPh = plotsToScale
        ph = subPh{1};
        set(ph(:,1),'CLim',[-1 1]);
        set(ph(:,2:end),'YTickLabels',{},'CLim',[-1 1]);
        set(ph,'FontSize',8)
        pos=get(ph(1,end),'Position');
        axes(ph(1,end))
        colorbar
        set(ph(1,end),'Position',pos);
        set(gcf,'color','w');
    end 
    
    cosWithCorrespondingBase(i,1) = cosine(reshape(groupSumFun(Data2{1}),[],1),reshape(groupSumFun(Data2{2}),[],1));
    cosWithCorrespondingBase(i,2) = cosine(reshape(groupSumFun(Data{1}),[],1),reshape(groupSumFun(Data{2}),[],1));
                
    %TODO: add delta adapt magnitude, save to var
    if saveResAndFigure
        saveas(fh, [subjectsToPlotResDirs{i} subjectsToPlotID{i} 'AEOG.png'])
        saveas(fh, [subjectsToPlotResDirs{i} subjectsToPlotID{i} 'AEOG'])
        saveas(fh2, [subjectsToPlotResDirs{i} subjectsToPlotID{i} 'AETM.png'])
        saveas(fh2, [subjectsToPlotResDirs{i} subjectsToPlotID{i} 'AETM'])
    end
end
AEScalar = array2table(AEScalar);
AEScalar.Properties.RowNames = subjectsToPlotID;
AEScalar.Properties.VariableNames = {'AE1(OG)','AE2(TM)'};
AEScalar

cosWithCorrespondingBase = array2table(cosWithCorrespondingBase);
cosWithCorrespondingBase.Properties.VariableNames = {'TMPost_{Early}','OGPost_{Early}'};
cosWithCorrespondingBase.Properties.RowNames = subjectsToPlotID;
cosWithCorrespondingBase

if saveResAndFigure %save to the last directory (if group, saved to group dir (careful for overwrite here); if 1 subject save to the subject dir).
    save([subjectsToPlotResDirs{end} subjectsToPlotID{end} '_AEEMGScalar_Cos'], 'AEScalar','cosWithCorrespondingBase','description');
end


%% run regression
%set up variables that could change the regression
usefft = 0; normalizeData = 0;

for i = 1:length(subjectsToPlot)
    for modelOption = 1:2 %option1 = 2 regressor model like pablo, 2 = adding an env switch component
        % reset regressor names for each model option, reset reg model versions  
        regressorNames = {'Adapt','NonAdapt','MultiEnvTrans','Trans1','Trans2'};
        for flip = [1,2]%2 legs separate first (flip = 1) and then asymmetry (flip = 2)
%     the flip asymmetry plots average of asymmetry (labeled aMuslce) and the average of asymmetry (labeled bMuscle).
            if flip == 1
                currLabelPrefix = newLabelPrefixPerSubj{i,:};
            else
                currLabelPrefix = symmetricLabelPrefix{i,:};
            end
            fh=figure('Units','Normalized','OuterPosition',[0 0 1 1]);
            ph=tight_subplot(1,5,[.03 .005],.04,.04);
            Data = cell(1,5); %in order: {'MultiContextAdapt','EnvTransition','MultiContextSwitch','Trans1','Trans2'};

            if modelOption == 1 %trans = adapt (EMGon- = negShort - tied) + nonadapt (-EMGon+ = -(posShort - tied)) (Pablo's model)
                [~,~,~,Data{3},~] = subjectsToPlot{i}.plotCheckerboards(currLabelPrefix,OGBaseEp,fh,ph(1,2),OGBaseEp,flip, groupSummMethod); % space holder 
                title('Space-Holder(Unused)') %space holder, data doesn't matter, won't be used
                regressorNames{3}='Unused';
            else %trans = envSwitch + adapt (EMGon- = negShort - tied) + nonadapt (-EMGon+ = -(posShort - tied)) (Pablo's model with evn component)
                %envSwitch = OG - TMBase
                [~,~,~,Data{3},~] = subjectsToPlot{i}.plotCheckerboards(currLabelPrefix,OGBaseEp,fh,ph(1,2),refEp,flip, groupSummMethod); % env-transition: OG-TRbase                
                title('MultiEnvTrans: OGbase - TMbase')
            end
            
            if usefft %adapt, use positive short and flip legs later, NonAdapt = posS - TMtied, flipped
                [~,~,~,Data{1},~] = subjectsToPlot{i}.plotCheckerboards(currLabelPrefix,epPosShortEarly,fh,ph(1,1),epTMPrePosShort,flip, groupSummMethod);
                title('Adapt (flip leg of PosShort-TMTiedPre)')
            else %adapt (EMGon- = negShort - tied)
                [~,~,~,Data{1},~] = subjectsToPlot{i}.plotCheckerboards(currLabelPrefix,epNegShortEarly,fh,ph(1,1),epTiedBeforeNegShort,flip, groupSummMethod);
                title('Adapt (NegShort-TMTiedPre)')
            end
            [~,~,~,Data{2},~] = subjectsToPlot{i}.plotCheckerboards(currLabelPrefix,epTMPrePosShort,fh,ph(1,3),epPosShortEarly,flip, groupSummMethod);
            title('NonAdapt (-(PosShort - TMTiedPre))')
            [~,~,~,Data{4},~] = subjectsToPlot{i}.plotCheckerboards(currLabelPrefix,OGPostEarlyEp,fh,ph(1,4),lateAdaEp,flip, groupSummMethod); %Post1 - Adaptation_{SS}, transition 1
            title('Tran1')
            [~,~,~,Data{5},~] = subjectsToPlot{i}.plotCheckerboards(currLabelPrefix,TMPostEarlyEp,fh,ph(1,5),OGPostLateEp,flip, groupSummMethod); %Post2 early - post 1 late, transition 2
            title('Tran2')

            set(ph(:,1),'CLim',[-1 1]);
            set(ph(:,2:end),'YTickLabels',{},'CLim',[-1 1]);
            set(ph,'FontSize',8)
            pos=get(ph(1,end),'Position');
            axes(ph(1,end))
            colorbar
            set(ph(1,end),'Position',pos);
            set(gcf,'color','w');

            if flip ~= 2 %run regression on the full (not asymmetry) data
                % run regression and save results
                format compact % format loose %(default)
                modelOption
                % not normalized first, then normalized, arugmnets order: (Data, normalizeData, isGroupData, dataId, resDir, saveResAndFigure, version, usefft) 
                runRegressionNirs(Data, false, isa(subjectsToPlot{1},'groupAdaptationData'), [subjectsToPlotID{i} '_modelOpt_' num2str(modelOption) '_flip_' num2str(flip)], subjectsToPlotResDirs{i}, saveResAndFigure, modelOption, usefft, regressorNames, groupSummMethod)
                runRegressionNirs(Data, true, isa(subjectsToPlot{1},'groupAdaptationData'), [subjectsToPlotID{i} '_modelOpt_' num2str(modelOption) '_flip_' num2str(flip)], subjectsToPlotResDirs{i}, saveResAndFigure, modelOption, usefft, regressorNames, groupSummMethod)
                if (saveResAndFigure) %only save the regression figure    
                    if not(isfolder(subjectsToPlotResDirs{i}))
                        mkdir(subjectsToPlotResDirs{i})
                    end
                    saveas(fh, [subjectsToPlotResDirs{i} subjectsToPlotID{i} 'Checkerboard_modelOption_' num2str(modelOption) '_flip_' num2str(flip) '_fft_' num2str(usefft) '_norm_' num2str(normalizeData) '.png'])
                    saveas(fh, [subjectsToPlotResDirs{i} subjectsToPlotID{i} 'Checkerboard_modelOption_' num2str(modelOption) '_flip_' num2str(flip) '_fft_' num2str(usefft) '_norm_' num2str(normalizeData)])
                end
            else
                asymCos = findCosBtwAsymOfEpochs(Data, size(currLabelPrefix,2),regressorNames, groupSummMethod)
            end
        end
    end
end
end

%% intervention plots
% TMpost per switch (cos vs TM base, should become more and more similar bc better at switching);
% AdaLate - AdaEarly per epoch, diff should become closer to 0 (less
% adaptation/changes in the process?) -> checkerboards of late and early,
% then cos table

flip = 1;
if intervention
    %%
    for conds = 1:2 %plot 1 = tmpost early, 2 = ada late - ada early
        for i = 1:length(subjectsToPlot)
%             if plotGroup
%                 adaptDataSubject = normalizedTMFullAbrupt;
%                 figureSaveId = groupID;
%                 labelPrefix
%             else
%                 adaptDataSubject = normalizedTMFullAbrupt.adaptData{1, i}; 
%                 figureSaveId = subjectID{i};
%             end
            adaptDataSubject = subjectsToPlot{i};
            figureSaveId = subjectsToPlotID{i};
            figSavePath = subjectsToPlotResDirs{i};
            fh=figure('Units','Normalized','OuterPosition',[0 0 1 1]);

            if conds == 1
                figureSaveId = [figureSaveId '_PostEarly'];
                ph=tight_subplot(1,8,[.03 .005],.04,.04);
                [~,~,~,DataTMBase,~] = adaptDataSubject.plotCheckerboards(newLabelPrefixPerSubj{i,:},refEp,fh,ph(1,1),[],flip, groupSummMethod); %plot TMbase
                epIdx = find(strcmp(ep.Properties.ObsNames,'TMPost1_{Early}'));
                [~,~,~,Data,~] = adaptDataSubject.plotCheckerboards(newLabelPrefixPerSubj{i,:},ep(epIdx:epIdx+3,:),fh,ph(1,2:5),[],flip, groupSummMethod); %data in format: interval x muscles x epochs (e.g., 12x28x4)
                [~,~,~,Data(:,:,end+1,:),~] = adaptDataSubject.plotCheckerboards(newLabelPrefixPerSubj{i,:},TMPostEarlyEp,fh,ph(1,6),[],flip, groupSummMethod); 
                [~,~,~,DataOGBase,~] = adaptDataSubject.plotCheckerboards(newLabelPrefixPerSubj{i,:},OGBaseEp,fh,ph(1,7),[],flip, groupSummMethod); 
                [~,~,~,Data(:,:,end+1,:),~] = adaptDataSubject.plotCheckerboards(newLabelPrefixPerSubj{i,:},OGPostEarlyEp,fh,ph(1,8),[],flip, groupSummMethod); 
                
                eval(['groupSumFun=@(x) ' groupSummMethod '(x,4);']);
                
                DataTMBase = reshape(groupSumFun(DataTMBase),[],1);
                DataOGBase = reshape(groupSumFun(DataOGBase),[],1);
                Data = groupSumFun(Data);
                AEScalar = nan(1,size(Data,3));
                cosWithCorrespondingBase = nan(1,size(Data,3));
                for epochIdx = 1:size(Data,3)
                    dataToComp = reshape(Data(:,:,epochIdx),[],1);
                    cosWithCorrespondingBase(epochIdx) = cosine(DataTMBase,dataToComp);
                    AEScalar(epochIdx) = norm(dataToComp - DataTMBase);
                    if epochIdx == size(Data,3) %OGPost
                        cosWithCorrespondingBase(epochIdx) = cosine(DataOGBase,dataToComp);
                        AEScalar(epochIdx) = norm(dataToComp - DataOGBase);
                    end
                end

                cosWithCorrespondingBase = array2table(cosWithCorrespondingBase);
                cosWithCorrespondingBase.Properties.VariableNames = [ep(epIdx:epIdx+3,:).Properties.ObsNames;'TMPost_{Early}';'OGPost_{Early}'];
                cosWithCorrespondingBase
                AEScalar = array2table(AEScalar);
                AEScalar.Properties.VariableNames = {'AE_TMPost1','AE_TMPost2','AE_TMPost3','AE_TMPost4','AE_TMPost','AE_OGPost',};
                AEScalar
            else
                figureSaveId = [figureSaveId '_AdaptChange'];
                ph=tight_subplot(1,5,[.03 .005],.04,.04);
                epIdx = find(strcmp(ep.Properties.ObsNames,'Adapt1_{Late}'));
                dataMagnitude = nan(1,5);
                [~,~,~,Data,~] = adaptDataSubject.plotCheckerboards(newLabelPrefixPerSubj{i,:},ep(epIdx,:),fh,ph(1,1),ep(epIdx+5,:),flip, groupSummMethod); 
                %summarize to get median per group first
                dataMagnitude(1) = norm(groupSumFun(Data));
                title([ep(epIdx,:).Properties.ObsNames{1} '-' ep(epIdx+5,:).Properties.ObsNames{1} ]);
                for adaptBlcks = 2:5
                    [~,~,~,Data(:,:,end+1,:),~] = adaptDataSubject.plotCheckerboards(newLabelPrefixPerSubj{i,:},ep(epIdx+adaptBlcks-1,:),fh,ph(1,adaptBlcks),ep(epIdx+4+adaptBlcks,:),flip, groupSummMethod); 
                    title([ep(epIdx+adaptBlcks-1,:).Properties.ObsNames{1} '-' ep(epIdx+4+adaptBlcks,:).Properties.ObsNames{1} ]);
                    dataMagnitude(adaptBlcks) = norm(groupSumFun(Data(:,:,end,:)));
                end
                dataMagnitude = array2table(dataMagnitude);
                dataMagnitudeVarName = cell(1,size(Data,3));
                for adaptBlcks = 1:size(Data,3)
                    dataMagnitudeVarName{adaptBlcks} = ['deltaAdapt' num2str(adaptBlcks)];
                end
                dataMagnitude.Properties.VariableNames = dataMagnitudeVarName;
                dataMagnitude
            end
            set(ph(:,1),'CLim',[-1 1]);
            set(ph(:,2:end),'YTickLabels',{},'CLim',[-1 1]);
            set(ph,'FontSize',8)
            pos=get(ph(1,end),'Position');
            axes(ph(1,end))
            colorbar
            set(ph(1,end),'Position',pos);
            set(gcf,'color','w');

            if (saveResAndFigure)
%                 if plotGroup
%                     figSavePath = resDir{end};
%                 else
%                     figSavePath = resDir{i};
%                 end
                if not(isfolder(figSavePath))
                    mkdir(figSavePath)
                end
                saveas(fh, [figSavePath figureSaveId '_CheckerBoard_Switch.png'])
                saveas(fh, [figSavePath figureSaveId '_CheckerBoard_Switch'])
                if conds == 1
                    save([figSavePath figureSaveId(1:end-10) '_AEEMGScalar_Cos'], 'AEScalar','cosWithCorrespondingBase','description');
                else
                    save([figSavePath figureSaveId(1:end-12) '_EMGDeltaAdaptMag'], 'dataMagnitude','description');
                end
            end

%             if plotGroup %exist the loop now
%                 break
%             end
        end
    end
    
    %%
    % regression per switch, beta adapt and non adapt both decrease and switch
% increase?  -> plot beta changes over time
% AE scalar per switch: should decrease over time -> plot AE scalar changes
% over time (print out first in a table)
    %set up variables that could change the regression
    usefft = 0; normalizeData = 0;
 
    for i = 1:length(subjectsToPlot)
        for modelOption = 1:2 %option1 = 2 regressor model like pablo, 2 = adding an env switch component
            % reset regressor names for each model option, reset reg model versions  
            regressorNames = {'Adapt','NonAdapt','MultiEnvTrans','Transition'};
            for flip = [1,2]%2 legs separate first (flip = 1) and then asymmetry (flip = 2)
    %     the flip asymmetry plots average of asymmetry (labeled aMuslce) and the average of asymmetry (labeled bMuscle).
                if flip == 1
                    currLabelPrefix = newLabelPrefixPerSubj{i,:};
                else
                    currLabelPrefix = symmetricLabelPrefix{i,:};
                end
                fh=figure('Units','Normalized','OuterPosition',[0 0 1 1]);
                ph=tight_subplot(1,9,[.03 .005],.04,.04); %3 regressors, 6 possible transitions
                Data = cell(1,4); %in order: {'MultiContextAdapt','EnvTransition','MultiContextSwitch','Trans1','Trans2'};

                if modelOption == 1 %trans = adapt (EMGon- = negShort - tied) + nonadapt (-EMGon+ = -(posShort - tied)) (Pablo's model)
                    [~,~,~,Data{3},~] = subjectsToPlot{i}.plotCheckerboards(currLabelPrefix,OGBaseEp,fh,ph(1,2),OGBaseEp,flip, groupSummMethod); % space holder 
                    title('Space-Holder(Unused)') %space holder, data doesn't matter, won't be used
                    regressorNames{3}='Unused';
                else %trans = envSwitch + adapt (EMGon- = negShort - tied) + nonadapt (-EMGon+ = -(posShort - tied)) (Pablo's model with evn component)
                    %envSwitch = OG - TMBase
                    [~,~,~,Data{3},~] = subjectsToPlot{i}.plotCheckerboards(currLabelPrefix,OGBaseEp,fh,ph(1,2),refEp,flip, groupSummMethod); % env-transition: OG-TRbase                
                    title('MultiEnvTrans: OGbase - TMbase')
                end

                if usefft %adapt, use positive short and flip legs later, NonAdapt = posS - TMtied, flipped
                    [~,~,~,Data{1},~] = subjectsToPlot{i}.plotCheckerboards(currLabelPrefix,epPosShortEarly,fh,ph(1,1),epTMPrePosShort,flip, groupSummMethod);
                    title('Adapt (flip leg of PosShort-TMTiedPre)')
                else %adapt (EMGon- = negShort - tied)
                    [~,~,~,Data{1},~] = subjectsToPlot{i}.plotCheckerboards(currLabelPrefix,epNegShortEarly,fh,ph(1,1),epTiedBeforeNegShort,flip, groupSummMethod);
                    title('Adapt (NegShort-TMTiedPre)')
                end
                [~,~,~,Data{2},~] = subjectsToPlot{i}.plotCheckerboards(currLabelPrefix,epTMPrePosShort,fh,ph(1,3),epPosShortEarly,flip, groupSummMethod);
                title('NonAdapt (-(PosShort - TMTiedPre))')
                
                epIdx = find(strcmp(ep.Properties.ObsNames,'TMPost1_{Early}'));
                earlyPostEpPerBlock = ep(epIdx:epIdx+3,:);
                earlyPostEpPerBlock(end+1,:) = OGPostEarlyEp;
                earlyPostEpPerBlock.Properties.ObsNames{end} = OGPostEarlyEp.Properties.ObsNames{1};
                earlyPostEpPerBlock(end+1,:) = TMPostEarlyEp;
                earlyPostEpPerBlock.Properties.ObsNames{end} = TMPostEarlyEp.Properties.ObsNames{1};
                
                epIdx = find(strcmp(ep.Properties.ObsNames,'Adapt1_{Late}'));
                latePreEpPerBlock = ep(epIdx:epIdx+4,:);
                latePreEpPerBlock(end+1,:) = OGPostLateEp;
                latePreEpPerBlock.Properties.ObsNames{end} = OGPostLateEp.Properties.ObsNames{1};
                
                for switchBlock = 1:size(earlyPostEpPerBlock,1)
                    [~,~,~,Data{4},~] = subjectsToPlot{i}.plotCheckerboards(currLabelPrefix,earlyPostEpPerBlock(switchBlock,:),fh,ph(1,3+switchBlock),latePreEpPerBlock(switchBlock,:),flip, groupSummMethod); %Post1 - Adaptation_{SS}, transition 1
                    title([earlyPostEpPerBlock(switchBlock,:).Properties.ObsNames{1} '-' latePreEpPerBlock(switchBlock,:).Properties.ObsNames{1}])
                    regressorNames{end} = ['Transition' num2str(switchBlock)];
                    
                    set(ph(:,1),'CLim',[-1 1]);
                    set(ph(:,2:end),'YTickLabels',{},'CLim',[-1 1]);
                    set(ph,'FontSize',8)
                    pos=get(ph(1,end),'Position');
                    axes(ph(1,end))
                    colorbar
                    set(ph(1,end),'Position',pos);
                    set(gcf,'color','w');

                    if (saveResAndFigure && switchBlock == size(earlyPostEpPerBlock,1)) %save after the last transition is plotted
                        if not(isfolder(subjectsToPlotResDirs{i}))
                            mkdir(subjectsToPlotResDirs{i})
                        end
                        saveas(fh, [subjectsToPlotResDirs{i} subjectsToPlotID{i} '_Checkerboard_modelOption_' num2str(modelOption) '_flip_' num2str(flip) '_fft_' num2str(usefft) '_norm_' num2str(normalizeData) '.png'])
                        saveas(fh, [subjectsToPlotResDirs{i} subjectsToPlotID{i} '_Checkerboard_modelOption_' num2str(modelOption) '_flip_' num2str(flip) '_fft_' num2str(usefft) '_norm_' num2str(normalizeData)])
                    end

                    if flip ~= 2 %run regression on the full (not asymmetry) data
                        % run regression and save results
                        format compact % format loose %(default)
                        modelOption
                        % not normalized first, then normalized, arugmnets order: (Data, normalizeData, isGroupData, dataId, resDir, saveResAndFigure, version, usefft) 
                        runRegressionNirs(Data, false, isa(subjectsToPlot{1},'groupAdaptationData'), [subjectsToPlotID{i} '_Switch' num2str(switchBlock) '_flip_' num2str(flip)], subjectsToPlotResDirs{i}, saveResAndFigure, modelOption, usefft, regressorNames, groupSummMethod)
                        runRegressionNirs(Data, true, isa(subjectsToPlot{1},'groupAdaptationData'), [subjectsToPlotID{i} '_Switch' num2str(switchBlock) '_flip_' num2str(flip)], subjectsToPlotResDirs{i}, saveResAndFigure, modelOption, usefft, regressorNames, groupSummMethod)
                        %TODO: taking screenshots here is not feasible,
                        %make plots of the betas;
                    else
                        fprintf('Transition %d ', switchBlock);
                        asymCos = findCosBtwAsymOfEpochs(Data, size(currLabelPrefix,2),regressorNames)
                    end
                end
            end
        end
    end
end