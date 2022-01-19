function raw = addStimulusDuration(raw, startingLetter, iterations)
    % find event strings in this dataset
    dataEventStrings=cell(1,length(raw.stimulus.values));
    for i = 1:length(raw.stimulus.values)
        dataEventStrings{i} = raw.stimulus.values{i}.name;
    end
    if length(unique(dataEventStrings)) ~= length(dataEventStrings)
        warning('Repeated event key identified. Needs to be taken care of.')
    end
    eventStrings = {'LastRest','Rest_Before_Stand_And_Alphabet','Rest_Before_Stand_And_Alphabet_3','Rest_Before_Walk',...
        'Rest_Before_Walk_And_Alphabet','Rest_Before_Walk_And_Alphabet_3','standAnd','walk','walkAnd','standAndEvery3','walkAndEvery3'};

    eventStringWithAlphabet = eventStrings;
    for idx = [2,5]
        eventStringWithAlphabet{idx} = [eventStringWithAlphabet{idx} '_' startingLetter];
    end
    for idx = [3,6,7,9,10,11]
        eventStringWithAlphabet{idx} = [eventStringWithAlphabet{idx} startingLetter];
    end
    
    allTimeLabels = [];
    allTime = [];
    for i = 1:length(eventStringWithAlphabet)
        stimulus = raw.stimulus(eventStringWithAlphabet{i});
        allTime = [allTime;stimulus.onset];
        allTimeLabels = [allTimeLabels, sprintfc([eventStrings{i} '%d'],1:iterations)];
        if length(stimulus.onset) ~= iterations
            warning(['Conditions are missing. Expected ', num2str(iterations) ,' iterations per condition. Got ',num2str(length(stimulus.onset)) ' for stimulus: ' stimulus.name])
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
        currEventTimeList = allTime(currLabelIndexInTimeList*iterations-iterations+1:currLabelIndexInTimeList*iterations);
        for i = 1:length(idx)
            currLabel = sortedLabels{idx(i)};
            nextLabel = sortedLabels{idx(i)+1}; 
            nextLabelIndexInTimeList = find(strcmp(eventStrings,nextLabel(1:end-1)));
            nextEventTimeList = allTime(nextLabelIndexInTimeList*iterations-iterations+1:nextLabelIndexInTimeList*iterations);
            eventDuration = [eventDuration; nextEventTimeList(str2num(nextLabel(end))) - currEventTimeList(str2num(currLabel(end)))];
        end 
        if (strcmp(es_string,'walkAnd'))
            es_string = 'walkAndAlphabet2';
        elseif (strcmp(es_string,'standAnd'))
            es_string = 'standAndAlphabet2';
        elseif (strcmp(es_string,'standAndEvery3'))
            es_string = 'standAndAlphabet3';
        elseif (strcmp(es_string,'walkAndEvery3'))
            es_string = 'walkAndAlphabet3';
        end
        stimulusClean(es_string) = nirs.design.StimulusEvents(es_string,currEventTimeList,eventDuration,[1;1;1;1;1;1]);
    end
    raw.stimulus = stimulusClean;
end