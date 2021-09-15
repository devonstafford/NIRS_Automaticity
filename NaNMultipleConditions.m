clear all
clc

%loads in the params file
load('/Users/mackenziestiles/Desktop/SML Lab Matlab/fNIRS/fNIRS path/NIRS_Automaticity/S04_MarcelaV03params.mat');

% load in your variables (the name of the condition you would like to
% split, your speed difference metric, and an appropriate value to replace the NaNs)
oldConditionName='MidThenAdapt';
speedDiff=400;
%this is a value I am replacing the NaNs with in difference, you probably
%should not change, but up to you
nanValue=-400;

% find the index for the label singleStanceSpeedFastAbsANK and SlowAbsANK
% this shows the index of where they are in data.labels
idxfast=find(compareListsNested({'singleStanceSpeedFastAbsANK'},adaptData.data.labels)==1);
idxslow=find(compareListsNested({'singleStanceSpeedSlowAbsANK'},adaptData.data.labels)==1);

% finds the trial number which matches oldConditionName
trialNum = adaptData.metaData.trialsInCondition{find(strcmp(adaptData.metaData.conditionName,oldConditionName))};
% finds which column the trials are listed in
columnIdxTrialNum=find(compareListsNested({'Trial'},adaptData.data.labels)==1);
%finds all of the rows where there is trialNum
rowIdxForCurrentTrial = find(adaptData.data.Data(:,columnIdxTrialNum) == trialNum);

% gets the difference data for only the rows of interest
firstRow = rowIdxForCurrentTrial(1,1);
lastRow = rowIdxForCurrentTrial(length(rowIdxForCurrentTrial),1);
fast=adaptData.data.Data(firstRow:lastRow,idxfast);
slow=adaptData.data.Data(firstRow:lastRow,idxslow);
difference=fast-slow;

%sets all NaN values to a real number
%you do not need to do this step but the logic was easier than isnan for me
for i=1:length(difference)
    if(isnan(difference(i))==1)
        difference(i)=nanValue;
    end
end

%0 is a small difference, 1 is a large difference, 2 is a NaN value
if((nanValue<difference(1))&&(difference(1)<speedDiff))
    diff=0; %tied trial
else
    if ((nanValue<difference(1))&&(difference(1)>speedDiff))
        diff=1; %split trial
    else 
        diff=2; %NaNs
    end
end

% sets the first location before the for loop
j=1;
k=1;
l=1;
speedChangeLoc(j,k)=1;
trialStartEnd(l,k)=firstRow;
k=2;
speedChangeLoc(j,k)=difference(1);

% sets two variables for rows, j for speedChangeLoc and l for trialStartEnd
j=2;
l=2;

%for loop is not robust if there are NaNs in the middle of a trial!! fix!

for i=2:length(difference) %for loop increasing until the final difference
    if(diff==0) %the last condition set was tied trial
        if((nanValue<difference(i))&&(difference(i)>speedDiff)) %split trial
            diff=1;
            k=2;
            trialStartEnd(l-1,k)=i+firstRow-2;
            k=1;
            speedChangeLoc(j,k)=i;
            trialStartEnd(l,k)=i+firstRow-1;
            k=2;
            speedChangeLoc(j,k)=difference(i);
            j=j+1;
            l=l+1;
        else
            if((nanValue==difference(i))&&(i==length(difference))) %the last trial is NaN
                k=2;
                trialStartEnd(l-1,k)=i+firstRow-1;
            else
                if(nanValue==difference(i)) %there is a NaN included
                    diff=2;
                    k=2;
                    trialStartEnd(l-1,k)=i+firstRow-2;
                    k=1;
                    speedChangeLoc(j,k)=i;
                    trialStartEnd(l,k)=i+firstRow-1;
                    k=2;
                    speedChangeLoc(j,k)=difference(i);
                    j=j+1;
                    l=l+1;
                end
            end
                
        end
    else
        if(diff==1) %previous condition was a split trial
            if((nanValue<difference(i))&&(difference(i)<speedDiff))
                diff=0;
                k=2;
                trialStartEnd(l-1,k)=i+firstRow-2;
                k=1;
                speedChangeLoc(j,k)=i;
                trialStartEnd(l,k)=i+firstRow-1;
                k=2;
                speedChangeLoc(j,k)=difference(i);
                j=j+1;
                l=l+1;
            else
                if((nanValue==difference(i))&&(i==length(difference))) %last trial is NaN
                    k=2;
                    trialStartEnd(l-1,k)=i+firstRow-1;
                else
                    if(nanValue==difference(i)) %there is a NaN
                        diff=2;
                        k=2;
                        trialStartEnd(l-1,k)=i+firstRow-2;
                        k=1;
                        speedChangeLoc(j,k)=i;
                        trialStartEnd(l,k)=i+firstRow-1;
                        k=2;
                        speedChangeLoc(j,k)=difference(i);
                        j=j+1;
                        l=l+1;
                    end
                end
            end
        else %if diff=2, there is a NaN
            if((nanValue<difference(i))&&(difference(i)<speedDiff)) %tied
                diff=0;
                k=1;
                speedChangeLoc(j,k)=i;
                k=2;
                speedChangeLoc(j,k)=difference(i);
                j=j+1;
            else
                if((nanValue<difference(i))&&(difference(i)>speedDiff)) %split
                    diff=1;
                    k=1;
                    speedChangeLoc(j,k)=i;
                    k=2;
                    speedChangeLoc(j,k)=difference(i);
                    j=j+1;
                else
                    if((nanValue==difference(i))&&(i==length(difference))) %ends on a NaN
                        k=2;
                        trialStartEnd(j-1,k)=i+firstRow-1;
                    end
                end  
            end
        end
    end
end

k=1;
speedChangeLoc(j,k)=i;
k=2;
speedChangeLoc(j,k)=difference(i);

newTrialNum=100;

%replaces the old trial numbers with numbers 100-
for i=1:length(trialStartEnd)
    adaptData.data.Data(trialStartEnd(i,1):trialStartEnd(i,2),columnIdxTrialNum)=newTrialNum;
    %adaptData.data.trialTypes{newTrialNum}=adaptData.data.trialTypes{trialNum};
    newTrialNum=newTrialNum+1;
end



% need to have:
% -change trial numbers
% -update to ConditionName, ConditionDescription, without deleting any columns
% -create more columns in trials in description, but keep the one trial in each column
%     -do the same thing for Trial types
%     -

% i=width(adaptData.metaData.conditionName)+1;
% 
% while i>=0
%     adaptData.metaData.conditionName{i}=NewConditions{i};
%     adaptData.metaData.trialsInCondition{i}=i;
%     adaptData.metaData.conditionDescription{i}= description{i};
%     adaptData.data.trialTypes{i}='TM';
%     i=i+1;
% 
% %     adaptData.metaData.conditionName{3}='Adaptation';
% %     adaptData.metaData.conditionName{4}='Washout';
% end
% adaptData.data.Data(idxSplit(1):idxSplit(end),4)=indexNewCond(1);
% adaptData.data.Data(idxSplit(end)+1:end,4)=indexNewCond(2);

% for i=1:length(speedChangeLoc)
%     if(isnan(speedChangeLoc(i,2))==1)
%             if(speedChangeLoc(i,1)==length(difference))
%                 m=2
%                 trialStartEnd(l,m)=i;
%             else
%                 if(speedChangeLoc(i-1,1)<speedDiff)
%                     if(difference(speedChangeLoc(i+1,1)>speedDiff)
%                         m=1
%                         trialStartEnd(l,m)=i;
%                     end
%                 end
%             end
%         if(speedChangeLoc(i+1,2)<speedDiff)
%             diff=1;
%             k=1;
%             speedChangeLoc(j,k)=i;
%             k=2;
%             speedChangeLoc(j,k)=difference(i);
%             j=j+1;
%         end
%     else
%         if(difference(i)<speedDiff)
%             diff=0;
%             k=1;
%             speedChangeLoc(j,k)=i;
%             k=2;
%             speedChangeLoc(j,k)=difference(i);
%             j=j+1;
%         end
%     end
% end
% 
% 
% trialStartEnd(l,m)


