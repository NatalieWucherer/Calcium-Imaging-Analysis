function Results = LocalSynchrony(Results,F)

R=Results.Pearson;

N=size(R,1);

K=min(10,N-1);

Local=zeros(N,1);

for n=1:N

    [~,idx]=sort(R(n,:),'descend');

    neighbours=idx(2:K+1);

    Local(n)=mean(R(n,neighbours),'omitnan');

end

Results.LocalSynchrony=Local;

Results.MeanLocalSynchrony=mean(Local);

Results.LocalGlobalRatio=Results.MeanLocalSynchrony/Results.GlobalSynchrony;

end