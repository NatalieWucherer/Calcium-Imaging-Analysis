function PublicationFigures(Results,F,coords,fileName,outFolder)



%% Global formatting

set(groot,...
'defaultAxesFontName','Arial',...
'defaultAxesFontSize',12,...
'defaultLineLineWidth',2,...
'defaultFigureColor','w');



%% Figure 1
% Pearson matrix


figure('Position',[100 100 600 500])

imagesc(Results.Pearson)

axis square

colorbar

xlabel('Neuron')

ylabel('Neuron')

title('Functional Connectivity')


exportgraphics(gcf,...
fullfile(outFolder,...
[fileName '_Fig1_Pearson.png']),...
'Resolution',600)



%% Figure 2
% Network graph


figure('Position',[100 100 700 600])


G=graph(Results.AdjacencyMatrix);


p=plot(G,...
'Layout','force');


p.MarkerSize=8;

p.NodeCData=Results.Degree;


colorbar


title('Functional Network')


exportgraphics(gcf,...
fullfile(outFolder,...
[fileName '_Fig2_Network.png']),...
'Resolution',600)




%% Figure 3
% Dynamic synchrony


figure


plot(Results.DynamicTime,...
Results.DynamicSynchrony)


xlabel('Frame')

ylabel('Synchrony')

title('Dynamic Network Synchrony')


exportgraphics(gcf,...
fullfile(outFolder,...
[fileName '_Fig3_DynamicSynchrony.png']),...
'Resolution',600)




%% Figure 4
% Raster plot


figure


imagesc(F)

colormap hot

xlabel('Frame')

ylabel('Neuron')

hold on


for b=1:Results.NumBursts

xline(Results.BurstStart(b),'r')

end


title('Calcium Activity Raster')


exportgraphics(gcf,...
fullfile(outFolder,...
[fileName '_Fig4_Raster.png']),...
'Resolution',600)





%% Figure 5
% Local synchrony


figure


histogram(Results.LocalSynchrony,30)


xlabel('Synchrony')

ylabel('Neuron count')


title('Functional Local Synchrony')


exportgraphics(gcf,...
fullfile(outFolder,...
[fileName '_Fig5_Local.png']),...
'Resolution',600)





%% Figure 6
% Spatial synchrony


if ~isempty(coords)


figure


scatter(coords(:,1),...
coords(:,2),...
60,...
Results.SpatialSynchrony,...
'filled')


axis equal

colorbar


xlabel('X')

ylabel('Y')

title('Spatial Synchrony Map')


exportgraphics(gcf,...
fullfile(outFolder,...
[fileName '_Fig6_Spatial.png']),...
'Resolution',600)


end





%% Figure 7
% Distance correlation


if ~isempty(coords)


figure


D=Results.DistanceMatrix;

R=Results.Pearson;


scatter(D(:),R(:),5,'.')


xlabel('Distance')

ylabel('Correlation')


title('Distance Dependence of Connectivity')


exportgraphics(gcf,...
fullfile(outFolder,...
[fileName '_Fig7_DistanceCorrelation.png']),...
'Resolution',600)


end





%% Figure 8
% Hub neurons


figure


bar(Results.Degree)


xlabel('Neuron')

ylabel('Connections')


title('Network Hub Structure')


exportgraphics(gcf,...
fullfile(outFolder,...
[fileName '_Fig8_Hubs.png']),...
'Resolution',600)

%% Figure 9
% Statistical Significance 
figure

imagesc(Results.SignificantConnectivity)

axis square

colorbar

title('Significant Functional Connections')

exportgraphics(gcf,...
fullfile(outFolder,...
[fileName '_SignificantNetwork.png']),...
'Resolution',600)

%% Figure 10
% Time-tailed synchrony plot


figure('Position',[100 100 700 400])


plot(Results.TimeTailedTimeSeconds,...
     Results.TimeTailedSynchrony,...
     'LineWidth',2)



xlabel('Time (seconds)')

ylabel('Synchrony')


legend(...
    {'5 sec','10 sec','30 sec'},...
    'Location','best')


title('Time-Tailed Network Synchrony')


box off



exportgraphics(gcf,...
fullfile(outFolder,...
[fileName '_TimeTailedSynchrony.png']),...
'Resolution',600)

%% Calcium-event STTC matrix


figure('Position',[100 100 600 500])


imagesc(Results.STTCMatrix)


axis square


colorbar


title('Calcium-event STTC')


xlabel('Neuron')

ylabel('Neuron')


exportgraphics(gcf,...
fullfile(outFolder,...
[fileName '_Calcium_STTC.png']),...
'Resolution',600)

%% local v global
figure('Position',[100 100 700 450])

values = [ ...
    Results.GlobalPearson Results.LocalPearson; ...
    Results.GlobalSTTC Results.LocalSTTC; ...
    Results.GlobalTimeTailed Results.LocalTimeTailed];

bar(values)

xticklabels({'Pearson','STTC','Time-tailed'})

ylabel('Synchrony')

legend({'Global','Local'},'Location','northwest')

box off

exportgraphics(gcf,...
fullfile(outFolder,...
[fileName '_Local_vs_Global.png']),...
'Resolution',600)

disp("Figures complete")


end