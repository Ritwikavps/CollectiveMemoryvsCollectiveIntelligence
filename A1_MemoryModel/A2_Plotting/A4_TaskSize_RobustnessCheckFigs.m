clear; clc;

%Ritwika VPS; 
%This script plots the robustness check SI figs for the TaskSize robustness checks.

%-----------------------------------------------------------------------------------------------------------------------------------------------------------
%Note that this uses the cmocean function from FileExchange, which is available here (and should be in the path: 
%https://www.mathworks.com/matlabcentral/fileexchange/57773-cmocean-perceptually-uniform-colormaps.
%Get required tables, etc
%CHANGE PATH ACCORDINGLY
DataPath = '/Users/ritwikavps/Desktop/GoogleDriveFiles/research/CollectiveMemoryvsCollectiveIntelligence/A1_MemoryModel/MemoryModelSimResults/RobustnessChecks/';
%-----------------------------------------------------------------------------------------------------------------------------------------------------------
cd(DataPath)

%The idea is to plot figs such that all the CM-CI diff covered bits as a proportion of task size surf plots are on the same X and Y scales and share a colour bar. So, first
% get those X, Y, and colour axis limits.
MatFiles = dir('RobustnessCheck_TaskSize*_CI_vs_CM_Sims_MemoryDistCondition__*.mat'); %dir the mat files
for i = 1:numel(MatFiles) %go thorugh mat files
    DataStruct = ConvertReqDataToDouble(load(MatFiles(i).name)); %Read in
    CoveredBitsDiffProp_CM_CI = GetCoveredBitsDiffProp_CM_CI(DataStruct.TaskSize,DataStruct.StableExcBits_CM,DataStruct.MeanExcBits_CI); %get the CM-CI covered bits difference
    %as a proportion of task size
    
    %Get min and max values for the colour axis, y axis, and x axis for each mat file.
    DiffMaxVals(i) = max(CoveredBitsDiffProp_CM_CI(:)); DiffMinVals(i) = min(CoveredBitsDiffProp_CM_CI(:));
    yMaxVals(i) = max(DataStruct.TaskSize./DataStruct.NumAgents_Vec); yMinVals(i) = min(DataStruct.TaskSize./DataStruct.NumAgents_Vec); 
    xMaxVals(i) = max(DataStruct.TaskSize./DataStruct.AgentMemory_Vec); xMinVals(i) = min(DataStruct.TaskSize./DataStruct.AgentMemory_Vec); 
end

%Get max values across the entire robustness results data.
cMax = max(DiffMaxVals); cMin = min(DiffMinVals); 
yMax = max(yMaxVals); yMin = min(yMinVals);
xMax = max(xMaxVals); xMin = min(xMinVals);

%Sub-plot title list: We can just pull the subplot titles from this (cuz the selected points are marked A, B, C, etc, and we will simply name the subplots for 
% each selected point the same..
SI_SubPlotTitles = num2cell('A':'Z'); 

MemoryDistConditions = {'NoRedundRandom','RedundNoRepBits'}; %list of task bit allocation protocols
TaskSizes_ForChk = [5 10 20 40 80]; %vector of task sizes in robustness checks

%% Plotting!
figure1 = figure('PaperType','<custom>','PaperSize',[21.25 8.75],'Color',[1 1 1]); %open figure!
Ctr = 0; %ctr variable to index the subplots
AxesPos = [0.0691534391534394 0.552934860723832 0.152152457380754 0.340833285422715 %Axes positions array
           0.251809835045124 0.552934860723832 0.152152457380753 0.340833285422715
           0.432482103952686 0.552934860723832 0.152152457380754 0.340833285422715
           0.612492997198874 0.552934860723832 0.152152457380754 0.340833285422715
           0.792328042328041 0.552934860723832 0.152152457380754 0.340833285422715
           0.0691534391534394 0.196526576019776 0.152152457380754 0.340833285422714
           0.251809835045124 0.196526576019776 0.152152457380753 0.340833285422714
           0.432482103952686 0.196526576019776 0.152152457380754 0.340833285422714
           0.612492997198874 0.196526576019776 0.152152457380754 0.340833285422714
           0.792328042328041 0.196526576019776 0.152152457380754 0.340833285422714];

for i_m = 1:numel(MemoryDistConditions) %go through task bit allocation protocols
    for j_T = 1:numel(TaskSizes_ForChk) %go through task sizes

        Ctr = Ctr + 1; %increment counter

        %Setting x and y labels + colour bar
        XlabelOrNo = false; YlabelOrNo = false; ColorbarOrNo = false; %defaults
        
        %toggle true based on subplot number
        if ismember(Ctr,6:10) %Xlabel
            XlabelOrNo = true;
        end
        if ismember(Ctr,[1 6]) %Y label
            YlabelOrNo = true;
        end
        if Ctr == 5 %Colorbar
            ColorbarOrNo = true;
        end

        %Get the file name for the mat file corresponding to the current task bit allocation protocol + task size.
        ReqMatName = ['RobustnessCheck_TaskSize' num2str(TaskSizes_ForChk(j_T)) '_CI_vs_CM_Sims_MemoryDistCondition__' MemoryDistConditions{i_m} '.mat'];

        CurrAxis = axes('Parent',figure1,'Position',AxesPos(Ctr,:)); %get current axes
        DataStruct = ConvertReqDataToDouble(load(ReqMatName)); %convert necessary data from int64 to double
        PlotTaskSizeRobustnessSubplot(DataStruct,CurrAxis,SI_SubPlotTitles{Ctr},XlabelOrNo,YlabelOrNo,ColorbarOrNo,[cMin cMax],[xMin xMax],[yMin yMax]) %plot!
    end
end

%Annotations:

annotation(figure1,'textbox',[0.940150003522069 0.889028489960566 0.0437792747739761 0.0547368422486729],'VerticalAlignment','middle','String','$\Delta P_{c}$',... % Create textbox
    'Interpreter','latex','HorizontalAlignment','center','FontSize',24,'FontName','Helvetica Neue','FitBoxToText','off','EdgeColor','none');
annotation(figure1,'textbox',[0.115736580399609 0.889028489960566 0.0575549362828492 0.0518518519877029],'VerticalAlignment','middle','String',{'$T$ = 5'},... % Create textbox
    'Interpreter','latex','HorizontalAlignment','center','FontSize',22,'EdgeColor','none');
annotation(figure1,'textbox',[0.295961438032684 0.889028489960566 0.0648300887415649 0.0518518519877029],'VerticalAlignment','middle','String',{'$T$ = 10'},... % Create textbox
    'Interpreter','latex','HorizontalAlignment','center','FontSize',22,'EdgeColor','none');
annotation(figure1,'textbox',[0.47651699358824 0.889028489960566 0.0648300887415648 0.0518518519877029],'VerticalAlignment','middle','String',{'$T$ = 20'},... % Create textbox
    'Interpreter','latex','HorizontalAlignment','center','FontSize',22,'EdgeColor','none');
annotation(figure1,'textbox',[0.656411173482419 0.889028489960566 0.0648300887415648 0.0518518519877029],'VerticalAlignment','middle','String',{'$T$ = 40'},... % Create textbox
    'Interpreter','latex','HorizontalAlignment','center','FontSize',22,'EdgeColor','none');
annotation(figure1,'textbox',[0.836305353376599 0.889028489960566 0.0648300887415649 0.0518518519877029],'VerticalAlignment','middle','String',{'$T$ = 80'},... % Create textbox
    'Interpreter','latex','HorizontalAlignment','center','FontSize',22,'EdgeColor','none');

%-----------------------------------------------------------------------------------------------------------------------------------------------------------
%Functions (these functions have been copied or adapted from the 'A1_CIvsCM_SurfPlots.m' script:
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
% Inputs: - DataStruct: structure with data to plot
%         - axes1: axis handle (initialised outside the function, in the main text)
%         - TitleTxt: subplot titles (e.g., A, B, etc; input is string)
%         - XlabelOrNo, YlabelOrNo: whether there should be an x or y label for subplot (logical)
%         - ColorbarOrNo: whether there should be a colorbar for subplot (logical)
%         - cLimVec,xLimVec,yLimVec: limits for colour axis, x axis, y axis.
% 
% This function also outputs the max and min value of the plotted difference in task coverage proportions (CM-CI) so that these values can then be used to estimate 
% the common colour bar limits for the tewo subplots (NoRedundRandom and RedundNoRepBits).
%--------------------------------------------------------------------------------------------
function PlotTaskSizeRobustnessSubplot(DataStruct,axes1,TitleTxt,XlabelOrNo,YlabelOrNo,ColorbarOrNo,cLimVec,xLimVec,yLimVec)

    %Get specific data to plot
    Xvec = (DataStruct.TaskSize)./(DataStruct.AgentMemory_Vec); Yvec = (DataStruct.TaskSize)./(DataStruct.NumAgents_Vec); %set X and Y vectors for plotting
    CoveredBitsDiffProp_CM_CI = GetCoveredBitsDiffProp_CM_CI(DataStruct.TaskSize,DataStruct.StableExcBits_CM,DataStruct.MeanExcBits_CI); %get the covered bits diff prop to plot
    %get max and min values for colour bar (will pass this as output to have a single colour bar for upper and lower figs).
    XvecForExactCovLine = min(Xvec): 0.1: max(Xvec);
    ExactCoverageLine_Y = (DataStruct.TaskSize)./XvecForExactCovLine; %get the line for T = Na*ma
    ExactCoverageLine_Y(ExactCoverageLine_Y > max(Yvec)) = NaN; %so that any Y values for this line greater than the max y value is NaN (so the line won't be plotted
    %beyond suf plot limits)

    %CM-CI proportion of covered bits (as proportion of task size)
    hold(axes1,'on'); box(axes1,'on');
    surf(Xvec,Yvec,CoveredBitsDiffProp_CM_CI,'Parent',axes1,'EdgeColor','none'); %plotting excluded bits as a proportion of task size 
    plot3(XvecForExactCovLine,ExactCoverageLine_Y,20*ones(size(XvecForExactCovLine)),'LineWidth',1.5,'Color',[0 0 0],'LineStyle','-'); %the line of TaskSize = Na*ma; white
    plot3(ones(size(Yvec)),Yvec,20*ones(size(Yvec)),'LineWidth',2.5,'Color',[0 0 0],'LineStyle',':') %vertical line for T/ma = 1; white
    plot3(Xvec,ones(size(Xvec)),20*ones(size(Xvec)),'LineWidth',2.5,'Color',[0 0 0],'LineStyle',':') %horizontal line for T/Na = 1; white
    ylim(axes1,yLimVec); xlim(axes1,xLimVec); clim(cLimVec); cmocean('balance','pivot',0.01);
    view(2); title(TitleTxt);  %labels
    set(axes1,'FontSize',24,'TickDir','out','XLimitMethod','tight','XMinorTick','on','XScale','log','XTick',[0.5 2 10 40],'XTickLabel',{'','','',''}, ...
        'YLimitMethod','tight','YMinorTick','on','YScale','log','YTick',[0.5 2 10 40],'YTickLabel',{'','','',''},'ZLimitMethod','tight','XGrid','on','YGrid','on');
    
    if XlabelOrNo %optional x label
        xlabel('$T/m_a$','Interpreter','latex'); 
        xticklabels({'0.5','2','10','40'});
    end
    if YlabelOrNo %optional x label
        ylabel('$T/N_a$','Interpreter','latex');
        yticklabels({'0.5','2','10','40'});
    end
    if ColorbarOrNo %optional colour bar
        colorbar(axes1,'Position',[0.951520131534849 0.196581196581197 0.0101200801053628 0.655270655270655]);
    end

    hold(axes1,'off');
end
