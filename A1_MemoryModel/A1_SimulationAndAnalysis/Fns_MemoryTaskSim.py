""" 
This file contains functions to simulate CI vs CM conditions. See relevant markdown text in the main 
file (CIvsCM_MemoryTaskSim.ipynb) for more details. 

Note that this file is not a standalone script and needs to be run in conjunction with the main script (CIvsCM_MemoryTaskSim.ipynb) to work properly.
"""

""""
Some notes on the code:
    - The parallelisation is set to use total number of CPU cores - NumFreeCores. This is to avoid overloading the system. If you want to change this, you can do so by 
    changingin the NumFreeCores input to the GetCIvsCMstats_ParallelParamSweep() function. 
"""



"""Importing modules"""
import numpy as np
import matplotlib.pyplot as plt #plotting library
import matplotlib.ticker as ticker #for customizing axis ticks
import seaborn as sbn #statistical data visualization library
import pandas as pd #data manipulation and analysis library
import mplcursors #for interactive plots
import os
import multiprocessing as mxp
from functools import partial #for parallelising
from tqdm import tqdm #for progress bar
from itertools import product #to get the element-wise combinations of two arrays



#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
##############---------Functions to simulate various cases of memory allocation for a single parameter combination---------##############
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
"""
This function distributes the task (consisting of TaskSize number of bits) among N_a agents (consisting of a group), each with memory size of m_a bits such that N_a*m_a <= TaskSize.
That is, the total number of memory bits pooled across agents in a group can at most only fully cover the TaskSize such that there are no redundant bits of memory.

Inputs:
TaskSize (int): memory size of task.
N_a (int): Number of agents in a group.
m_a (int): Memory capacity of each agent.

Returns:
AgentBits (2d numpy array): each row corresponds to an agent and the elements in the row correspond to the memory bits assigned to that agent.
NumExcludedBits (int): Number of bits of the task not covered by the agents in the group.
"""
def DistributeTask_LeqGroupMem(TaskSize, N_a, m_a):

    TotalCoverage = N_a*m_a # Total memory coverage across agents
    if TotalCoverage > TaskSize: #error check 
        raise ValueError("Total memory across agents exceeds TaskSize such that there will be empty agent memory bits. Please ensure N_a * m_a <= TaskSize.")
    
    MemoryPerm = np.random.permutation(range(TaskSize)) + 1 # Randomly permute the memory vector (obtained as range(TaskSize)) (+ 1 because Python indexes from 0)
    
    if TotalCoverage == TaskSize: #if total memory across agents exactly covers the Task
        AgentBits = np.reshape(MemoryPerm, (N_a, m_a)) #Reshape the permuted memory vector into an array of N_a rows and m_a columns, such that each row corresponds to 
        #the memory bits assigned to an agent
        NumExcludedBits = np.size(MemoryPerm) - np.size(AgentBits) #Number of bits excluded 

        #error checks
        if NumExcludedBits != 0: 
            raise ValueError("Number of bits excluded should be zero when TotalCoverage is exactly equal to TaskSize.")
        
        if np.size(np.setdiff1d(MemoryPerm, AgentBits)) != 0: #note that as set up here, is agnostic to NaNs in AgentBits, because we are extracting values that are
        #in TrueMemoryVec but not in AgentBits
            raise ValueError("The setdiff of the AgentBits array and the MemoryPerm array/list should be empty (because the task is fully covered by pooled agent memory in the group).")
        
    elif TotalCoverage < TaskSize: #if total memory across agents is less than TaskSize
        MemoryPermTrimmed = MemoryPerm[0:TotalCoverage] #Trim the permuted memory vector to only include the first TotalCoverage number of bits
        #(note that this will actually index from 0 to TotalCoverage-1 because Python indexes from 0)
        
        AgentBits = np.reshape(MemoryPermTrimmed, (N_a, m_a)) #Reshape the trimmed permuted memory vector into an appropriately shaped array (see above)
        NumExcludedBits = np.size(MemoryPerm) - np.size(AgentBits) #Number of bits excluded (should be TaskSize - TotalCoverage in this case)
        
         #error checks
        if NumExcludedBits != (TaskSize - TotalCoverage):
            raise ValueError("Number of bits excluded should be equal to TaskSize - TotalCoverage when TotalCoverage is less than TaskSize.")
        elif NumExcludedBits < 0:
            raise ValueError("Number of bits excluded should not be negative.")
    
    return AgentBits, NumExcludedBits



""" 
This function distributes the task (consisting of TaskSize number of bits) among N_a agents in a group, each with memory size of m_a bits such that N_a*m_a > TaskSize. That is, the
total number of memory bits pooled across agents in a group exceeds the TaskSize such that there are redundant bits of memory. 

Task memory distribution is done such that bits are assigned randomly to agents. This is accomplished by padding the range(TaskSize) vector with NaNs such that the total length 
is now equal to N_a*m_a (the total number of memory bits available in the group), randomly permuting this padded vector, and reshaping it into an array of shape (N_a, m_a) such 
that each row corresponds to an agent and the elements in the row correspond to the memory bits assigned to that agent. By doing this, it is ensured that all agents get assigned 
some bits (strictly speaking this would depend on how much redundancy exists, such that when N_a*m_a >> TaskSize, some agents may still get assigned no bits). Since there is no 
redundancy, unfilled agent memory bits are assigned NaN.

Inputs:
TaskSize (int): memory size of task.
N_a (int): Number of agents in a group.
m_a (int): Memory capacity of each agent.

Returns:
AgentBits (2d numpy array): each row corresponds to an agent and the elements in the row correspond to the memory bits assigned to that agent.
NumExcludedBits (int): Number of bits of the task not covered by the agents in the group.
"""
def DistributeTask_GreaterGroupMem_NoRedundRandom(TaskSize, N_a, m_a):
    
    TotalCoverage = N_a*m_a # Total memory coverage across agents
    if TotalCoverage <= TaskSize: #error check 
        raise ValueError("Total memory across agents is less than TaskSize such that there cannot be empty agent memory bits. Please ensure N_a * m_a > TaskSize.")
    
    PaddedMemoryPerm = np.random.permutation(range(TotalCoverage)) + 1# Randomly permute the padded memory vector (obtained as range(TotalCoverage)) (+ 1 because Python indexes from 0)
    PaddedMemoryPerm = PaddedMemoryPerm.astype(np.float64) # Convert to float to allow NaN assignment (see below)
    PaddedMemoryPerm[PaddedMemoryPerm > TaskSize] = np.nan #Assign NaN to all memory bits that exceed TaskSize 
    AgentBits = np.reshape(PaddedMemoryPerm, (N_a, m_a)) #Reshape the permuted memory vector into an array of N_a rows and m_a columns, such that each row corresponds to 
    #the memory bits assigned to an agent

    #error checks
    TrueMemoryVec = np.arange(TaskSize) + 1 #The true memory vector (i.e., the range(TaskSize) vector) (+ 1 because Python indexes from 0)
    #print(TrueMemoryVec) #print(np.setdiff1d(TrueMemoryVec, AgentBits))
    if np.size(np.setdiff1d(TrueMemoryVec, AgentBits)) != 0: #note that as set up here, is agnostic to NaNs in AgentBits, because we are extracting values that are
        #in TrueMemoryVec but not in AgentBits
        raise ValueError("The setdiff of the AgentBits array and TrueMemoryVec should be empty (because the task is fully covered by pooled agent memory in the group).")
    
    NumExcludedBits = 0 #Number of bits excluded (should be zero in this case) (and we know this because we have done error checks)
    
    return AgentBits, NumExcludedBits



""" 
This function distributes the task (consisting of TaskSize number of bits) among N_a agents in a group, each with memory size of m_a bits such that N_a*m_a > TaskSize. That is, the
total number of memory bits pooled across agents in a group exceeds the TaskSize such that there are redundant bits of memory. 

Task memory distribution is done such that bits are assigned randomly and sequentially to agents. That is, the first agent receives a randomised bit, then the second agent receives
a randomised bit from the remaining bits, and so on and so forth till all task memory bits are assigned. This is accomplished by randomly permuting the range(TaskSize) 
bits, and if there are any leftover bits, those are randomly assigned to the second agent and so on and so forth. This is accomplished by randomly permuting the range(TaskSize) 
vector and *then* padding it with NaNs such that the total length is now equal to N_a*m_a (the total number of memory bits available in the group). This is followed by sequentially 
assigning bits from this permuted vector to each agent by reshaping the permuted vector into an array of shape (N_a, m_a) such that each row corresponds to an agent and the elements
in the row correspond to the memory bits assigned to that agent. By doing this, the memory distribution is such that the first one or more agents are biased to store more (or all)
bits of the task. Since there is no redundancy, unfilled agent memory bits are assigned NaN. 

Inputs:
TaskSize (int): memory size of task.
N_a (int): Number of agents in a group.
m_a (int): Memory capacity of each agent.

Returns:
AgentBits (2d numpy array): each row corresponds to an agent and the elements in the row correspond to the memory bits assigned to that agent.
NumExcludedBits (int): Number of bits of the task not covered by the agents in the group.
"""
def DistributeTask_GreaterGroupMem_NoRedund1Come1Serve(TaskSize, N_a, m_a):
    
    TotalCoverage = N_a*m_a # Total memory coverage across agents
    if TotalCoverage <= TaskSize: #error check 
        raise ValueError("Total memory across agents is less than TaskSize such that there cannot be empty agent memory bits. Please ensure N_a * m_a > TaskSize.")
    
    MemoryPerm = np.random.permutation(range(TaskSize)) + 1 # Randomly permute the memory vector (obtained as range(TaskSize)) (+ 1 because Python indexes from 0)
    ArrayToPad = np.full((TotalCoverage-TaskSize,),np.nan) #Create a 1d array of NaNs to pad the permuted memory vector with. Here, the argument (TotalCoverage-TaskSize,) 
    #creates a 1D array of length (TotalCoverage-TaskSize). That is, there will be (TotalCoverage-TaskSize) number of NaNs in this array.
    PaddedMemoryPerm = np.concatenate((MemoryPerm, ArrayToPad)) #Pad the permuted memory vector with NaNs such that its length is equal to TotalCoverage
    AgentBits = np.reshape(PaddedMemoryPerm, (N_a, m_a)) #Reshape the permuted memory vector 
    
    #error checks
    TrueMemoryVec = np.arange(TaskSize) + 1 #The true memory vector (i.e., the range(TaskSize) vector) (+ 1 because Python indexes from 0)
    if len(PaddedMemoryPerm) != TotalCoverage: 
        raise ValueError("The length of the padded memory vector should be equal to TotalCoverage.")
    
    if len(MemoryPerm) != TaskSize:
        raise ValueError("The length of the permuted memory vector should be equal to TaskSize.")
    
    if np.size(np.setdiff1d(TrueMemoryVec, AgentBits)) != 0: #note that as set up here, is agnostic to NaNs in AgentBits, because we are extracting values that are
        #in TrueMemoryVec but not in AgentBits
        raise ValueError("The setdiff of the AgentBits array and TrueMemoryVec should be empty (because the task is fully covered by pooled agent memory in the group).")
    
    NumExcludedBits = 0 #Number of bits excluded (should be zero in this case) (and we know this because we have done error checks)
    
    return AgentBits, NumExcludedBits



""" 
This function distributes the task (consisting of TaskSize number of bits) among N_a agents in a group, each with memory size of m_a bits such that N_a*m_a > TaskSize. That is, the
total number of memory bits pooled across agents in a group exceeds the TaskSize such that there are redundant bits of memory. 

Task memory distribution is done such that bits are assigned randomly to agents on a first come first serve basis. That is, the first agent receives a randomised assortment of task 
bits, and if there are any leftover bits, those are randomly assigned to the second agent and so on and so forth. This is accomplished by randomly permuting the range(TaskSize) 
vector and *then* padding it with NaNs such that the total length is now equal to N_a*m_a (the total number of memory bits available in the group). This is followed by sequentially 
assigning bits from this permuted vector to each agent by reshaping the permuted vector into an array of shape (m_a, N_a) and *then* transposing it such that each row corresponds 
to an agent and the elements in the row correspond to the memory bits assigned to that agent. By doing this (distribution by reshaping with rows = agent memory size and columns = 
number of agents, *followed* by transposing) the memory distribution is such that the agents are sequentially and randomly assigned bits. 

Inputs:
TaskSize (int): memory size of task.
N_a (int): Number of agents in a group.
m_a (int): Memory capacity of each agent.

Returns:
AgentBits (2d numpy array): each row corresponds to an agent and the elements in the row correspond to the memory bits assigned to that agent.
NumExcludedBits (int): Number of bits of the task not covered by the agents in the group.
"""
def DistributeTask_GreaterGroupMem_NoRedundRandSeq(TaskSize, N_a, m_a):
    
    #The only difference between this function and DistributeTask_GreaterGroupMem_NoRedund1Come1Serve is that here, the reshaping is done with rows = agent memory size and
    #columns = number of agents, followed by transposing. So, we can simply use the DistributeTask_GreaterGroupMem_NoRedund1Come1Serve function and then transpose the output.
    AgentBits, NumExcludedBits = DistributeTask_GreaterGroupMem_NoRedund1Come1Serve(TaskSize, m_a, N_a)
    AgentBits = AgentBits.T #Transpose to get the desired shape

    return AgentBits, NumExcludedBits



""" 
This function distributes the task (consisting of TaskSize number of bits) among N_a agents in a group, each with memory size of m_a bits such that N_a*m_a > TaskSize. That is, the
total number of memory bits pooled across agents in a group exceeds the TaskSize such that there are redundant bits of memory. 

In particular, this case allows for redundancy, such that unfilled agent memory bits after the initial memory allocation are again randomly assigned bits from the task memory, 
with the constraint that an agent cannot have multiple copies of the same bit. Within this framework, cases IIa1-3 in the initial markdown broadly collapse into a single case, 
given that unfilled memory bits get filled by a re-drawing from the task memory pool. With this in mind, I will use case IIa.1 (DistributeTask_GreaterGroupMem_NoRedundRandom, 
where agents are randomly assigned bits such that all agents get some bits; see markdown and the relevant function above) for the initial memory allocation.

This will be followed by a second round of memory allocation where each agent draws randomly from the task memory pool minus the bits alredy allocated to it.

Inputs:
TaskSize (int): memory size of task.
N_a (int): Number of agents in a group.
m_a (int): Memory capacity of each agent.

Returns:
AgentBits (2d numpy array): each row corresponds to an agent and the elements in the row correspond to the memory bits assigned to that agent.
NumExcludedBits (int): Number of bits of the task not covered by the agents in the group.
"""
def DistributeTask_GreaterGroupMem_RedundNoRepBits(TaskSize, N_a, m_a):
    
    MemoryVec = np.arange(TaskSize) + 1 #Get memory vector (+ 1 because Python indexes from 0)

    if TaskSize > m_a: #if task size is greater than agent memory size (this is because if task size is <= m_a, then the entire task will simply be allocated to each agent in the group
        #under the current allocation condition)
        #get initial bit allocation
        AgentBits, NumExcludedBits = DistributeTask_GreaterGroupMem_NoRedundRandom(TaskSize, N_a, m_a)

        #print(AgentBits)

        for i in range(N_a): #go through each agent memory allocation
            Agent_i_Bits = AgentBits[i, :] #get bits assigned to agent i
            ExcludedBits = np.random.permutation(np.setdiff1d(MemoryVec,Agent_i_Bits)) #get bits that are not in the ith agent's memory followed by permuting for random assinment
            #Note that as set up here, is agnostic to NaNs in AgentBits, because we are extracting values that are in TrueMemoryVec but not in AgentBits
            UnfilledIndices = np.where(np.isnan(Agent_i_Bits)) #get indices corresponding to nan values in the Agent_i_Bits array. Note that UnfilledIndices is a tuple with one 
            #element, which is an array of the indices corresponding to nan values. As such, to index into UnfilledIndices, we need to use UnfilledIndices[0].
            Agent_i_Bits[UnfilledIndices] = ExcludedBits[0:len(UnfilledIndices[0])] #Fill the unfilled agent memory bits with randomly assigned excluded bits

            #CHECKS: if task size is greater than m_a, then there shuould be no NaN bits in agent memory
            Agent_i_Bits_NanRem = Agent_i_Bits[~np.isnan(Agent_i_Bits)] #first remove NaN bits
            if np.array_equal(Agent_i_Bits, Agent_i_Bits_NanRem) == False:
                raise ValueError("There are NaN bits in the agent memory. This is not allowed under this allocation scheme when TaskSize > m_a.")

            #CHECKS! Are there repeated bits in the agent memory
            u_indices = np.unique(Agent_i_Bits, return_index = True)[1] #unique returns the output sorted, so the check below will return false. By accessing the original indices through
            #retun_index = True, where the full function output would be uniqvals, indices = np.unique(array, return_index=True). By doing np.unique(Agent_i_Bits, return_index = True)[1],
            #we get the indices (unsorted) corresponding to the unique values in Agent_i_Bits.
            u_Agent_i_Bits = [Agent_i_Bits[ind] for ind in sorted(u_indices)]
            if np.array_equal(Agent_i_Bits, u_Agent_i_Bits) == False:
                raise ValueError("There are repeated bits in the agent memory allocation. This is not allowed under this allocation scheme.")
            
            AgentBits[i, :] = Agent_i_Bits #update the AgentBits array with the updated agent i bits 
             
    else: #if TaskSize <= m_a (so that the entire task can fit into each agent's memory)
        Agent_i_Bits = [float('nan')] * m_a #initialise agent_i_bits as a list that is all NaN with m_a elements (so that this can get stacked into the AgentBits 2d array)
        Agent_i_Bits[0:TaskSize] = MemoryVec #assign the entire memory task to the agent bits vector
        AgentBits = np.tile(Agent_i_Bits,(N_a,1)) #tile this array across all agents in the group

        #CHECKS: The task should be fully covered by each agent memory
        if np.size(np.setdiff1d(MemoryVec,Agent_i_Bits)) != 0: #Note that as set up here, is agnostic to NaNs in AgentBits, because we are extracting values that are
        #in TrueMemoryVec but not in AgentBits
            raise ValueError("The setdiff of the Agent_i_Bits list and MemoryVec should be empty (because the task is fully covered by each agent memory, since m_a >= TaskSize).")
            #Note that size gets the number of elements while shape gets the dimensions of the array (e.g., (2,2))

        #CHECKS: There should not be any NaN bits in agent memory if it is TaskSize is exactly equal to m_a
        if TaskSize == m_a:
            if np.isnan(Agent_i_Bits).any():
                raise ValueError("There should be no NaN bits in the agent memory when TaskSize == m_a.")    

        AgentBits_forCheck, NumExcludedBits = DistributeTask_GreaterGroupMem_NoRedundRandom(TaskSize, N_a, m_a) #to do checks, get the AgentBits array from 
        #the DistributeTask_GreaterGroupMem_NoRedundRandom function

        #CHECKS: The size of agent bits arrays should be the same
        if np.size(AgentBits) != np.size(AgentBits_forCheck):
            raise ValueError("The size of the AgentBits array is not equal to that obtained from the DistributeTask_GreaterGroupMem_NoRedundRandom function.")

    if NumExcludedBits != 0:
        raise ValueError("Number of bits excluded should be zero since N_a*m_a > TaskSize.")    
    
    return AgentBits, NumExcludedBits



#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
##############---------Functions to parse run the simulations across N_g groups and get relevant outputs for CI vs CM---------##############
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
"""
This function generates the aggregated AgentBits array (AggregAgentBits) for N_groups. Here, AggregAgentBits is a 2D numpy array generated by vertically stacking the AgentBits 
arrays obtained from each group. See relevant functions used for more details

Inputs:
TaskSize (int): memory size of task.
N_a (int): Number of agents in a group.
m_a (int): Memory capacity of each agent.
N_groups (int): Number of groups.
MemoryDistCondition (str): Condition for task memory distribution. 
    Possible values are: "GreaterGroupMem_NoRedundRandom", "GreaterGroupMem_NoRedund1Come1Serve", "GreaterGroupMem_NoRedundRandSeq", "GreaterGroupMem_RedundNoRepBits"

Returns:
AggregAgentBits: aggregated AgentBits array for N_groups. 
TrueExcludedBits: number of excluded bits for stable groups
"""
def GetAggregateAgentBitsForNgroups(TaskSize, N_a, m_a, N_groups, MemoryDistCondition):
    
    TotalCoverage = N_a*m_a # Total memory coverage across agents

    AggregAgentBits = np.empty((0, m_a))  # Initialize an empty NumPy array with m_a columns (since each agent has m_a memory bits). We will use this to sequentially store
    #the AgentBits arrays obtained from each group, and then use this aggregated array to create shufflef groups
    ExcludedBitsArray = np.zeros((N_groups,))

    if TotalCoverage <= TaskSize: #Case when total task coverage is at most the same as TaskSize
        for i in range(N_groups): #Go through each group
            AgentBits, ExcludedBitsArray[i] = DistributeTask_LeqGroupMem(TaskSize, N_a, m_a) #Get AgentBits array for each group
            AggregAgentBits = np.vstack([AggregAgentBits, AgentBits]) #Append the AgentBits array to the AggregAgentBits array
    elif TotalCoverage > TaskSize: #Case when total task coverage exceeds TaskSize
        for i in range(N_groups): #Go through each group and test for different conditions
            if MemoryDistCondition == "GreaterGroupMem_NoRedundRandom":
                AgentBits, ExcludedBitsArray[i] = DistributeTask_GreaterGroupMem_NoRedundRandom(TaskSize, N_a, m_a) 
            elif MemoryDistCondition == "GreaterGroupMem_NoRedund1Come1Serve":
                AgentBits, ExcludedBitsArray[i] = DistributeTask_GreaterGroupMem_NoRedund1Come1Serve(TaskSize, N_a, m_a) 
            elif MemoryDistCondition == "GreaterGroupMem_NoRedundRandSeq":
                AgentBits, ExcludedBitsArray[i] = DistributeTask_GreaterGroupMem_NoRedundRandSeq(TaskSize, N_a, m_a) 
            elif MemoryDistCondition == "GreaterGroupMem_RedundNoRepBits":
                AgentBits, ExcludedBitsArray[i] = DistributeTask_GreaterGroupMem_RedundNoRepBits(TaskSize, N_a, m_a)
            else:
                raise ValueError("Invalid MemoryDistCondition. Possible values are: GreaterGroupMem_NoRedundRandom, GreaterGroupMem_NoRedund1Come1Serve, GreaterGroupMem_NoRedundRandSeq, GreaterGroupMem_RedundNoRepBits.")
            
            AggregAgentBits = np.vstack([AggregAgentBits, AgentBits]) #Append the AgentBits array to the AggregAgentBits array

    if np.size(np.unique(ExcludedBitsArray)) > 1:
        raise ValueError('Number of excluded bits varies across groups. This should not happen') #cuz the excluded bits should be the same across all groups in stable 
    #group formation scenarios
    
    TrueExcludedBits = np.unique(ExcludedBitsArray)[0] #get the number of excluded bits for stable groups
        
    return AggregAgentBits, TrueExcludedBits



""" 
This function generates the aggregate array for N_groups of N_a agents each with memory size m_a, shuffles the groups, and returns the shuffled groups. See relevant functions 
used for more details.

Inputs:
TaskSize (int): memory size of task.
N_a (int): Number of agents in a group.
m_a (int): Memory capacity of each agent.
N_groups (int): Number of groups to simulate.
MemoryDistCondition (string): Memory distribution condition. We only use this when the TaskSize is less than the total memory across agents in a group (N_a*m_a > TaskSize).
    Possible values are: GreaterGroupMem_NoRedundRandom, GreaterGroupMem_NoRedund1Come1Serve, GreaterGroupMem_NoRedundRandSeq, GreaterGroupMem_RedundNoRepBits.

Returns:
ShuffledGroups: array with the shuffled groups, such that each consecutive group of N_a rows correspond to one shuffled group
TrueExcludedBits: number of excluded bits for stable groups
"""
def GetShuffledGroups(TaskSize, N_a, m_a, N_groups, MemoryDistCondition):

    #Get aggregated AgentBits array for N_groups as well as the number of excluded bits for stable groups
    AggregAgentBits, TrueExcludedBits = GetAggregateAgentBitsForNgroups(TaskSize, N_a, m_a, N_groups, MemoryDistCondition)

    NumRows = np.shape(AggregAgentBits)[0] #Get the number of rows in the AggregAgentBits array (this will be the actual length, not indexed from 0. So, a value of 3 will mean there
    #are 3 rows, not 2)
    ShuffledGroupInds = np.random.permutation(range(NumRows)) #Get a random permutation of the row indices of the AggregAgentBits array
    #Note that because we are using range(NumRows), the indices are indexed from 0. So, if NumRows = 3, the possible indices are [0, 1, 2], which will then be randomly permuted
    ShuffledGroups = AggregAgentBits[ShuffledGroupInds] #Shuffle the groups by indexing the AggregAgentBits array with the randomly permuted row indices

    if NumRows != np.shape(ShuffledGroups)[0]:
        raise ValueError("Number of rows in ShuffledGroups should be the same as that in AggregAgentBits.")

    return ShuffledGroups, TrueExcludedBits



""" 
This function returns the mean and standard deviation of the number of excluded bits across N_groups by computing the number of excluded bits for each shuffled group and 
then taking the average and the std deviation. Meanwhile, for stable groups, the number of excluded bits remains fixed.

Inputs:
TaskSize (int): memory size of task.
N_a (int): Number of agents in a group.
m_a (int): Memory capacity of each agent.
N_groups (int): Number of groups to simulate.
MemoryDistCondition (string): Memory distribution condition. We only use this when the TaskSize is less than the total memory across agents in a group (N_a*m_a > TaskSize).
    Possible values are: "GreaterGroupMem_NoRedundRandom", "GreaterGroupMem_NoRedund1Come1Serve", "GreaterGroupMem_NoRedundRandSeq", "GreaterGroupMem_RedundNoRepBits"

Returns:
MeanExcludedBits, StdExcludedBits: mean and std deviation of the number of excluded bits across N_groups
Stable_ExcludedBits: number of excluded bits for stable groups
"""
def GetMeanAndStdExcludedBits(TaskSize, N_a, m_a, N_groups, MemoryDistCondition):

    ShuffledGroups, Stable_ExcludedBits = GetShuffledGroups(TaskSize, N_a, m_a, N_groups, MemoryDistCondition)
    
    TrueMemoryVec = np.arange(TaskSize) + 1 #The true memory vector (i.e., the range(TaskSize) vector) (+ 1 because Python indexes from 0)
    ExcludedBitsArray = np.zeros((N_groups,)) #Initialize an array to store the number of excluded bits across N_groups number of runs

    for i in range(N_groups):
        CurrShuffledGroup = ShuffledGroups[i*N_a:(i+1)*N_a, :] #Get the current shuffled group by indexing the ShuffledGroups array.
        #Note that when python indexes from i to j, what we actually get is i to (j-1), which is why the above indexing works (which is wild and a lil confusing to me)
        NumExcludedBits_ShuffledGroup = np.size(np.setdiff1d(TrueMemoryVec, CurrShuffledGroup)) #Get the number of excluded bits for the current shuffled group
        #Note that as set up here, is agnostic to NaNs in AgentBits, because we are extracting values that are in TrueMemoryVec but not in AgentBits
        ExcludedBitsArray[i] = NumExcludedBits_ShuffledGroup 
    
    MeanExcludedBits = np.mean(ExcludedBitsArray) #Mean of excluded bits across N_groups number of runs (setdiff already takes care of NaNs )
    StdExcludedBits = np.std(ExcludedBitsArray) #Standard deviation of excluded bits across N_groups number of runs
    
    return MeanExcludedBits, StdExcludedBits, Stable_ExcludedBits



#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
##############---------Functions for parallelisation---------##############
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
"""
This is a worker function to be able to parallelise the parameter sweep over the function GetMeanAndStdExcludedBits. Essentially, this worker function takes in a set of arguments
for one parameter combo for the parameter sweep (args). args is a tuple (i.e., it is ordered, unchangeable, and allows for the storage of multiple item types). By taking in the 
argument for one parameter combo as a tuple, this function serves as a wrapper that allows for easy parallelisation

Inputs: 
    args (tuple): a tuple containing the arguments for one parameter combo for the parameter sweep. The order of the arguments in the tuple should be:
        (TaskSize, N_a, m_a, N_g , MemoryDistCondition (string))

Outputs: 
    N_a, m_a: group size and agent memory size inputs for the current case
    MeanExcBits_CI: Mean value of excluded bits in the CI case across N_g number of groups (i.e., N_g number of 'trials) 
    StdExcBits_CI: Std deviation of the number of excluded bits in the CI case across N_g groups
    StableExcBits: number of excluded bits in the stable case (CM; deterministic) 
"""
def WorkerFn_ForParallelParamSweep(args):
    
    TaskSize, N_a, m_a, N_g, MemoryDistCondition = args #unpack the args tuple into arguments for the GetMeanAndStdExcludedBits function
    MeanExcBits_CI, StdExcBits_CI, StableExcBits = GetMeanAndStdExcludedBits(TaskSize, N_a, m_a, N_g, MemoryDistCondition) #do the computation

    #return the results. Since we are parallelising over N_a and m_a (which are the parameters being swept over), we also return those to keep track of the results
    return N_a, m_a, MeanExcBits_CI, StdExcBits_CI, StableExcBits



"""
This function parallelises the parameter sweep using the worker function WorkerFn_ForParallelParamSweep (whic is a wrapper for GetMeanAndStdExcludedBits). Parallelisation is over 
N_a and m_a values

Inputs: 
    TaskSize: size of task (total number of taks memory bits) 
    N_a_vec: vector of N_a (number of agents in a group) 
    m_a_vec: vector of m_a (agent memory size)
    N_g: number of groups (i.e., trials) across which the mean values of the CI condition is assessed 
    MemoryDistCondition: the memory distibution condition to use (string). Possible values are: 
        "GreaterGroupMem_NoRedundRandom", "GreaterGroupMem_NoRedund1Come1Serve", "GreaterGroupMem_NoRedundRandSeq", "GreaterGroupMem_RedundNoRepBits"
    NumFreeCores: number of cores to leave free

Outputs:
"""
def GetCIvsCMstats_ParallelParamSweep(TaskSize, N_a_vec, m_a_vec, N_g, MemoryDistCondition, NumFreeCores):

    #Initialise arrays
    NumAgents = len(N_a_vec)
    NumAgentMemBits = len(m_a_vec)
    MeanExcludedBits_CI_Array = np.full((NumAgents, NumAgentMemBits), np.nan) #np.zeros((len(TaskMem_To_Na), len(TaskMem_To_ma)))
    StdExcludedBits_CI_Array = np.full((NumAgents, NumAgentMemBits), np.nan)
    StableExcludedBits_CM_Array = np.full((NumAgents, NumAgentMemBits), np.nan)

    #Generate the argument tuples to be passed to the parallel process
    Na_ma_paramcombos = product(N_a_vec, m_a_vec) #get the element-by-element combos of N_a and m_a values to be swept over. We can pack these with the other (fixed) arguments
    #to get the args tuple to be passed to the worker function (WorkerFn_ForParallelParamSweep) taht will be parallelised over

    #get the list of args tuples by combining each value of N_a and m_a to the other inputs to be passed, by iterating over the element-by-element product object of N_a and m_a
    List_of_args = [(TaskSize, Na_i, ma_i, N_g, MemoryDistCondition) for Na_i, ma_i in Na_ma_paramcombos]

    #Before passing arguments to the parallel process, we need to make a dictionary so that the unordered output from the parallel process can be reconstituted in order. Since
    #the parallelisation will be over the combo of N_a and m_a values, we will use these as keys for their own separate dicts. Note that the value of Na and ma are the keys, and the
    #corresponding indices that index into N_a_vec and m_a_vec are the values, in this dict. So, Indices_for_Na[Na_val] will give the index of Na_val in N_a_vec. 
    #What enumerate does is, it appends an index to each element in the iterable (here, N_a_vec or m_a_vec). So, for example, if N_a_vec = [2, 4, 6], then enumerate(N_a_vec) will 
    #give (0,2), (1,4), (2,6). 
    Indices_for_Na = {Na_val: i_Na for i_Na, Na_val in enumerate(N_a_vec)}
    Indices_for_ma = {ma_val: i_ma for i_ma, ma_val in enumerate(m_a_vec)}

    if NumFreeCores < 0: #error check
        raise Exception('NumFreeCores cannot be negative. Please set a non-negative value for NumFreeCores')
    elif NumFreeCores >= os.cpu_count(): #error check
        raise Exception('NumFreeCores cannot be greater than or equal to the total number of CPU cores. Please set a an appropriate value for NumFreeCores')

    num_processes = os.cpu_count()-NumFreeCores  #Set the number of processes to the total number of CPU cores minus NumFreeCores so (ideally) there are a couple 
    #free cores for other uses. Setting NumFreeCores to 0 would mean that all CPU cores are used for parallel processing.

    with mxp.Pool(processes = num_processes) as pool: #set up the parallel process pool with N_cores number of cores
        SweepResults = list(
            tqdm(
            pool.imap_unordered(WorkerFn_ForParallelParamSweep, List_of_args), #This does the parallelisation
            total = len(List_of_args)) #this second paranthesis is for the progress bar (tqdm)
            ) #finally, the list() converts the imap_unordered object to a list for easier indexing

    #Reconstitute the unordered output into ordered arrays corresponding to values of N_a and m_a. This works because the WorkerFn_ForParallelParamSweep function returns
    #N_a, m_a, MeanExcBits_CI, StdExcBits_CI, and StableExcBits
    for Na_val_i, ma_val_i, MeanExcBits_CI_i, StdExcBits_CI_i, StableExcBits_i in SweepResults:
        Na_ind = Indices_for_Na[Na_val_i] #get the index corresponding to the N_a value
        ma_ind = Indices_for_ma[ma_val_i] #get the index corresponding to the m_a value

        MeanExcludedBits_CI_Array[Na_ind,ma_ind] = MeanExcBits_CI_i 
        StdExcludedBits_CI_Array[Na_ind,ma_ind] = StdExcBits_CI_i
        StableExcludedBits_CM_Array[Na_ind,ma_ind] = StableExcBits_i

    return MeanExcludedBits_CI_Array, StdExcludedBits_CI_Array, StableExcludedBits_CM_Array



""" 
Old non-parallelised function for getting CI vs CM stats 
"""
# def GetCIvsCMstatsForParamSweep(TaskSize, N_a_vec, m_a_vec, N_g, MemoryDistCondition):

#     #Initialise arrays
#     NumAgents = len(N_a_vec)
#     NumAgentMemBits = len(m_a_vec)
#     MeanExcludedBitsArray = np.full((NumAgents, NumAgentMemBits), np.nan) #np.zeros((len(TaskMem_To_Na), len(TaskMem_To_ma)))
#     StdExcludedBitsArray = np.full((NumAgents, NumAgentMemBits), np.nan)
#     Stable_ExcludedBitsArray = np.full((NumAgents, NumAgentMemBits), np.nan)

#     #print(type(MeanExcludedBitsArray), type(StdExcludedBitsArray), type(Stable_ExcludedBitsArray))

#     for i_Na in tqdm(range(NumAgents), total=NumAgents):
#         for i_ma in range(NumAgentMemBits):

#             N_a = N_a_vec[i_Na] #Number of agents in a group
#             m_a = m_a_vec[i_ma] #Memory size of each agent

#             #print(N_a, m_a)
#             MeanTemp, StdTemp, StableExcBitsTemp = GetMeanAndStdExcludedBits(TaskSize, N_a, m_a, N_g, MemoryDistCondition)

#             MeanExcludedBitsArray[i_Na,i_ma] = MeanTemp
#             StdExcludedBitsArray[i_Na,i_ma] = StdTemp
#             Stable_ExcludedBitsArray[i_Na,i_ma] = StableExcBitsTemp

#     #print(type(MeanTemp), type(StdTemp), type(StableExcBitsTemp))
#     return MeanExcludedBitsArray, StdExcludedBitsArray, Stable_ExcludedBitsArray 

