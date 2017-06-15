% ColorMaterialModelCrossValidation
% Perform cross valiadation to establish the quality of the model.
%
% We want to be able to compare several instancies of our model using cross
% validation. The main goal is to figure out whether we're overfitting with
% our many parameters. Here we use the simulated demo data to learn more
% about diffferent models by examining the cross validation
%
% 03/17/2017 ar Wrote it.
% 04/30/2017 ar Clean up and comment.

% Initialize
clear; close all;

% Set directories and load the subject data
mainDir = '/Users/ana/Dropbox (Aguirre-Brainard Lab)/CNST_analysis/ColorMaterial/demoPlots';

% Load lookup tables.
nModelTypes = 3;
nConditions = 1;

% Try linear vs. non-linear data simulation.
LINEAR = 1;

% Set cross validation paramters
nFolds = 6;
cd('/Users/Shared/Matlab/Toolboxes/BrainardLabToolbox/ColorMaterialModel/DemoData')
if LINEAR
    load(['DemoData0.5W24Blocks1Lin.mat']); % data
else
    load(['DemoData0.5W24Blocks1NonLin.mat']); % data
end
nTrials = nBlocks*ones(size(dataSet{1}.responsesForOneBlock));
nTrials = nTrials(1);
params.whichMethod = 'lookup'; % could be also 'simulate' or 'analytic'
params.nSimulate = 1000; % for method 'simulate'
params.whichDistance = 'euclidean';

% Initial position spacing values to try.
params.trySpacingValues = [0.5 1 2];
params.maxPositionValue = 20;

params.tryWeightValues = [0.5 0.2 0.8];
params.addNoise = true;

% Partition data for cross validation.
c = cvpartition(nBlocks,'Kfold',nFolds);

for whichCondition = 1:nConditions
    for kk = 1:c.NumTestSets
        
        clear trainingIndex testIndex trainingData testData nTrainingTrials nTestTrials probabilitiesTestData
        
        % Get indices for kkth fold
        trainingIndex = c.training(kk);
        testIndex = c.test(kk);
        
        % Separate the training from test data
        trainingData = sum(dataSet{1}.responsesAcrossBlocks(:,trainingIndex),2);
        testData = sum(dataSet{1}.responsesAcrossBlocks(:,testIndex),2);
        nTrainingTrials = c.TrainSize(kk)*ones(size(trainingData));
        nTestTrials = c.TestSize(kk)*ones(size(testData));
        probabilitiesTestData = testData./nTestTrials;
        
        
        
        for whichModelType = 1:nModelTypes
            if whichModelType == 1
                params.whichWeight = 'weightVary';
                params.whichPositions = 'smoothSpacing';
                params.smoothOrder = 1;
                params.tryColorSpacingValues = params.trySpacingValues;
                params.tryMaterialSpacingValues = params.trySpacingValues;
                params.tryWeightValues = params.tryWeightValues;
            elseif whichModelType == 2
                params.whichWeight = 'weightVary';
                params.whichPositions = 'smoothSpacing';
                params.smoothOrder = 3;
                params.tryColorSpacingValues = [params.trySpacingValues linearSolutionColorSlope];
                params.tryMaterialSpacingValues = [params.trySpacingValues linearSolutionMaterialSlope];
                params.tryWeightValues = [params.tryWeightValues linearSolutionWeight];
            elseif whichModelType == 3
                params.whichWeight = 'weightVary';
                params.whichPositions = 'full';
                params.tryColorSpacingValues = [params.trySpacingValues linearSolutionColorSlope];
                params.tryMaterialSpacingValues = [params.trySpacingValues linearSolutionMaterialSlope];
                params.tryWeightValues = [params.tryWeightValues linearSolutionWeight];
            end
            
            % Get the predictions from the model for current parameters
            [thisSubject.condition{whichCondition}.crossVal(whichModelType).returnedParamsTraining(kk,:), ...
                thisSubject.condition{whichCondition}.crossVal(whichModelType).logLikelyFitTraining(kk), ...
                thisSubject.condition{whichCondition}.crossVal(whichModelType).predictedProbabilitiesBasedOnSolutionTraining(kk,:)] = ...
                FitColorMaterialModelMLDS(pairColorMatchColorCoords, pairMaterialMatchColorCoords,...
                pairColorMatchMaterialCoords, pairMaterialMatchMaterialCoords,...
                trainingData, nTrainingTrials,params, ...
                'whichPositions',params.whichPositions,'whichWeight',params.whichWeight, ...
                'tryWeightValues',params.tryWeightValues,'tryColorSpacingValues',params.tryColorSpacingValues,'tryMaterialSpacingValues',params.tryMaterialSpacingValues, ...
                'maxPositionValue', params.maxPositionValue);
            
            % For linear model, grab solution to use as a start when we search for
            % the cubic and full solutions.
            %
            % ANA TO CHECK WHICH IS MATERIAL SLOPE AND WHICH ONE IS THE
            % COLOR SLOPE.
            if (whichModelType == 1)
                linearSolutionParameters = thisSubject.condition{whichCondition}.crossVal(whichModelType).returnedParamsTraining(kk,:);
                linearSolutionMaterialSlope = linearSolutionParameters(1);
                linearSolutionColorSlope = linearSolutionParameters(2);
                linearSolutionWeight = linearSolutionParameters(3);
            end
            
            % Now use these parameters to predict the responses for the test data.
            [negLogLikely,predictedResponses] = FitColorMaterialModelMLDSFun(thisSubject.condition{whichCondition}.crossVal(whichModelType).returnedParamsTraining(kk,:),...
                pairColorMatchColorCoords,pairMaterialMatchColorCoords,...
                pairColorMatchMaterialCoords,pairMaterialMatchMaterialCoords,...
                testData, nTestTrials, params);
            
            thisSubject.condition{whichCondition}.crossVal(whichModelType).LogLikelyhood(kk) = -negLogLikely;
            thisSubject.condition{whichCondition}.crossVal(whichModelType).predictedProbabilities(kk,:) = predictedResponses;
            
            %  Compute RMSE, in case we want to look at them at some point in the future)
            thisSubject.condition{whichCondition}.crossVal(whichModelType).RMSError(kk) = ...
                ComputeRealRMSE(predictedResponses, probabilitiesTestData);
            clear negLogLikely predictedResponses
        end
    end
    
    % Compute mean error for both log likelihood and rmse.
    thisSubject.condition{whichCondition}.crossVal(whichModelType).meanRMSError = ...
        ;
    thisSubject.condition{whichCondition}.crossVal(whichModelType).meanLogLikelihood = ...
        mean(thisSubject.condition{whichCondition}.crossVal(whichModelType).LogLikelyhood);
    
    % Save in the right folder.
    cd(figAndDataDir);
    save([subjectList{s} conditionCode{whichCondition} params.whichWeight '-' num2str(nFolds) 'Folds'],  'thisSubject');
end
cd(mainDir);
if LINEAR
    save(['demoCrossVal' num2str(nFolds) 'NonLinFolds' date],  'thisSubject');
else
    save(['demoCrossVal' num2str(nFolds) 'LinFolds' date],  'thisSubject');
end

%% Print outputs
for i = 1:nModelTypes
    k(i) = mean(thisSubject.condition{whichCondition}.crossVal(whichModelType).meanLogLikelihood);
end
fprintf('meanLogLikely: Linear %.4f, Cubic %.4f, Full %.4f.\n', k(1), k(2),k(3)); 

for i = 1:nModelTypes
    k(i) = mean(thisSubject.condition{whichCondition}.crossVal(whichModelType).RMSError);
end
fprintf('meanRMSE: Linear %.4f, Cubic %.4f, Full %.4f.\n', k(1), k(2),k(3));

[H,P,CI,STATS] = ttest(thisSubject.condition{1}.crossVal(1).LogLikelyhood, thisSubject.condition{1}.crossVal(2).LogLikelyhood); 
fprintf('Linear Vs Cubic LogLikely: t(%d) = %.2f, p = %.4f, \n', STATS.df, STATS.tstat, P); 

[H,P,CI,STATS] = ttest(thisSubject.condition{1}.crossVal(2).LogLikelyhood, thisSubject.condition{1}.crossVal(3).LogLikelyhood); 
fprintf('Cubic Vs Full LogLikely: t(%d) = %.2f, p = %.4f, \n', STATS.df, STATS.tstat, P); 

[H,P,CI,STATS] = ttest(thisSubject.condition{1}.crossVal(1).LogLikelyhood, thisSubject.condition{1}.crossVal(3).LogLikelyhood); 
fprintf('Linear Vs Full LogLikely: t(%d) = %.2f, p = %.4f, \n', STATS.df, STATS.tstat, P); 

[H,P,CI,STATS] = ttest(thisSubject.condition{1}.crossVal(1).RMSError, thisSubject.condition{1}.crossVal(2).RMSError); 
fprintf('Linear Vs Cubic RMSE: t(%d) = %.2f, p = %.4f, \n', STATS.df, STATS.tstat, P); 

[H,P,CI,STATS] = ttest(thisSubject.condition{1}.crossVal(2).RMSError, thisSubject.condition{1}.crossVal(3).RMSError); 
fprintf('Cubic Vs Full RMSE: t(%d) = %.2f, p = %.4f, \n', STATS.df, STATS.tstat, P); 

[H,P,CI,STATS] = ttest(thisSubject.condition{1}.crossVal(1).RMSError, thisSubject.condition{1}.crossVal(3).RMSError); 
fprintf('Linear Vs Full RMSE: t(%d) = %.2f, p = %.4f, \n', STATS.df, STATS.tstat, P); 