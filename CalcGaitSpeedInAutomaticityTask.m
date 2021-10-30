%This script needs access to the Y drive data
close all; clear all; clc;
subjID = 'ShuqiTest';
dataPath = 'Y:\Shuqi\NirsAutomaticityStudy\Data\TestPilot02\V01Processed\';
subjectID = 'TestPilot02';
load(['Y:\Shuqi\Nirs1VisitTM\' subjID '\' subjID 'Raw'])
%%
trialIDs = [8];
distWalk = nan(length(trialIDs),3); %in mm
for trialID = trialIDs
    rhipx = rawExpData.data{trialID}.markerData.Data(:,contains(rawExpData.data{trialID}.markerData.labels,'RHIPx'));
    rhipy = rawExpData.data{trialID}.markerData.Data(:,contains(rawExpData.data{trialID}.markerData.labels,'RHIPy'));
    lhipx = rawExpData.data{trialID}.markerData.Data(:,contains(rawExpData.data{trialID}.markerData.labels,'LHIPx'));
    lhipy = rawExpData.data{trialID}.markerData.Data(:,contains(rawExpData.data{trialID}.markerData.labels,'LHIPy'));
    hipX = nanmean([rhipx, lhipx],2);
    hipY = nanmean([rhipy, lhipy],2);

    %%
    xdiff = diff(hipX);
    ydiff = diff(hipY);
    dist = sqrt(xdiff.^2 + ydiff.^2);
    figure; plot(dist);

    %%
    figure; 
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

    %%
    dist = reshape(dist, 1, length(dist)); %make it row vector
    walkMask = dist > 0.5; %find all cases where distance travelled > 0.5 from btw 2 frames
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

    %% Plot the finding
    figure(2); %plot on top of the x and y mark figure
    yrange = ylim;
    for stp = startWalkingFrame
        plot([stp, stp],ylim,'k--')
    end
    for stp = stopWalkingFrame
        plot([stp, stp],ylim,'r--')
    end
    legend('X','Y','Start1','Start2','Start3','Stop1','Stop2','Stop3');

    figure(1);
    hold on;
    for stp = startWalkingFrame
        plot([stp, stp],ylim,'k--')
    end
    for stp = stopWalkingFrame
        plot([stp, stp],ylim,'r--')
    end
    plot(xlim,[0.5 0.5],'k.-')
    legend('EucledianDistance','Start1','Start2','Start3','Stop1','Stop2','Stop3');

    %%
    
    for idx = 1:length(startWalkingFrame)
        distWalk(idx) = nansum(dist(startWalkingFrame(idx):stopWalkingFrame(idx)));
    end
end
distWalk = distWalk / 1000 %in meters
% save([dataPath, subjectID, 'distanceWalked'], 'distWalk')
% %%
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