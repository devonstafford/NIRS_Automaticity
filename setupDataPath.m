function [datapath, datapathspliter, resultPath, subjectID, visitNum] = setupDataPath(subjectID, visitNumStr, loadPathSuffix, savePathSuffix)
    %%
    % Set up the path to load the data based on subject ID and visit num,
    % use appropriate root directory and slashes for windows (\, and Y drive)
    % and mac (/, and Volumes/users or research)
    % environment. 
    % 
    % Arguments:
    %    - intervention: string of the subject ID, e.g., 'AUF01'
    %    - visitNumStr: string representation of the visit number, in format:
    %                   'V01'
    %    - loadPathSuffix: string keywords for the specific directory to load data
    %                    if not provided or empty, will have load data
    %                    path as:
    %                    X:\Shuqi\NirsAutomaticityStudy\Data\AUF01\V01
    %    - savePathSuffix: string keywords for the specific directory to
    %                    save data, if not provided or empty, will save to:
    %                    X:\Shuqi\NirsAutomaticityStudy\Data\SubjectID\visitNum\Results\
    % Returns:
    %    - datapath: the proper path where the params file, DTdata and raw files are stored
    %                depends on the environoment
    %    - datapathspliter: a single character, \ for windows and / for mac
    %    - resultPath: result saving directory
    %    - subjectID: full subject ID string including the visit number,
    %    i.d., AUF01V01
    %    - visitNum: integer representing the visit number, 1 through 4

    datapath = ['X:\Shuqi\NirsAutomaticityStudy\Data\' subjectID '\' visitNumStr '\'];
    resultPath = [datapath 'Results\'];

    if nargin>=3 && ~isempty(loadPathSuffix)
        datapath = [datapath loadPathSuffix '\'];
    end
    
    if nargin==4 && ~isempty(savePathSuffix)
        resultPath = [resultPath savePathSuffix '\'];
    end

    scriptDir = fileparts(matlab.desktop.editor.getActiveFilename); 
    datapathspliter = '\';
    if contains(scriptDir, '/') %mac enviroment, replace \ with /
        datapath = replace(datapath,"\","/");
        datapath = replace(datapath,'X:','/Volumes/Research');
        resultPath = replace(resultPath,"\","/");
        resultPath = replace(resultPath,'X:','/Volumes/Research');
        datapathspliter = '/';
    end
    subjectID = [subjectID visitNumStr];
    visitNum = str2double(visitNumStr(3));
end