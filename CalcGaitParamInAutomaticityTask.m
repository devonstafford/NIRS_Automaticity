%This script needs access to the Y drive data
subjID = 'ShuqiTest';
load(['Y:\Shuqi\Nirs1VisitTM\' subjID '\' subjID 'Raw'])
%%
trialID = 27;
rhipx = rawExpData.data{trialID}.markerData.Data(:,contains(rawExpData.data{trialID}.markerData.labels,'RHIPx'));
rhipy = rawExpData.data{trialID}.markerData.Data(:,contains(rawExpData.data{trialID}.markerData.labels,'RHIPy'));
lhipx = rawExpData.data{trialID}.markerData.Data(:,contains(rawExpData.data{trialID}.markerData.labels,'LHIPx'));
lhipy = rawExpData.data{trialID}.markerData.Data(:,contains(rawExpData.data{trialID}.markerData.labels,'LHIPy'));
hipX = nanmean([rhipx, lhipx],2);
hipY = nanmean([rhipy, lhipy],2);
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
xdiff = diff(hipX);
ydiff = diff(hipY);
dist = sqrt(xdiff.^2 + ydiff.^2);
%%
mask = ydiff > 1; %both x and y continuously increase (turning to start)
thresholdFrames = 150;
activeThreshold = repmat(1,thresholdFrames,1);
starts = strfind([0; mask]', [0; activeThreshold]'); %start index: no pattern, then start to show first turn pattern
mask = ydiff < -1; %x continuously increase, y continuously decrease (approaching the last turn)
stops = strfind([mask; 0]', [activeThreshold; 0]'); %end index: show the last turn pattern, then stops (end of the last turn)
buffer = 150; %1.5s, this is not idea maybe another way to find the best cutoff
startsBuffered = starts - buffer;
stopsBuffered = stops + buffer;
%%
for stp = stops
    plot([stp, stp],[6000,-4000],'k--')
end
for stp = starts
    plot([stp, stp],[6000,-4000],'r--')
end
for stp = stopsBuffered
    plot([stp, stp],[6000,-4000],'k.-')
end
for stp = startsBuffered
    plot([stp, stp],[6000,-4000],'r.-')
end
%%
distWalk = [];
distWalkBuffered = [];
for idx = 1:length(starts)
    distWalk(end+1) = nansum(dist(starts(idx):stops(idx)));
    distWalkBuffered (end+1) = nansum(dist(startsBuffered(idx):stopsBuffered(idx)));
end
%%
% adaptData.plotAvgTimeCourse(adaptData,'stepSpeedFast')