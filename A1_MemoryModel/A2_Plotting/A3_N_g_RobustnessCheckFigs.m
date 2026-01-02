clear; clc;

%Ritwika VPS; 
%This script plots the robustness check SI figs for the num_groups robustness checks.

%-----------------------------------------------------------------------------------------------------------------------------------------------------------
%Note that this uses the cmocean function from FileExchange, which is available here (and should be in the path: 
%https://www.mathworks.com/matlabcentral/fileexchange/57773-cmocean-perceptually-uniform-colormaps.
%Get required tables, etc
%CHANGE PATH ACCORDINGLY
DataPath = '/Users/ritwikavps/Desktop/GoogleDriveFiles/research/CollectiveMemoryvsCollectiveIntelligence/A1_MemoryModel/MemoryModelSimResults/RobustnessChecks/';
%-----------------------------------------------------------------------------------------------------------------------------------------------------------
cd(DataPath) %go to datapath
DataTab_ForChks = readtable('RobustnessCheckValues.xlsx','Sheet','Data'); %get the table with the points for num_groups robustness checks identified
ProtocolsFrmTab = unique(DataTab_ForChks.BitAllocationProtocol); %get list of bit allocation protocols from this table
Ng_Robustness_ResultsTab = readtable('CIvsCM_RobustnessChecks_NumberOfGroups.csv'); %get table with results from num_groups robustness checks
 
%Open main txt fig
%-----------------------------------------------------------------------------------------------------------------------------------------------------------
%CHANGE PATH ACCORDINGLY
FigPath = '~/Desktop/GoogleDriveFiles/research/CollectiveMemoryvsCollectiveIntelligence/__Figures/MainTxt/';
%-----------------------------------------------------------------------------------------------------------------------------------------------------------
cd(FigPath)
Main_CIvsCMFig = openfig('CovBitsPropCM_CIDelta_HeatMap_NoRedRand_RedNoRep_MAIN.fig'); %open required figure
MainTxtFigAxesHandles = findobj(Main_CIvsCMFig,'Type','axes'); %get axes handles to both sub-plots

%Error check!
if numel(MainTxtFigAxesHandles) ~= 2
    error('There should only be 2 sub-plots')
end

%% Num_groups robustness check plotting

SI_SubPlotTitles = num2cell('A':'Z'); %We can just pull the subplot titles from this (cuz the selected points are marked A, B, C, etc, and we will simply name the subplots for 
% each selected point the same.

%go through the taks bit allocation protocols.
for i = 1:numel(ProtocolsFrmTab) 

    %open figure to plot current allocation protocol Num_groups robustness checks
    figure1 = figure('PaperType','<custom>','PaperSize',[21.5 11.5],'WindowState','maximized','Color',[1 1 1]); 

    %subset DataTab_ForChks and num_groups robustness check results re: the ith protocol
    SubTab_Chks = DataTab_ForChks(strcmp(DataTab_ForChks.BitAllocationProtocol,ProtocolsFrmTab{i}),:);
    SubTab_Ng_Rob = Ng_Robustness_ResultsTab(contains(Ng_Robustness_ResultsTab.BitAllocationProtocol,ProtocolsFrmTab{i}),:);
    Ng_Rob_SubTab_uItemList = unique(SubTab_Ng_Rob.ItemId); %get number of unique items in the subsetted numgroups results table (each item corresponds to results for 
    %a given selected point for the list of N_groups tested
    if height(SubTab_Chks) ~= numel(Ng_Rob_SubTab_uItemList)
        error(['Number of rows in the data table with selected points subsetted for allocation protocol should be the same as the number of unique items ' ...
            'from the robustness check results table, also subsetted for allocation protocol'])
    end

    %Error check: MainTxtSubplotTitle stores the subplot title (B or C) in the main text figure to which the points belong to, and each unique subplot title corresponds to 
    %a unique bit allocation protocol. As such, as long as we subset one bit allocation protocol, there should only be one subplot title.
    if numel(unique(SubTab_Chks.MainTxtSubplotTitle)) ~= 1
        error('There should only be one subplot associated with one bit allocation protocol')
    end

    %Pick out the MainTxtSubplotTitle from the subsetted table so we can match it to the correct actual subplot from the saved .fig file.
    ReqSubplotTitle = SubTab_Chks.MainTxtSubplotTitle{1};

    %Go through the list of axis handles from main text fig
    for j = 1:numel(MainTxtFigAxesHandles)
        if strcmp(MainTxtFigAxesHandles(j).Title.String,ReqSubplotTitle) %Pick the subplot that matches the correct task bit allocation protocol from the table

            ReqMainTextSubplot = get(MainTxtFigAxesHandles(j), 'children'); %get the actual subplot from main text figure (we are going to copy this onto a separate SI fig
            % for each allocation protocol)

            %Plotting to new figure: The first sub-plot will be the main fig CM-CI surf plot with the selected points highlighted, and num_groups robustness test results
            % will be plotted as a separate subplot for each selected point. The number of selected points is different for the allocation protocols, so this if condition
            % sets that.
            if height(SubTab_Chks) == 7 %NoRedundRandom
                AxesPos = [0.05026455026455 0.578163771712159 0.203544973544973 0.348650717221952
                           0.376852629940863 0.484548825710754 0.197089947089944 0.440121669014288
                           0.583318549642068 0.484548825710754 0.197089947089944 0.440121669014288
                           0.789021164021164 0.484548825710754 0.197089947089945 0.440121669014288
                           0.068783068783069 0.118652657601977 0.299603174603174 0.340833285422715
                           0.376852629940863 0.118652657601977 0.197089947089945 0.340833285422715
                           0.583318549642068 0.118652657601977 0.197089947089945 0.340833285422715
                           0.789021164021164 0.118652657601977 0.197089947089945 0.340833285422715];
                LegendPos = [0.496914360045553 0.496423898138132 0.069538757283851 0.0697071278198393];
                ColorbarPos = [0.259344488081599 0.575682382133995 0.011158157421047 0.311833069040294]; 
                YlabelSubPlots = [2 5]; %identify subplot numbers that have Y and X labels, respectively
                XlabelSubPlots = 5:8;
            elseif height(SubTab_Chks) == 9 %RedundNoRepBits
                AxesPos = [0.0502645502645503 0.578163771712159 0.187169312169312 0.346506723012882
                           0.358334111422345 0.484548825710754 0.151031746031738 0.440121669014288
                           0.517842359165884 0.484548825710754 0.151031746031738 0.440121669014288
                           0.677350606909426 0.484548825710754 0.151031746031738 0.440121669014288
                           0.837301587301587 0.484548825710754 0.151031746031738 0.440121669014288
                           0.0687830687830688 0.118652657601977 0.281084656084655 0.340833285422715
                           0.358334111422345 0.118652657601977 0.151031746031738 0.340833285422715
                           0.517842359165884 0.118652657601977 0.151031746031738 0.340833285422715
                           0.677350606909426 0.118652657601977 0.151031746031738 0.340833285422715
                           0.837301587301587 0.118652657601977 0.151031746031738 0.340833285422715];
                LegendPos = [0.432099545230739 0.49876635811904 0.0695387572838514 0.0699665836305827];
                ColorbarPos = [0.242810096547209 0.575682382133995 0.011158157421047 0.311833069040294];
                YlabelSubPlots = [2 6];
                XlabelSubPlots = 6:10;
            end

            TxtLabels = SI_SubPlotTitles(1:numel(SubTab_Chks.T_by_ma_Xax)); %get text labels for the selected points

            %Actual plotting: copying main text CM-CI figure for the current allocation protocol.
            CurrAxes_MainTxtCopy = axes('Parent',figure1,'Position',AxesPos(1,:)); hold(CurrAxes_MainTxtCopy,'on');
            copyobj(ReqMainTextSubplot, CurrAxes_MainTxtCopy); %copy main txt subplot
            plot3(SubTab_Chks.T_by_ma_Xax,SubTab_Chks.T_by_Na_Yax,10*ones(size(SubTab_Chks.T_by_ma_Xax)),'s','MarkerSize',11,'MarkerFaceColor','w',...
                'MarkerEdgeColor','k','LineWidth',1.5); %plot selected points
            text(SubTab_Chks.T_by_ma_Xax,SubTab_Chks.T_by_Na_Yax,10*ones(size(SubTab_Chks.T_by_ma_Xax)),TxtLabels,'FontWeight','bold','FontSize',22); %add text labels
            ylim(MainTxtFigAxesHandles(j).YLim); xlim(MainTxtFigAxesHandles(j).XLim);  %axis limits 
            colorbar('Position',ColorbarPos);   %colour bar 
            clim(MainTxtFigAxesHandles(j).CLim); cmocean('balance','pivot',0.01)
            ylabel('$T/N_a$','Interpreter','latex'); xlabel('$T/m_a$','Interpreter','latex'); %ylabel and title
            hold(CurrAxes_MainTxtCopy,'off');
            set(CurrAxes_MainTxtCopy,'FontSize',24,'TickDir','out','XLimitMethod','tight','XMinorTick','on','XScale','log','XTick',[0.5 1 10],'XTickLabel',...
                {'0.5','1','10'},'YLimitMethod','tight','YMinorTick','on','YScale','log','YTick',[0.5 1 10],'YTickLabel',{'0.5','1','10'},'ZLimitMethod','tight');

            for i_robchk = 1:numel(Ng_Rob_SubTab_uItemList) %plot robustness results in subplots

                CurrAxes_SI = axes('Parent',figure1,'Position',AxesPos(i_robchk+1,:)); hold(CurrAxes_SI,'on'); box(CurrAxes_SI,'on');

                CurrItemRobChk_SubTab = SubTab_Ng_Rob(SubTab_Ng_Rob.ItemId == Ng_Rob_SubTab_uItemList(i_robchk),:); %subset robustness check results for 
                %each unique item (corresponding to one selected point).

                %Check to make sure that the allocation protocol and Na and ma values match between the current robustness check results and the corresponding
                % selected point (from the SubTab_Chks subsetted table). 
                if ~(strcmp(unique(CurrItemRobChk_SubTab.BitAllocationProtocol),SubTab_Chks.BitAllocationProtocol{i_robchk})) || ...
                   (unique(CurrItemRobChk_SubTab.Na) ~= SubTab_Chks.Rounded_Na(i_robchk)) || (unique(CurrItemRobChk_SubTab.ma) ~= SubTab_Chks.Rounded_ma(i_robchk))
                    error('Item details from robustness check results do not match (expected) corresponding details in the data table with details of selected points')
                end

                %plot proportion of covered bits (CM and mean CI values have to be converetd from number of excluded bits and then scaled by task size; std dev is the same for
                % covered and excluded bits and therefore, only requires scaling by TaskSize).
                plot(CurrItemRobChk_SubTab.NumGroups,1-(CurrItemRobChk_SubTab.CM_NumExcBits./CurrItemRobChk_SubTab.TaskSize),'s','MarkerSize',9,'LineWidth',1.5, ...
                    'LineStyle','-','MarkerFaceColor','auto') %plot CM
                errorbar(CurrItemRobChk_SubTab.NumGroups,1-(CurrItemRobChk_SubTab.CI_MeanNumExcBits./CurrItemRobChk_SubTab.TaskSize), ...
                    CurrItemRobChk_SubTab.CI_StdNumExcBits./CurrItemRobChk_SubTab.TaskSize,'.','MarkerSize',15,'LineWidth',1.2,'LineStyle','-') %plot CI

                %legend, x and y labels etc based on subplot number
                if i_robchk == 1
                    legend({'$P_{c} ^{\rm CM}$','$\mu(P_{c}^{\rm CI})$'},'Interpreter','latex','Position',LegendPos);
                end

                title(SI_SubPlotTitles{i_robchk}); xlim([7 25000]); ylim([0 1.02]);
                hold(CurrAxes_SI,'off')
                set(CurrAxes_SI,'FontSize',24,'XGrid','on','XLimitMethod','tight','XMinorTick','on','XScale','log','XTick',[10 100 1000 10000],'XTickLabel',{'','','',''},...
                    'YGrid','on','YLimitMethod','tight','YMinorTick','on','YTick',[0 0.2 0.4 0.6 0.8 1],'YTickLabel',{'','','','','',''},'ZLimitMethod','tight');

                %x labels and x tick labels
                if ismember(i_robchk+1,XlabelSubPlots)
                    xlabel('$N_g$','Interpreter','latex')
                    xticklabels({'10^1','10^2','10^3','10^4'})
                end

                %y labels and y tick labels
                if ismember(i_robchk+1,YlabelSubPlots)
                    ylabel('Prop. covered bits ');
                    yticklabels({'0','0.2','0.4','0.6','0.8','1'})
                end
            end 

            % Create textbox
            annotation(figure1,'textbox',[0.231155294527361 0.881733987075567 0.0437792747739761 0.0547368422486729],'VerticalAlignment','middle','String','$\Delta P_{c}$',...
                'Interpreter','latex','HorizontalAlignment','center','FontSize',24,'FontName','Helvetica Neue','FitBoxToText','off','EdgeColor','none');
        end
    end
end

close(Main_CIvsCMFig) %close main txt fig










