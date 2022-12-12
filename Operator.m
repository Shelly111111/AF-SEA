function [OffDec,OffMask] = Operator(ParentDec,ParentMask,FrontNo,REAL,FE,maxFE)
% The operator of AF-SEA

%------------------------------- Copyright --------------------------------
% Copyright (c) 2022 BIMK Group. You are free to use the PlatEMO for
% research purposes. All publications which use this platform or any code
% in the platform should acknowledge the use of "PlatEMO" and reference "Ye
% Tian, Ran Cheng, Xingyi Zhang, and Yaochu Jin, PlatEMO: A MATLAB platform
% for evolutionary multi-objective optimization [educational forum], IEEE
% Computational Intelligence Magazine, 2017, 12(4): 73-87".
%--------------------------------------------------------------------------

    %% Parameter setting
    [N,D]       = size(ParentDec);
    Parent1Dec  = ParentDec(1:floor(end/2),:);
    Parent2Dec  = ParentDec(floor(end/2)+1:floor(end/2)*2,:);
    Parent1Mask = ParentMask(1:floor(end/2),:);
    Parent2Mask = ParentMask(floor(end/2)+1:floor(end/2)*2,:);
    Problem = PROBLEM.Current();
    
    %% Update Fitness
    rank1 = FrontNo == 1;
    Fitness = sum(ParentMask(rank1,:),1)/sum(rank1);
    
     %% Crossover and mutation for dec
     if REAL
         [OffDec,groupIndex,chosengroups] = GLPMask_OperatorGAhalf(Parent1Dec,Parent2Dec,Parent1Mask,Parent2Mask,4); % 4 -- numberofgroups
     end
            
    %% Crossover for mask
    OffMask = Parent1Mask;
    for i = 1 : N/2
        SelectedIndex=[];
        for j = 1 : floor(log2(Problem.D/100))+2
            if rand < 0.5
                index = find(Parent1Mask(i,:)&~Parent2Mask(i,:));
                index = setdiff(index,SelectedIndex);
                index = index(ArgMax(-Fitness(index)));
                if ~isempty(index)
                    OffMask(i,index) = 0;
                    SelectedIndex=[SelectedIndex,index];
                end
            else
                index = find(~Parent1Mask(i,:)&Parent2Mask(i,:));
                index = setdiff(index,SelectedIndex);
                index = index(ArgMax(Fitness(index)));
                if ~isempty(index) && REAL
                    OffMask(i,index) = 1;
                    SelectedIndex=[SelectedIndex,index];
                elseif ~isempty(index)
                    OffMask(i,index) = 1;
                    SelectedIndex=[SelectedIndex,index];
                end
            end
        end
    end
    
    %% Mutation for mask
    if REAL
        chosenindex = groupIndex == chosengroups;
        for i = 1 : N/2
            SelectedIndex=[];
            for j = 1 : floor(log2(Problem.D/100))+2
                rd=rand;
                if rd < 0.5*(1-FE/maxFE)
                    index = find(OffMask(i,:)&chosenindex(i,:));
                    index = setdiff(index,SelectedIndex);
                    index = index(ArgMax(-Fitness(index)));
                    if ~isempty(index)
                        OffMask(i,index) = 0;
                        SelectedIndex=[SelectedIndex,index];
                    end
                elseif rd < 1-FE/maxFE
                    index = find(~OffMask(i,:)&chosenindex(i,:));
                    index = setdiff(index,SelectedIndex);
                    index = index(ArgMax(Fitness(index)));
                    if ~isempty(index)
                        OffMask(i,index) = 1;
                        SelectedIndex=[SelectedIndex,index];
                    end
                end
            end
        end
    end
end

function index = ArgMax(Fitness)
    [~,index] =max(Fitness);
end