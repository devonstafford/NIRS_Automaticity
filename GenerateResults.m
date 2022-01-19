%this is only applicable if we are running 1 subject at a time or running
%group only
fileNameToRun = 'EMGDataAnalysis';
resFile = publish([fileNameToRun '.m']); 
resDir'

%%
eval(['movefile html ' resDir{end}])
if plotGroup
    renameStatement = ['movefile ' resDir{end} 'html\' fileNameToRun '.html ' resDir{end} 'html\' groupID 'PrintOut.html'];
else
    renameStatement = ['movefile ' resDir{end} 'html\' fileNameToRun '.html ' resDir{end} 'html\' subjectID{1} 'PrintOut.html'];
end
scriptDir = fileparts(matlab.desktop.editor.getActiveFilename); 
if contains(scriptDir, '/') %mac enviroment, replace \ with /
    renameStatement = replace(renameStatement,"\","/");
end
eval(renameStatement)
