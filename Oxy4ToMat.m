%% load data and conver to mat file
close all; clear all; clc;
scriptDir = fileparts(matlab.desktop.editor.getActiveFilename); 
subjectFolderName = 'S07_Mackenzie';
visitNumber = 'V02';
raw = nirs.io.loadDirectory([scriptDir '\Data\' subjectFolderName '\' visitNumber], {'subject'})

%% plot to visualize the data and stimulus encoding
for i=1:length(raw)
    figure();
    raw(i).draw
end
%% save the converted data
if length(raw) == 1 %if only one file save as the same name but as .mat
    save([raw.description(1:end-5)], 'raw')
else %if has more than 1 oxy4 files, save as the overall subjectIDVisitNumber, e.g. S01V01.mat
    save([scriptDir '\Data\' subjectFolderName '\' visitNumber '\' subjectFolderName visitNumber], 'raw')
end