%% LOAD DATA

my_data = readtable('C:\Ca Prep Done\Freq mixed effects model.xlsx');

my_data.Properties.VariableNames = ...
{'Replicate','Line','DIV','Condition','Coverslip','Video','Freq'};


%% CONVERT VARIABLES
my_data.Replicate = categorical(my_data.Replicate);
my_data.Line = categorical(my_data.Line);
my_data.DIV = categorical(my_data.DIV);
my_data.Condition = categorical(my_data.Condition);
my_data.Coverslip = categorical(my_data.Coverslip);
my_data.Video = categorical(my_data.Video);
my_data.Freq = double(my_data.Freq);


%% BASELINE DATA ONLY

baselineData = my_data(my_data.Condition == 'B', :);

%% CALCULATE COVERSLIP MEANS

coverslipMeans = groupsummary( ...
    my_data,...
    {'Replicate','Line','Condition','DIV','Coverslip'},...
    'mean','Freq');

coverslipMeans.Properties.VariableNames{'mean_Freq'} = 'Freq';
writetable(coverslipMeans,...
    'Freq_CoverslipMeans.csv');

%% MODEL 1: NO INTERACTION

lme1 = fitlme(baselineData,...
    'Freq ~ Line*DIV + (1|Replicate) + (1|Coverslip)');


%% MODEL 2: LINE x DIV INTERACTION

lme_Baseline = fitlme(baselineData,...
    'Freq ~ Line*DIV + (1|Replicate) + (1|Coverslip) + (1|Coverslip:Video)');

compare(lme1,lme_Baseline)
%% DISPLAY MAIN MODEL

disp('BASELINE LINE x DIV MODEL')

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



%% CONTRASTS: CONTROL VS T AT EACH DIV

disp('T vs CONTROL CONTRASTS')


coefNames = lme_Baseline.CoefficientNames;

beta = lme_Baseline.Coefficients.Estimate;

covBeta = lme_Baseline.CoefficientCovariance;


makeH = @(terms) double(ismember(coefNames,terms));


DIVs = {'60','70','80','90'};


for i = 1:length(DIVs)

    div = DIVs{i};


    % Reference DIV is DIV60
    if strcmp(div,'60')

        H = makeH({'Line_T'});

    else

        H = makeH({'Line_T',...
            ['Line_T:DIV_' div]});

    end


    % Estimate of difference
    estimate = H * beta;


    % Standard error
    SE = sqrt(H * covBeta * H');


    % Degrees of freedom
    df = lme_Baseline.DFE;


    % 95% CI
    tcrit = tinv(0.975,df);

    CI_low = estimate - tcrit*SE;

    CI_high = estimate + tcrit*SE;


    % Statistical test
    [p,F] = coefTest(lme_Baseline,H);



    fprintf('\n============================\n')
    fprintf('T vs Control DIV %s\n',div)

    fprintf('Difference = %.4f \n',estimate)

    fprintf('95%% CI = [%.4f , %.4f]\n',...
        CI_low,CI_high)

    fprintf('F = %.4f\n',F)

    fprintf('p = %.4g\n',p)

end
