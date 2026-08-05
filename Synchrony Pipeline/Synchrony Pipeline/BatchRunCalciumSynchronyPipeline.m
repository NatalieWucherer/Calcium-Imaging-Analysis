function BatchRunCalciumSynchronyPipeline()

% ==========================================================
% BatchRunCalciumSynchronyPipeline
%
% Selects a folder containing exStruct .mat files and runs
% CalciumNetworkPipelineMainScript on every file.
%
% Results are saved into:
%
%   SelectedFolder/Synchrony_Results/
%
% ==========================================================


clc

disp('===============================================')
disp(' Batch Calcium Synchrony Pipeline')
disp('===============================================')


%% Select folder

inputFolder = uigetdir(pwd,...
    'Select folder containing MAT files');

if inputFolder == 0
    disp('No folder selected')
    return
end


%% Find MAT files

files = dir(fullfile(inputFolder,'*.mat'));


if isempty(files)

    error('No MAT files found in selected folder')

end


fprintf('\nFound %d MAT files\n\n',length(files))


%% Create output folder

outputFolder = fullfile(inputFolder,...
    'Synchrony_Results');


if ~exist(outputFolder,'dir')
    mkdir(outputFolder)
end



%% Run each file

for i = 1:length(files)


    filePath = fullfile(inputFolder,...
        files(i).name);


    fprintf('\n---------------------------------\n')
    fprintf('Processing %d/%d\n',i,length(files))
    fprintf('%s\n',files(i).name)
    fprintf('---------------------------------\n')


    try


        %% Check file contains exStruct

        vars = whos('-file',filePath);


        names = {vars.name};


        if ~ismember('exStruct',names)

            warning('%s does not contain exStruct. Skipping.',...
                files(i).name)

            continue

        end



        %% Run pipeline

        Results = CalciumNetworkPipelineMainScript(filePath);



        %% Save MATLAB results

        [~,name,~] = fileparts(files(i).name);


        save(fullfile(outputFolder,...
            [name '_Results.mat']),...
            'Results',...
            '-v7.3');


        fprintf('Completed: %s\n',name)



    catch ME


        fprintf('\nFAILED: %s\n',...
            files(i).name)

        fprintf('%s\n',...
            ME.message)


        % save error log

        errorFile = fullfile(outputFolder,...
            'Batch_Error_Log.txt');


        fid = fopen(errorFile,'a');


        fprintf(fid,...
            '\n\nFile: %s\n',...
            files(i).name);


        fprintf(fid,...
            '%s\n',...
            ME.getReport());


        fclose(fid);


    end


end


disp(' ')
disp('===============================================')
disp(' Batch processing complete')
disp(['Results saved in: ' outputFolder])
disp('===============================================')


end