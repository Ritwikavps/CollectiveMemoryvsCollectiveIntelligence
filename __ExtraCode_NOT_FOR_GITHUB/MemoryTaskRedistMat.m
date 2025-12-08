clear; clc

% Ritwika VPS, Oct 6, 2025
% This code simulates the toy model for the memmory game in the collective memory (CM) vs. collective intelligence (CI) project. 
% Here, we investigate how 'performance' (estimated as the number of memory bits covered) varies as a function of task complexity (measured as number of memory bits for task; M), 
% agent memory size (measured as the number of memory bits per agent; m_a. Note that this is the same for all agents), and number of agents in a group (N_a) for 'mixed' groups vs. 
% 'stable' groups. 

%Iniitalise parameters
N_g = 50; %Nuumber of groups (to reshuffle agents into)
TaskMem = 10;

TaskMem_To_Na = 0.1:0.5:4;
TaskMem_To_ma = 1.1:0.2:4;

%TaskMem_To_Na = T/Na => Na = T/TaskMemToNa

for i_Tn = 1:numel(TaskMem_To_Na)
    for i_Tm = 1:numel(TaskMem_To_ma)

        N_a = round(TaskMem/TaskMem_To_Na(i_Tn));
        m_a = round(TaskMem/TaskMem_To_ma(i_Tm));

        if m_a < TaskMem
            [MeanExcBits(i_Tn,i_Tm),StdExcBits(i_Tn,i_Tm)] = GetExcBitsStats(TaskMem, N_a, m_a, N_g);
        else
            [m_a TaskMem_To_ma(i_Tm)]
            MeanExcBits(i_Tn,i_Tm) = NaN;
            StdExcBits(i_Tn,i_Tm) = NaN;
        end
    end
end

% mean(MeanExcBits)
% std(MeanExcBits)

figure;
h = surf(TaskMem_To_ma, TaskMem_To_Na, MeanExcBits);
h.EdgeColor = 'none';
view(2)
axis tight
xlabel('M/m_a'); ylabel('M/N_a')


%------------------------------------------------
function [MeanExcBits,StdExcBits,NumBitsExcluded] = GetNewGroupMemoryCoverageAndStats(AgentBits, N_a, N_g, MemoryBitsVec)

    NewGroups = randperm(N_a*N_g); %Get new groups by randomly permuting agents

    for i = 1:N_g
        CurrNewGroup_Ind = NewGroups(1:N_a);
        CurrReshuffAgentBits = AgentBits(CurrNewGroup_Ind,:);
        if height(CurrReshuffAgentBits) ~= N_a
            error('Incorrect agent number')
        end
        
        u_BitsCovered = unique(CurrReshuffAgentBits);
        %MUST CHECK THAT THERE ARE NO BITS OUTSIDE OF TASK MEMORY SIZE.
        u_BitsCovered = u_BitsCovered(~isnan(u_BitsCovered));
        NumBitsExcluded(i,1) = numel(setdiff(MemoryBitsVec,u_BitsCovered));

        NewGroups = NewGroups(N_a+1:end);
    end

    MeanExcBits = mean(NumBitsExcluded);
    StdExcBits = std(NumBitsExcluded);

end

%------------------------------------------------
function [MeanExcBits,StdExcBits] = GetExcBitsStats(TaskMem, N_a, m_a, N_g) 

    MemoryBitsVec = 1:TaskMem;
    TotalCoverage = N_a*m_a;

    for i_trial = 1
        AgentBits = [];
        AgentBits_Ia = []; AgentBits_Ib = []; AgentBits_Ic = []; AgentBits_II = [];
        
        for i = 1:N_g
            %Case I: when N_a*m_a = M (i.e., the total memory size for agents exactly covers the task size)
            if TotalCoverage <= TaskMem
                [AgentBits_Temp, NumExcludedBits] = DistributeTask_caseFullCoverage(TaskMem, N_a, m_a, MemoryBitsVec);
                AgentBits = [AgentBits; AgentBits_Temp];
                if abs(NumExcludedBits) ~= abs(TotalCoverage-TaskMem)
                    error('Number of excluded bits is incorrect')
                end
            elseif TotalCoverage > TaskMem
                [AgentBits_Ia_Temp, AgentBits_Ib_Temp, AgentBits_Ic_Temp, AgentBits_II_Temp] =  GetAgentBits(TotalCoverage, N_a, m_a, TaskMem, MemoryBitsVec);
                AgentBits_Ia = [AgentBits_Ia; AgentBits_Ia_Temp]; 
                AgentBits_Ib = [AgentBits_Ib; AgentBits_Ib_Temp]; 
                AgentBits_Ic = [AgentBits_Ic; AgentBits_Ic_Temp]; 
                AgentBits_II = [AgentBits_II; AgentBits_II_Temp];
                
                AgentsBits = AgentBits_Ia;
            else
                error('There cannot be another case!')T
            end
        end
        
        if TotalCoverage <= TaskMem
            if N_a*N_g ~= height(AgentBits)
                error('The number of rows should be the same as the  product of number of agents and number of groups')
            end
        else
            if N_a*N_g ~= height(AgentBits_II)
                error('The number of rows should be the same as the  product of number of agents and number of groups')
            end
            
            if (sum(size(AgentBits_Ic) ~= size(AgentBits_Ib) ~= 0)) || (sum(size(AgentBits_Ic) ~= size(AgentBits_Ia)) ~= 0) ...
                    || (sum(size(AgentBits_Ic) ~= size(AgentBits_II)) ~= 0)
                error('These arrays should have the same size')
            end
        end
    
        [MeanExcBits,StdExcBits,~] = GetNewGroupMemoryCoverageAndStats(AgentBits_II, N_a, N_g, MemoryBitsVec);
    end

end




























%------------------------------------------------
function [AgentBits_Ia, AgentBits_Ib, AgentBits_Ic, AgentBits_II] =  GetAgentBits(TotalCoverage, N_a, m_a, TaskMem, MemoryBitsVec)
    
% There are two broad cases:
    % I when there is no redundancy (i.e., some agent memory bits get unfilled): 
        % Ia: when the mempry bits are assigned randomly such that all agents randomly get assigned some bits; 
        % Ib: first come, first serve, such that depending on how much redundancy exists, some agents get assigned no bits; and
        % Ic: when the mempry bits are assigned sequentially and randomly such that depending on how many bits of redundancy exists, agents have roughly equal number of
             % memory bits as NaN
    % II: when there *is* redundancy:
        % .

    %Case Ia:
    PaddedMemoryPerm = randperm(TotalCoverage);
    AgentBits_Ia = reshape(PaddedMemoryPerm, N_a, m_a);
    AgentBits_Ia(AgentBits_Ia > TaskMem) = NaN;

    %Case Ib:
    UnpaddedMemoryPerm = randperm(TaskMem);
    UnpaddedMemoryPerm(TaskMem+1:TotalCoverage) = NaN;
    AgentBits_Ib = reshape(UnpaddedMemoryPerm, m_a, N_a);
    AgentBits_Ib = AgentBits_Ib';

    %Case Ic:
    UnpaddedMemoryPerm = randperm(TaskMem);
    UnpaddedMemoryPerm(TaskMem+1:TotalCoverage) = NaN;
    AgentBits_Ic = reshape(UnpaddedMemoryPerm, N_a, m_a);

    %Case II:
    PaddedMemoryPerm = randperm(TotalCoverage);
    AgentBits_II = reshape(PaddedMemoryPerm, N_a, m_a);
    AgentBits_II(AgentBits_II > TaskMem) = NaN;
    for i = 1:N_a
        CurrAgentBits = AgentBits_II(i,:);
        MemoryCopy = setdiff(MemoryBitsVec,CurrAgentBits);
        CurrAgentBits(isnan(CurrAgentBits)) = randsample(MemoryCopy,numel(CurrAgentBits(isnan(CurrAgentBits))));
        AgentBits_II(i,:) = CurrAgentBits;
    end    
end

%------------------------------------------------------------------------------------------------------------------------------------------------------------------------------.
function [AgentBits, NumExcludedBits] = DistributeTask_caseFullCoverage(TaskMem, N_a, m_a, M_copy) 
    TotalCoverage = N_a*m_a;
    if TotalCoverage > numel(M_copy)
        error('This is a different case. This function is only for cases where the total coverage is less than or equal to task memory size.')
    end

    MemoryPerm = randperm(TaskMem);
    if TotalCoverage == TaskMem
        AgentBits = reshape(MemoryPerm,N_a,m_a);
    elseif TotalCoverage < TaskMem
        MemoryPerm = MemoryPerm(1:TotalCoverage);
        AgentBits = reshape(MemoryPerm,N_a,m_a);
    end

    % AgentBits = NaN*ones(N_a,m_a); %each agent is a row, and the bits stored by that agent is in the row
    % for i_a = 1:N_a
    %     CurrAgentBits = randsample(M_copy,m_a);
    %     M_copy = setdiff(M_copy,CurrAgentBits);
    %     AgentBits(i_a,:) = CurrAgentBits;
    % end
    % 
    % 
    % if TotalCoverage == numel(M_copy)
    %     if ~isempty(M_copy)
    %         error('Task memory vector should be empty.')
    %     end
    % elseif TotalCoverage < numel(M_copy)
    %     if isempty(M_copy)
    %         error('Task memory vector should NOT be empty.')
    %     end
    % end

    NumExcludedBits = numel(AgentBits)-TaskMem;
end


