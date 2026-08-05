function Results = SpatialSynchrony(Results,coords)

if isempty(coords)

    Results.SpatialSynchrony=[];

    return

end

R=Results.Pearson;

N=size(R,1);

K=min(10,N-1);

D=pdist2(coords,coords);

Spatial=zeros(N,1);

for n=1:N

    [~,idx]=sort(D(n,:));

    neighbours=idx(2:K+1);

    Spatial(n)=mean(R(n,neighbours),'omitnan');

end

Results.SpatialSynchrony=Spatial;

Results.MeanSpatialSynchrony=mean(Spatial);

end