classdef AFSEA < ALGORITHM
% <multi> <real> <large> <sparse>

%------------------------------- Reference --------------------------------
% G. Zhang, N. Wu, and C. N. Shen, An adaptive fitness evolutionary 
% algorithm for sparse large-scale multi-objective optimization problems,
% 2022.
%------------------------------- Copyright --------------------------------
% Copyright (c) 2022 BIMK Group. You are free to use the PlatEMO for
% research purposes. All publications which use this platform or any code
% in the platform should acknowledge the use of "PlatEMO" and reference "Ye
% Tian, Ran Cheng, Xingyi Zhang, and Yaochu Jin, PlatEMO: A MATLAB platform
% for evolutionary multi-objective optimization [educational forum], IEEE
% Computational Intelligence Magazine, 2017, 12(4): 73-87".
%--------------------------------------------------------------------------

    methods
        function main(Algorithm,Problem)
            %% Population initialization
            % Calculate the fitness of each decision variable
            TDec    = [];
            TMask   = [];
            TempPop = [];
            Fitness = zeros(1,Problem.D);
            REAL    = ~strcmp(Problem.encoding,'binary');

            if REAL
                Dec = unifrnd(repmat(Problem.lower,Problem.D,1),repmat(Problem.upper,Problem.D,1));
            else
                Dec = ones(Problem.D,Problem.D);
            end
            Mask       = eye(Problem.D);
            Population = SOLUTION(Dec.*Mask);
            TDec       = [TDec;Dec];
            TMask      = [TMask;Mask];
            TempPop    = [TempPop,Population];
            Fitness    = Fitness + NDSort([Population.objs,Population.cons],inf);
            
            % Generate initial population
            if REAL
                Dec = unifrnd(repmat(Problem.lower,Problem.N,1),repmat(Problem.upper,Problem.N,1));
            else
                Dec = ones(Problem.N,Problem.D);
            end
            Mask = zeros(Problem.N,Problem.D);
            for i = 1 : Problem.N
                Mask(i,TournamentSelection(2,ceil(rand*Problem.D),Fitness)) = 1;
            end
            Population = SOLUTION(Dec.*Mask);
            [Population,Dec,Mask,FrontNo,CrowdDis] = EnvironmentalSelection([Population,TempPop],[Dec;TDec],[Mask;TMask],Problem.N);

            %% Optimization
            while Algorithm.NotTerminated(Population)
                MatingPool       = TournamentSelection(2,2*Problem.N,FrontNo,-CrowdDis);
                [OffDec,OffMask] = Operator(Dec(MatingPool,:),Mask(MatingPool,:),FrontNo,REAL,Algorithm.pro.FE,Algorithm.pro.maxFE);
                Offspring        = SOLUTION(OffDec.*OffMask);
                [Population,Dec,Mask,FrontNo,CrowdDis] = EnvironmentalSelection([Population,Offspring],[Dec;OffDec],[Mask;OffMask],Problem.N);
            end
        end
    end
end