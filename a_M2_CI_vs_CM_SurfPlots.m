clear; clc

%Ritwika VPS; Plotting figures for memory game simulation--these are the key surface plots that go into the main txt and SI.

%-----------------------------------------------------------------------------------------------------------------------------------------------------------
%Note that this uses the cmocean function from FileExchange, which is available here (and should be in the path: 
%https://www.mathworks.com/matlabcentral/fileexchange/57773-cmocean-perceptually-uniform-colormaps.
%CHANGE PATH ACCORDINGLY
DataPath = '~/Desktop/GoogleDriveFiles/research/CollectiveMemoryvsCollectiveIntelligence/';%MemoryGameData/';
%-----------------------------------------------------------------------------------------------------------------------------------------------------------
cd(DataPath)
MemoryDistCondition_Vec = {'NoRedundRandom', 'RedundNoRepBits', 'NoRedund1Come1Serve', 'NoRedundRandSeq'}; %various memory conditions

%Main text figs: We are going to plot, in 2 rows, 1 column, the difference in covered bits (CM-CI) as a propotion of total task size, so this figure can go with 
%the memory game schematic.
figure1 = figure('PaperType','<custom>','PaperSize',[7.25 9.75],'Color',[1 1 1]);

%Case: 'NoRedundRandom'
MemoryDistCond_Str = 'NoRedundRandom'; 
LineClr = [1 1 1];TitleTxt = 'B'; XlabelOrNo = false; ColorbarOrNo = true; %other fn inputs
axes1 = axes('Parent',figure1,'Position',[0.149626552692587 0.530293721538477 0.636078841498284 0.337257285637112]); %initialise axis
[c_MaxVal_NoRedundRand, c_MinVal_NoRedundRand] = PlotMainTxtFig_CIvsCMsurf(MemoryDistCond_Str,DataPath,axes1,LineClr,TitleTxt,XlabelOrNo,ColorbarOrNo);
annotation(figure1,'textbox',[0.132889638795151 0.889086098144991 0.195850518685164 0.0338345864661654],'String',MemoryDistCond_Str); %Annotation for memory condition

%Case: 'RedundNoRepBits'
MemoryDistCond_Str = 'RedundNoRepBits';
LineClr = [0 0 0];TitleTxt = 'C'; XlabelOrNo = true; ColorbarOrNo = false; %other fn inputs
axes2 = axes('Parent',figure1,'Position',[0.149626552692587 0.167980675804921 0.636078841498284 0.337257285637112]);
[c_MaxVal_RedundNoRepBits, c_MinVal_RedundNoRepBits] = PlotMainTxtFig_CIvsCMsurf(MemoryDistCond_Str,DataPath,axes2,LineClr,TitleTxt,XlabelOrNo,ColorbarOrNo);
annotation(figure1,'textbox',[0.121078615173103 0.475207535567543 0.195850518685164 0.0338345864661654],'String',MemoryDistCond_Str); %Annotation for memory condition

%put together common colourbar + colourmap (using the cmocean function)
cbar_Max_Main = max(c_MaxVal_NoRedundRand,c_MaxVal_RedundNoRepBits);
cbar_Min_Main = min(c_MinVal_NoRedundRand, c_MinVal_RedundNoRepBits);
set(axes2,'CLim',[cbar_Min_Main cbar_Max_Main]); cmocean('balance','pivot',0.01); 
set(axes1,'CLim',[cbar_Min_Main cbar_Max_Main]); %cmocean('balance','pivot',0.01); hold(axes1,'off'); %GOING TO JUST SET THIS MANUALLY!
disp('Remember to set the color map manually for subplot(2) for the main txt fig. We are doing cmocean: balance, pivot at 0.01')
annotation(figure1,'textbox',[0.866760785902084 0.859484296099058 0.0437792747739761 0.0547368422486729],'VerticalAlignment','middle',...
    'String','$\Delta P_{c}$','Interpreter','latex','HorizontalAlignment','center','FontSize',24,'FitBoxToText','off','EdgeColor','none'); %color bar label


%Other Annotations
annotation(figure1,'doublearrow',[0.296754593953732 0.784232365145228],[0.883519206939282 0.883519206939282],'Head2Style','rectangle','Head2Length',1,...
    'Head1Style','rectangle','Head1Length',1); %doublearrow
annotation(figure1,'doublearrow',[0.817427385892116 0.817427385892116],[0.60470879801735 0.86843689148522],'Head2Style','rectangle','Head2Length',1,...
    'Head1Style','rectangle','Head1Length',1); %doublearrow
annotation(figure1,'textbox',[0.448132780082988 0.876084262701363 0.176348547717842 0.0128245241356262],'VerticalAlignment','middle',... %textbox
    'String',{'$T > m_a$'},'Interpreter','latex','HorizontalAlignment','center','FontSize',24,'FitBoxToText','off','EdgeColor','none','BackgroundColor',[1 1 1]);
annotation(figure1,'textbox',[0.842323651452282 0.671623296158612 0.207657941460906 0.0260223048327137],'VerticalAlignment','middle',... %textbox
    'String',{'$T > N_a$'},'Rotation',90,'Interpreter','latex','HorizontalAlignment','center','FontSize',24,'FitBoxToText','off','EdgeColor','none','BackgroundColor',[1 1 1]);
annotation(figure1,'arrow',[0.272047424616258 0.272047424616258],[0.619338417095159 0.795722180932797],'Color',[1 1 1],'LineWidth',1); % Create arrow
annotation(figure1,'textbox',[0.264496573537165 0.66493889223312 0.0779375489989868 0.0434205297294489],'Color',[1 1 1],'VerticalAlignment','middle','String','Decreasing',...
    'Rotation',90,'HorizontalAlignment','center','FontSize',23,'FontName','Helvetica Neue','FitBoxToText','off','EdgeColor','none'); % Create textbox
annotation(figure1,'textbox',[0.271472448452298 0.776178156826149 0.0407736059309837 0.0434205297294491],'Color',[1 1 1],'VerticalAlignment','middle','String','$N_a$',...
    'Rotation',90,'Interpreter','latex','HorizontalAlignment','center','FontSize',25,'FontName','Helvetica Neue','FitBoxToText','off','EdgeColor','none');% Create textbox
annotation(figure1,'arrow',[0.315023253782835 0.581661630166598],[0.590978715289424 0.590978715289424],'Color',[1 1 1],'LineWidth',1); % Create arrow
annotation(figure1,'textbox',[0.388151020140806 0.544887671686087 0.0779375489989874 0.0434205297294488],'Color',[1 1 1],'VerticalAlignment','middle','String','Decreasing',...
    'HorizontalAlignment','center','FontSize',23,'FontName','Helvetica Neue','FitBoxToText','off','EdgeColor','none'); % Create textbox
annotation(figure1,'textbox',[0.546223976610017 0.542415483799807 0.0779375489989864 0.0434205297294489],'Color',[1 1 1],'VerticalAlignment','middle','String','$m_a$',...
    'Interpreter','latex','HorizontalAlignment','center','FontWeight','bold','FontSize',25,'FontName','Helvetica Neue','FitBoxToText','off','EdgeColor','none'); % Create textbox


%%
%Supplemetary Figs
for i = 1:numel(MemoryDistCondition_Vec)

    %set the MainTxtClim vector: For the figures for NoRedundRandom and RedundNoRepBits conditions, we want the CM-CI plots to have the same colormap *and* colormap pivot 
    % (see relevant cmocean documentation + the SI plotting function: PlotSIFig_CIvsCMsur) for visual coherence. So, for these conditions, we use the color axis limits that 
    % we used in the main txt figures (which uses the combined max and combined min for the CM-CI diff for the NoRedundRandom and RedundNoRepBits conditions; see above for
    % main txt figs. So, these values are passed to this function. For other conditions, please use [NaN NaN] since there is an if condition that uses this as a check to 
    % implement these colour axis limits.
    if strcmp(MemoryDistCondition_Vec{i},'NoRedundRandom') || strcmp(MemoryDistCondition_Vec{i},'RedundNoRepBits')
        MainTxtClim = [cbar_Min_Main cbar_Max_Main];
    else
        MainTxtClim = [NaN NaN];
    end
    PlotSIFig_CIvsCMsurf(MemoryDistCondition_Vec{i},DataPath,MainTxtClim) %PLOT!!
end


%-----------------------------------------------------------------------------------------------------------------------------------------------------------
%Functions:
%--------------------------------------------------------------------------------------------
%This function gets the number of covered bits given the number of excluded bits.
%--------------------------------------------------------------------------------------------
function NumCoveredBits = GetTaskCoverage(TaskSize,NumExcBits)
    NumCoveredBits = TaskSize - NumExcBits; %number of covered bits is diff b/n task size and number of excluded bits
    if NumCoveredBits < 0 %CHECK
        error('Number of covered bits should not be zero')
    end
end


%--------------------------------------------------------------------------------------------
%This function gets the proportion of CM-CI covered bits as a proportion of task size.
%--------------------------------------------------------------------------------------------
function CoveredBitsDiffProp_CM_CI = GetCoveredBitsDiffProp_CM_CI(TaskSize,NumExcBits_CM,NumExcBits_CI)
    
    %get number of covered bits for CI and CM 
    NumCoveredBits_CM = GetTaskCoverage(TaskSize,NumExcBits_CM); 
    NumCoveredBits_CI = GetTaskCoverage(TaskSize,NumExcBits_CI);

    CoveredBitsDiffProp_CM_CI = (NumCoveredBits_CM-NumCoveredBits_CI)/TaskSize; %get diff (CM-CI) as proportion of task size
end


%--------------------------------------------------------------------------------------------
%This function takes in the data structure and converts all int64 etc to double to allow calculations (cuz the data was saved in python).
%--------------------------------------------------------------------------------------------
function DataStruct = ConvertReqDataToDouble(DataStruct)

    FieldNames = fieldnames(DataStruct); %get field names
    for i = 1:numel(FieldNames)
        if ~isa(DataStruct.(FieldNames{i}),'double') && ~isstr(DataStruct.(FieldNames{i})) %if field is not a string and not a double, convert to double
            DataStruct.(FieldNames{i}) = double(DataStruct.(FieldNames{i}));
        end
    end
end


%--------------------------------------------------------------------------------------------
% This function plots the surface plots for CI vs CM for the various cases. Each instance of this function plots a subplot in a figure. These are plots that go into the main text. 
% 
% Inputs: - MemoryDistCond_Str: the memrody distribution condition (string)
%         - DataPath: path to data
%         - axes1: axis handle (initialised outside the function, in the main text)
%         - LineClr: RGB colour (3 element vector) for the lines indicating T = N_a x m_a, T = N_a, T = m_a
%         - TitleTxt: subplot titles (e.g., A, B, etc; input is string)
%         - XlabelOrNo: whether there should be an x label for subplot (logical)
%         - ColorbarOrNo: whether there should be a colorbar for subplot (logical)
% 
% This function also outputs the max and min value of the plotted difference in task coverage proportions (CM-CI) so that these values can then be used to estimate 
% the common colour bar limits for the tewo subplots (NoRedundRandom and RedundNoRepBits).
%--------------------------------------------------------------------------------------------
function [c_MaxVal, c_MinVal] = PlotMainTxtFig_CIvsCMsurf(MemoryDistCond_Str,DataPath,axes1,LineClr,TitleTxt,XlabelOrNo,ColorbarOrNo)

    cd(DataPath) %get data struct with data to plot
    DataStruct = load(['CI_vs_CM_Sims_MemoryDistCondition__' MemoryDistCond_Str '.mat']); %load .mat file as a structure
    %Since these were saved from Python, some of the vriables are saved as double and some others as int64, so we have to transform all numbers to converted to double.
    DataStruct = ConvertReqDataToDouble(DataStruct);
   
    %Get specific data to plot
    Xvec = (DataStruct.TaskSize)./(DataStruct.AgentMemory_Vec); Yvec = (DataStruct.TaskSize)./(DataStruct.NumAgents_Vec); %set X and Y vectors for plotting
    CoveredBitsDiffProp_CM_CI = GetCoveredBitsDiffProp_CM_CI(DataStruct.TaskSize,DataStruct.StableExcBits_CM,DataStruct.MeanExcBits_CI); %get the covered bits diff prop to plot
    %get max and min values for colour bar (will pass this as output to have a single colour bar for upper and lower figs).
    c_MaxVal = max(CoveredBitsDiffProp_CM_CI(:)); c_MinVal = min(CoveredBitsDiffProp_CM_CI(:)); %get max and min values of plotted data

    %CM-CI proportion of covered bits (as proportion of task size)
    hold(axes1,'on');
    surf(Xvec,Yvec,CoveredBitsDiffProp_CM_CI,'Parent',axes1,'EdgeColor','none'); %plotting excluded bits as a proportion of task size  
    plot3(Xvec,(DataStruct.TaskSize)./Xvec,20*ones(size(Xvec)),'LineWidth',2.5,'Color',LineClr,'LineStyle','--'); %the line of TaskSize = Na*ma; white
    plot3(ones(size(Yvec)),Yvec,20*ones(size(Yvec)),'LineWidth',2.5,'Color',LineClr,'LineStyle',':') %vertical line for T/ma = 1; white
    plot3(Xvec,ones(size(Xvec)),20*ones(size(Xvec)),'LineWidth',2.5,'Color',LineClr,'LineStyle',':') %horizontal line for T/Na = 1; white
    ylim(axes1,[min(Yvec) max(Yvec)]); 
    title(TitleTxt); ylabel('$T/N_a$','Interpreter','latex'); %labels
    if XlabelOrNo %optional x label
        xlabel('$T/m_a$','Interpreter','latex'); 
    end
    if ColorbarOrNo %optional colour bar
        colorbar(axes1,'Position',[0.862643093792829 0.166047087980173 0.0330261975457532 0.701363073110285]);
    end
    view(2); hold(axes1,'off');
    set(axes1,'FontSize',24,'TickDir','out','XLimitMethod','tight','XMinorTick','on','XScale','log','XTick',[0.5 1 10],'XTickLabel',...
        {'0.5','1','10'},'YLimitMethod','tight','YMinorTick','on','YScale','log','YTick',[0.5 1 10],'YTickLabel',{'0.5','1','10'},'ZLimitMethod','tight');
end

%--------------------------------------------------------------------------------------------
% This function plots the surface plots for CI vs CM for the various cases. This function, in contrast with the previous plotting function (see above; PlotMainTxtFig_CIvsCMsurf)
% plots the entire figure consisting of A) CM covered propotion; B) Mean CI covered proportion; C) Diff in covered proportion (CM-CI); D) std. dev of CI covered prop. 
% These are plots that go into the supplementary.
%
% Inputs: - MemoryDistCond_Str: the memrody distribution condition (string)
%         - DataPath: path to data
%         - MainTxtClim: colour axis min and max values in a vector ([min max]). For the figures for NoRedundRandom and RedundNoRepBits conditions, we want the CM-CI plots to 
%                        have the same colormap *and* colormap pivot (see relevant cmocean documentation) for visual coherence. So, for these conditions, we use the color axis 
%                        limits that we used in the main txt figures (which uses the combined max and combined min for the CM-CI diff for the NoRedundRandom and RedundNoRepBits 
%                        conditions. So, these values are passed to this function. For other conditions, please use [NaN NaN] since there is an if condition that uses this as 
%                        a check to implement these colour axis limits.
%--------------------------------------------------------------------------------------------
function PlotSIFig_CIvsCMsurf(MemoryDistCond_Str,DataPath,MainTxtClim)

    cd(DataPath) %get data struct with data to plot
    DataStruct = load(['CI_vs_CM_Sims_MemoryDistCondition__' MemoryDistCond_Str '.mat']); %load .mat file as a structure
    %Since these were saved from Python, some of the vriables are saved as double and some others as int64, so we have to transform all numbers to doubled.
    DataStruct = ConvertReqDataToDouble(DataStruct);

    %Plotting
    figure1 = figure('PaperType','<custom>','PaperSize',[13 9.75],'Color',[1 1 1]);
    % c_MaxVal = max([max(DataStruct.StableExcBits_CM) max(DataStruct.MeanExcBits_CI)])/(DataStruct.TaskSize); %get max and min values for colour bar
    % c_MinVal = min([min(DataStruct.StableExcBits_CM) min(DataStruct.MeanExcBits_CI)])/(DataStruct.TaskSize);
    c_MinVal = 0; c_MaxVal = 1; %setting colour limits to 0 and 1 (cuz we are looking at proportions)
    Xvec = (DataStruct.TaskSize)./(DataStruct.AgentMemory_Vec); Yvec = (DataStruct.TaskSize)./(DataStruct.NumAgents_Vec); %set X and Y vectors for plotting


    %CM proportion of covered bits (proportion of task size)
    axes1 = axes('Parent',figure1,'Position',[0.153041474654378 0.54799048495127 0.281663699204022 0.340833285422715]); hold(axes1,'on');
    surf(Xvec,Yvec,1 - ((DataStruct.StableExcBits_CM)/(DataStruct.TaskSize)),'Parent',axes1,'EdgeColor','none'); %plotting covered bits as a proportion of task size
    plot3(Xvec,(DataStruct.TaskSize)./Xvec,20*ones(size(Xvec)),'LineWidth',2.5,'Color',[0 0 0],'LineStyle','--'); %the line of TaskSize = Na*ma; 
    plot3(ones(size(Yvec)),Yvec,20*ones(size(Yvec)),'LineWidth',2.5,'Color',[0 0 0],'LineStyle',':') %vertical line for T/ma = 1; 
    plot3(Xvec,ones(size(Xvec)),20*ones(size(Xvec)),'LineWidth',2.5,'Color',[0 0 0],'LineStyle',':') %horizontal line for T/Na = 1; 
    title('A'); ylabel('$T/N_a$','Interpreter','latex'); %labels
    view(2); ylim(axes1,[min(Yvec) max(Yvec)]); 
    %COLORBAR---
    colorbar(axes1,'Position',[0.439432212550492 0.546971569839302 0.0158673266200148 0.288627935723119],'Ticks',[0 0.2 0.4 0.6 0.8 1]); 
    clim([c_MinVal c_MaxVal]); cmocean('haline'); 
    annotation(figure1,'textbox',[0.43434588907927 0.842489765067624 0.0437792747739764 0.0547368422486727],'VerticalAlignment','middle','String','$P_{c} ^{\rm CM}$',...
    'Interpreter','latex','HorizontalAlignment','center','FontSize',22,'FitBoxToText','off','EdgeColor','none'); %colorbar label
    %-----------
    hold(axes1,'off');
    set(axes1,'FontSize',24,'TickDir','out','XLimitMethod','tight','XMinorTick','on','XScale','log','XTick',[0.5 1 10],'XTickLabel',{'','',''},'YLimitMethod',...
    'tight','YMinorTick','on','YScale','log','YTick',[0.5 1 10],'YTickLabel',{'0.5','1','10'},'ZLimitMethod','tight');
    %Annotations
    annotation(figure1,'doublearrow',[0.211981566820276 0.211981566820276],[0.63040791100123 0.886515451174277],'Head2Width',7,'Head2Style','rectangle',...
    'Head2Length',1,'Head1Width',7,'Head1Style','rectangle','Head1Length',1); % Create doublearrow
    annotation(figure1,'textbox',[0.213824884792627 0.682812473673639 0.107761439470715 0.0440107648924829],'VerticalAlignment','middle','String',{'$T > N_a$'},...
        'Rotation',90,'Interpreter','latex','HorizontalAlignment','center','FontSize',22,'FitBoxToText','off','EdgeColor','none'); % Create textbox
    annotation(figure1,'doublearrow',[0.223041474654378 0.432936973440159],[0.616810877626691 0.616810877626691],'Head2Width',7,'Head2Style','rectangle',...
        'Head2Length',1,'Head1Width',7,'Head1Style','rectangle','Head1Length',1); % Create doublearrow
    annotation(figure1,'textbox',[0.285714285714286 0.569839307787383 0.0779375489989865 0.0434205297294489],'VerticalAlignment','middle','String',{'$T > m_a$'},...
        'Interpreter','latex','HorizontalAlignment','center','FontSize',22,'FitBoxToText','off','EdgeColor','none'); % Create textbox
    annotation(figure1,'arrow',[0.230627306273062 0.230627306273062],[0.692448702101354 0.848832465938992]); % Create arrow
    annotation(figure1,'textbox',[0.264496573537163 0.697156983930766 0.0779375489989863 0.0434205297294489],'VerticalAlignment','middle','String','Decreasing',...
        'Rotation',90,'HorizontalAlignment','center','FontSize',21,'FontName','Helvetica Neue','FitBoxToText','off','EdgeColor','none'); % Create textbox
    annotation(figure1,'textbox',[0.267527675276752 0.812113720642754 0.0407736059309838 0.0434205297294489],'VerticalAlignment','middle','String','$N_a$',...
        'Rotation',90,'Interpreter','latex','HorizontalAlignment','center','FontSize',22,'FitBoxToText','off','EdgeColor','none'); % Create textbox
    annotation(figure1,'arrow',[0.279520295202952 0.40590405904059],[0.635588380716933 0.635588380716933]);% Create arrow
    annotation(figure1,'textbox',[0.28755930416447 0.637824474660064 0.0779375489989863 0.0434205297294489],'VerticalAlignment','middle','String','Decreasing',...
        'HorizontalAlignment','center','FontSize',21,'FontName','Helvetica Neue','FitBoxToText','off','EdgeColor','none'); % Create textbox
    annotation(figure1,'textbox',[0.354902477596204 0.635352286773785 0.0779375489989863 0.0434205297294489],'VerticalAlignment','middle','String','$m_a$',...
        'Interpreter','latex','HorizontalAlignment','center','FontSize',22,'FitBoxToText','off','EdgeColor','none');% Create textbox


    %CI proportion of mean covered bits (proportion of task size)
    axes2 = axes('Parent',figure1,'Position',[0.568497591118559 0.54799048495127 0.281663699204022 0.340833285422715]); hold(axes2,'on');
    surf(Xvec,Yvec,1-((DataStruct.MeanExcBits_CI)/(DataStruct.TaskSize)),'Parent',axes2,'EdgeColor','none'); %plotting covered bits as a proportion of task size
    plot3(Xvec,(DataStruct.TaskSize)./Xvec,20*ones(size(Xvec)),'LineWidth',2.5,'Color',[1 1 1],'LineStyle','--'); %the line of TaskSize = Na*ma; 
    plot3(ones(size(Yvec)),Yvec,20*ones(size(Yvec)),'LineWidth',2.5,'Color',[1 1 1],'LineStyle',':') %vertical line for T/ma = 1; 
    plot3(Xvec,ones(size(Xvec)),20*ones(size(Xvec)),'LineWidth',2.5,'Color',[1 1 1],'LineStyle',':') %horizontal line for T/Na = 1; 
    title('B'); view(2); ylim(axes2,[min(Yvec) max(Yvec)]); hold(axes2,'off'); 
    %COLORBAR---
    colorbar(axes2,'Position',[0.855023610399955 0.546971569839302 0.015867326620015 0.288627935723119],'Ticks',[0 0.2 0.4 0.6 0.8 1]); %COlour bar
    clim([c_MinVal c_MaxVal]); cmocean('haline'); 
    annotation(figure1,'textbox',[0.860152340692173 0.842489765067622 0.0437792747739761 0.0547368422486725],'VerticalAlignment','middle','String','$\mu(P_{c}^{\rm CI})$',...
    'Interpreter','latex','HorizontalAlignment','center','FontSize',22,'FitBoxToText','off','EdgeColor','none'); %colorbar label
    %-----------
    set(axes2,'FontSize',24,'TickDir','out','XLimitMethod','tight','XMinorTick','on','XScale','log','XTick',[0.5 1 10],'XTickLabel',{'','',''},'YLimitMethod',...
    'tight','YMinorTick','on','YScale','log','YTick',[0.5 1 10],'YTickLabel',{'0.5','1','10'},'ZLimitMethod','tight');


    %CM-CI covered proportion
    CoveredBitsDiffProp_CM_CI = GetCoveredBitsDiffProp_CM_CI(DataStruct.TaskSize,DataStruct.StableExcBits_CM,DataStruct.MeanExcBits_CI);
    axes3 = axes('Parent',figure1,'Position',[0.153041474654378 0.160679851668725 0.281663699204022 0.340833285422714]); hold(axes3,'on');
    surf(Xvec,Yvec,CoveredBitsDiffProp_CM_CI,'Parent',axes3,'EdgeColor','none'); %plotting CM-CI covered bits proportion   
    plot3(Xvec,(DataStruct.TaskSize)./Xvec,20*ones(size(Xvec)),'LineWidth',2.5,'Color',[1 1 1],'LineStyle','--'); %the line of TaskSize = Na*ma; 
    plot3(ones(size(Yvec)),Yvec,20*ones(size(Yvec)),'LineWidth',2.5,'Color',[1 1 1],'LineStyle',':') %vertical line for T/ma = 1; 
    plot3(Xvec,ones(size(Xvec)),20*ones(size(Xvec)),'LineWidth',2.5,'Color',[1 1 1],'LineStyle',':') %horizontal line for T/Na = 1; 
    title('C'); xlabel('$T/m_a$','Interpreter','latex'); ylabel('$T/N_a$','Interpreter','latex');
    view(2); ylim(axes3,[min(Yvec) max(Yvec)]); hold(axes3,'off'); 
    %COLORBAR---
    colorbar(axes3,'Position',[0.439432212550492 0.159456118665017 0.015867326620015 0.30407911001236]); 
    if ~all(isnan(MainTxtClim)) %color bar + appropriate pivot for colormap 
        clim(MainTxtClim); 
    else
        clim([0 max(CoveredBitsDiffProp_CM_CI(:))]); 
    end
    cmocean('balance','pivot',0.01);
    annotation(figure1,'textbox',[0.433424230093095 0.459300642694311 0.0437792747739764 0.054736842248673],'VerticalAlignment','middle','String','$\Delta P_{c}$',...
    'Interpreter','latex','HorizontalAlignment','center','FontSize',22,'FitBoxToText','off','EdgeColor','none'); %coorbar label
    %-----------
    set(axes3,'FontSize',24,'TickDir','out','XLimitMethod','tight','XMinorTick','on','XScale','log','XTick',[0.5 1 10],'XTickLabel',{'0.5','1','10'},'YLimitMethod',...
    'tight','YMinorTick','on','YScale','log','YTick',[0.5 1 10],'YTickLabel',{'0.5','1','10'},'ZLimitMethod','tight');
    %Lines demarcating CM-CI plot
    annotation(figure1,'line',[0.149447004608295 0.44147465437788],[0.524103831891224 0.524103831891224],'Color',[0.650980392156863 0.650980392156863 0.650980392156863], ...
        'LineWidth',2,'LineStyle',':'); 
    annotation(figure1,'line',[0.502304147465439 0.502304147465439],[0.489061804697152 0.15333127317676],'Color',[0.650980392156863 0.650980392156863 0.650980392156863],...
        'LineWidth',2,'LineStyle',':');


    %CI proportion of std dev of covered bits (proportion of task size)
    axes4 = axes('Parent',figure1,'Position',[0.568497591118559 0.160679851668725 0.281663699204022 0.340833285422714]); hold(axes4,'on');
    surf(Xvec,Yvec,(DataStruct.StdExcBits_CI)/(DataStruct.TaskSize),'Parent',axes4,'EdgeColor','none'); %plotting std dev covered bits as a proportion of task size
    %Note that SD(X) = SD(1-X), so there is no need to do (1 - SD(excluded bits))
    plot3(Xvec,(DataStruct.TaskSize)./Xvec,20*ones(size(Xvec)),'LineWidth',2.5,'Color',[1 1 1],'LineStyle','--'); %the line of TaskSize = Na*ma; 
    plot3(ones(size(Yvec)),Yvec,20*ones(size(Yvec)),'LineWidth',2.5,'Color',[1 1 1],'LineStyle',':') %vertical line for T/ma = 1; 
    plot3(Xvec,ones(size(Xvec)),20*ones(size(Xvec)),'LineWidth',2.5,'Color',[1 1 1],'LineStyle',':') %horizontal line for T/Na = 1; 
    title('D'); xlabel('$T/m_a$','Interpreter','latex');
    view(2); ylim(axes4,[min(Yvec) max(Yvec)]); hold(axes4,'off'); 
    %COLORBAR---
    colorbar(axes4,'Position',[0.855023610399955 0.159456118665017 0.015867326620015 0.288627935723119]); clim([c_MinVal c_MaxVal]); cmocean('haline'); %Colorbar
    annotation(figure1,'textbox',[0.860829493087557 0.454356266921751 0.0412588044062419 0.054736842248673],'VerticalAlignment','middle','String','$\sigma(P_{c} ^{\rm CI})$',...
    'Interpreter','latex','HorizontalAlignment','center','FontSize',22,'FitBoxToText','off','EdgeColor','none');
    %-----------
    set(axes4,'FontSize',24,'TickDir','out','XLimitMethod','tight','XMinorTick','on','XScale','log','XTick',[0.5 1 10],'XTickLabel',{'0.5','1','10'},'YLimitMethod',...
    'tight','YMinorTick','on','YScale','log','YTick',[0.5 1 10],'YTickLabel',{'0.5','1','10'},'ZLimitMethod','tight');


    %Annotation for memory distribution condition
    annotation(figure1,'textbox',[0.000661375661375549 0.961654135338347 0.0562169312169312 0.0338345864661654],'String',MemoryDistCond_Str,'FitBoxToText','off'); % Create textbox
end

