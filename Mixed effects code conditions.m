% Condition mixed models
%% LOAD DATA

my_data = readtable('C:\Ca Prep Done\Decay Time mixed effects model.xlsx');

my_data.Properties.VariableNames = ...
{'Replicate','Line','DIV','Condition','Coverslip','Video','DT'};


%% CONVERT VARIABLES
my_data.Replicate = categorical(my_data.Replicate);
my_data.Line = categorical(my_data.Line);
my_data.DIV = categorical(my_data.DIV);
my_data.Condition = categorical(my_data.Condition);
my_data.Coverslip = categorical(my_data.Coverslip);
my_data.Video = categorical(my_data.Video);
my_data.DT = double(my_data.DT);

cats = {'B','ACSF','APV','Carbenoxolone','M','NBQX'};
my_data.Condition = reordercats(my_data.Condition,cats);

%% MODEL 1: NO Video

lme1 = fitlme(my_data,...
    'DT ~ Line*Condition + (1|Replicate) + (1|Coverslip) + (1|Coverslip:Video)');


%% MODEL 2: Video
lme_Baseline = fitlme(my_data,...
    'DT ~ Line*Condition + DIV + (1|Replicate) + (1|Coverslip) + (1|Coverslip:Video)');

compare(lme1,lme_Baseline)
%% DISPLAY MAIN MODEL

disp('Video Conditions')

disp(lme_Baseline)


disp('--- FIXED EFFECTS ---')
disp(lme_Baseline.Coefficients)


disp('--- ANOVA ---')
disp(anova(lme_Baseline,'DFMethod','Satterthwaite'))


disp('--- MODEL FIT ---')
disp(lme_Baseline.ModelCriterion)


disp('--- RANDOM EFFECTS ---')
disp(lme_Baseline.covarianceParameters)



%% COMPARE MODELS

disp('MODEL COMPARISON')

compare(lme1,lme_Baseline)



%% RESIDUAL DIAGNOSTICS

figure
plotResiduals(lme_Baseline,'fitted')
title('Residuals vs Fitted')


figure
plotResiduals(lme_Baseline,'probability')
title('Normal Q-Q Plot')


%% EXPORT CONDITION EMMs FOR PRISM

% Conditions you want plotted
plotConditions = {'B','APV','NBQX','M'};

% Lines
plotLines = {'C','T'};


%% EXPORT SPECIFIC EMMs FOR PRISM

% Specify exactly the experimental groups that exist

EMM_Data = table();

EMM_Data.Line = categorical(...
    {'C';'C';'C';'C';...
     'T';'T';'T';'T'},...
     {'C','T'});

EMM_Data.Condition = categorical(...
    {'B';'NBQX';'APV';'M';...
     'B';'NBQX';'APV';'M'},...
     {'B','ACSF','APV','Carbenoxolone','M','NBQX'});

EMM_Data.DIV = categorical(...
    {'70';'70';'70';'70';...
     '80';'80';'80';'80'},...
     {'60','70','80','90'});


% Add random effect variables required by predict()
EMM_Data.Replicate = repmat(my_data.Replicate(1),height(EMM_Data),1);
EMM_Data.Coverslip = repmat(my_data.Coverslip(1),height(EMM_Data),1);
EMM_Data.Video = repmat(my_data.Video(1),height(EMM_Data),1);


% Generate estimated marginal means
[Predicted,CI] = predict(lme_Baseline,...
    EMM_Data,...
    'Conditional',false);


% Store results
EMM_Data.Mean = Predicted;
EMM_Data.CI_low = CI(:,1);
EMM_Data.CI_high = CI(:,2);


% Keep only useful columns
EMM_Output = EMM_Data(:,...
    {'Line','Condition','DIV','Mean','CI_low','CI_high'});


disp(EMM_Output)


writetable(EMM_Output,...
'DT_EMMs_Prism_condition.xlsx');

%% CUSTOM CONDITION CONTRASTS

disp('CUSTOM CONDITION CONTRASTS')


coefNames = lme_Baseline.CoefficientNames;

beta = lme_Baseline.Coefficients.Estimate;

covBeta = lme_Baseline.CoefficientCovariance;


makeH = @(terms) double(ismember(coefNames,terms));



%% DEFINE CONTRASTS

contrasts = {

'C vs T at B',...
{'Line_T'};


'C vs T at ACSF',...
{'Line_T','Line_T:Condition_ACSF'};


'C vs T at APV',...
{'Line_T','Line_T:Condition_APV'};


'C vs T at MUSCIMOL',...
{'Line_T','Line_T:Condition_M'};


'C vs T at NBQX',...
{'Line_T','Line_T:Condition_NBQX'};



'C(B) vs T(APV)',...
{'Line_T','Condition_APV','Line_T:Condition_APV'};


'C(B) vs T(M)',...
{'Line_T','Condition_M','Line_T:Condition_M'};


'C(B) vs T(NBQX)',...
{'Line_T','Condition_NBQX','Line_T:Condition_NBQX'};



'C(B) vs C(ACSF)',...
{'Condition_ACSF'};


'T(B) vs T(ACSF)',...
{'Condition_ACSF','Line_T:Condition_ACSF'};



'C(B) vs C(APV)',...
{'Condition_APV'};


'T(B) vs T(APV)',...
{'Condition_APV','Line_T:Condition_APV'};



'C(B) vs C(NBQX)',...
{'Condition_NBQX'};


'T(B) vs T(NBQX)',...
{'Condition_NBQX','Line_T:Condition_NBQX'};



'C(B) vs C(M)',...
{'Condition_M'};


'T(B) vs T(M)',...
{'Condition_M','Line_T:Condition_M'};

};



%% RUN CONTRASTS

results = table();

pValues = [];


for i = 1:size(contrasts,1)


    name = contrasts{i,1};

    terms = contrasts{i,2};


    H = makeH(terms);


    % Estimate
    est = H*beta;


    % Standard error
    SE = sqrt(H*covBeta*H');


    % Confidence interval
    df = lme_Baseline.DFE;

    tcrit = tinv(0.975,df);

    CI_low = est - tcrit*SE;

    CI_high = est + tcrit*SE;


    % Statistical test
    [p,F] = coefTest(lme_Baseline,H);


    % Store
    results.Name(i)=string(name);

    results.Difference(i)=est;

    results.CI_low(i)=CI_low;

    results.CI_high(i)=CI_high;

    results.F(i)=F;

    results.p_uncorrected(i)=p;


    pValues(i)=p;


end



%% HOLM-BONFERRONI CORRECTION

[pSorted,sortIndex] = sort(pValues);

m = length(pValues);

holm = zeros(size(pValues));


for i = 1:m

    holm(sortIndex(i)) = min((m-i+1)*pSorted(i),1);

end


results.p_Holm = holm';



%% DISPLAY

disp(results)