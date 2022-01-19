function runRegression(Data, normalizeData, isGroupData, dataId, resDir, saveResAndFigure, version, usefft, regressorNames, summFlag) 
% perform regression anlysis V2 (see grant one note: Regression discussion (two transitions)
% printout the regression results and save the results to destination
% folders (if saveResAndFigure flag is on)
% ----- Arguments ------
% - Data: a 1x5 cell where each cell contains a 12x28 matrix. The cell
% corresponds to data for: adapt, envSwitch, taskSwitch, transition1 and
% transition 2. The matrix size might differ due to removal of bad data.
% The cell can also be 1x4 if there is only 1 transition
% - normalizeData: boolean flag of whether or not to normalize the vector
% (regressor) by the length
% - isGroupData: boolean flag indicating the regression is for individual
% (0) or group results (1)
% - dataId: a string representing the data id (groupID if group data and
% subjectID if individual data), with potentially other keywords will be used in naming the saved results.
% - resDir: String, the directory to save the results figures, OPTIONAL if
% saveResAndFigure is false.
% - saveResAndFigure: a boolean flag to indicate if the results should be
% saved
% -version: 1 if 2 regressor and 2 if 3 regressors
% - usefft: OPTIONAL, boolean flag indicating if should use fft of the data to
% approximate deltaOn-, default false.
% - regressorNames: OPTIONAL, a cell array of the regressor names, size of
% 1 x 5, default name: {'Adapt','WithinContextSwitch','MultiContextSwitch','Trans1','Trans2'}
% - summFlag: the method to summarize across subjects, only relevant if
% isGroupData = true, default nanmedian.
% 
% ----- Returns ------
%  none
% 
    if nargin < 7 || isempty(version)
        version = 1; %default 1, 2 regressor, pablo's model
    end
    if nargin < 8 || isempty(usefft)
        usefft = false; %default false
    end
    if nargin < 9
        regressorNames = {'Adapt','NonAdapt','MultiEnvTrans','Trans1','Trans2'}; %default names
    end
    if nargin < 10
        summFlag = 'nanmedian'; %default summarize with median
    end
    
    if ~isGroupData
        for i = 1:size(Data,2)
            Data{i} = reshape(Data{i}, [],1); %make it a column vector
        end
    else %group data, take the median
        for i = 1:size(Data,2)
            eval(['fun=@(x) ' summFlag '(x,4);']);
            d=fun(Data{i});
            Data{i} = reshape(d, [],1); %make it a column vector
        end
    end

    if usefft %do fft - run only once
        Data{size(Data,2) + 1} = Data{1}; %store the current on to the last
        Data{1} = fftshift(Data{1},1);
    end
    
    fprintf('\n\n\n')
    normalizeData
    if normalizeData
        for i = 1:size(Data,2)
            Data{i} = Data{i}/norm(Data{i});
        end
    end

    %define model based on the version, version has to fall in 1 of the 3
    %categories, otherwise there is a bug in the code.
    if version == 1 %default, 3 regressors version
        trans1Model = [regressorNames{4} '~' regressorNames{1} '+' regressorNames{2} '-1'];
        if (length(Data) == 5)
            trans2Model = [regressorNames{5} '~' regressorNames{1} '+' regressorNames{2} '-1'];
        end
    else %3 regressor model
        trans1Model = [regressorNames{4} '~' regressorNames{1} '+' regressorNames{2} '+' regressorNames{3} '-1'];
        if (length(Data) == 5)
            trans2Model = [regressorNames{5} '~' regressorNames{1} '+' regressorNames{2} '+' regressorNames{3} '-1'];
        end
    end
    
    %%% Run regression analysis V2
    
    tableData=table(Data{:},'VariableNames',regressorNames);
    fitTrans1NoConst=fitlm(tableData,trans1Model)%exclude constant
    modelsToPlot = {fitTrans1NoConst};
    Rsquared = fitTrans1NoConst.Rsquared
    %compute adaptation and switch index
    beta1_index = computeBetaIndex(fitTrans1NoConst);
    
    if (length(Data) == 5)
        fprintf('\n\n')

        fitTrans2NoConst=fitlm(tableData,trans2Model)%exclude constant
        Rsquared = fitTrans2NoConst.Rsquared
        %compute adaptation and switch index
        beta2_index = computeBetaIndex(fitTrans2NoConst);
        modelsToPlot{end+1} = fitTrans2NoConst;
    end
    %compute and print out relative vector norm to assess the length
    %difference between regressors
    fprintf('\n\n')
    vec_norm = vecnorm(fitTrans1NoConst.Variables{:,:});
    relNom = normalize(vec_norm,'norm',1)
    
    if normalizeData
        f = plotRegBetas(modelsToPlot, [num2str(version) 'Normalized'], relNom);
    else
        f = plotRegBetas(modelsToPlot, [num2str(version) 'NotNormalized'], relNom);
    end
           
    if saveResAndFigure
        if not(isfolder(resDir))
            mkdir(resDir)
        end
        if ~isGroupData
            save([resDir dataId '_fft_' num2str(usefft) '_modelOpt_' num2str(version) '_norm_' num2str(normalizeData)], '-regexp','fitTrans[0-9]NoConst','beta[0-9]_index','relNom');
            saveas(f, [resDir dataId '_fft_' num2str(usefft) '_modelOpt_' num2str(version) '_norm_' num2str(normalizeData) '_Betas'])
            saveas(f, [resDir dataId '_fft_' num2str(usefft) '_modelOpt_' num2str(version) '_norm_' num2str(normalizeData) '_Betas.png'])
        else
            %version convention: first digit: use first or last stride, 2nd digit:
            %use fft or not, 3rd digit: normalize or not, i.e., ver_101 = use first
            %20 strides, no fft and normalized data
%           save([resDir 'Group_' dataId '_fft_' num2str(usefft) '_norm_' num2str(normalizeData)], 'fitTrans1NoConst','fitTrans2NoConst','beta1_index','beta2_index','relNom');
            save([resDir 'Group_' dataId '_fft_' num2str(usefft) '_modelOpt_' num2str(version) '_norm_' num2str(normalizeData)],'-regexp','fitTrans[0-9]NoConst','beta[0-9]_index','relNom');
            saveas(f, [resDir 'Group_' dataId '_fft_' num2str(usefft) '_modelOpt_' num2str(version) '_norm_' num2str(normalizeData) '_Betas'])
            saveas(f, [resDir 'Group_' dataId '_fft_' num2str(usefft) '_modelOpt_' num2str(version) '_norm_' num2str(normalizeData) '_Betas.png'])
        end
    end
end

function f = plotRegBetas(models, modelVerKeywords, relNom)
% models can be a list of 1 or multiple models
% the keywords will include model version (Usually a number 1 or 2) and
% normalized or not
%%  
    colorOrder=colororder;
    ylimRange = [-1.1,1.5];
    pThreshold = 0.05;
    f = figure('units','normalized','outerposition',[0 0 1 1]);
    annotationSpace = 0.05; %shrink the figure to leave space for figure annotations that will display R^2 and relative norm of coefficients
    annotationStrs= cell(1,numel(models));
    annotationLocs = nan(numel(models),2); %each column: x and y loc
    for modelIdx = 1:numel(models)
        sf = subplot(1,numel(models),modelIdx);
        originalPos = sf.Position;
        sf.Position = [originalPos(1) originalPos(2) + annotationSpace originalPos(3) originalPos(4)-annotationSpace];
        model = models{modelIdx};
        hold on;
        sigMarkOffset = range(ylimRange) * 0.03;
        for varIdx = 1:length(model.Coefficients.Estimate)
            beta = model.Coefficients.Estimate(varIdx);
            bar(varIdx, beta,'FaceColor',colorOrder(varIdx,:),'DisplayName',model.CoefficientNames{varIdx});
            er = errorbar(varIdx,model.Coefficients.Estimate(varIdx),model.Coefficients.SE(varIdx),model.Coefficients.SE(varIdx),'LineStyle','none','Color',[0 0 0],'LineWidth',3,'DisplayName','SE');
            if model.Coefficients.pValue(varIdx) <= pThreshold
%                 sigSc = scatter(varIdx,sign(beta) .* (abs(beta) + model.Coefficients.SE(varIdx) + sigMarkOffset),180, '*','k','HandleVisibility','off'); %the sign helps to put the * to be above pos value and below neg value
                sigSc = scatter(varIdx,sign(beta) .* (abs(beta) + model.Coefficients.SE(varIdx) + sigMarkOffset),180, '*','k','DisplayName',['p<=' num2str(pThreshold)]); %the sign helps to put the * to be above pos value and below neg value
            end
        end
        xticks(1:varIdx);
        xticklabels(model.CoefficientNames)
        xlim([0.5,varIdx+0.5])
        ylim(ylimRange)
        title([model.ResponseName ' Model' modelVerKeywords])
        if (modelIdx == 1) %only have y label for the left most (1st) subplot
            ylabel('Coefficient Value')
        end
        if numel(models) > 1 %more than 1 element, write things in multiple lines
            annotationStrs{modelIdx} = {['Adjusted R^2=' num2str(model.Rsquared.Adjusted,4) '; Ordinary R^2=' num2str(model.Rsquared.Ordinary,4)]};
            if modelIdx == 1 %the relNom is the same for all models only need to print it once
                annotationStrs{modelIdx}{end+1}= ['Relative Norm of Variables: ' mat2str(relNom,2)];
            end
        else %otherwise in 1 line
            annotationStrs{modelIdx} = {['Adjusted R^2=' num2str(model.Rsquared.Adjusted,4) '; Ordinary R^2=' num2str(model.Rsquared.Ordinary,4) '. Relative Norm of Variables: ' mat2str(relNom,2)]};
        end
        annotationLocs(modelIdx,:) = [originalPos(1),originalPos(2)];
    end
    legendItems = findall(gcf,'type','bar');
    if numel(models) > 1
        legendItems = legendItems(1:length(model.Coefficients.Estimate));
    end
    legendItems = [flipud(legendItems); er]; %reverse order to first plotted item appear first since by default last item is listed first
    if (exist('sigSc','var'))
        legendItems(end+1) = sigSc;
    end
    if numel(models) > 1
        legend(legendItems) %TODO: this would sometimes require manually moving legend around before saving, not ideal, but ok for now.
    else %if only 1 figure, can place legend outside (space is enough)
        legend(legendItems,'Location','bestoutside'); 
    end

    set(findall(gcf,'-property','FontSize'),'FontSize',30)
    delete(findall(gcf,'type','annotation'));
    for modelIdx = 1:numel(models)
        annotation('textbox', [annotationLocs(modelIdx,1),annotationLocs(modelIdx,2)*0.9, 0, 0], 'string', annotationStrs{modelIdx},'fitBoxToText','on','FontSize',30,'EdgeColor','none')
    end
end
