function Results = CalciumEventSTTC(Results,F)

% =========================================================
% Calcium-event Spike Time Tiling Coefficient (STTC)
%
% Adapted STTC for calcium imaging.
%
% Uses detected calcium events rather than electrophysiological
% spikes.
%
% Frame-based coincidence window.
%
% Designed for:
%   2 Hz calcium imaging
%   500 ms/frame
%
%
% INPUT:
%
% F:
% neurons x frames dF/F matrix
%
%
% OUTPUT:
%
% Results.STTCMatrix
% Results.STTCEvents
% Results.STTCWindowFrames
%
% =========================================================


%% Parameters

[numNeurons,numFrames]=size(F);


% Coincidence window

% 1 frame = 500 ms

deltaFrames = 1;


% Detect calcium events


events=false(numNeurons,numFrames);



for i=1:numNeurons


    trace=F(i,:);


    % baseline estimate

    baseline=median(trace);


    % noise estimate

    noise=mad(trace,1)*1.4826;



    % event threshold

    threshold=baseline+2*noise;



    events(i,:)=trace>threshold;



end



Results.STTCEvents=events;


% Calculate STTC matrix

STTC=zeros(numNeurons);



for i=1:numNeurons


    for j=i:numNeurons


        if i==j

            STTC(i,j)=1;

            continue

        end



        A=find(events(i,:));

        B=find(events(j,:));



        % If no events

        if isempty(A) || isempty(B)

            STTC(i,j)=0;
            STTC(j,i)=0;

            continue

        end



        %% P_A

        PA=sum(arrayfun(@(x)...
            any(abs(B-x)<=deltaFrames),A))...
            /length(A);



        %% P_B

        PB=sum(arrayfun(@(x)...
            any(abs(A-x)<=deltaFrames),B))...
            /length(B);



        %% T_A

        TA=tilingCoefficient(events(i,:),deltaFrames);



        %% T_B

        TB=tilingCoefficient(events(j,:),deltaFrames);



        %% STTC equation


        termA=(PA-TB)/(1-PA*TB);


        termB=(PB-TA)/(1-PB*TA);


        value=0.5*(termA+termB);



        STTC(i,j)=value;

        STTC(j,i)=value;


    end

end



%% Store

Results.STTCMatrix=STTC;

Results.STTCWindowFrames=deltaFrames;

Results.STTCWindowSeconds=deltaFrames/2;



disp('Calcium-event STTC complete')


end


% Helper function


function T=tilingCoefficient(eventTrace,deltaFrames)


frames=find(eventTrace);


if isempty(frames)

    T=0;

    return

end



covered=false(size(eventTrace));



for k=1:length(frames)


    start=max(1,frames(k)-deltaFrames);

    stop=min(length(eventTrace),frames(k)+deltaFrames);


    covered(start:stop)=true;


end



T=sum(covered)/length(eventTrace);



end