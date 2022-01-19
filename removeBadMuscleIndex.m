function newLabelPrefix = removeBadMuscleIndex(badMuscleNames,newLabelPrefix, removeSymmetric)
% Find the index of the bad muscles with the given name and remove it from
% the label prefixes. 
% 
% ------- Arguments --------
% - badMuscleNames: a cell array of the bad muscle names, need to contain the
% f/s leg and the s suffix, o.w. the code won't be able to find the names
% legit names example: sPERs, fSEMTs
% 
% - newLabelPrefix: the current cell array of the label prefix that will
% later be used to find EMG data to plot
% 
% - removeSymmetric (optional): boolean flag to indicate if the removal should also
% find the symmetric labels (corresponding muscle on the other leg) and
% remove them. Default false.
% 
% ------- Returns ---------
% - newLabelPrefix: the modified cell array of new label prefix with bad
% muscles removed
% 
    if nargin<3 %default false
        removeSymmetric = false;
    end
    
    if removeSymmetric
        symmetricBadMuscleNames = badMuscleNames;
        for b = badMuscleNames
            if b{1}(1) == 'f'
                newName = ['s', b{1}(2:end)];
            else
                newName = ['f', b{1}(2:end)];
            end
            if ~ismember(symmetricBadMuscleNames,newName)
                symmetricBadMuscleNames{end+1} = newName;
            end
        end
        badMuscleNames = symmetricBadMuscleNames;
    end
    
    if ~isempty(badMuscleNames) %check if badMuscleNames is defined, if so update the labels list.
        badMuscleIdx=[];
        for bm = badMuscleNames
            badMuscleIdx = [badMuscleIdx, find(ismember(newLabelPrefix,bm))];
        end
        newLabelPrefix = newLabelPrefix(setdiff(1:end, badMuscleIdx))
    else
        fprintf('\nNo muscle removed from labels\n');
    end
end