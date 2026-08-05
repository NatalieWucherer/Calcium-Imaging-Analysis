function Results = GraphTheoryAnalysis(Results)

% =========================================================
% Graph theory analysis of functional connectivity network
%
% Uses statistically significant synchrony edges
%
% Compatible with MATLAB R2025b
%
% =========================================================


%% Check connectivity matrix

if isfield(Results,'SignificantConnectivity')

    A = Results.SignificantConnectivity;

else

    error('No significant connectivity matrix found')

end



%% Remove self connections

A(1:size(A,1)+1:end)=0;


% Ensure binary matrix

A = double(A>0);

%% Store adjacency matrix

Results.AdjacencyMatrix = A;

%% Number of neurons

N=size(A,1);



%% Create graph

G = graph(A);


% Degree

Results.Degree = degree(G);


% Network density

possibleEdges = N*(N-1)/2;

actualEdges = numedges(G);


Results.NetworkDensity = ...
    actualEdges/possibleEdges;


% Clustering coefficient

clustering=zeros(N,1);


for i=1:N


    neighbors=find(A(i,:));


    k=length(neighbors);


    if k>1


        neighborConnections = ...
            sum(sum(A(neighbors,neighbors)));


        clustering(i)=...
            neighborConnections/(k*(k-1));


    else

        clustering(i)=0;

    end


end



Results.ClusteringCoefficient=clustering;

% Efficiency

try


    D = distances(G);


    D(D==0)=NaN;


    Results.GlobalEfficiency = ...
        mean(1./D,'all','omitnan');


catch


    Results.GlobalEfficiency = NaN;


end


% Betweenness centrality

try

    % convert to directed graph for centrality

    DG = digraph(A);


    Results.Betweenness = ...
        centrality(DG,'betweenness');


catch


    Results.Betweenness = NaN(N,1);


end



%% -----------------------------
% Modularity (optional)
% ------------------------------

Results.Modularity = NaN;



disp('Graph theory complete')


end