function Results = NetworkBurstDetection(Results,F)


% ---------------------------------------------------------
% Detect synchronous calcium events
%
% Input:
% F = neurons x frames
%
% Output:
% Burst timing and statistics
%
% ---------------------------------------------------------



%% Parameters

threshold = 2;

minimumNeurons = 0.1;



N=size(F,1);



%% Detect active neurons


% z-score activity

Z=zscore(F,0,2);



active = Z > threshold;



%% Fraction active per frame

populationActivity = mean(active,1);



%% Burst threshold

burstThreshold = minimumNeurons;



burstFrames = populationActivity > burstThreshold;



%% Find burst periods


starts = find(diff([0 burstFrames])==1);

ends   = find(diff([burstFrames 0])==-1);



numBursts = length(starts);



Duration=zeros(numBursts,1);

Amplitude=zeros(numBursts,1);

Recruitment=zeros(numBursts,1);



for b=1:numBursts


    idx=starts(b):ends(b);



    Duration(b)=length(idx);


    Amplitude(b)=mean(populationActivity(idx));


    Recruitment(b)=max(populationActivity(idx));


end



%% Save results


Results.BurstFrames = burstFrames;

Results.BurstStart = starts;

Results.BurstEnd = ends;

Results.BurstDuration = Duration;

Results.BurstAmplitude = Amplitude;

Results.BurstRecruitment = Recruitment;

Results.NumBursts=numBursts;


Results.PopulationActivity=populationActivity;



end