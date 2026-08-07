% Condition mixed models
%% LOAD DATA

my_data = readtable('C:\Ca Prep Done\Network Density mixed effects model.xlsx');

my_data.Properties.VariableNames = ...
{'Replicate','Line','DIV','Condition','Coverslip','Video','ND'};


%% CONVERT VARIABLES
my_data.Replicate = categorical(my_data.Replicate);
my_data.Line = categorical(my_data.Line);
my_data.DIV = categorical(my_data.DIV);
my_data.Condition = categorical(my_data.Condition);
my_data.Coverslip = categorical(my_data.Coverslip);
my_data.Video = categorical(my_data.Video);
my_data.ND = double(my_data.ND);

cats = {'B','ACSF','APV','Carbenoxolone','M','NBQX'};
my_data.Condition = reordercats(my_data.Condition,cats);

%% MODEL 1: NO Video

lme1 = fitlme(my_data,...
    'ND ~ Line*Condition + (1|Replicate) + (1|Coverslip) + (1|Coverslip:Video)');


%% MODEL 2: Video
lme_Baseline = fitlme(my_data,...
    'ND ~ Line*Condition + DIV + (1|Replicate) + (1|Coverslip) + (1|Coverslip:Video)');

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
{'Line_T','Line_T:Condition_MUSCIMOL'};


'C vs T at NBQX',...
{'Line_T','Line_T:Condition_NBQX'};



'C(B) vs T(APV)',...
{'Line_T','Condition_APV','Line_T:Condition_APV'};


'C(B) vs T(MUSCIMOL)',...
{'Line_T','Condition_MUSCIMOL','Line_T:Condition_MUSCIMOL'};


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



'C(B) vs C(MUSCIMOL)',...
{'Condition_MUSCIMOL'};


'T(B) vs T(MUSCIMOL)',...
{'Condition_MUSCIMOL','Line_T:Condition_MUSCIMOL'};

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