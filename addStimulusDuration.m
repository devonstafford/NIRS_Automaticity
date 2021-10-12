function addStimulusDuration(raw, startingLetter, savePath)
    % find event strings in this dataset
    dataEventStrings=cell(1,length(raw.stimulus.values));
    for i = 1:length(raw.stimulus.values)
        dataEventStrings{i} = raw.stimulus.values{i}.name;
    end
    if length(unique(dataEventStrings)) ~= length(dataEventStrings)
        warning('Repeated event key identified. Needs to be taken care of.')
    end
    eventStrings = {'LastRest','Rest_Before_Stand_And_Alphabet','Rest_Before_Walk',...
        'Rest_Before_Walk_And_Alphabet','Stand_and_Alphabet','Walk','Walk_and_Alphabet'};

    eventStringWithAlphabet = eventStrings;
    eventStringWithAlphabet{5} = [eventStringWithAlphabet{5} '_' startingLetter];
    eventStringWithAlphabet{7} = [eventStringWithAlphabet{7} '_' startingLetter];

    allTimeLabels = [];
    allTime = [];
    for i = 1:length(eventStringWithAlphabet)
        stimulus = raw.stimulus.values{strcmp(dataEventStrings,eventStringWithAlphabet{i})};
        allTime = [allTime;stimulus.onset];
        allTimeLabels = [allTimeLabels, sprintfc([eventStrings{i} '%d'],1:6)];
        if length(stimulus.onset) ~= 6
            warning(['Conditions are missing. Expected 6 iterations per condition. Only got ',length(stimulus.onset)])
        end
    end

    [allTimeSorted,sortIndex] = sort(allTime);
    sortedLabels = allTimeLabels(sortIndex);

    % create the cleaned stimulus
    stimulusClean = Dictionary();
    for es = eventStrings(2:end)
        es_string = es{1}; % get the string out of the 1x1 cell
        idx = find(~cellfun(@isempty,regexp(sortedLabels,['^' es_string '[0-9]'])));
        eventDuration = [];
        currLabel = sortedLabels{idx(1)};
        currLabelIndexInTimeList = find(strcmp(eventStrings,currLabel(1:end-1)));
        currEventTimeList = allTime(currLabelIndexInTimeList*6-5:currLabelIndexInTimeList*6);
        for i = 1:length(idx)
            currLabel = sortedLabels{idx(i)};
            nextLabel = sortedLabels{idx(i)+1}; 
            nextLabelIndexInTimeList = find(strcmp(eventStrings,nextLabel(1:end-1)));
            nextEventTimeList = allTime(nextLabelIndexInTimeList*6-5:nextLabelIndexInTimeList*6);
            eventDuration = [eventDuration; nextEventTimeList(str2num(nextLabel(end))) - currEventTimeList(str2num(currLabel(end)))];
        end    
        stimulusClean(es_string) = nirs.design.StimulusEvents(es_string,currEventTimeList,eventDuration,[1;1;1;1;1;1]);
    end
    raw.stimulus = stimulusClean;
    
    figure();
    raw.draw
    
    if ~isempty(savePath)
        save([savePath, '.mat'], 'raw');
        disp(['The cleaned data is saved at ' savePath, '.mat']);
    end
end