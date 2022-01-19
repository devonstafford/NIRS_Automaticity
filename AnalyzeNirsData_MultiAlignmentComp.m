%% Load data - new
close all; clear all; clc;
scriptDir = fileparts(matlab.desktop.editor.getActiveFilename); 
% raw = nirs.core.Data.empty;
% raw(2) = data.raw; %can simply add in this way
[dataPath, ~, ~, subjectID, ~] = setupDataPath('AUF03', 'V04', 'NIRS', 'NIRS');

saveResAndFigure = false;
data = load([dataPath subjectID 'NirsStimulusCleaned.mat']);
raw = data.raw;

%% plot the raw data
for i=1:length(raw)
    f1 = figure('units','normalized','outerposition',[0 0 1 1]);
    raw(i).draw
    if saveResAndFigure
        saveas(f1, [dataPath subjectID 'RawSignalTrial' num2str(i) '.png'])
        saveas(f1, [dataPath subjectID 'RawSignalTrial' num2str(i) '.fig'])
    end
end

%% load alignment version 
for version = 1:6
load(['\\TORRES-PRC.bioe.pitt.edu\Users\Shuqi\NirsAutomaticityStudy\Data\AUF01\V01\V01NIRSRecoveryAttempt1\NoRestAUF01NirsStimulusAlignmentV' num2str(version) '.mat'])

%% now processing
j=nirs.modules.RemoveStimless;
j=nirs.modules.OpticalDensity(j);
j=nirs.modules.Resample(j);
j=nirs.modules.BeerLambertLaw(j);
Hb=j.run(raw);

close all;
for i=1:length(Hb)
    f2 = figure('units','normalized','outerposition',[0 0 1 1]);
    Hb(i).draw
    if saveResAndFigure
        saveas(f2, [dataPath subjectID 'HboSignalTrial' num2str(i) '.png'])
        saveas(f2, [dataPath subjectID 'HboSignalTrial' num2str(i) '.fig'])
    end
end

%% GLM
j=nirs.modules.GLM;
j.goforit=true;
SubjStats=j.run(Hb); %A ChannelStats object, with variables: stimulus x 2(hbo or hbr) x 8 (sources)

%% compare each active condition against baseline + compare walk with alphabet vs walk alone
SubjStatsVsBaseline=SubjStats.ttest({'walk-Rest_Before_Walk'
                            'standAndAlphabet2-Rest_Before_Stand_And_Alphabet'
                            'walkAndAlphabet2-Rest_Before_Walk_And_Alphabet'
                            'standAndAlphabet3-Rest_Before_Stand_And_Alphabet_3'
                            'walkAndAlphabet3-Rest_Before_Walk_And_Alphabet_3'
                            })
%                         last argument = condition name, if not provided
%                         use the first argument as the default

SubjStatsDTVsST=SubjStats.ttest({'walkAndAlphabet2-standAndAlphabet2'
                            'walkAndAlphabet3-standAndAlphabet3'
                            'walkAndAlphabet2-walk'
                            'walkAndAlphabet3-walk'
                            })


%%
statsv = struct();
statsv.subjstats = SubjStats;
statsv.subjStatsDTvsST = SubjStatsDTVsST;
statsv.subjStatsVsBaseline = SubjStatsVsBaseline;
eval(['statsv' num2str(version) '=statsv'])
end
%% ROI wise - condense to by detector (left/right) or overall PFC
% define some ROIs
ROI{1}=table(1,NaN,'VariableNames',{'detector','source'});
ROI{2}=table(2,NaN,'VariableNames',{'detector','source'});
tableByDetectorRaw=nirs.util.roiAverage(SubjStats,ROI,{'Det1','Det2'}); %conditions x 4(2dectorx2signal(hbo and hbr))
ROIc=table(NaN,NaN,'VariableNames',{'detector','source'});
tablePFCRaw=nirs.util.roiAverage(SubjStats,ROIc,{'PFC'});  

% hbo = hemoglobin, hbr = deoxy-hemoglobin
tableByDetector_VsBaseline=nirs.util.roiAverage(SubjStatsVsBaseline,ROI,{'Det1','Det2'});
% Locate statisitcally significant pairs with q <= 0.05
sigIndexDetector_VsBaseline = tableByDetector_VsBaseline.q <= 0.05;
sigpairsDetector_VsBaseline = tableByDetector_VsBaseline(sigIndexDetector_VsBaseline,:);

%combined
tablePFC_VsBaseline=nirs.util.roiAverage(SubjStatsVsBaseline,ROIc,{'PFC'});  
sigIndexPFC_VsBaseline = tablePFC_VsBaseline.q <= 0.05;
sigpairsPFC_VsBaseline = tablePFC_VsBaseline(sigIndexPFC_VsBaseline,:);

%DT vs ST
tableByDetector_DTvsST=nirs.util.roiAverage(SubjStatsDTVsST,ROI,{'Det1','Det2'});
sigIndexDetector_DTvsST = find(tableByDetector_DTvsST.q <= 0.05);
sigpairsDetector_DTvsST = tableByDetector_DTvsST(sigIndexDetector_DTvsST,:);

%combined
tablePFC_DTvsST=nirs.util.roiAverage(SubjStatsDTVsST,ROIc,{'PFC'});  
sigIndexPFC_DTvsST = find(tablePFC_DTvsST.q <= 0.05);
sigpairsPFC_DTvsST = tablePFC_DTvsST(sigIndexPFC_DTvsST,:);

if saveResAndFigure
    save([dataPath subjectID 'OutcomeMeasures'], 'SubjStats','SubjStatsVsBaseline','SubjStatsDTVsST',...
        'tableByDetectorRaw','tablePFCRaw','tableByDetector_VsBaseline',...
        'sigIndexDetector_VsBaseline','sigpairsDetector_VsBaseline','tablePFC_VsBaseline','sigIndexPFC_VsBaseline','sigpairsPFC_VsBaseline',...
        'tablePFC_VsBaseline','sigIndexDetector_DTvsST','sigpairsDetector_DTvsST','tablePFC_DTvsST','sigIndexPFC_DTvsST','sigpairsPFC_DTvsST');
end

%% Draw the stats
SubjStatsVsBaseline(1).draw
SubjStatsDTVsST(1).draw

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
