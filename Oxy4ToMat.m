%% load data and conver to mat file
close all; clear all; clc;
scriptDir = fileparts(matlab.desktop.editor.getActiveFilename); 
%add nirs-toolbox and subfolders to the search path
addpath(genpath([scriptDir '\nirs-toolbox']))

%provide the folder where the .oxy4 files are located
dataPath = 'Y:\Shuqi\Nirs1VisitTM\ShuqiTest\Nirs';
subjectID = 'ShuqiTest';
% subjectFolderName = [scriptDir '\Data\' 'S07_Mackenzie\V02'];
%%
raw = nirs.io.loadDirectory(dataPath, {'subject'})
%% plot to visualize the data and stimulus encoding
for i=1:length(raw)
    figure();
    raw(i).draw
end
%% save the converted data
% if length(raw) == 1 %if only one file save as the same name but as .mat
%     save([raw.description(1:end-5)], 'raw')
% else %if has more than 1 oxy4 files, save as the overall subjectIDVisitNumber, e.g. S01V01.mat
%     save([scriptDir '\Data\' subjectFolderName '\' visitNumber '\' subjectFolderName visitNumber], 'raw')
% end
save([dataPath '\' subjectID 'NirsRaw'],'raw')