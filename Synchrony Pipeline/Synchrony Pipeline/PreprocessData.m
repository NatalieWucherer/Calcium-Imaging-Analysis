function F = PreprocessData(F)

%% Remove NaNs

F(isnan(F))=0;

%% Z-score each neuron

F=zscore(F,0,2);

%% Remove remaining NaNs

F(isnan(F))=0;

end