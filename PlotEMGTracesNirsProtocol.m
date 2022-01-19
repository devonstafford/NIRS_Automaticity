%%Traces from example subject to show how data is summarized
%% Load data
close all; clc; clear all;
% subjectID = 'AUF01V03';
% dataPath = split(subjectID,'V');
% visitNum = str2double(dataPath(2));
[dataPath, ~, saveDir, subjectID, visitNum] = setupDataPath('AUF01', 'V03', '', 'EMGV1')
load([dataPath subjectID '.mat']);
saveResAndFigure = false;

if saveResAndFigure
%   saveDir = [dataPath 'Results\EMGV1\'];
   if ~isfolder(saveDir)
        mkdir(saveDir)
    end
end
%% Align it
%early: first 10 strides except first 1, baseline/late: last 40 strides
%except last stride
if visitNum == 2 || visitNum == 4 %pre-post intervention trials
    conds={'OGBase','TMMidThenAdapt','TMSlow','TMFast','OGPost','TMPost','PosShort','NegShort','Adaptation'};
    %in order rows: baseline, baselin vs neg/pos short early, late, early post vs neg short (similar), 
    %early ada vs pos short (should be similar) ; columns: condIndex to plot,
    %strideIdx per condition, plot title, save name, legend (cond name), condColors indexes
    plotConfig = {[1,3:4,2],[repmat([-40:-1],3,1);[110:149]],'Baseline','EMGTrace_Base';...
        [1:2,7:8],[repmat([2:11],2,1);repmat([52:61],2,1)],'Baseline PosNeg Short Early','EMGTrace_PosNeg';...
        [1,9,2],[repmat([-40:-1],2,1);[110:149]],'Late (Base, Adaptation)','EMGTrace_Late';...
        [5:8],[repmat([2:11],2,1);[52:61];[52:61]],'Early Post and Short','EMGTrace_EarlyPost_Short';...
        [2,7:8],[[152:161];[52:61];[52:61]],'Early Adaptation and Short','EMGTrace_EarlyAda_Short'}; 
    for i = 1:size(plotConfig,1) %add condition names
        legendStrs = conds(plotConfig{i,1});
        if i == 1     %rename the special cases for TMMidThenAdapt
            legendStrs{end} = 'TMMidBase';
        elseif i == 2
            legendStrs{2} = 'TMMidBase';
        elseif i == 3
            legendStrs{end} = 'TMMidBase';
            for j = 1:length(legendStrs)
                legendStrs{j} = [legendStrs{j} '_{late}'];
            end
        elseif i == 5
            legendStrs{1} = 'Adaptation';
        end
        if i ==2 || i == 4 || i ==5
            for j = 1:length(legendStrs)
                legendStrs{j} = [legendStrs{j} '_{early}'];
            end
        end
        plotConfig{i,5} = legendStrs;
    end
    %populate cond plot color index
    plotConfig = [plotConfig,plotConfig(:,1)];

else %intervention trials
    if strcmp(subjectID, 'AUF03V03') %special case for AUF03V03
        conds={'OGBase','MidAdaptation1','TMSlow','TMFast','OGPost','TMPost','PosShort','NegShort','SwitchAdaptation2',...
        'SwitchAdaptation4','LastAdaptation'};
        %in order rows: baseline, baseline vs neg/pos short early, late ada each vs TMbase (similar), 
        %early post each vs neg short (similar), early ada each vs pos short
        %(shoulr bd similar); columns: condIndex to plot,strideIdx per condition, 
        %plot title, save name, legend (cond name), condColors indexes
        plotConfig = {[1,3:4,2],[repmat([-40:-1],3,1);[110:149]],'Baseline','EMGTrace_Base';... %OG, TM 3 speeds base last 40 strides
            [1:2,7:8],[repmat([2:11],2,1);repmat([52:61],2,1)],'Baseline PosNeg Short Early','EMGTrace_PosNeg';... %OG, TMMid, PosS, NegS, first 10 strides
            [2,9:11,2],[repmat([-66:-27],3,1);[-40:-1];[110:149]],'Late (TMBase, Adaptation Per Switch)','EMGTrace_LateAda';... 
            [2,9,10,5:6,7:8],[repmat([-23:-14],3,1);repmat([2:11],2,1);repmat([52:61],2,1)],'Early Post (Per Switch) and Short','EMGTrace_EarlyPost_AndShort';... 
            [2,9:11,7:8],[[152:161];repmat([27:36],3,1);repmat([52:61],2,1)],'Early Adaptation (Per Switch) and Short','EMGTrace_EarlyAda_AndShort'};
  
    else
        conds={'OGBase','MidAdaptation1','TMSlow','TMFast','OGPost','TMPost','PosShort','NegShort','SwitchAdaptation2','SwitchAdaptation3',...
            'SwitchAdaptation4','LastAdaptation'};
        %in order rows: baseline, baseline vs neg/pos short early, late ada each vs TMbase (similar), 
        %early post each vs neg short (similar), early ada each vs pos short
        %(shoulr bd similar); columns: condIndex to plot,strideIdx per condition, 
        %plot title, save name, legend (cond name), condColors indexes
        plotConfig = {[1,3:4,2],[repmat([-40:-1],3,1);[110:149]],'Baseline','EMGTrace_Base';... %OG, TM 3 speeds base last 40 strides
            [1:2,7:8],[repmat([2:11],2,1);repmat([52:61],2,1)],'Baseline PosNeg Short Early','EMGTrace_PosNeg';... %OG, TMMid, PosS, NegS, first 10 strides
            [2,9:12,2],[repmat([-66:-27],4,1);[-40:-1];[110:149]],'Late (TMBase, Adaptation Per Switch)','EMGTrace_LateAda';... 
            [2,9:11,5:6,7:8],[repmat([-23:-14],4,1);repmat([2:11],2,1);repmat([52:61],2,1)],'Early Post (Per Switch) and Short','EMGTrace_EarlyPost_AndShort';... 
            [2,9:12,7:8],[[152:161];repmat([27:36],4,1);repmat([52:61],2,1)],'Early Adaptation (Per Switch) and Short','EMGTrace_EarlyAda_AndShort'};   
    end
    for i = 1:size(plotConfig,1) %add condition names
        legendStrs = conds(plotConfig{i,1});
        if i == 1     %rename the special cases for TMMidThenAdapt
            legendStrs{end} = 'TMMidBase';
        elseif i == 2 %early base and early pos/neg shorts
            legendStrs{2} = 'TMMidBase';
            for j = 1:length(legendStrs)
                legendStrs{j} = [legendStrs{j} '_{early}'];
            end
        elseif i== 3 %late base, and late ada per switch
            if strcmp(subjectID,'AUF03V03')
                legendStrs{1} = ['Adaptation1_{late}'];
                legendStrs{2} = ['Adaptation2_{late}'];
                legendStrs{3} = ['Adaptation4_{late}'];
                legendStrs{4} = ['Adaptation5_{late}'];
            else
                for j = 1:(length(legendStrs)-1)
                    legendStrs{j} = ['Adaptation' legendStrs{j}(end) '_{late}'];
                end  
            end
            legendStrs{end} = 'TMMidBase_{late}';
        elseif i== 4 %early post per switch
            if strcmp(subjectID,'AUF03V03')
                legendStrs{1} = ['TMPost1'];
                legendStrs{2} = ['TMPost2'];
                legendStrs{3} = ['TMPost4'];
            else
                for j = 1:(length(legendStrs)-4)
                    legendStrs{j} = ['TMPost' legendStrs{j}(end)];
                end
            end
            for j = 1:length(legendStrs)
                legendStrs{j} = [legendStrs{j} '_{early}'];
            end
        elseif i== 5 %early ada per switch
            if strcmp(subjectID, 'AUF03V03')
                legendStrs{1} = ['Adaptation1_{early}'];
                legendStrs{2} = ['Adaptation2_{early}'];
                legendStrs{3} = ['Adaptation4_{early}'];
                legendStrs{4} = ['Adaptation5_{early}'];
            else
                for j = 1:(length(legendStrs)-2)
                    legendStrs{j} = ['Adaptation' legendStrs{j}(end) '_{early}'];
                end
            end
            for j = length(legendStrs)-1: length(legendStrs)
                legendStrs{j} = [legendStrs{j} '_{early}'];
            end
        end
        plotConfig{i,5} = legendStrs;
    end
    %populate cond plot color index
    plotConfig = [plotConfig,plotConfig(:,1)];
    plotConfig{3,6}(1) = 3; %use color 3 for first adaptation
end

%set up events, muscles, common plot colors
events={'RHS','LTO','LHS','RTO'};
alignmentLengths=[16,32,16,32];

muscle={'TA', 'PER', 'SOL', 'LG', 'MG', 'BF', 'SEMB', 'SEMT', 'VM', 'VL', 'RF', 'TFL', 'GLU', 'HIP'};
lm=1:2:35;

poster_colors;
colorOrder=[p_red; p_orange; p_fade_green; p_fade_blue; p_plum; p_green; p_blue; p_fade_red; p_lime; p_yellow; [0 0 0]; p_gray];
condColors=colorOrder;

%%
for plotIdx=5:size(plotConfig,1)%( %1=base, 2= early, 3= late, If intervention: 4=early TMPost per switch, 5=late ada per switch, 6=early ada per switch
    fh=figure('Units','Normalized');
    for m=1:length(muscle)
        for leg = 1:2 % 1=R, 2=L
            dataToPlot = {};
            if leg == 1
                alignmentEvent = events;
                legLabel = 'R';
            else
                alignmentEvent = events([3,4,1,2]);
                legLabel='L';
            end
            for condIdx = 1:length(conds)
                dataToPlot{end+1} = expData.getAlignedField('procEMGData',conds(condIdx),alignmentEvent,alignmentLengths).getPartialDataAsATS({[legLabel muscle{m}]});
            end
            tit=[legLabel muscle{m}];
            ph1=[];
            prc=[16,84];
            MM=sum(alignmentLengths);
            M=cumsum([0 alignmentLengths]);
            xt=sort([M,M(1:end-1)+[diff(M)/2]]);
            phaseSize=8;
            xt=[0:phaseSize:MM];
            %xt=[0:8:MM];s
            fs=16; %FontSize
            
            ph=subplot(5,6,lm(m)+leg-1);
            set(gcf,'color','w');
            %     set(ph,'Position',[.07 .48 .35 .45]);
            hold on
            condIdxToPlot = plotConfig{plotIdx,1};
            strideIdxPerCond = plotConfig{plotIdx,2};
            legendStrings = plotConfig{plotIdx,5};
            pltColorIdx = plotConfig{plotIdx,6};
            for i = 1:length(condIdxToPlot)
                strideIdx = strideIdxPerCond(i,:);
                if any(strideIdx<=0) %Counting from the back
                    strideIdx(strideIdx<=0)=size(dataToPlot{condIdxToPlot(i)}.Data,3)+strideIdx(strideIdx<=0); 
                end
                toPlot = dataToPlot{condIdxToPlot(i)}.getPartialStridesAsATS(strideIdx);
                %the strideIdx arg here is not being used for plotting
                toPlot.plot(fh,ph,condColors(pltColorIdx(i),:),[],0,strideIdxPerCond(i,:),prc,true); %last 40 strides excluding the last 1
            end

            axis tight
            ylabel('')
            ylabel(tit)
%             set(ph,'YTick',[0,1],'YTickLabel',{'0%','100%'})
            grid on
        end
    end
    legendObj=findobj(ph,'Type','Line');
    legend(legendObj(end:-1:1),legendStrings);
    if saveResAndFigure
        saveName = [saveDir subjectID plotConfig{plotIdx,4}];
        sgtitle(plotConfig{plotIdx,3});
        saveas(fh,saveName)
        saveas(fh,[saveName '.png'])
    end
end

%%
%         RBase=expData.getAlignedField('procEMGData',conds(2),events,alignmentLengths).getPartialDataAsATS({['R' muscle{m}]});
%         LBase=expData.getAlignedField('procEMGData',conds(2),events([3,4,1,2]),alignmentLengths).getPartialDataAsATS({['L' muscle{m}]});
%         
%         RBaseSlow=expData.getAlignedField('procEMGData',conds(3),events,alignmentLengths).getPartialDataAsATS({['R' muscle{m}]});
%         LBaseSlow=expData.getAlignedField('procEMGData',conds(3),events([3,4,1,2]),alignmentLengths).getPartialDataAsATS({['L' muscle{m}]});
%         
%         RBaseFast=expData.getAlignedField('procEMGData',conds(4),events,alignmentLengths).getPartialDataAsATS({['R' muscle{m}]});
%         LBaseFast=expData.getAlignedField('procEMGData',conds(4),events([3,4,1,2]),alignmentLengths).getPartialDataAsATS({['L' muscle{m}]});
%                 
%         RAdap=expData.getAlignedField('procEMGData',conds(5),events,alignmentLengths).getPartialDataAsATS({['R' muscle{m}]});
%         LAdap=expData.getAlignedField('procEMGData',conds(5),events([3,4,1,2]),alignmentLengths).getPartialDataAsATS({['L' muscle{m}]});
%         
%         ROGPost=expData.getAlignedField('procEMGData',conds(6),events,alignmentLengths).getPartialDataAsATS({['R' muscle{m}]});
%         LOGPost=expData.getAlignedField('procEMGData',conds(6),events([3,4,1,2]),alignmentLengths).getPartialDataAsATS({['L' muscle{m}]});
%         
%         RPost=expData.getAlignedField('procEMGData',conds(7),events,alignmentLengths).getPartialDataAsATS({['R' muscle{m}]});
%         LPost=expData.getAlignedField('procEMGData',conds(7),events([3,4,1,2]),alignmentLengths).getPartialDataAsATS({['L' muscle{m}]});
%                 
%         RPosShort=expData.getAlignedField('procEMGData',conds(8),events,alignmentLengths).getPartialDataAsATS({['R' muscle{m}]});
%         LPosShort=expData.getAlignedField('procEMGData',conds(8),events([3,4,1,2]),alignmentLengths).getPartialDataAsATS({['L' muscle{m}]});
%         
%         RNegShort=expData.getAlignedField('procEMGData',conds(9),events,alignmentLengths).getPartialDataAsATS({['R' muscle{m}]});
%         LNegShort=expData.getAlignedField('procEMGData',conds(9),events([3,4,1,2]),alignmentLengths).getPartialDataAsATS({['L' muscle{m}]});
%         
        % RNeg=expData.getAlignedField('procEMGData',conds(6),events,alignmentLengths).getPartialDataAsATS({['R' muscle{m}]});
        % LNeg=expData.getAlignedField('procEMGData',conds(6),events([3,4,1,2]),alignmentLengths).getPartialDataAsATS({['L' muscle{m}]});
        
        
        % %
        % %  % Save, to avoid dealing with the whole file again
        % save([ expData.subData.ID,'EMG_',muscle{m}],'RBaseSlow','LBaseSlow','RBase','LBase','RAdap','LAdap','RPost','LPost')
        
        % load(['GYAAT_10PNormOGEMG_',muscle{m}])
        % subject='GYAAT_10';
        % load([subject, 'PNormOGEMG_',muscle{m},'.mat'])
        %% Create plots
        % close all;

        
        % fh=figure('Units','Normalized','Position',[0 0 .45 .2]);

%         for l=1:2
%             if l == 1 %right side  
%                 B=RBase.getPartialStridesAsATS(find(RBase.Data(end-40:end)));
%                 OGB=ROGBase.getPartialStridesAsATS(find(ROGBase.Data(end-40:end)));
%                 A_early=RAdap.getPartialStridesAsATS(find(RAdap.Data(100:110)));
%                 A_late=RAdap.getPartialStridesAsATS(find(RAdap.Data(2000:2050)));
%                 A_post=RAdap.getPartialStridesAsATS(find(RAdap.Data(2090:2100)));
%                 S=RBaseSlow.getPartialStridesAsATS(find(RBaseSlow.Data(end-40:end)));%23:73 03 range
%                 F=RBaseFast.getPartialStridesAsATS(find(RBaseFast.Data(end-40:end)));
%                 P=RPost.getPartialStridesAsATS(find(RPost.Data(end-40:end)));
% %                     Pos=RPosi.getPartialStridesAsATS(find(RPosi.Data(2:10)));
% %                     N=RNeg.getPartialStridesAsATS(find(RNeg.Data(2:10)));
%                 %Early
% 
%                 tit=['R' muscle{m}];
%             else  %left side               
%                 B=LBase.getPartialStridesAsATS(find(LBase.Data(end-40:end))); % young 110:150
%                 A=LAdap.getPartialStridesAsATS(find(LAdap.Data(100:110))); %young 900-50:898
%                 A_late=LAdap.getPartialStridesAsATS(find(RAdap.Data(2000:2050)));
%                 A_post=LAdap.getPartialStridesAsATS(find(RAdap.Data(2090:2100)));
%                 S=LBaseSlow.getPartialStridesAsATS(find(LBaseSlow.Data(end-40:end))); %young 60:95
%                 F=LBaseFast.getPartialStridesAsATS(find(LBaseFast.Data(end-40:end)));
%                 P=LPost.getPartialStridesAsATS(find(LPost.Data(end-40:end))); %young 300-50:300
% %                     Pos=LPosi.getPartialStridesAsATS(find(LPosi.Data(2:10)));
% %                     N=LNeg.getPartialStridesAsATS(find(LNeg.Data(2:10)));
% 
%                 %Early
%                 tit=['L' muscle{m}];                
%             end
%             
%             condColors=colorOrder;
            % ph=[];
%             ph1=[];
%             prc=[16,84];
%             MM=sum(alignmentLengths);
%             M=cumsum([0 alignmentLengths]);
%             xt=sort([M,M(1:end-1)+[diff(M)/2]]);
%             phaseSize=8;
%             xt=[0:phaseSize:MM];
%             %xt=[0:8:MM];s
%             fs=16; %FontSize
%             
%             ph=subplot(5,6,lm(m)+l-1);
%             set(gcf,'color','w');
%             %     set(ph,'Position',[.07 .48 .35 .45]);
%             hold on
%             if plotIdx==1
%                 RBase.plot(fh,ph,condColors(1,:),[],0,[110:149],prc,true); %last 40 of mid base excluding the last one
%                 
% 
%             elseif plotIdx == 2
%                 S.plot(fh,ph,condColors(3,:),[],0,[-49:0],prc,true);
%                 F.plot(fh,ph,condColors(4,:),[],0,[-49:0],prc,true);
%                 B.plot(fh,ph,condColors(1,:),[],0,[-49:0],prc,true);
%                 A_late.plot(fh,ph,condColors(3,:),[],0,[-49:0],prc,true);
% %                 Pos.plot(fh,ph,condColors(6,:),[],0,[-49:0],prc,true);
%                 RBase.plot(fh,ph,condColors(1,:),[],0,[110:149],prc,true); %last 40 of mid base excluding the last one
%                 RBase.plot(fh,ph,condColors(1,:),[],0,[151:161],prc,true); %first 10 of adapt excluding the first stride
%                 
%             else
%                 A.plot(fh,ph,condColors(2,:),[],0,[-49:0],prc,true);
%                 A_post.plot(fh,ph,condColors(4,:),[],0,[-49:0],prc,true);
%                 P.plot(fh,ph,condColors(5,:),[],0,[-49:0],prc,true);
%                 
% %                 N.plot(fh,ph,condColors(7,:),[],0,[-49:0],prc,true);
%                 
%             end
%             
% %             axis tight
% %             ylabel('')
% %             ylabel(tit)
% %             set(ph,'YTick',[0,1],'YTickLabel',{'0%','100%'})
% %             grid on
% %             ll=findobj(ph,'Type','Line');
%         end
%     end
%     legend(ll(end:-1:1),condlegend{:})
% end%%
