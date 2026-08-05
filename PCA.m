% TANC2 Calcium Imaging PCA Analysis
%
% Video-level PCA of calcium/network phenotype
%
% Rows = videos
% Features = calcium activity/network metrics

clear
clc
close all


%%  LOAD DATA 

data = readtable('C:\Ca Prep Done\PCA Work Book.xlsx',...
    'VariableNamingRule','preserve');


%%  CONVERT VARIABLES 

% Ensure categorical variables

data.Replicate = categorical(data.Replicate);
data.Line = categorical(data.Line);
data.Coverslip = categorical(data.Coverslip);
data.Video = categorical(data.Video);
data.Age = categorical(data.Age);
data.Condition = categorical(data.Condition);



%%  BASELINE ONLY 

% Remove drug conditions

pcaData = data(data.Condition == 'B',:);


fprintf('Number of videos included: %d\n',height(pcaData))



%%  DEFINE PCA FEATURES 

features = {
    'Average AUC'
    'Average Dtime'
    'Average Freq'
    'Average AMP'
    'Global Pearson'
    'Local Pearson'
    'Global STTC'
    'Local STTC'
    'Network Density'
    'Mean Degree'
    'Mean Clustering'
    'Number Of Bursts'
};


%% Extract feature matrix

X = pcaData{:,features};



%%  REMOVE MISSING DATA 

validRows = all(~isnan(X),2);


X = X(validRows,:);

pcaData = pcaData(validRows,:);



fprintf('Videos after removing missing values: %d\n',...
    height(pcaData))



%% STANDARDISE DATA 
% Mean = 0
% SD = 1

Xz = zscore(X);



%% RUN PCA 


[coeff,score,latent,~,explained] = pca(Xz);



%% DISPLAY RESULTS 

disp('Variance explained (%)')

disp(explained(1:10))


disp('Feature loadings PC1 and PC2')

loadingTable = table(...
    features,...
    coeff(:,1),...
    coeff(:,2),...
    coeff(:,3),...
    'VariableNames',...
    {'Feature','PC1_loading','PC2_loading','PC3_loading'});


disp(loadingTable)


disp(loadingTable)


% FIGURE 1: PCA SCORE PLOT (Colour = genotype, Marker = age)


figure

scatter3(score(pcaData.Line=="C",1),...
         score(pcaData.Line=="C",2),...
         score(pcaData.Line=="C",3),...
         100,'filled')

hold on

scatter3(score(pcaData.Line=="T",1),...
         score(pcaData.Line=="T",2),...
         score(pcaData.Line=="T",3),...
         100,'filled')


xlabel('PC1')
ylabel('PC2')
zlabel('PC3')

legend('Control','TANC2')

grid on
view(45,25)


xlabel(sprintf('PC1 (%.1f%% variance)',explained(1)))

ylabel(sprintf('PC2 (%.1f%% variance)',explained(2)))

title('PCA of Calcium Imaging Network Phenotype')

legend('Location','bestoutside')

grid on


% FIGURE 2: PCA LOADING PLOT


figure


bar(coeff(:,1:2))


xticks(1:length(features))

xticklabels(features)

xtickangle(45)


ylabel('Loading')


legend({'PC1','PC2'},...
    'Location','best')


title('Feature Contributions to PCA')


grid on

% FIGURE 3: SCREE PLOT


figure


pareto(explained)


xlabel('Principal Component')


ylabel('Variance Explained (%)')


title('PCA Variance Explained')

% FIGURE 4: PC1 DISTRIBUTION BY GENOTYPE

figure


boxchart(pcaData.Line,...
    score(:,1))


ylabel('PC1 score')


xlabel('Genotype')


title('PC1 Separation Between Genotypes')


grid on

% SAVE RESULTS


PCA_scores = pcaData;

PCA_scores.PC1 = score(:,1);
PCA_scores.PC2 = score(:,2);
PCA_scores.PC3 = score(:,3);


writetable(PCA_scores,...
    'TANC2_PCA_scores.xlsx')



writetable(loadingTable,...
    'TANC2_PCA_loadings.xlsx')


% FIGURE: 3D PCA SCORE PLOT, PC1 vs PC2 vs PC3

figure
hold on


lines = categories(pcaData.Line);
ages = categories(pcaData.Age);

markers = {'o','^','s','d','+'};


for i = 1:length(lines)

    for j = 1:length(ages)

        idx = pcaData.Line == lines{i} & ...
              pcaData.Age == ages{j};


        scatter3(...
            score(idx,1),...
            score(idx,2),...
            score(idx,3),...
            80,...
            'filled',...
            'Marker',...
            markers{mod(j-1,length(markers))+1},...
            'DisplayName',...
            [char(lines{i}) ' Age ' char(ages{j})]);

    end

end


xlabel(sprintf('PC1 (%.1f%%)',explained(1)))

ylabel(sprintf('PC2 (%.1f%%)',explained(2)))

zlabel(sprintf('PC3 (%.1f%%)',explained(3)))


title('3D PCA of Calcium Imaging Phenotype')


grid on

view(45,25)

legend('Location','bestoutside')

rotate3d on

figure
hold on

idxC = pcaData.Line=="C";
idxT = pcaData.Line=="T";

scatter3(score(idxC,1),score(idxC,2),score(idxC,3),...
    100,'filled')

scatter3(score(idxT,1),score(idxT,2),score(idxT,3),...
    100,'filled')


xlabel('PC1: Network synchrony')
ylabel('PC2: Activity')
zlabel('PC3: Kinetics')

legend('Control','TANC2')

grid on
view(45,25)
rotate3d on

disp('PCA analysis complete')
