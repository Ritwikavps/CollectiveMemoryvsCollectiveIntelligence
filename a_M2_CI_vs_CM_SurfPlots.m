clear; clc

%Ritwika VPS; Plotting figures for memory game simulation.
%Note that this uses the viridis function from FileExchange, this might be something we want to change.

%-----------------------------------------------------------------------------------------------------------------------------------------------------------
%CHANGE PATH ACCORDINGLY
DataPath = '~/Desktop/GoogleDriveFiles/research/CollectiveMemoryvsCollectiveIntelligence/MemoryGameData/';
%-----------------------------------------------------------------------------------------------------------------------------------------------------------
cd(DataPath)

MemoryDistCondition_Vec = {'NoRedundRandom', 'RedundNoRepBits', 'NoRedund1Come1Serve', 'NoRedundRandSeq'};

%Main text figs
PlotMainTxtFig_CIvsCMsurf('NoRedundRandom',DataPath)
PlotMainTxtFig_CIvsCMsurf('RedundNoRepBits',DataPath)

%Supplemetary Figs
for i = 1:numel(MemoryDistCondition_Vec)
    PlotSIFig_CIvsCMsurf(MemoryDistCondition_Vec{i},DataPath)
end

%-----------------------------------------------------------------------------------------------------------------------------------------------------------
%Functions:
%--------------------------------------------------------------------------------------------
%This function plots the surface plots for CI vs CM for the various cases. These are plots that go into the main text.
%--------------------------------------------------------------------------------------------
function PlotMainTxtFig_CIvsCMsurf(MemoryDistCond_Str,DataPath)

    cd(DataPath)
    DataStruct = load(['CI_vs_CM_Sims_MemoryDistCondition__' MemoryDistCond_Str '.mat']); %load .mat file as a structure
    %Since these were saved from Python, some of the vriables are saved as double and some others as int64, so we have to transform all
    % numbers to doubled.
    FieldNames = fieldnames(DataStruct); %get field names
    for i = 1:numel(FieldNames)
        if ~isa(DataStruct.(FieldNames{i}),'double') && ~isstr(DataStruct.(FieldNames{i})) %if field is not a string and not a double, convert to double
            DataStruct.(FieldNames{i}) = double(DataStruct.(FieldNames{i}));
        end
    end

    %cm_viridis = viridis();

    %Plotting
    figure1 = figure('PaperType','<custom>','PaperSize',[18.75 9.5],'Color',[1 1 1]);
    c_MaxVal = max([max(DataStruct.StableExcBits_CM) max(DataStruct.MeanExcBits_CI)])/(DataStruct.TaskSize); %get max and min values for colour bar
    c_MinVal = min([min(DataStruct.StableExcBits_CM) min(DataStruct.MeanExcBits_CI)])/(DataStruct.TaskSize);
    c_MinVal = 0; c_MaxVal = 1; %setting colour limits to 0 and 1 (cuz we are looking at proportions)
    Xvec = (DataStruct.TaskSize)./(DataStruct.AgentMemory_Vec); Yvec = (DataStruct.TaskSize)./(DataStruct.NumAgents_Vec); %set X and Y vectors for plotting

    %CM proportion of excluded bits (proportion of task size)
    axes1 = axes('Parent',figure1,'Position',[0.124708994708985 0.134418701476819 0.334659090909082 0.779867012808896]); hold(axes1,'on');
    surf(Xvec,Yvec,(DataStruct.StableExcBits_CM)/(DataStruct.TaskSize),'Parent',axes1,'EdgeColor','none'); %plotting excluded bits as a proportion of task size
    view(2); %colormap(cm_viridis);
    plot3(Xvec,(DataStruct.TaskSize)./Xvec,20*ones(size(Xvec)),'LineWidth',1,'Color',[1 1 1],'LineStyle','--'); %the line of TaskSize = Na*ma; white
    plot3(ones(size(Yvec)),Yvec,20*ones(size(Yvec)),'LineWidth',1,'Color',[1 1 1],'LineStyle',':') %vertical line for T/ma = 1; white
    plot3(Xvec,ones(size(Xvec)),20*ones(size(Xvec)),'LineWidth',1,'Color',[1 1 1],'LineStyle',':') %horizontal line for T/Na = 1; white
    title('A'); ylabel('$T/N_a$','Interpreter','latex'); xlabel('$T/m_a$','Interpreter','latex'); %labels
    ylim(axes1,[0.512820512820513 10]); 
    hold(axes1,'off');
    set(axes1,'CLim',[c_MinVal c_MaxVal],'FontSize',24,'TickDir','out','XLimitMethod','tight','XMinorTick','on','XScale','log','XTick',[0.5 1 10],'XTickLabel',...
        {'0.5','1','10'},'YLimitMethod','tight','YMinorTick','on','YScale','log','YTick',[0.5 1 10],'YTickLabel',{'0.5','1','10'},'ZLimitMethod','tight');
    annotation(figure1,'textbox',[0.126984126984127 0.943609022556391 0.0701058201058201 0.0338345864661654],'String',{'Stable CM Exc Bits'}); % Create textbox

    %CI proportion of excluded bits (proportion of task size)
    axes2 = axes('Parent',figure1,'Position',[0.512139850889846 0.134418701476819 0.334659090909086 0.779867012808896]); hold(axes2,'on');
    surf(Xvec,Yvec,(DataStruct.MeanExcBits_CI)/(DataStruct.TaskSize),'Parent',axes2,'EdgeColor','none'); %plotting excluded bits as a proportion of task size
    view(2); %colormap(cm_viridis);
    plot3(Xvec,(DataStruct.TaskSize)./Xvec,20*ones(size(Xvec)),'LineWidth',1,'Color',[0 0 0],'LineStyle','--'); %the line of TaskSize = Na*ma; black
    plot3(ones(size(Yvec)),Yvec,20*ones(size(Yvec)),'LineWidth',1.5,'Color',[0 0 0],'LineStyle',':') %vertical line for T/ma = 1; black
    plot3(Xvec,ones(size(Xvec)),20*ones(size(Xvec)),'LineWidth',1.5,'Color',[0 0 0],'LineStyle',':') %horizontal line for T/Na = 1; black
    title('B'); xlabel('$T/m_a$','Interpreter','latex'); %labels
    ylim(axes2,[0.512820512820513 10]); hold(axes2,'off');
    set(axes2,'CLim',[c_MinVal c_MaxVal],'FontSize',24,'TickDir','out','XLimitMethod','tight','XMinorTick','on','XScale','log','XTick',[0.5 1 10],'XTickLabel',...
        {'0.5','1','10'},'YLimitMethod','tight','YMinorTick','on','YScale','log','YTick',[0.5 1 10],'YTickLabel',{'0.5','1','10'},'ZLimitMethod','tight');    
    colorbar(axes2,'Position',[0.886243386243377 0.131578947368421 0.0152116402116417 0.781203007518797]); %colorbar
    annotation(figure1,'textbox',[0.502645502645501 0.943609022556392 0.0638227513227514 0.0338345864661654],'String',{'CI Mean Exc Bits'}); % Create textbox

    %Annotations
    annotation(figure1,'doublearrow',[0.589285714285683 0.846560846560805],[0.945864661654141 0.945864661654141],'Head2Style','rectangle','Head2Length',1,...
        'Head1Style','rectangle','Head1Length',1); % Create doublearrow
    
    annotation(figure1,'doublearrow',[0.85978835978835 0.859788359788351],[0.30827067669173 0.914285714285714],'Head2Style','rectangle','Head2Length',1,...
        'Head1Style','rectangle','Head1Length',1); % Create doublearrow
    
    annotation(figure1,'textbox',[0.872453927993762 0.92020300737539 0.0437792747739761 0.0547368422486728],'VerticalAlignment','middle',...
        'String',{'$P_{exc}$'},'Interpreter','latex','HorizontalAlignment','center','FontSize',22,'EdgeColor','none','BackgroundColor',[1 1 1]); % Create textbox
    
    annotation(figure1,'textbox',[0.683201058201013 0.917195488578403 0.0664649085393029 0.0547368422486728],'VerticalAlignment','middle',... % Create textbox
        'String',{'$T > N_a$'},'Interpreter','latex','HorizontalAlignment','center','FontSize',22,'FitBoxToText','off','EdgeColor','none','BackgroundColor',[1 1 1]);
    
    annotation(figure1,'textbox',[0.872473567881897 0.517195488578398 0.0675495188072245 0.0547368422486728],'VerticalAlignment','middle',... % Create textbox
        'String',{'$T > m_a$'},'Rotation',90,'Interpreter','latex','HorizontalAlignment','center','FontSize',22,'EdgeColor','none','BackgroundColor',[1 1 1]); 

    %Annotation for memory distribution condition
    annotation(figure1,'textbox',[0.000661375661375549 0.961654135338347 0.0562169312169312 0.0338345864661654],'String',MemoryDistCond_Str); % Create textbox

end

%--------------------------------------------------------------------------------------------
%This function plots the surface plots for CI vs CM for the various cases. These are plots that go into the supplementary.
%--------------------------------------------------------------------------------------------
function PlotSIFig_CIvsCMsurf(MemoryDistCond_Str,DataPath)

    cd(DataPath)
    DataStruct = load(['CI_vs_CM_Sims_MemoryDistCondition__' MemoryDistCond_Str '.mat']); %load .mat file as a structure
    %Since these were saved from Python, some of the vriables are saved as double and some others as int64, so we have to transform all
    % numbers to doubled.
    FieldNames = fieldnames(DataStruct); %get field names
    for i = 1:numel(FieldNames)
        if ~isa(DataStruct.(FieldNames{i}),'double') && ~isstr(DataStruct.(FieldNames{i})) %if field is not a string and not a double, convert to double
            DataStruct.(FieldNames{i}) = double(DataStruct.(FieldNames{i}));
        end
    end

    %cm_viridis = viridis();

    %Plotting
    figure1 = figure('PaperType','<custom>','PaperSize',[21.5 7.75],'Color',[1 1 1]);
    c_MaxVal = max([max(DataStruct.StableExcBits_CM) max(DataStruct.MeanExcBits_CI)])/(DataStruct.TaskSize); %get max and min values for colour bar
    c_MinVal = min([min(DataStruct.StableExcBits_CM) min(DataStruct.MeanExcBits_CI)])/(DataStruct.TaskSize);
    c_MinVal = 0; c_MaxVal = 1; %setting colour limits to 0 and 1 (cuz we are looking at proportions)
    Xvec = (DataStruct.TaskSize)./(DataStruct.AgentMemory_Vec); Yvec = (DataStruct.TaskSize)./(DataStruct.NumAgents_Vec); %set X and Y vectors for plotting

    %CM proportion of excluded bits (proportion of task size)
    axes1 = axes('Parent',figure1,'Position',[0.0482804232804232 0.134573156481099 0.275945479641131 0.779867012808897]); hold(axes1,'on');
    surf(Xvec,Yvec,(DataStruct.StableExcBits_CM)/(DataStruct.TaskSize),'Parent',axes1,'EdgeColor','none'); %plotting excluded bits as a proportion of task size
    view(2); %colormap(cm_viridis);
    plot3(Xvec,(DataStruct.TaskSize)./Xvec,20*ones(size(Xvec)),'LineWidth',1,'Color',[1 1 1],'LineStyle','--'); %the line of TaskSize = Na*ma; white
    plot3(ones(size(Yvec)),Yvec,20*ones(size(Yvec)),'LineWidth',1,'Color',[1 1 1],'LineStyle',':') %vertical line for T/ma = 1; white
    plot3(Xvec,ones(size(Xvec)),20*ones(size(Xvec)),'LineWidth',1,'Color',[1 1 1],'LineStyle',':') %horizontal line for T/Na = 1; white
    title('A'); ylabel('$T/N_a$','Interpreter','latex'); %xlabel('$T/m_a$','Interpreter','latex'); %labels
    ylim(axes1,[0.512820512820513 10]); 
    hold(axes1,'off');
    set(axes1,'CLim',[c_MinVal c_MaxVal],'FontSize',24,'TickDir','out','XLimitMethod','tight','XMinorTick','on','XScale','log','XTick',[0.5 1 10],'XTickLabel',...
        {'0.5','1','10'},'YLimitMethod','tight','YMinorTick','on','YScale','log','YTick',[0.5 1 10],'YTickLabel',{'0.5','1','10'},'ZLimitMethod','tight');
    annotation(figure1,'textbox',[0.126984126984127 0.943609022556391 0.0701058201058201 0.0338345864661654],'String',{'Stable CM Exc Bits'}); % Create textbox

    %CI proportion of mean excluded bits (proportion of task size)
    axes2 = axes('Parent',figure1,'Position',[0.350611916264088 0.134573156481099 0.27594547964113 0.779867012808897]); hold(axes2,'on');
    surf(Xvec,Yvec,(DataStruct.MeanExcBits_CI)/(DataStruct.TaskSize),'Parent',axes2,'EdgeColor','none'); %plotting excluded bits as a proportion of task size
    view(2); %colormap(cm_viridis);
    plot3(Xvec,(DataStruct.TaskSize)./Xvec,20*ones(size(Xvec)),'LineWidth',1,'Color',[0 0 0],'LineStyle','--'); %the line of TaskSize = Na*ma; black
    plot3(ones(size(Yvec)),Yvec,20*ones(size(Yvec)),'LineWidth',1.5,'Color',[0 0 0],'LineStyle',':') %vertical line for T/ma = 1; black
    plot3(Xvec,ones(size(Xvec)),20*ones(size(Xvec)),'LineWidth',1.5,'Color',[0 0 0],'LineStyle',':') %horizontal line for T/Na = 1; black
    title('B'); xlabel('$T/m_a$','Interpreter','latex'); %labels
    ylim(axes2,[0.512820512820513 10]); hold(axes2,'off');
    set(axes2,'CLim',[c_MinVal c_MaxVal],'FontSize',24,'TickDir','out','XLimitMethod','tight','XMinorTick','on','XScale','log','XTick',[0.5 1 10],'XTickLabel',{'0.5','1','10'},...
    'YLimitMethod','tight','YMinorTick','on','YScale','log','YTick',[0.5 1 10],'YTickLabel',{'','',''},'ZLimitMethod','tight');
    annotation(figure1,'textbox',[0.502645502645501 0.943609022556392 0.0638227513227514 0.0338345864661654],'String',{'CI Mean Exc Bits'}); % Create textbox

    %CI proportion of std dev of excluded bits (proportion of task size)
    axes3 = axes('Parent',figure1,'Position',[0.654557165861512 0.134573156481099 0.275945479641129 0.779867012808897]); hold(axes3,'on');
    surf(Xvec,Yvec,(DataStruct.StdExcBits_CI)/(DataStruct.TaskSize),'Parent',axes3,'EdgeColor','none'); %plotting excluded bits as a proportion of task size
    view(2); %colormap(cm_viridis);
    plot3(Xvec,(DataStruct.TaskSize)./Xvec,20*ones(size(Xvec)),'LineWidth',1,'Color',[1 1 1],'LineStyle','--'); %the line of TaskSize = Na*ma; white
    plot3(ones(size(Yvec)),Yvec,20*ones(size(Yvec)),'LineWidth',1.5,'Color',[1 1 1],'LineStyle',':') %vertical line for T/ma = 1; white
    plot3(Xvec,ones(size(Xvec)),20*ones(size(Xvec)),'LineWidth',1.5,'Color',[1 1 1],'LineStyle',':') %horizontal line for T/Na = 1; white
    title('C'); 
    ylim(axes3,[0.512820512820513 10]); hold(axes3,'off');
    set(axes3,'CLim',[c_MinVal c_MaxVal],'FontSize',24,'TickDir','out','XLimitMethod','tight','XMinorTick','on','XScale','log','XTick',[0.5 1 10],'XTickLabel',{'0.5','1','10'},...
    'YLimitMethod','tight','YMinorTick','on','YScale','log','YTick',[0.5 1 10],'YTickLabel',{'','',''},'ZLimitMethod','tight'); 
    colorbar(axes3,'Position',[0.961309523809523 0.120090634441088 0.0105820105820106 0.779456193353474]); %colorbar
    annotation(figure1,'textbox',[0.667460317460314 0.815210231015607 0.0638227513227513 0.0338345864661654],'String',{'CI Std. Dev Exc Bits'}); % Create textbox

    %Annotations
    annotation(figure1,'doublearrow',[0.941137566137549 0.94113756613755],[0.30784383559303 0.913858873187015],'Head2Style','rectangle','Head2Length',1,... % Create doublearrow
        'Head1Style','rectangle','Head1Length',1);
    
    annotation(figure1,'doublearrow',[0.718253968253935 0.92989417989418],[0.943927246537315 0.943927246537315],'Head2Style','rectangle','Head2Length',1,... % Create doublearrow
        'Head1Style','rectangle','Head1Length',1);
    
    annotation(figure1,'textbox',[0.792989417989371 0.915258073461577 0.0664649085393029 0.0547368422486728],'VerticalAlignment','middle','String',{'$T > N_a$'},...
        'Interpreter','latex','HorizontalAlignment','center','FontSize',22,'FitBoxToText','off','EdgeColor','none','BackgroundColor',[1 1 1]); % Create textbox
    
    annotation(figure1,'textbox',[0.951177271585598 0.521300369534079 0.0675495188072246 0.0547368422486728],'VerticalAlignment','middle','String',{'$T > m_a$'},...
        'Rotation',90,'Interpreter','latex','HorizontalAlignment','center','FontSize',22,'FitBoxToText','off','EdgeColor','none','BackgroundColor',[1 1 1]); % Create textbox
    
    annotation(figure1,'textbox',[0.945866626406459 0.919127589542302 0.0437792747739761 0.0547368422486727],'VerticalAlignment','middle','String',{'$P_{exc}$'},...
        'Interpreter','latex','HorizontalAlignment','center','FontSize',22,'FitBoxToText','off','EdgeColor','none','BackgroundColor',[1 1 1]); % Create textbox

    %Annotation for memory distribution condition
    annotation(figure1,'textbox',[0.000661375661375549 0.961654135338347 0.0562169312169312 0.0338345864661654],'String',MemoryDistCond_Str); % Create textbox

end



% figure('Color',[1 1 1]); hold all
% 
% subplot(1,3,1); hold all
% h = surf(TaskSize./AgentMemory_Vec,TaskSize./NumAgents_Vec,StableExcBits_CM/double(TaskSize));
% axis tight
% h.EdgeColor = 'none';
% title('A (CM exc bits prop TaskSize)')
% view(2)
% caxis([MinVal MaxVal]);
% subplot(1,3,2); hold all
% h = surf(TaskSize./AgentMemory_Vec,TaskSize./NumAgents_Vec,MeanExcBits_CI/double(TaskSize));
% axis tight
% h.EdgeColor = 'none';
% title('B (Mean CI exc bits prop TaskSize)')
% view(2)
% caxis([MinVal MaxVal]);
% subplot(1,3,3); hold all
% h = surf(TaskSize./AgentMemory_Vec,TaskSize./NumAgents_Vec,StdExcBits_CI/double(TaskSize));
% axis tight
% h.EdgeColor = 'none';
% title('C (StdDev CI exc bits prop TaskSize)')
% view(2)
% colorbar; caxis([MinVal MaxVal]);

