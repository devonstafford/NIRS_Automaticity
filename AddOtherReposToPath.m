restoredefaultpath
scriptDir = fileparts(matlab.desktop.editor.getActiveFilename); 
rootDir = scriptDir(1:end-48); %parse out common root that leads to one drive folder
dirToAdd = {};
%set up path using \ like windows env
dirToAdd{end+1} = [rootDir 'Documents\GitHub\labTools'];
dirToAdd{end+1} = [rootDir 'Documents\MATLAB\btk'];
dirToAdd{end+1} = [rootDir 'Documents\MATLAB\pi-tools-master'];
dirToAdd{end+1} = [rootDir '\Documents\GitHub\LongAdaptation'];
%add nirs-toolbox and subfolders to the search path
% dirToAdd{end+1} = [rootDir 'SML\Projects\fNIR Project\Code_NIRS_Automaticity\nirs-toolbox'];
% dirToAdd{end+1} = [rootDir 'SML\Projects\fNIR Project\Code_NIRS_Automaticity'];

if contains(rootDir, '/') %mac enviroment, replace \ with /
    dirToAdd = replace(dirToAdd,"\","/");
end
for i = 1:length(dirToAdd)
    addpath(genpath(dirToAdd{i}))
end
