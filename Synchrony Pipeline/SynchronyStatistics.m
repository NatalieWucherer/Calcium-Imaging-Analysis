function Results = SynchronyStatistics(Results,F)

% ---------------------------------------------------------
% Statistical validation of functional connectivity
%
% Methods:
%
% 1. Phase randomization surrogate testing
% 2. FDR correction
%
% Output:
%
% Significant connectivity matrix
% Null distribution
% p-values
%
% ---------------------------------------------------------


%% Parameters

numSurrogates = 1000;

alpha = 0.05;



%% Original correlation matrix

R = Results.Pearson;

N=size(F,1);



%% Extract upper triangle

upperMask = triu(true(N),1);

realCorr = R(upperMask);



%% Surrogate correlations

surrogateCorr=zeros(sum(upperMask(:)),numSurrogates);



disp('Running surrogate testing...')



for s=1:numSurrogates


    Fs=zeros(size(F));


    for neuron=1:N


        % Fourier phase randomization
        
        signal=F(neuron,:);


        fftSignal=fft(signal);


        phase=angle(fftSignal);


        magnitude=abs(fftSignal);



        randomPhase=phase;

        
        randomPhase(2:end-1)=...
            2*pi*rand(length(phase)-2,1)';



        randomizedFFT=...
            magnitude .* exp(1i*randomPhase);



        Fs(neuron,:)=real(ifft(randomizedFFT));


    end



    Rs=corrcoef(Fs');


    Rs(1:N+1:end)=NaN;



    surrogateCorr(:,s)=Rs(upperMask);



end



%% Calculate p values


pValues=zeros(length(realCorr),1);



for i=1:length(realCorr)


    null=squeeze(surrogateCorr(i,:));


    pValues(i)=...
        mean(abs(null)>=abs(realCorr(i)));


end



%% FDR correction

[h,~,adjP]=fdr_bh(pValues,alpha);



%% Rebuild matrices


SignificantMatrix=zeros(N);


PMatrix=zeros(N);


SignificantMatrix(upperMask)=h;

SignificantMatrix=...
    SignificantMatrix + SignificantMatrix';



PMatrix(upperMask)=adjP;

PMatrix=PMatrix+PMatrix';



%% Save


Results.SurrogateCorrelation = surrogateCorr;

Results.PValues=PMatrix;

Results.SignificantConnectivity=SignificantMatrix;



Results.SignificanceThreshold=alpha;


disp('Statistics complete')


end