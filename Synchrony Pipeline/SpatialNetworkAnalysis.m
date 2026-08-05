function Results = SpatialNetworkAnalysis(Results,coords)


% ---------------------------------------------------------
% Spatial relationship between neurons and synchrony
% ---------------------------------------------------------


if isempty(coords)

    warning('No coordinates found')

    return

end



R=Results.Pearson;



N=size(R,1);



%% Distance matrix


D=pdist2(coords,coords);



Results.DistanceMatrix=D;



%% Remove diagonal


D(1:N+1:end)=NaN;



R(1:N+1:end)=NaN;



%% Distance vs correlation


distanceVector=D(:);

correlationVector=R(:);



valid=~isnan(distanceVector) & ...
      ~isnan(correlationVector);



Results.DistanceCorrelation=...
    corr(distanceVector(valid),...
         correlationVector(valid));



%% Spatial synchrony


K=min(10,N-1);


SpatialSync=zeros(N,1);



for i=1:N


    [~,idx]=sort(D(i,:));


    neighbours=idx(1:K);



    SpatialSync(i)=...
        mean(R(i,neighbours),...
        'omitnan');

end



Results.SpatialSynchrony=SpatialSync;



end