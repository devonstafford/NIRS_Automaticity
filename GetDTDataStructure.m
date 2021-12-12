%% create data structure to store the DT data
function [DTdata, DTdataRowNameMap] = GetDTDataStructure(dataPath)
if exist(dataPath,'file') %exist one already load
    fprintf('\nDT data exists. Load: %s\n\n', dataPath);
    DTdata = load(dataPath);
    DTdata = DTdata.DTdata;
else %DN exist, create an empty one
    fprintf('\nDT data not found. Creating an empty one\n\n');
    DTdata = struct();
    DTdata.startingAlphabet = '';
    dataField = {nan(1,6),cell(1,6),nan(1,6),nan(1,6),nan(1,6),nan(1,6)}; %each array contains data for all 6 trials.
    dataField = repmat(dataField,5,1); %repeat 5 times for 5 active conditions
    %conditions in the row, outcome variables in the column, each cell contains an array or 
    % cell of data across all trials
    dataField = cell2table(dataField); 
    dataField.Properties.VariableNames = {'alphabetCount','alphabetGenerated','alphabetRate','walkDist','walkSpeed','trialTime'};
    dataField.Properties.RowNames =  {'standAndAlphabet2','walkAndAlphabet2','standAndAlphabet3','walkAndAlphabet3','walk'};
    DTdata.data = dataField;
end
%1 = stand and alphabet A, 2 = walk and alphabet A, 3 = walk, 4 = stand and
%alphabet 3 A, 5 = walk and alphabet 3 A; 6 = stand and alphabet B, 7 = walk and alphabet B, 8 = stand and
%alphabet 3B, 9 = walk and alphabet 3B
keyset = 1:9; %create num to string mapping to populate table column names
valueset = {'standAndAlphabet2','walkAndAlphabet2','walk','standAndAlphabet3','walkAndAlphabet3','standAndAlphabet2','walkAndAlphabet2','standAndAlphabet3','walkAndAlphabet3'};
DTdataRowNameMap = containers.Map (keyset, valueset);