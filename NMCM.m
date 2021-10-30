clear 
cd '/Users/neminchen/Box/ebrain/fNIRS/NMCM/Datasets'
folder = '/Users/neminchen/Box/Rosso Study Files/NMCM Study/NMCM Data/NIRS Accelerometry GaitMat Files';
xlfile='/Users/neminchen/Box/Rosso Study Files/NMCM Study/NMCM Data/Excel Data for NMCM/Final Data Set/Mobility Final Data Set for NMCM.xlsx';

folder = '/Users/mac/OneDrive - University of Pittsburgh/SML/Projects/fNIR Project/Code_NIRS_Automaticity/Data/002nirsdata'

%% load the data
folder = '/Users/mac/Desktop/Lab/SMLLab/Code/NIRS_Automaticity/data/002nirsdata';
raw = nirs.io.loadDirectory(folder,{'subject'});

rawt = fix_Andi_data_N(raw,xlfile);

nirs.createDemographicsTable(rawt)
nirs.createStimulusTable(rawt)

for i=1:length(rawt);
    rawt(i).draw
    figure();
end;

%% now processing
%% 
j=nirs.modules.RemoveStimless;
j=nirs.modules.OpticalDensity(j);
j=nirs.modules.Resample(j);
j=nirs.modules.BeerLambertLaw(j);
Hb=j.run(rawt);

for i=1:length(Hb);
   Hb(i).draw
   figure();
end;

%% GLM
j=nirs.modules.GLM;
j.goforit=true;
SubjStats=j.run(Hb);
% active vs rest comparison 
SubjStats=SubjStats.ttest({'Even-Rest_Even'
                           'Even_ABC-Rest_Even_ABC'
                           'Uneven-Rest_Uneven'
                           'Uneven_ABC-Rest_Uneven_ABC'
                           'Standing_ABC-Rest_Standing_ABC'},[],...
                           {'Even','Even_ABC','Uneven','Uneven_ABC','Standing_ABC'});
% among active/walking conditions comparison                        
SubjStats2=SubjStats.ttest({'Uneven-Even'
                            'Even_ABC-Even'
                            'Uneven_ABC-Even'}, [], ...
                            {'Uneven-Even', 'Even_ABC-Even', 'Uneven_ABC-Even'});
 
%% exclude flagging data
%022 (1) T1 even_ABC
height(SubjStats(81).variables)
for i=1:height(SubjStats(81).variables);
  if isequal(SubjStats(81).variables.cond(i),{'Even_ABC'});
  SubjStats(81).variables{i,4}={''}; 
  %SubjStats(81).tstat(i)=missing;
  %SubjStats(81).p(i)=missing;
  %SubjStats(81).q(i)=missing;
  %disp(['SubjStats' num2str(i) 'is flagged'])
  end;
end;
%  (2) T1 even_ABC-even
for i=1:height(SubjStats2(81).variables);
  if isequal(SubjStats2(81).variables.cond(i), {'Even_ABC-Even'});
      SubjStats2(81).variables{i, 4}={''};
  end;
end;                  
%024 T1 standing_ABC2 ?
for i=1:height(SubjStats(89).variables);
  if isequal(SubjStats(89).variables.cond(i),{'Standing_ABC'});
  SubjStats(89).variables.cond(i)={''};  
  end; 
end;
%027 T1 standing_ABC 1,2
for i=1:height(SubjStats(97).variables);
    if isequal(SubjStats(97).variables.cond(i),{'Standing_ABC'});
    SubjStats(97).variables.cond(i)={''};    
    end;
end;
%028 T1 standing_ABC2 ?
for i=1:height(SubjStats(101).variables);
    if isequal(SubjStats(101).variables.cond(i),{'Standing_ABC'});
    SubjStats(101).variables.cond(i)={''};    
    end;
end;
%022 T2 standing_ABC2
for i=1:height(SubjStats(82).variables);
    if isequal(SubjStats(82).variables.cond(i),{'Standing_ABC'});
    SubjStats(82).variables.cond(i)={''};    
    end;
end;
%027 (1) T4 even_ABC
for i=1:height(SubjStats(100).variables);
    if isequal(SubjStats(100).variables.cond(i),{'Even_ABC'});
    SubjStats(100).variables.cond(i)={''};    
    end;
end;
     %(2) even_ABC-even
for i=1:height(SubjStats2(100).variables);
    if isequal(SubjStats2(100).variables.cond(i),{'Even_ABC-Even'});
    SubjStats2(100).variables.cond(i)={''};
    end;
end;
%% Output channel-wise SubjStats table
j=nirs.modules.SubjLevelStats;
SubjStats=j.run(SubjStats);
SubjStats2=j.run(SubjStats2);
%for i=1:length(SubjStats);
%    SubjStats(i).draw
%    figure()
%end;
%SubjStatsDiff=SubjStats.ttest({     'Uneven-Even' 
%                                    'Even_ABC-Even'
%                                    'Even_ABC-Standing_ABC' 
%                                    'Uneven_ABC-Even'
%                                    'Uneven_ABC-Standing_ABC'},[],...
%                                    {'Ctrast1','Ctrast2','Ctrast3','Ctrast4','Ctrast5'});

SubjStatstable=[];
for i=1:length(SubjStats);
  SubjStatstable=vertcat(SubjStatstable, SubjStats(i).table);
end;
SubjStatstable=rmmissing(SubjStatstable, 'DataVariables', {'cond'});
nirs.createDemographicsTable(SubjStats).subject;
id=[1:29]';
Subjid=array2table(repelem(id,80),'VariableNames',{'Subjid'});
SubjStatstable=[Subjid SubjStatstable];
writetable(SubjStatstable,'SubjStats_channelw.xls','sheet',1);

SubjStatstable2=[];
for i=1:length(SubjStats2);
    SubjStatstable2=vertcat(SubjStatstable2, SubjStats2(i).table);
end;
SubjStatstable2=rmmissing(SubjStatstable2, 'DataVariables', {'cond'});
id=nirs.createDemographicsTable(SubjStats2).subject;
Subjid=array2table(repelem(id, 48), 'VariableNames', {'Subjid'});
SubjStatstable2=[Subjid SubjStatstable2];
writetable(SubjStatstable2, 'SubjStatsdiff_channelw.csv');
                                
%% Group based model-- without adjustment
j=nirs.modules.MixedEffects;
j.formula='beta ~ -1 + cond + (1|subject)';
GroupStats= j.run(SubjStats);

GroupStats.draw('tstat',[],'q<0.05')


%% ROI wise
% define some ROIs
j=nirs.modules.SubjLevelStats;
SubjStats=j.run(SubjStats);
ROI{1}=table(1,NaN,'VariableNames',{'detector','source'});
ROI{2}=table(2,NaN,'VariableNames',{'detector','source'});
%nirs.util.roiAverage(GroupStats,ROI,{'Det1','Det2'})
table1=nirs.util.roiAverage(SubjStats,ROI,{'Det1','Det2'});

table1=rmmissing(table1, 'DataVariables', {'Contrast'});
writetable(table1,'SubjStats_ROIw.xlsx','sheet',1);

table_diff=nirs.util.roiAverage(SubjStatsDiff,ROI,{'Det1','Det2'});
writetable(table_diff,'SubjStatsDiff.xls','sheet',1);

%combined
ROIc=table(NaN,NaN,'VariableNames',{'detector','source'});
table2=nirs.util.roiAverage(SubjStats,ROIc,{'PFC'});
writetable(table2,'SubjStatsc.xls','sheet',1);      

%performance variables
speed=getspeed(xlfile);
writetable(speed,'speed.xls','sheet',1);

%% ROI wise 2
% define some ROIs
j=nirs.modules.SubjLevelStats;
SubjStats=j.run(SubjStats);
ROI{1}=table(1,NaN,'VariableNames',{'detector','source'});
ROI{2}=table(2,NaN,'VariableNames',{'detector','source'});
%nirs.util.roiAverage(GroupStats,ROI,{'Det1','Det2'})
table1=nirs.util.roiAverage(SubjStats,ROI,{'Det1','Det2'});

table1=rmmissing(table1, 'DataVariables', {'Contrast'});
writetable(table1,'SubjStats_ROIw.xlsx','sheet',1);

%% add demographic data
nirs.createDemographicsTable(raw)

demo = readtable('NMCM demo.xlsx');


job = nirs.modules.AddDemographics;
job.demoTable=demo;
SubjStats = job.run(SubjStats);

%% Group based models--adjusting for demographics
job = nirs.modules.SubjLevelStats;
SubjStats=job.run(SubjStats);

job = nirs.modules.MixedEffects;
job.formula='beta ~ -1 + cond + cond:Age + Sex +(1|subject)';
G=job.run(SubjStats);

G.draw('tstat',[],'q<0.05')


%% Load GUI
nirs.viz.nirsviewer;
