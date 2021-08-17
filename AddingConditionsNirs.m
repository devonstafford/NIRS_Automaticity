%Chagingparams, create new conditions in 1 trial, currently only need to
%use it fors the first block for preintervention trials.
function in= AddingConditionsNirs(in, oldConditionName, newConditions, dataPath, newDecription, newTrialType)
    if nargin < 5 || isempty(newDecription)
        newDecription = 'Beginning of adaptation';
    end

    if nargin < 6 || isempty(newTrialType)
        newTrialType = 'TM';
    end
    
%     subplot(3,1,1)
    in.plotAvgTimeCourse(in,'netContributionNorm2')
    title('Before Changing Conditions');
%     subplot(3,1,2)
%     in.plotAvgTimeCourse(in,'singleStanceSpeedFastAbsANK')
%     subplot(3,1,3)
%     in.plotAvgTimeCourse(in,'singleStanceSpeedSlowAbsANK')
    
    % find the index for the label singleStanceSpeedFastAbsANK
    idxfast=compareListsNested({'singleStanceSpeedFastAbsANK'},in.data.labels)==1;
    idxslow=compareListsNested({'singleStanceSpeedSlowAbsANK'},in.data.labels)==1;
    
    trialNum = in.metaData.trialsInCondition{strcmp(in.metaData.conditionName,oldConditionName)};
    columnIdxForTrialNum=find(compareListsNested({'Trial'},in.data.labels));

    fast=in.data.Data(:,idxfast);
    slow=in.data.Data(:,idxslow);
    difference=fast-slow;

    % find the index with speed difference or speed at 1 but also within the
    % current condition of interes
    idxSplit=difference>400 & in.data.Data(:,columnIdxForTrialNum) == trialNum;

    currConditionLength = length(in.metaData.conditionName);
    currMaxTrial = max(cell2mat(in.metaData.trialsInCondition));

    %for now handles 1 new condition at a time
    % ismember finds A in B 
    newConditionTrialCount = 1;
    [condExist, loc] = ismember(newConditions, in.metaData.conditionName);
    condExistIdx = find(condExist);
    loc = loc(condExistIdx);
    if condExistIdx
%         in.metaData.conditionName{currConditionLength+1}=in.metaData.conditionName{loc};
        oldTrials = in.metaData.trialsInCondition{loc};
        newCondTrials = nan(1,length(oldTrials)+newConditionTrialCount);
        newCondTrials(1) = currMaxTrial + 1;
        in.data.Data(idxSplit,columnIdxForTrialNum)=newCondTrials(1);
        in.data.trialTypes{1}=in.data.trialTypes{1};
        for i = 2:length(oldTrials)+1
            newCondTrials(i) = currMaxTrial + i;
            dataIdxToUpdate = in.data.Data(:,columnIdxForTrialNum) == oldTrials(i-1);
            in.data.Data(dataIdxToUpdate,columnIdxForTrialNum) = newCondTrials(i);
            in.data.trialTypes{end+1}=in.data.trialTypes{i-1};
        end
        
        in.metaData.trialsInCondition{loc} = newCondTrials;
%         in.metaData.conditionDescription{currConditionLength+1}= in.metaData.conditionDescription{loc};
%         in.data.trialTypes{end+1}=in.data.trialTypes{loc};
%         in.metaData.conditionName{loc} = 'Not used anymore';
    else
        in.metaData.conditionName{currConditionLength+1}=newConditions;
        in.metaData.trialsInCondition{currConditionLength+1}=currMaxTrial+1;
        in.metaData.conditionDescription{currConditionLength+1}= newDecription;
        in.data.trialTypes{currConditionLength+1}=newTrialType;
        in.data.Data(idxSplit,columnIdxForTrialNum)=currMaxTrial+1;
    end
    
%     subplot(3,1,1)
    in.plotAvgTimeCourse(in,'netContributionNorm2')
    title('After Changing Params')
%     subplot(3,1,2)
%     in.plotAvgTimeCourse(in,'singleStanceSpeedFastAbsANK')
%     subplot(3,1,3)
%     in.plotAvgTimeCourse(in,'singleStanceSpeedSlowAbsANK')
    
%     adaptData = in;
%     save([dataPath in.subData.ID 'paramsNewConditions.mat'],'adaptData','-v7.3');
end 
