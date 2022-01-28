close all; clc; clear all;
saveResAndFigure = true;
saveDir = ['/Volumes/Research/Shuqi/NirsAutomaticityStudy/Data/GroupResults/Group4Sub/Nirs/'];
visitNum = 'V01';
subjectIDs = {'AUF01','AUF03','AUF02','AUF04'};
saveDir = [saveDir visitNum '/']
DTdataPaths = {};
for sub = subjectIDs
    if strcmp(sub{1},'AUF01') && strcmp(visitNum,'V01')
        DTdataPaths{end+1} = ['/Volumes/Research/Shuqi/NirsAutomaticityStudy/Data/' sub{1} '/' visitNum 'Retest/' sub{1} visitNum 'RetestDTdata.mat'];
    else
        DTdataPaths{end+1} = ['/Volumes/Research/Shuqi/NirsAutomaticityStudy/Data/' sub{1} '/' visitNum '/' sub{1} visitNum 'DTdata.mat'];
    end
end

scriptDir = fileparts(matlab.desktop.editor.getActiveFilename); 
if contains(scriptDir, '\') %windows enviroment, replace / with \
    saveDir = replace(saveDir,'/Volumes/Research','X:');
    saveDir = replace(saveDir,"/","\");
    for dIdx = 1:length(DTdataPaths)
        DTdataPaths{dIdx} = replace(DTdataPaths{dIdx},'/Volumes/Research','X:');
        DTdataPaths{dIdx} = replace(DTdataPaths{dIdx},"/","\");
    end
end

if ~exist(saveDir,'dir')
    mkdir(saveDir)
end
DTdataAll = cell(1,length(DTdataPaths));
for dIdx = 1:length(DTdataPaths)
    dt = load(DTdataPaths{dIdx});
    DTdataAll{dIdx} = dt.DTdata;
end

% poster_colors;
% colorOrder=[p_red; p_orange; p_fade_green; p_fade_blue; p_plum; p_green; p_blue; p_fade_red; p_lime; p_yellow; [0 0 0]; p_gray];
colorOrder = colororder;

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

%%
% tableToPlot = {tableSrc_VsBase, tableSrc_DTvsST, tablePFC_VsBase, tablePFC_DTvsST};
tableToPlot = {[], [], 'tablePFC_VsBase', 'tablePFC_DTvsST'};
condsOrdered = {{'StandAndAlphabet2RC';'StandAndAlphabet3RC';'WalkRestCorrected'; 'WalkAndAlphabet2RC';'WalkAndAlphabet3RC'},...
    {'WalkAlphabet2VsWalk';'WalkAlphabet2VsStandAlphabet2';'WalkAlphabet3VsWalk';'WalkAlphabet3VsStandAlphabet3'}};
gapBtwGroups = 1; %figure setting, gaps between groups of bar plots
close all;
for tblIdx = 3:length(tableToPlot) %first 2 sources x hbr and hbo, then 1PFC x 2 (hbr and hbo)
    if tblIdx <= 2
        groups = 4;
        xlabels = {'Source1 hbo','Source1 hbr','Source2 hbo','Source2 hbr'};
        
        if tblIdx == 1
            titleId = 'By Source (Compared to Rest Baseline)';
            saveNameId = 'VsBase_BySource';
        else
            titleId = 'By Source (DT vs ST)';
            saveNameId = 'DTvsST_BySource';
        end
    else
        groups = 2;
        xlabels = {'hbo','hbr'};
        if tblIdx == 3
            titleId = 'PFC (Compared to Rest Baseline)';
            saveNameId = 'VsBase_PFC';
        else
            titleId = 'PFC (DT vs ST)';
            saveNameId = 'DTvsST_PFC';
        end
    end
    if tblIdx == 1 || tblIdx == 3 %vs base
        conds = condsOrdered{1};
    else %vs DT
        conds = condsOrdered{2};
    end
%     tableByROI = tableToPlot{tblIdx};
    f = figure('units','normalized','outerposition',[0 0 1 1]);
    hold on;
%     conds = eval(['unique(DTdataAll{1}.statsTables.' tableToPlot{tblIdx} '.Contrast)']);
%     sigMarkOffset = range(tableByROI.T) * 0.03;
    tIdx = 1;

    for t = {'hbo','hbr'}
        avgData = [];
        plotXLocs = [];
        for dIdx = 1:length(DTdataAll)
            tableByROI = eval(['DTdataAll{dIdx}.statsTables.' tableToPlot{tblIdx}]);
            barXLocs = [];
            dataToPlot = [];
            for condIdx = 1:length(conds)
                barXLocs = [barXLocs, (tIdx - 1) * (length(conds) + gapBtwGroups) + condIdx];
                dataToPlot = [dataToPlot, tableByROI(strcmp(tableByROI.Contrast,conds{condIdx}) & strcmp(tableByROI.type,t{1}),:).T];
            end
            avgData = [avgData; dataToPlot];
                %             end
                %find x location (not the best bc the bars won't allocate the width themsevles)
                % end idx is groups * conds + groups - 1 (add gaps)
    %             barXLocs = condIdx:length(conds)+gapBtwGroups:groups*(length(conds)+gapBtwGroups)-1;
            
%                 bar(barXLocs, mean(dataToPlot.T),'BarWidth', 1/(length(conds)+1));
%                 sigIdx = dataToPlot.q < 0.05; %logical array to index significant values
%                 scatter(barXLocs(sigIdx), sign(dataToPlot.T(sigIdx)) .* (abs(dataToPlot.T(sigIdx)) + sigMarkOffset),'*','k');
        end
        avgPerf = mean(avgData);
        barColors = 1:-1/(length(avgPerf)-1):0;
        for pIdx = 1:length(avgPerf)
            if pIdx == 1
                bar(barXLocs(pIdx), avgPerf(pIdx),'FaceColor',repmat(barColors(pIdx),1,3),'LineWidth',5,'DisplayName',['Avg ' conds{pIdx}]);
            else
                bar(barXLocs(pIdx), avgPerf(pIdx),'FaceColor',repmat(barColors(pIdx),1,3),'EdgeColor',repmat(barColors(pIdx),1,3),'LineWidth',5,'DisplayName',['Avg ' conds{pIdx}]);
            end
        end
        %%
        stdBarHeight = std(avgData); %2nd arg is weight, 0 means equal weight
        hold on
        er = errorbar(barXLocs,avgPerf,stdBarHeight,stdBarHeight,'DisplayName','SD');    
        er.Color = [0 0 0];                            
        er.LineStyle = 'none';
        er.LineWidth = 5;
        for dIdx = 1:length(DTdataAll)
            plot(barXLocs,avgData(dIdx,:),'o-','Color',colorOrder(dIdx,:),'LineWidth',5,'MarkerSize',25,'DisplayName',DTdataAll{dIdx}.subjectID);
        end
        tIdx = tIdx + 1;
    end
    %xticks in the middle, 
    condIdx = 3;
    xticks(condIdx:length(conds)+1:(groups+1)*length(conds)-1);
    xticklabels(xlabels)
    ylabel('T-stats (T-value)')
    title(['Group T - stats ' titleId ' ' visitNum])
    legend();
    hLegend = findobj(gcf, 'Type', 'Legend');
    hLegend = hLegend.String;
    legend(hLegend(1:length(hLegend)/2))
    set(findall(gcf,'-property','FontSize'),'FontSize',30)
    if saveResAndFigure
        saveas(f,[saveDir 'Stats' saveNameId])
        saveas(f,[saveDir 'Stats' saveNameId '.png'])
    end
end