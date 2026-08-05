function X = CrossCorrelationSynchrony(F)

N=size(F,1);

lag=20;

X=zeros(N);

for i=1:N

    for j=i:N

        c=xcorr(F(i,:),F(j,:),lag,'coeff');

        X(i,j)=c(lag+1);

        X(j,i)=X(i,j);

    end

end

end