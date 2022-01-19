function cosAsym = findCosBtwAsymOfEpochs(Data, numLabels, variableNames, summFlag)
% find cosine between the asymmetry between 2 legs of each regressors and transition1 and transition 2.
    if nargin < 3
        variableNames = {'Adapt','WithinContextSwitch','MultiContextSwitch','Trans1','Trans2'}; %default names
    end
    if nargin < 4
        summFlag = 'nanmedian'; %default summarize with median
    end
    eval(['fun=@(x) ' summFlag '(x,4);']);
    for i = 1:numel(Data)
        Data{i} = fun(Data{i});
    end
    AEScalar(i,1) = norm(fun(Data{3}));
    asymData = Data;
    %top half is the asymmetry data
    asym_trans1 = asymData{4}(:,1:numLabels/2);
    asym_trans1 = reshape(asym_trans1, [],1); %make it a column vector
    
    if (length(asymData) == 5)
        asym_trans2 = asymData{5}(:,1:numLabels/2);
        asym_trans2 = reshape(asym_trans2, [],1); %make it a column vector
        cosAsym = nan(2,3);
    else
        cosAsym = nan(1,3);
    end
    colName = cell(1,3);
    for i = 1:3
        currAsym = reshape(asymData{i}(:,1:numLabels/2), [],1);
        cosAsym (1,i) = cosine(currAsym, asym_trans1);
        if (length(asymData) == 5)
            cosAsym (2,i) = cosine(currAsym, asym_trans2);
        end
        colName{i} = ['CosWith' variableNames{i}];
    end
    
    cosAsym = array2table(cosAsym);
    cosAsym.Properties.VariableNames = colName;
    cosAsym.Properties.RowNames = variableNames(:,4:end);
end