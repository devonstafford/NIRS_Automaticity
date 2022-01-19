%% Compare V04-V01
close all; clearvars; clc;
saveResAndFigure = true;
dataIsGroupEMG = true;
subjectID = '2Sub';
%get the proper splitter(\ or / and generic path), the visit num here won't
%be used, provided for the fcn to run properly
[datapath, splitter, ~, ~, ~] = setupDataPath(subjectID, 'V01', '', ''); 
if dataIsGroupEMG
    datapath = datapath(1:end-(5+length(subjectID))); %remove the visit number
    datapath = [datapath 'GroupResults' splitter 'Group2Sub' splitter]
else
    datapath = datapath(1:end-4); %remove the visit number
end
resDir = [datapath 'V04_V01Results' splitter]
if saveResAndFigure && ~isfolder(resDir)
    mkdir(resDir)
end
colorOrders = colororder;
%%
if ~dataIsGroupEMG
% adaptDataPre=load([datapath splitter 'V02' splitter subjectID 'V02params.mat']);
% adaptDataPost=load([datapath splitter 'V04' splitter subjectID 'V04params.mat']);
outcomePre=load([datapath 'V02' splitter 'Results' splitter 'Kinematics' splitter 'OutcomeMeasures.mat']);
outcomePost=load([datapath 'V04' splitter 'Results' splitter 'Kinematics' splitter 'OutcomeMeasures.mat']);
if strcmp(subjectID, 'AUF01') %load V3 kinematics
    outcomeTraining=load([datapath 'V03' splitter 'Results' splitter 'KinematicsV3' splitter 'OutcomeMeasures.mat']);
else
    outcomeTraining=load([datapath 'V03' splitter 'Results' splitter 'Kinematics' splitter 'OutcomeMeasures.mat']);
end
    
outcomePre = outcomePre.outcomeMeasures;
outcomePost = outcomePost.outcomeMeasures;
outcomeTraining = outcomeTraining.outcomeMeasures;

% Rename variables
outcomeTraining.Properties.RowNames = replace(outcomeTraining.Properties.RowNames, 'Post','TMPost');
outcomeTraining.Properties.RowNames = replace(outcomeTraining.Properties.RowNames, 'TMTMPost','TMPost');
outcomeTraining.Properties.RowNames = replace(outcomeTraining.Properties.RowNames, 'OGTMPost','OGPost');
if strcmp(subjectID,'AUF03') %switch 3 missing, add nan
    outcomeTraining{'TMPost3',:} = nan(1,4);
    outcomeTraining{'SSAdaptation3',:} = nan(1,4);
    outcomeTraining{'deltaAdaptAdaptation3',:} = nan(1,4);
    outcomeTraining{'AdaptationRateAdaptation3',:} = nan(1,4);
end
%% load EMG outcome measure
EMGAEPre=load([datapath splitter 'V02' splitter 'Results' splitter 'EMGV2' splitter subjectID 'V02_AEEMGScalar.mat']);
EMGAEPost=load([datapath splitter 'V04' splitter 'Results' splitter 'EMGV2' splitter subjectID 'V04_AEEMGScalar.mat']);
EMGAETraining=load([datapath splitter 'V03' splitter 'Results' splitter 'EMGV2' splitter subjectID 'V03_AEEMGScalar.mat']);
    
EMGAEPre = EMGAEPre.AEScalar;
EMGAEPost = EMGAEPost.AEScalar;
EMGAETraining = EMGAETraining.AEScalar;

outcomePre{'EMGOGPost','EMGScalar'} = EMGAEPre{:,'AE1(OG)'};
outcomePre{'EMGTMPost','EMGScalar'} = EMGAEPre{:,'AE2(TM)'};
outcomePost{'EMGOGPost','EMGScalar'} = EMGAEPost{:,'AE1(OG)'};
outcomePost{'EMGTMPost','EMGScalar'} = EMGAEPost{:,'AE2(TM)'};
outcomeTraining{'EMGOGPost','EMGScalar'} = EMGAETraining{:,'AE_OGPost'};
outcomeTraining{'EMGTMPost','EMGScalar'} = EMGAETraining{:,'AE_TMPost'};
for block = 1:4
    outcomeTraining{['EMGTMPost' num2str(block)],'EMGScalar'} = EMGAETraining{:,['AE_TMPost' num2str(block)]};
end

else %load group EMG res
    EMGPre=load([datapath 'EMGV2' splitter 'V02' splitter subjectID 'V02_AEEMGScalar_Cos.mat']);
    EMGPost=load([datapath 'EMGV2' splitter 'V04' splitter subjectID 'V04_AEEMGScalar_Cos.mat']);
    EMGTraining=load([datapath 'EMGV2' splitter 'V03' splitter subjectID 'V03_AEEMGScalar_Cos.mat']);
    EMGAEPre = EMGPre.AEScalar;
    EMGAEPost = EMGPost.AEScalar;
    EMGAETraining = EMGTraining.AEScalar;
    outcomePre = table();
    outcomePost = table();
    outcomeTraining = table();
    
    outcomePre{'EMGOGPost','EMGScalar'} = EMGAEPre{end,'AE1(OG)'};
    outcomePre{'EMGTMPost','EMGScalar'} = EMGAEPre{end,'AE2(TM)'};
    outcomePost{'EMGOGPost','EMGScalar'} = EMGAEPost{end,'AE1(OG)'};
    outcomePost{'EMGTMPost','EMGScalar'} = EMGAEPost{end,'AE2(TM)'};
    outcomeTraining{'EMGOGPost','EMGScalar'} = EMGAETraining{end,'AE_OGPost'};
    outcomeTraining{'EMGTMPost','EMGScalar'} = EMGAETraining{end,'AE_TMPost'};
    for block = 1:4
        outcomeTraining{['EMGTMPost' num2str(block)],'EMGScalar'} = EMGAETraining{:,['AE_TMPost' num2str(block)]};
    end
end

%% plot kinematic outcome variables and EMG AE 
close all
if ~dataIsGroupEMG
    vars = {'OGPost','TMPost','AdaptationRate','SS','deltaAdapt','EMGOGPost','EMGTMPost'};
else
    vars = {'EMGOGPost','EMGTMPost'};
end
colorOrders = colororder;
for varIdx = 1:numel(vars)
    var = vars{varIdx};
    f = figure('units','normalized','outerposition',[0 0 1 1]);%('Position', get(0, 'Screensize'));
    if ~contains(var,'EMG')
        varColsToPlot = 1:4;
    elseif ~dataIsGroupEMG
        varColsToPlot = 5;
    else
        varColsToPlot = 1;
    end
    for col = varColsToPlot
        if ~contains(var,'EMG')
            subplot(2,2,col);
        end
        barXLoc = 1;
        bar(barXLoc, outcomePre{var,col}, 'FaceColor', colorOrders(1,:),'DisplayName','Pre');
        hold on;
        if contains(var, 'OGPost') 
            barXLoc = barXLoc + 1;
            bar(barXLoc, outcomeTraining{var,col}, 'FaceColor', colorOrders(3,:),'DisplayName','Training');
        else
            yToPlot = nan(1,5);
            if contains(var, 'TMPost')
                for block = 1:4
                    yToPlot(block) = outcomeTraining{[var num2str(block)],col};
                end
                yToPlot(end) = outcomeTraining{var,col};
            else
                for block = 1:5
                    yToPlot(block) = outcomeTraining{[var 'Adaptation' num2str(block)],col};
                end
            end
            bar(barXLoc+1:barXLoc+5, yToPlot, 'FaceColor', colorOrders(3,:),'DisplayName','Training');
            barXLoc = barXLoc+5;
        end
        barXLoc = barXLoc + 1;
        bar(barXLoc, outcomePost{var,col}, 'FaceColor', colorOrders(4,:),'DisplayName','Post');
        if (length(varColsToPlot) > 1) %title for sub figure, only applies is there is multiple figures
            title(outcomePre.Properties.VariableNames{col})
        end
        xticks([]);
    end
    legendHandle = legend();
    if contains(var, 'OGPost')
        xticks([1:barXLoc]);
        xticklabels(legendHandle.String);
    else
        xticks([1:barXLoc]);
        tickLabels = {legendHandle.String{1}};
        for block = 1:5
            tickLabels{end+1} = ['Switch' num2str(block)];
        end
        tickLabels{end+1} = legendHandle.String{end};
        xticklabels(tickLabels);
        xtickangle(45);
    end
    sgtitle(var)
    set(findall(gcf,'-property','FontSize'),'FontSize',30)
    if saveResAndFigure
        saveas(f, [resDir var 'Change.fig'])
        saveas(f, [resDir var 'Change.png'])
    end
end

%% plot EMG outcome measures of individual and group

%% load V03 indiv data
AUF01V03 = load('/Volumes/Research/Shuqi/NirsAutomaticityStudy/Data/AUF01/V03/Results/EMGV2/AUF01V03_AEEMGScalar_Cos.mat')
AUF03V03 = load('/Volumes/Research/Shuqi/NirsAutomaticityStudy/Data/AUF03/V03/Results/EMGV2/AUF03V03_AEEMGScalar_Cos.mat')
newTable = AUF01V03.cosWithCorrespondingBase;
newTable(end+1,:) = AUF03V03.cosWithCorrespondingBase;
newTable(end+1,:) = EMGTraining.cosWithCorrespondingBase;
newTable.Properties.RowNames = {'AUF01V03','AUF03V03','2SubV03'};
EMGTraining.cosWithCorrespondingBase = newTable;

CosTMTable = EMGPre.cosWithCorrespondingBase(:,1); %in order, TMpre, OGPre, TM1,2,3,4,TM, OG; TMPost, OGPost
CosTMTable(:,end+1:end+5) = EMGTraining.cosWithCorrespondingBase(:,1:5);
CosTMTable(:,end+1) = EMGPost.cosWithCorrespondingBase(:,1);
% CosTMTable.Properties.VariableNames = {'TMPre','OGPre','TrainingTM1','TrainingTM2','TrainingTM3','TrainingTM4','TrainingOG','TrainingTM','TMPost','OGPost'};
CosOGTable = EMGPre.cosWithCorrespondingBase(:,2); %in order, TMpre, OGPre, TM1,2,3,4,TM, OG; TMPost, OGPost
CosOGTable(:,end+1) = EMGTraining.cosWithCorrespondingBase(:,end);
CosOGTable(:,end+1) = EMGPost.cosWithCorrespondingBase(:,end);

%%
close all
subjIdx = 3;
for varType = {'CosOG','CosTM'}%1OG, 2TM
    f = figure('units','normalized','outerposition',[0 0 1 1]);%('Position', get(0, 'Screensize'));
    var = varType{1};
    dataToPlot = eval([var 'Table(' num2str(subjIdx) ',:)']);

    barXLoc = 1;
    bar(barXLoc, dataToPlot{1,1}, 'FaceColor', colorOrders(1,:),'DisplayName','Pre');
    hold on;
    if contains(var, 'OG') 
        barXLoc = barXLoc + 1;
        bar(barXLoc, dataToPlot{1,2}, 'FaceColor', colorOrders(3,:),'DisplayName','Training');
    else
        bar(barXLoc+1:barXLoc+5, dataToPlot{1,2:6}, 'FaceColor', colorOrders(3,:),'DisplayName','Training');
        barXLoc = barXLoc+5;
    end
    barXLoc = barXLoc + 1;
    bar(barXLoc, dataToPlot{1,end}, 'FaceColor', colorOrders(4,:),'DisplayName','Post');
    xticks([]);
    
    legendHandle = legend();
    if contains(var, 'OGPost')
        xticks([1:barXLoc]);
        xticklabels(legendHandle.String);
    else
        xticks([1:barXLoc]);
        tickLabels = {legendHandle.String{1}};
        for block = 1:5
            tickLabels{end+1} = ['Switch' num2str(block)];
        end
        tickLabels{end+1} = legendHandle.String{end};
        xticklabels(tickLabels);
        xtickangle(45);
    end
    sgtitle(['Cosine of ' var(end-1:end) 'Post with Corresponding Baseline'])
    set(findall(gcf,'-property','FontSize'),'FontSize',30)
    if saveResAndFigure
        saveas(f, [resDir var 'Change.fig'])
        saveas(f, [resDir var 'Change.png'])
    end
end

%%
close all;
for rateToPlot = 1:2 %1=walkSpeed, 2= cognitive Perf
    f = figure('units','normalized','outerposition',[0.05 0.05 0.95 0.95]);
%     subplot(1, 3, [1 2])
    if rateToPlot == 1 %walk speed
        validIdx = contains(DTdataAll{1}.data.Properties.RowNames,{'walk','walkAndAlphabet3','walkAndAlphabet2'});
        fieldToPlot = 'walkSpeed';
        ylabelString = 'Gait Speed (m/s)';
        titleString1 = 'Gait Speed per Trial';
        titleString2 = 'Average Gait Speed';
        saveTitle = 'GaitSpeed';
    else
        validIdx = contains(DTdataAll{1}.data.Properties.RowNames,{'standAndAlphabet2','walkAndAlphabet2','standAndAlphabet3','walkAndAlphabet3'});
        fieldToPlot = 'alphabetRate';
        ylabelString = 'Alphabet Performance (correct alphabet / s)';
        titleString1 = 'Cognitive Task Performance per Trial';
        titleString2 = 'Average Cognitive Task Performance';
        saveTitle = 'CognitivePerf';
        end
    
    dataToPlot = [];
    scatterToPlot = []; %1 column per subject
    for dIdx = 1:length(DTdataAll)
        currSubData = eval(['DTdataAll{dIdx}.data.' fieldToPlot '(validIdx,:)']);
        dataToPlot = [dataToPlot, currSubData];
        scatterToPlot = [scatterToPlot, mean(currSubData,2)]
    end
        
    avgPerf = mean(dataToPlot,2);
    bar(avgPerf,'FaceColor','none','LineWidth',5,'DisplayName','Avg')
    stdBarHeight = std(dataToPlot,0,2); %2nd arg is weight, 0 means equal weight
    xticklabels(erase(erase(DTdataAll{1}.data.Properties.RowNames(validIdx),'And'),'bet'))
    ylabel(ylabelString)
    hold on
    er = errorbar(1:length(avgPerf),avgPerf,stdBarHeight,stdBarHeight,'DisplayName','SD');    
    er.Color = [0 0 0];                            
    er.LineStyle = 'none';
    er.LineWidth = 5;
    for dIdx = 1:length(DTdataAll)
        plot(1:length(avgPerf),scatterToPlot(:,dIdx)','o-','LineWidth',5,'MarkerSize',25,'DisplayName',DTdataAll{dIdx}.subjectID);
    end
    legend();%,'Location','bestoutside')
    title(titleString2)
    set(findall(gcf,'-property','FontSize'),'FontSize',30)
    if saveResAndFigure
        saveas(f,[saveDir saveTitle])
        saveas(f,[saveDir saveTitle '.png'])
    end
end
% %OGPost = switching
% f = figure('Position', get(0, 'Screensize'));
% for col = 1:4
%     subplot(2,2,col);
%     bar(1, outcomePre{'OGPost',col});
%     hold on;
%     bar(2, outcomePost{'OGPost',col});
%     bar(3, outcomePost{'OGPost',col});
%     bar(4, outcomePost{'OGPost',col});
%     bar(5, outcomePost{'OGPost',col});
%     bar(6, outcomePost{'OGPost',col});
%     title(outcomePre.Properties.VariableNames{col})
% end
% legend({'Pre','Post'})

% dataToPlot = {deltaAdapt, ssData, stride2SS};
% titles = {'Delta Adapt (SS - earlyAdapt)', 'Steady States (unbiased)','Adaptation Rate (strides to steady state)'};
% saveTitle = {'DeltaAdapt','SS','AdaptationRateBar'};
% for dIdx = 1:length(dataToPlot)
%     data = dataToPlot{dIdx};
%     f = figure('Position', get(0, 'Screensize'));
%     for i =1:4
%         subplot(2,2,i)
%         bar(data(:,i))
%         title(params{i})
%         xticklabels(lateConditions)
%     end
%     sgtitle(titles{dIdx}); 
%     
%     if saveResAndFigure
%         saveas(f, [resDir saveTitle{dIdx} '.png'])
%         saveas(f, [resDir saveTitle{dIdx} '.fig'])
%     end
% end
