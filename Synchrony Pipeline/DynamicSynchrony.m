function Results = DynamicSynchrony(Results,F)

% ---------------------------------------------------------
% Dynamic synchrony using sliding-window Pearson correlation
%
% Input:
% F = neurons x frames
%
% Output:
% Results.DynamicSynchrony
% Results.TimePoints
%
% ---------------------------------------------------------


%% Parameters

window = 100;      % frames per window

step = 10;         % window movement


N = size(F,1);

T = size(F,2);



%% Window positions

starts = 1:step:(T-window+1);

numWindows = length(starts);


DynamicSync=zeros(numWindows,1);


MeanCorrelation=zeros(numWindows,1);



%% Calculate synchrony through time

for w=1:numWindows


    frames = starts(w):(starts(w)+window-1);


    Fwindow = F(:,frames);



    % correlation matrix

    R=corrcoef(Fwindow');


    % remove self correlations

    R(1:N+1:end)=NaN;



    % average network synchrony

    DynamicSync(w)=mean(R,'all','omitnan');



    % optional metric

    MeanCorrelation(w)=mean(abs(R),'all','omitnan');



end



%% Save results

Results.DynamicSynchrony = DynamicSync;

Results.DynamicMeanCorrelation = MeanCorrelation;

Results.DynamicTime = starts + window/2;



end