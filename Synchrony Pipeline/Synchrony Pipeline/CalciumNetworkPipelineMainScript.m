function CalciumNetworkPipelineMainScript(filePath)

clc
close all

%% Load data
[data,coords,fileName,outFolder] = LoadData(filePath);


%% Preprocess
F = PreprocessData(data);


%% Static synchrony
Results = PearsonSynchrony(F);


%% Cross correlation
Results.CrossCorr = CrossCorrelationSynchrony(F);


%% Statistical testing
Results = SynchronyStatistics(Results,F);


%% Dynamic synchrony
Results = DynamicSynchrony(Results,F);


%% Time-tailed synchrony
Results = TimeTailedSynchrony(Results,F);

%% Calcium-event STTC
Results = CalciumEventSTTC(Results,F);

%% Global v local

Results = LocalGlobalSynchrony(Results,coords);


%% Network bursts
Results = NetworkBurstDetection(Results,F);


%% Local synchrony
Results = LocalSynchrony(Results,F);


%% Spatial synchrony
Results = SpatialSynchrony(Results,coords);


%% Graph theory
Results = GraphTheoryAnalysis(Results);


%% Spatial network analysis
Results = SpatialNetworkAnalysis(Results,coords);

%% EXPORT LAST
ExportResults(Results,fileName,outFolder)

%% FIGURES LAST
PublicationFigures(Results,F,coords,fileName,outFolder)

disp("Analysis Complete")

end
%CalciumNetworkPipelineMainScript('C:\Ca Prep Done\1_R1_T2_d70_Baseline_3_ExStruct.mat')