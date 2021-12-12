%%Traces from example subject to show how data is summarized
%% Load data
% load('.../GYAAT_01.mat');

%% Align it
conds={'OGBase','TMBaseSlow','TMBaseFast','Adaptation','OGPost','TMPost'};

events={'RHS','LTO','LHS','RTO'};
alignmentLengths=[16,32,16,32];

muscle={'TA', 'PER', 'SOL', 'LG', 'MG', 'BF', 'SEMB', 'SEMT', 'VM', 'VL', 'RF', 'TFL', 'GLU', 'HIP'};
% muscle={'TA', 'PER',  'VM', 'VL', 'RF'};
lm=1:2:35;

late=0;

if late==1
    
    condlegend={'MidBase_{late}','Fast_{late}'};
else
    condlegend={'MidBase_{early}','Fast_{early}'};
    
end

for s=5
    % load(['SCB0',num2str(s), '.mat'])
    fh=figure('Units','Normalized');
    for m=1:length(muscle)
        
        RBaseSlow=expData.getAlignedField('procEMGData',conds(1),events,alignmentLengths).getPartialDataAsATS({['R' muscle{m}]});
        LBaseSlow=expData.getAlignedField('procEMGData',conds(1),events([3,4,1,2]),alignmentLengths).getPartialDataAsATS({['L' muscle{m}]});
        
        RBaseFast=expData.getAlignedField('procEMGData',conds(2),events,alignmentLengths).getPartialDataAsATS({['R' muscle{m}]});
        LBaseFast=expData.getAlignedField('procEMGData',conds(2),events([3,4,1,2]),alignmentLengths).getPartialDataAsATS({['L' muscle{m}]});
        
        RBase=expData.getAlignedField('procEMGData',conds(3),events,alignmentLengths).getPartialDataAsATS({['R' muscle{m}]});
        LBase=expData.getAlignedField('procEMGData',conds(3),events([3,4,1,2]),alignmentLengths).getPartialDataAsATS({['L' muscle{m}]});
        
        RAdap=expData.getAlignedField('procEMGData',conds(4),events,alignmentLengths).getPartialDataAsATS({['R' muscle{m}]});
        LAdap=expData.getAlignedField('procEMGData',conds(4),events([3,4,1,2]),alignmentLengths).getPartialDataAsATS({['L' muscle{m}]});
        
        RPost=expData.getAlignedField('procEMGData',conds(5),events,alignmentLengths).getPartialDataAsATS({['R' muscle{m}]});
        LPost=expData.getAlignedField('procEMGData',conds(5),events([3,4,1,2]),alignmentLengths).getPartialDataAsATS({['L' muscle{m}]});
        
        
        RShort=expData.getAlignedField('procEMGData',conds(6),events,alignmentLengths).getPartialDataAsATS({['R' muscle{m}]});
        LShort=expData.getAlignedField('procEMGData',conds(6),events([3,4,1,2]),alignmentLengths).getPartialDataAsATS({['L' muscle{m}]});
        
        
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
        poster_colors;
        colorOrder=[p_red; p_orange; p_fade_green; p_fade_blue; p_plum; p_green; p_blue; p_fade_red; p_lime; p_yellow; [0 0 0]];
        condColors=colorOrder;
        
        % fh=figure('Units','Normalized','Position',[0 0 .45 .2]);
        
        
        
        for l=1:2
            switch l
                case 1
                    
                    %Late
                    B=RBase.getPartialStridesAsATS(find(RBase.Data(end-40:end)));
                    A=RAdap.getPartialStridesAsATS(find(RAdap.Data(100:110)));
                    A_late=RAdap.getPartialStridesAsATS(find(RAdap.Data(2000:2050)));
                    A_post=RAdap.getPartialStridesAsATS(find(RAdap.Data(2090:2100)));
                    S=RBaseSlow.getPartialStridesAsATS(find(RBaseSlow.Data(end-40:end)));%23:73 03 range
                    F=RBaseFast.getPartialStridesAsATS(find(RBaseFast.Data(end-40:end)));
                    P=RPost.getPartialStridesAsATS(find(RPost.Data(end-40:end)));
%                     Pos=RPosi.getPartialStridesAsATS(find(RPosi.Data(2:10)));
%                     N=RNeg.getPartialStridesAsATS(find(RNeg.Data(2:10)));
                    
                    %Early
                    
                    tit=['R' muscle{m}];
                case 2
                    
                    %Late
                    B=LBase.getPartialStridesAsATS(find(LBase.Data(end-40:end))); % young 110:150
                    A=LAdap.getPartialStridesAsATS(find(LAdap.Data(100:110))); %young 900-50:898
                    A_late=LAdap.getPartialStridesAsATS(find(RAdap.Data(2000:2050)));
                    A_post=LAdap.getPartialStridesAsATS(find(RAdap.Data(2090:2100)));
                    S=LBaseSlow.getPartialStridesAsATS(find(LBaseSlow.Data(end-40:end))); %young 60:95
                    F=LBaseFast.getPartialStridesAsATS(find(LBaseFast.Data(end-40:end)));
                    P=LPost.getPartialStridesAsATS(find(LPost.Data(end-40:end))); %young 300-50:300
%                     Pos=LPosi.getPartialStridesAsATS(find(LPosi.Data(2:10)));
%                     N=LNeg.getPartialStridesAsATS(find(LNeg.Data(2:10)));
                    
                    %Early
                    
                    tit=['L' muscle{m}];
                    
            end
            
            condColors=colorOrder;
            % ph=[];
            ph1=[];
            prc=[16,84];
            MM=sum(alignmentLengths);
            M=cumsum([0 alignmentLengths]);
            xt=sort([M,M(1:end-1)+[diff(M)/2]]);
            phaseSize=8;
            xt=[0:phaseSize:MM];
            %xt=[0:8:MM];s
            fs=16; %FontSize
            
            ph=subplot(5,6,lm(m)+l-1);
            set(gcf,'color','w');
            %     set(ph,'Position',[.07 .48 .35 .45]);
            hold on
            if late==1
                S.plot(fh,ph,condColors(3,:),[],0,[-49:0],prc,true);
                F.plot(fh,ph,condColors(4,:),[],0,[-49:0],prc,true);
                B.plot(fh,ph,condColors(1,:),[],0,[-49:0],prc,true);
                A_late.plot(fh,ph,condColors(3,:),[],0,[-49:0],prc,true);
%                 Pos.plot(fh,ph,condColors(6,:),[],0,[-49:0],prc,true);
            else
                A.plot(fh,ph,condColors(2,:),[],0,[-49:0],prc,true);
                A_post.plot(fh,ph,condColors(4,:),[],0,[-49:0],prc,true);
                P.plot(fh,ph,condColors(5,:),[],0,[-49:0],prc,true);
                
%                 N.plot(fh,ph,condColors(7,:),[],0,[-49:0],prc,true);
                
            end
            
            axis tight
            ylabel('')
            ylabel(tit)
            set(ph,'YTick',[0,1],'YTickLabel',{'0%','100%'})
            grid on
            ll=findobj(ph,'Type','Line');

        end
    end
    legend(ll(end:-1:1),condlegend{:})
end%%
