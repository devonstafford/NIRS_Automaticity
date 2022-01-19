%This script needs access to the Y drive data
close all; clear all; clc;
% subjectID = 'AUF01V01Retest';
% dataPath = split(subjectID,'V');
% dataPath = ['Y:\Shuqi\NirsAutomaticityStudy\Data\' dataPath{1} '\V' dataPath{2} '\'];
% load([dataPath 'NirsParam\' subjectID 'NirsTaskViconRAW.mat']) %load rawExpData from c3d2mat

[dataPath, ~, saveDir, subjectID, visitNum] = setupDataPath('AUF02', 'V01', 'NirsParam', 'walkDistFigure');
load([dataPath subjectID 'RAW.mat']) %load rawExpData from c3d2mat
saveResAndFigure = true;

%% Find or create the DTdata data structure, find task orders to populate the DTdata
[DTdata, DTdataRowNameMap] = GetDTDataStructure([dataPath(1:end-10) subjectID 'DTdata.mat']); %if exists one load it TODO

if visitNum == 4
    visitNum = 2;
end
scriptDir = fileparts(matlab.desktop.editor.getActiveFilename);
load([scriptDir '/Data/SubjectTaskAlphabetRandomizationOrderRetest.mat'])
userID = str2num(subjectID(4:5)); %after AUF
taskOrder = taskOrders(userID, :);
alphabet = alphabetOrder(userID,visitNum);

if alphabet==1 %'A'
    all_events = [2 4 3 1 5;4 3 2 1 5;3 1 2 4 5; 3 2 4 5 1;3 4 1 2 5;2 3 5 4 1];
else %B
   all_events= [7 8 3 6 9; 8 3 7 6 9; 3 6 7 8 9; 3 7 8 9 6; 3 8 6 7 9; 7 3 9 8 6]; 
end

%%
trialIDs = [4];%,4:8];%,11,12,13,14];
distWalk = nan(length(trialIDs),3); %in mm
trialIdx = 1;
for trialID = trialIDs
    rhipx = rawExpData.data{trialID}.markerData.Data(:,contains(rawExpData.data{trialID}.markerData.labels,'RHIPx'));
    rhipy = rawExpData.data{trialID}.markerData.Data(:,contains(rawExpData.data{trialID}.markerData.labels,'RHIPy'));
    lhipx = rawExpData.data{trialID}.markerData.Data(:,contains(rawExpData.data{trialID}.markerData.labels,'LHIPx'));
    lhipy = rawExpData.data{trialID}.markerData.Data(:,contains(rawExpData.data{trialID}.markerData.labels,'LHIPy'));
    hipX = nanmean([rhipx, lhipx],2);
    hipY = nanmean([rhipy, lhipy],2);

    % Plot x and y hip positions
    f1 = figure('units','normalized','outerposition',[0 0 1 1]); 
    plot(hipX)
    hold on;
    plot(hipY);
    legend('X','Y');
    xlabel('Frames (100Hz)');
    ylabel('Hip Positions (mm)');
    %y should go from negative to positive and back, x should go from negative
    %to positive - to negative - slightly positive. They should start moving at
    %roughtly the same time, and when y is changing faster x should be roughly
    %stable, when x is changing faster (moving horizontally/turning), x should
    %change slowly
    
    % compute difference (distance in x and y per frame) and eucledian distance travelled per frame
    xdiff = diff(hipX);
    ydiff = diff(hipY);
    dist = sqrt(xdiff.^2 + ydiff.^2);
    
    % find the frames that participants are moving
    dist = reshape(dist, 1, length(dist)); %make it row vector
    walkMask = dist > 1; %find all cases where distance travelled > 0.5 from btw 2 frames
    thresholdFrames = 150; %if happens continuously for 150 frames: walking
    thresholdFramesMask = ones(1, thresholdFrames);
    % pad 0 to walkMask in case started walking at frame 1, the 2nd argument is the pattern
    % to match, find the index where the previous frame didn't travel > 0.5 and the 
    % next 150 frames travelled > 0.5
    startWalkingFrame = strfind([0,walkMask],[0,thresholdFramesMask])
    %this is the starting index of the [0 1 1 1 ...] pattern, add 1 to start at
    %the frame of 1 instead of the initial 0
    % pad 0 to the end of walkMask in case ended walking at the last frame, 
    % the 2nd argument is the pattern to match, find the index where the last frame didn't travel > 0.5 and the 
    % previous 150 frames travelled > 0.5
    stopWalkingFrame = strfind([walkMask,0],[thresholdFramesMask,0]);
    %this is the starting index of the [1 1 1 ... 0] pattern, add 150-1 (or threshold frame number-1)
    % to locate the last frame of 1 instead of the initial 1 that is 150 frames
    % ahead
    stopWalkingFrame = stopWalkingFrame + thresholdFrames - 1
    % Should find 3 values each
    if length(startWalkingFrame) ~= 3 || length(stopWalkingFrame) ~=3
        warning('The index found is incorrect. Double check to fix it')
    end
    %manual fixes
    if trialID == 4 %ignore the last one
        startWalkingFrame(end) = [] %ignore the last one
        stopWalkingFrame(end-1) = []
% %     elseif trialID == 11
%         startWalkingFrame(end) = []
%         stopWalkingFrame(end-1) = []
%     elseif trialID == 12 || trialID == 13
%         startWalkingFrame(end) = []
%         stopWalkingFrame(end) = []
%     elseif trialID == 14
%         startWalkingFrame(end-1:end) = []
%         stopWalkingFrame(end-1:end) = []
    end

    %plot on top of the x and y mark figure, the start/stop frames
    yrange = ylim;
    for stp = startWalkingFrame
        plot([stp, stp],ylim,'k--')
    end
    for stp = stopWalkingFrame
        plot([stp, stp],ylim,'r--')
    end
    legend('X','Y','Start1','Start2','Start3','Stop1','Stop2','Stop3');
    title(['Trial ' num2str(trialIDs(trialIdx))])

    %plot the distance travelled per frame and start and stop marks.
    f2=figure('units','normalized','outerposition',[0 0 1 1]); 
    plot(dist);
    hold on;
    for stp = startWalkingFrame
        plot([stp, stp],ylim,'k--')
    end
    for stp = stopWalkingFrame
        plot([stp, stp],ylim,'r--')
    end
    plot(xlim,[1 1],'k.-')
    ylabel('EucledianDistance Traveld Per Frame (mm)')
    xlabel('Frame Number (Collected at 100Hz)')
    legend('EucledianDistance','Start1','Start2','Start3','Stop1','Stop2','Stop3');
    title(['Trial ' num2str(trialIDs(trialIdx))])
    
    if saveResAndFigure
%         saveDir = [dataPath 'walkDistFigure\'];
        if ~exist(saveDir,'dir')
            mkdir(saveDir)
        end
        saveas(f1, [saveDir 'XYHipPostPerFrame_Trial' num2str(trialIDs(trialIdx))])
        saveas(f2, [saveDir 'EucledianDistancePerFrame_Trial' num2str(trialIDs(trialIdx))])
    end
    
    %compute distance walked and save into a table
    for idx = 1:length(startWalkingFrame)
        distWalk(trialIdx,idx) = nansum(dist(startWalkingFrame(idx):stopWalkingFrame(idx)))/1000; %in meters
    end
    
    % Populate the walk distance into corresponding task and trial in the DTdata table.
    %1 = stand and alphabet A, 2 = walk and alphabet A, 3 = walk, 4 = stand and
    %alphabet 3 A, 5 = walk and alphabet 3 A; 6 = stand and alphabet B, 7 = walk and alphabet B, 8 = stand and
    %alphabet 3B, 9 = walk and alphabet 3B
    for i = taskOrder(trialIdx)
        curr_seq = all_events(i,:);
        walkTaskIdx = 1;
        for task = curr_seq
            if ismember(task, [1,4,6,8])
                continue
            end
            DTdata.data{DTdataRowNameMap(task),'walkDist'}(trialIdx) = distWalk(trialIdx,walkTaskIdx);
            walkTaskIdx = walkTaskIdx + 1;
        end
    end
    trialIdx = trialIdx + 1;
end
distWalk
% gaitSpeed = distWalk / 20 %in meters/second
% comment = 'Removed start walk time at index 3 and 5, end walk time at index 2 and 5, because there was one frame with no distance in between and in the end there was minor movements';

%% save data
save([dataPath(1:end-10) subjectID 'DistanceWalked'], 'distWalk')
save([dataPath(1:end-10) subjectID 'DTdata.mat'],'DTdata')
%%
% mask = ydiff > 1; %both x and y continuously increase (turning to start)
% thresholdFrames = 150;
% activeThreshold = repmat(1,thresholdFrames,1);
% starts = strfind([0; mask]', [0; activeThreshold]'); %start index: no pattern, then start to show first turn pattern
% mask = ydiff < -1; %x continuously increase, y continuously decrease (approaching the last turn)
% stops = strfind([mask; 0]', [activeThreshold; 0]'); %end index: show the last turn pattern, then stops (end of the last turn)
% buffer = 150; %1.5s, this is not idea maybe another way to find the best cutoff
% startsBuffered = starts - buffer;
% stopsBuffered = stops + buffer;
% %%
% for stp = stops
%     plot([stp, stp],[6000,-4000],'k--')
% end
% for stp = starts
%     plot([stp, stp],[6000,-4000],'r--')
% end
% for stp = stopsBuffered
%     plot([stp, stp],[6000,-4000],'k.-')
% end
% for stp = startsBuffered
%     plot([stp, stp],[6000,-4000],'r.-')
% end
%%
% distWalk = [];
% distWalkBuffered = [];
% for idx = 1:length(starts)
%     distWalk(end+1) = nansum(dist(starts(idx):stops(idx)));
%     distWalkBuffered (end+1) = nansum(dist(startsBuffered(idx):stopsBuffered(idx)));
% end
% distWalk
% distWalkBuffered
%%
% adaptData.plotAvgTimeCourse(adaptData,'stepSpeedFast')