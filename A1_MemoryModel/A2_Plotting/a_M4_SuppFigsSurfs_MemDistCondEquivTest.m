clear; clc

%Ritwika VPS; Plotting figures to show that the NoRedundRandom and NoRedundRandSeq protocols are functionally equivalent when TaskSize >= N_a*m_a (for results from 
% a_M2_DemoAllocationProtocolEquivUptoFullCoverage.ipynb). Note that in this regime, the NoRedundRandom and NoRedund1Come1Serve protocols are operationally equivalent, as are 
% the NoRedundRandom and RedundNoRepBits protocols. As such, we are not testing functional equivalence for those.

%-----------------------------------------------------------------------------------------------------------------------------------------------------------
%Note that this uses the cmocean function from FileExchange, which is available here (and should be in the path: 
%https://www.mathworks.com/matlabcentral/fileexchange/57773-cmocean-perceptually-uniform-colormaps.
%CHANGE PATH ACCORDINGLY
DataPath = '~/Desktop/GoogleDriveFiles/research/CollectiveMemoryvsCollectiveIntelligence/MemoryGameData/PooledGrpMemLessThanTaskSize_MemoryCondEquivTest/';
%-----------------------------------------------------------------------------------------------------------------------------------------------------------

%% Plotting
%set up plotting function inputs to loop through
MemoryDistCondition_Vec = {'NoRedundRandom', 'NoRedundRandSeq'}; %various memory conditions
QtyToPlot = {'StableExcBits_CM','MeanExcBits_CI','StdExcBits_CI'}; %diff data to plot
QtyToPlt_TxtBoxTxt = {'$P_{c} ^{\rm CM}$','$\mu(P_{c}^{\rm CI})$','$\sigma(P_{c} ^{\rm CI})$'}; %text box within subplots to id what's being plotted
TxtBoxPos = [0.172619047619048 0.569544554455445 0.0496031746031746 0.0445544554455446; %text box position for the QtyToPlt_TxtBox
             0.416666666666665 0.569544554455445 0.049603174603175 0.044554455445545;
             0.660052910052907 0.569544554455445 0.0496031746031749 0.044554455445545;
             0.172619047619047 0.180930693069307 0.0502645502645503 0.0445544554455445;
             0.416666666666664 0.180930693069306 0.0496031746031748 0.0445544554455451;
             0.660052910052905 0.180930693069306 0.0496031746031749 0.0445544554455451];
AxesPos = [0.167037037037036 0.562797605341929 0.213405797101448 0.341162790697675; %Axes positions
               0.410797101449275 0.562797605341929 0.213405797101449 0.341162790697675;
               0.654557165861511 0.562797605341929 0.213405797101448 0.341162790697675;
               0.167037037037036 0.173118811881188 0.213405797101448 0.341162790697675;
               0.410797101449275 0.173118811881188 0.213405797101449 0.341162790697675;
               0.654557165861511 0.173118811881188 0.213405797101448 0.341162790697675];
TitleTxt = {'A','B','C','D','E','F'}; %subplot title txt
ColorbarOrNo_Vec = [false false true false false false]; 
YlabelOrNo_Vec = [true false false true false false];
XlabelOrNo_Vec = [false false false true true true];

figure1 = figure('PaperType','<custom>','PaperSize',[19 10],'WindowState','maximized','Color',[1 1 1]);
Ctr = 0; %ctr variable to loop through subplot level stuff (cuz the memory dist condition and the qty to plot are two different for loops
for i = 1:numel(MemoryDistCondition_Vec)
    for j = 1:numel(QtyToPlot)
        Ctr = Ctr + 1; %update ctr
        CurrAxes = axes('Parent',figure1,'Position',AxesPos(Ctr,:)); %get current axes
        PlotSuppFig_CIvsCMsurf_MemDistCondEquivTest(MemoryDistCondition_Vec{i},DataPath,QtyToPlot{j},CurrAxes,TitleTxt{Ctr},...
            XlabelOrNo_Vec(Ctr),YlabelOrNo_Vec(Ctr),ColorbarOrNo_Vec(Ctr)) %PLOT!
        annotation(figure1,'textbox',TxtBoxPos(Ctr,:),'String',QtyToPlt_TxtBoxTxt{j},'FontSize',24,'EdgeColor','none','Interpreter','latex'); %add txt box id's what's being plotted
    end
end

%Other textboxes
annotation(figure1,'textbox',[0.0992063492063456 0.114717821782178 0.24239417989418 0.079826732673267],'String',{'Sequential Random','Assignment W/o Redundancy'},...
    'Rotation',90,'HorizontalAlignment','center','FontSize',23,'FitBoxToText','off','EdgeColor','none');
annotation(figure1,'textbox',[0.102678571428567 0.580064356435644 0.159391534391534 0.0773514851485149],'String',{'Random Assignment','Without Redundancy'},...
    'Rotation',90,'HorizontalAlignment','center','FontSize',23,'EdgeColor','none');

%% Compute cumulative frctional diff b/n CM covered bits, mean CI covered bits, and std. CI covered bits for NoRedundRandom and NoRedundRandSeq protocols.
R_Struct = load('CI_vs_CM_Sims_MemoryDistCondEquivTest_LeqGroupMem__NoRedundRandom.mat');
RS_Struct = load('CI_vs_CM_Sims_MemoryDistCondEquivTest_LeqGroupMem__NoRedundRandSeq.mat');
disp('The cumulative fractional difference computed as the sum of abs(NoRedundRandSeq - NoRedundRand)/NoRedundRand for all non-NaN values of:')
for i = 1:numel(QtyToPlot)
    %get number of non-nan items for NoRedundRandom and NoRedundRandSeq structs x current measure (CM bits, CI mean bits or CI std bits)
    NumItems_R = numel(R_Struct.(QtyToPlot{i})(~isnan(R_Struct.(QtyToPlot{i})))); 
    NumItems_RS = numel(RS_Struct.(QtyToPlot{i})(~isnan(RS_Struct.(QtyToPlot{i}))));

    if NumItems_RS ~= NumItems_R
        error('NoRedundRandom and NoRedundRandSeq structs should have the same number of non-NaN items')
    end

    %convert number (CM) and mean (CI) excluded bits to covered task bits; std dev does not have to be converted.
    if contains(QtyToPlot{i},'Std')
        R_Qty_Prop = R_Struct.(QtyToPlot{i})/double(R_Struct.TaskSize);
        RS_Qty_Prop = RS_Struct.(QtyToPlot{i})/double(RS_Struct.TaskSize);
    else
        R_Qty_Prop = 1 - (R_Struct.(QtyToPlot{i})/double(R_Struct.TaskSize));
        RS_Qty_Prop = 1 - (RS_Struct.(QtyToPlot{i})/double(RS_Struct.TaskSize));
    end

    %Get abs diff between NoRedundRandom and RedundNoRepBits protocols as a fraction of the corresponding NoRedundRandom value (since that's sort of the default and therefore 
    % the ref).
    AbsFracDiff = abs(RS_Qty_Prop - R_Qty_Prop)./(R_Qty_Prop);
    CumAbsFracDiff = sum(AbsFracDiff(:),'omitnan');

    CurrQtyTxt = regexprep(QtyToPlot{i},'Exc','Covered'); %changes 'excluded' to 'covered' bits
    
    disp(['- ' CurrQtyTxt ' (as a fraction of Task Size) across ' num2str(NumItems_R) ' non-NaN values (when TaskSize >= N_a*m_a ONLY) is ' num2str(CumAbsFracDiff) ...
       '; mean abs fractional diff per non-NaN value is ' num2str(CumAbsFracDiff/NumItems_R)])

end

%-----------------------------------------------------------------------------------------------------------------------------------------------------------
%Functions (these are copied from a_M2_CI_vs_CM_SurfPlots.m):
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
% This function plots the surface plots for CI mean covered bits, CM covered bits, and CI std. covered bits for the various relevant task bit allocation protocols. 
% Each instance of this function plots a subplot in a figure. These are plots that go into the SI. 
% 
% Inputs: - MemoryDistCond_Str: the memrody distribution condition (string)
%         - DataPath: path to data
%         - DataTypeToPlt: the specific data being plotted (CI mean covered bits, CI std covered bits std, CM covered bits) 
%         - axes1: axis handle (initialised outside the function, in the main text)
%         - LineClr: RGB colour (3 element vector) for the lines indicating T = N_a x m_a, T = N_a, T = m_a
%         - TitleTxt: subplot titles (e.g., A, B, etc; input is string)
%         - XlabelOrNo: whether there should be an x label for subplot (logical)
%         - ColorbarOrNo: whether there should be a colorbar for subplot (logical)
% 
% This function also outputs the max and min value of the plotted difference in task coverage proportions (CM-CI) so that these values can then be used to estimate 
% the common colour bar limits for the tewo subplots (NoRedundRandom and RedundNoRepBits).
%--------------------------------------------------------------------------------------------
function PlotSuppFig_CIvsCMsurf_MemDistCondEquivTest(MemoryDistCond_Str,DataPath,DataTypeToPlt,axes1,TitleTxt,XlabelOrNo,YlabelOrNo,ColorbarOrNo)

    cd(DataPath) %get data struct with data to plot
    DataStruct = load(['CI_vs_CM_Sims_MemoryDistCondEquivTest_LeqGroupMem__' MemoryDistCond_Str '.mat']); %load .mat file as a structure
    %Since these were saved from Python, some of the vriables are saved as double and some others as int64, so we have to transform all numbers to converted to double.
    DataStruct = ConvertReqDataToDouble(DataStruct);
   
    %Get specific data to plot
    Xvec = (DataStruct.TaskSize)./(DataStruct.AgentMemory_Vec); Yvec = (DataStruct.TaskSize)./(DataStruct.NumAgents_Vec); %set X and Y vectors for plotting
    if contains(DataTypeToPlt,'Std') %surface plotting: If this is the std dev, we can plot it straight away. 
        DataForSurf = (DataStruct.(DataTypeToPlt))/(DataStruct.TaskSize); %std dev of covered and excluded bits is the same
    else
        DataForSurf = 1 - ((DataStruct.(DataTypeToPlt))/(DataStruct.TaskSize)); %the saved variable is in terms of excluded bits, so if it is the mean covered bits (CI)
        %or covered bits in the stable grps (CM), we need to do 1-(proportion of excluded bits).
    end
    c_MaxVal = 1; c_MinVal = 0; %max and min values for colorbar

    %Plotting
    hold(axes1,'on');
    surf(Xvec,Yvec,DataForSurf,'Parent',axes1,'EdgeColor','none'); %plotting excluded bits as a proportion of task size  
    ylim(axes1,[min(Xvec) max(Xvec)]); xlim(axes1,[min(Xvec) max(Xvec)]);  %axes limits
    title(TitleTxt);  %labels
    if XlabelOrNo %optional x label
        xlabel('$T/m_a$','Interpreter','latex'); xticks([0.5 5 10])
    else
        xticks([0.5 5 10]); xticklabels({'','',''})
    end
    if YlabelOrNo %optional x label
        ylabel('$T/N_a$','Interpreter','latex'); yticks([0.5 5 10])
    else
        yticks([0.5 5 10]); yticklabels({'','',''})
    end
    if ColorbarOrNo %optional colour bar
        colorbar(axes1,'Position',[0.876567773503702 0.173267326732673 0.0123211153851864 0.730948239611606]);
    end
    cmocean('haline'); clim([c_MinVal c_MaxVal])
    view(2); hold(axes1,'off');
    set(axes1,'FontSize',24,'TickDir','out','XLimitMethod','tight','XMinorTick','on','YLimitMethod','tight','YMinorTick','on','ZLimitMethod','tight',...
        'XGrid','on','XMinorGrid','on','YGrid','on','YMinorGrid','on');
end

