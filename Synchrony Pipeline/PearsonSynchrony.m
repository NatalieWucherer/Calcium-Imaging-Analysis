function Results = PearsonSynchrony(F)

N=size(F,1);

R=corrcoef(F');

R(1:N+1:end)=NaN;

Results.Pearson=R;

Results.GlobalSynchrony=mean(R,'all','omitnan');

Results.NeuronSynchrony=mean(R,2,'omitnan');

end