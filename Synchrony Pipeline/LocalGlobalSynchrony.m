function Results = LocalGlobalSynchrony(Results,coords)

% ==========================================================
% Local vs Global Synchrony
%
% Calculates:
%   - Pearson
%   - STTC
%   - Time-tailed
%
% using the same spatial neighbours.
% ==========================================================

K = min(10,size(coords,1)-1);

distMat = pdist2(coords,coords);

%% -------- Pearson --------

R = Results.Pearson;

R(1:size(R,1)+1:end)=NaN;

Results.GlobalPearson = mean(R(:),'omitnan');

localPearson=zeros(size(R,1),1);

for i=1:size(R,1)

    [~,idx]=sort(distMat(i,:));

    neighbours=idx(2:K+1);

    localPearson(i)=mean(R(i,neighbours),'omitnan');

end

Results.LocalPearsonNeuron=localPearson;
Results.LocalPearson=mean(localPearson,'omitnan');
Results.PearsonLocalGlobalRatio=...
    Results.LocalPearson/Results.GlobalPearson;

%% -------- STTC --------

if isfield(Results,'STTCMatrix')

    S=Results.STTCMatrix;

    S(1:size(S,1)+1:end)=NaN;

    Results.GlobalSTTC=mean(S(:),'omitnan');

    localSTTC=zeros(size(S,1),1);

    for i=1:size(S,1)

        [~,idx]=sort(distMat(i,:));

        neighbours=idx(2:K+1);

        localSTTC(i)=mean(S(i,neighbours),'omitnan');

    end

    Results.LocalSTTCNeuron=localSTTC;

    Results.LocalSTTC=mean(localSTTC,'omitnan');

    Results.STTCLocalGlobalRatio=...
        Results.LocalSTTC/Results.GlobalSTTC;

end

%% -------- Time-tailed --------

if isfield(Results,'TimeTailedMatrix')

    TT=Results.TimeTailedMatrix;

    numFrames=size(TT,3);

    localTT=zeros(numFrames,1);

    globalTT=zeros(numFrames,1);

    for t=1:numFrames

        M=TT(:,:,t);

        M(1:size(M,1)+1:end)=NaN;

        globalTT(t)=mean(M(:),'omitnan');

        neuronLocal=zeros(size(M,1),1);

        for i=1:size(M,1)

            [~,idx]=sort(distMat(i,:));

            neighbours=idx(2:K+1);

            neuronLocal(i)=mean(M(i,neighbours),'omitnan');

        end

        localTT(t)=mean(neuronLocal,'omitnan');

    end

    Results.GlobalTimeTailed=mean(globalTT,'omitnan');

    Results.LocalTimeTailed=mean(localTT,'omitnan');

    Results.TimeTailedLocalGlobalRatio=...
        Results.LocalTimeTailed/Results.GlobalTimeTailed;

end

disp('Local vs Global synchrony complete')

end