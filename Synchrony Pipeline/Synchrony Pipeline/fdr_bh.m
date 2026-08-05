function [h,crit_p,adj_p]=fdr_bh(pvals,q)

% Benjamini-Hochberg FDR correction


p=pvals(:);

m=length(p);


[sortedP,idx]=sort(p);


threshold=(1:m)'/m*q;


w=find(sortedP<=threshold);


if isempty(w)

    crit_p=0;

else

    crit_p=sortedP(max(w));

end



h=p<=crit_p;



% adjusted p-values

adj=zeros(m,1);


for i=1:m

    adj(i)=min(sortedP(i)*m/i,1);

end



adj_p=zeros(m,1);

adj_p(idx)=adj;


end