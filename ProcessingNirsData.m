%% Load data - new
close all; clear all; clc;
raw = load('/Users/mac/Desktop/Lab/SMLLab/Code/NIRS_Automaticity/data/S06V01/S06V01M0102.mat');
%only the 2nd one is valid
raw = raw.raw(2,1);

%% 
stimulusClean = Dictionary();
stimulusClean('Connected1') = raw.stimulus('Connected1');
connectTime = raw.stimulus.values{1,2}.onset;
stimulusClean('Connected2') = nirs.design.StimulusEvents('Connected2',connectTime(1),[1],[1]);
stimulusClean('Connected3') = nirs.design.StimulusEvents('Connected3',connectTime(2),[1],[1]);
stimulusClean('Connected4') = nirs.design.StimulusEvents('Connected4',connectTime(2),[1],[1]);
stimulusClean('Connected5') = raw.stimulus('Connected5');
stimulusClean('Connected6') = raw.stimulus('Connected6');
stimulusClean('Trial_End') = nirs.design.StimulusEvents('Trial_End',raw.stimulus.values{1,5}.onset,1*ones(6,1),1*ones(6,1));
onsettime = [121.100000000000;267.500000000000;391.100000000000;649.400000000000;901.700000000000;1046.80000000000];
stimulusClean('Stand_and_Alphabet_B') = nirs.design.StimulusEvents('Stand_and_Alphabet_B',onsettime,[1;1;1;1;1;1],[1;1;1;1;1;1]);
stimulusClean('Walk') = nirs.design.StimulusEvents('Walk',raw.stimulus.values{1,10}.onset,1*ones(6,1),1*ones(6,1));
stimulusClean('Walk_and_Alphabet_B') = nirs.design.StimulusEvents('Walk_and_Alphabet_B',raw.stimulus.values{1,11}.onset,1*ones(6,1),1*ones(6,1));
stimulusClean('Rest') = raw.stimulus('Rest');

restBeforeWalk = [21.1;208.5;452.1; 669.4;843.9; 1.0669e3];
stimulusClean('RestBeforeWalk') = nirs.design.StimulusEvents('RestBeforeWalk',restBeforeWalk,1*ones(6,1),1*ones(6,1));

restBeforeStandAlphabet = [101.1;247.4;371.1;629.4;881.7;1.0268e3];
stimulusClean('RestBeforeStandAlphabet') = nirs.design.StimulusEvents('RestBeforeStandAlphabet',restBeforeStandAlphabet,1*ones(6,1),1*ones(6,1));

raw.stimulus = stimulusClean;

%% Rename stimulus conditions to avoid space
% idx = [7,8,9,11];
% keys = raw.stimulus.keys;
% keys
% for id = idx
%     key = keys{id};
%     splitkeys = split(key);
%     combinedkey = [splitkeys{1}];
%     for wordidx = 2:length(splitkeys)
%         combinedkey = [combinedkey,'_',splitkeys{wordidx}]
%     end
%     keys{id} = combinedkey;
% end
% 
% keys
% raw.stimulus.keys = keys;
% 
% % correct repeated stimulus with different name
% onsettime = [121.100000000000;267.500000000000;391.100000000000;649.400000000000;901.700000000000;1046.80000000000];
% newevent = nirs.design.StimulusEvents('Stand and AlphabetB',onsettime,[1;1;1;1;1;1],[1;1;1;1;1;1]);
% raw.stimulus('Stand_and_Alphabet_B_New') = newevent;
%% rename stimulus values to avoid space
%% plot the raw data
for i=1:length(raw)
    figure();
    raw(i).draw
end
%% now processing
j=nirs.modules.RemoveStimless;
j=nirs.modules.OpticalDensity(j);
j=nirs.modules.Resample(j);
j=nirs.modules.BeerLambertLaw(j);
Hb=j.run(raw);

for i=1:length(Hb)
    figure();
    Hb(i).draw
end
%% GLM
j=nirs.modules.GLM;
j.goforit=true;
SubjStats=j.run(Hb); %A ChannelStats object, with variables: stimulus x 2(hbo or hbr) x 8 (sources)

%%
SubjStats2=SubjStats.ttest({'Walk_and_Alphabet_B-Walk'
                            'Walk_and_Alphabet_B-Stand_and_Alphabet_B'
                            'Walk-RestBeforeWalk'
                            'Stand_and_Alphabet_B-RestBeforeStandAlphabet'
                            'Walk-Rest'
                            'Stand_and_Alphabet_B-Rest'
                            })
%                         last argument = condition name, if not provided
%                         use the first argument as the default

%% Locate statisitcally significant pairs with q <= 0.05
sigIndex = find(SubjStats2.q <= 0.05);
sigpairs = SubjStats2.variables(sigIndex,:);

%% ROI wise - condense to source or overall
% define some ROIs
% j=nirs.modules.SubjLevelStats;
% SubjStats=j.run(SubjStats);
ROI{1}=table(1,NaN,'VariableNames',{'detector','source'});
ROI{2}=table(2,NaN,'VariableNames',{'detector','source'});
tableByDetector=nirs.util.roiAverage(SubjStats,ROI,{'Det1','Det2'}); %conditions x 4(2dectorx2signal(hbo and hbr))
% hbo = hemoglobin, hbr = deoxy-hemoglobin
table_diff=nirs.util.roiAverage(SubjStats2,ROI,{'Det1','Det2'});

%combined
ROIc=table(NaN,NaN,'VariableNames',{'detector','source'});
tableCombined=nirs.util.roiAverage(SubjStats,ROIc,{'PFC'});   

sigIndex = find(table_diff.q <= 0.05);
sigpairs = table_diff(sigIndex,:);


%% Output channel-wise SubjStats table - Needs demographic data
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
