%% Load data - new
close all; clear all; clc;
scriptDir = fileparts(matlab.desktop.editor.getActiveFilename); 
raw={};
raw = nirs.core.Data.empty;
dataPath = [scriptDir '/Data/S08/V01Nirs/'];
saveResAndFigures = false;
% data1 = load([scriptDir 'Data/S06/V01/NIRS/S06V01M0102CleanV2.mat']);
data2 = load([dataPath 'S08V01M01Clean.mat']);
raw(1) = data2.raw;

%% plot the raw data
for i=1:length(raw)
    f1 = figure();
    raw(i).draw
end

if saveResAndFigure
    saveas(f1, [dataPath 'RawSignal.png'])
    saveas(f1, [dataPath 'RawSignal.fig'])
end

%% now processing
j=nirs.modules.RemoveStimless;
j=nirs.modules.OpticalDensity(j);
j=nirs.modules.Resample(j);
j=nirs.modules.BeerLambertLaw(j);
Hb=j.run(raw);

for i=1:length(Hb)
    f2 = figure();
    Hb(i).draw
end
if saveResAndFigure
    saveas(f2, [dataPath 'HboSignal.png'])
    saveas(f2, [dataPath 'HboSignal.fig'])
end

%% GLM
j=nirs.modules.GLM;
j.goforit=true;
SubjStats=j.run(Hb); %A ChannelStats object, with variables: stimulus x 2(hbo or hbr) x 8 (sources)

%% compare each active condition against baseline + compare walk with alphabet vs walk alone
SubjStatsVsBaseline=SubjStats.ttest({'Walk_and_Alphabet_B-RestBeforeWalk'
                            'Walk-RestBeforeWalk'
                            'Stand_and_Alphabet_B-RestBeforeStandAlphabet'
                            'Walk_and_Alphabet_B-Walk'
                            })
%                         last argument = condition name, if not provided
%                         use the first argument as the default

%% Locate statisitcally significant pairs with q <= 0.05
sigIndex = find(SubjStatsVsBaseline.q <= 0.05);
sigpairs = SubjStatsVsBaseline.variables(sigIndex,:);

%% ROI wise - condense to by detector (left/right) or overall PFC
% define some ROIs
% j=nirs.modules.SubjLevelStats;
% SubjStats=j.run(SubjStats);
ROI{1}=table(1,NaN,'VariableNames',{'detector','source'});
ROI{2}=table(2,NaN,'VariableNames',{'detector','source'});
tableByDetector=nirs.util.roiAverage(SubjStats,ROI,{'Det1','Det2'}); %conditions x 4(2dectorx2signal(hbo and hbr))
% hbo = hemoglobin, hbr = deoxy-hemoglobin
tableByDetector_VsBaseline=nirs.util.roiAverage(SubjStatsVsBaseline,ROI,{'Det1','Det2'});

%combined
ROIc=table(NaN,NaN,'VariableNames',{'detector','source'});
tablePFC=nirs.util.roiAverage(SubjStats,ROIc,{'PFC'});  
tablePFC_VsBaseline=nirs.util.roiAverage(SubjStatsVsBaseline,ROIc,{'PFC'});  

sigIndex = find(tableByDetector_VsBaseline.q <= 0.05);
sigpairs = tableByDetector_VsBaseline(sigIndex,:);

if saveResAndFigure
    save([dataPath 'OutcomeMeasures'], 'tableByDetector','tableByDetector_VsBaseline','tablePFC','tablePFC_VsBaseline');
end

%% Output channel-wise SubjStats table - Needs demographic data
% TODO: how to proceed from here
j=nirs.modules.SubjLevelStats;
SubjStats3=j.run(SubjStats);
SubjStats4=j.run(SubjStats2);

%% 
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
