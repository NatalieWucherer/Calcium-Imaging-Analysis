function Results = TimeTailedSynchrony(Results,F)

% =========================================================
% Time-Tailed Synchrony Analysis
%
% Calculates exponentially weighted functional synchrony.
%
% Recent activity contributes more strongly than older
% activity using exponential decay.
%
% Designed for:
%   Calcium imaging
%   2 Hz acquisition
%   5 minute recordings
%
%
% INPUT:
%
% F:
% neurons x frames matrix (dF/F)
%
%
% OUTPUT:
%
% Results.TimeTailedSynchrony
% Results.TimeTailedTime
% Results.TimeTailedTau
%
% =========================================================


%% -----------------------------
% Parameters
% ------------------------------


% Imaging rate

frameRate = 2;   % Hz


% Temporal decay constants
%
% Units = frames
%
% 10 frames  = 5 seconds
% 20 frames  = 10 seconds
% 60 frames  = 30 seconds


tauValues = [10 20 60];



%% -----------------------------
% Basic dimensions
% ------------------------------


[numNeurons,numFrames] = size(F);



% Replace NaNs

F(isnan(F)) = 0;



%% -----------------------------
% Output storage
% ------------------------------


numTau = length(tauValues);


timeSynchrony = zeros(numFrames,numTau);



%% -----------------------------
% Calculate time-tailed synchrony
% ------------------------------


for k = 1:numTau


    tau = tauValues(k);



    % Exponential decay factor

    alpha = exp(-1/tau);



    % Running mean

    mu = zeros(numNeurons,1);



    % Running covariance

    C = zeros(numNeurons);



    for t = 1:numFrames


        % Current activity

        x = F(:,t);



        % Update exponentially weighted mean

        mu = alpha*mu + (1-alpha)*x;



        % Remove mean

        dx = x - mu;



        % Update covariance

        C = alpha*C + (1-alpha)*(dx*dx');



        % Convert covariance to correlation


        variance = diag(C);



        denominator = sqrt(variance*variance');



        R = C ./ denominator;



        % Remove invalid values

        R(~isfinite(R)) = NaN;



        % Remove diagonal

        R(1:numNeurons+1:end)=NaN;



        % Mean synchrony

        timeSynchrony(t,k)=...
            mean(R,'all','omitnan');


    end


end



%% -----------------------------
% Store results
% ------------------------------


Results.TimeTailedSynchrony = timeSynchrony;


% Frames

Results.TimeTailedTimeFrames = 1:numFrames;


% Seconds

Results.TimeTailedTimeSeconds = ...
    (1:numFrames)/frameRate;


% Tau values

Results.TimeTailedTauFrames = tauValues;


Results.TimeTailedTauSeconds = ...
    tauValues/frameRate;



disp('Time-tailed synchrony complete')

disp('Temporal integration windows:')

disp(Results.TimeTailedTauSeconds)



end