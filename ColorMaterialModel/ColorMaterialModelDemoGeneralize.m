% ColorMaterialModelDemoGeneralize
%
% Demonstrates color material MLDS model fitting procedure for a data set.
% Initially used as a test bed for testing and improving search algorithm.
%
% The work is done by other routines in this folder.
%
% Requires optimization toolbox.
%
% 11/18/16  ar  Wrote from color selection model version

%% Initialize and parameter set
clear; close all;
currentDir = pwd; 
figDir = ['/Users/radonjic/Dropbox (Aguirre-Brainard Lab)/CNST_analysis/ColorMaterial/demoPlots'];
% Simulate up some data, or read in data.  DEMO == true means simulate.
DEMO = true;

lookupMethod = 'linear';
% Load lookup table
switch lookupMethod
    case  'linear'
        load colorMaterialInterpolateFunctionLinear.mat
        colorMaterialInterpolatorFunction = colorMaterialInterpolatorFunctionLinear;
    case 'cubic'
        load colorMaterialInterpolateFunctionCubic.mat
        colorMaterialInterpolatorFunction = colorMaterialInterpolatorFunctionCubic;
end
%% Load structure giving experiment design parameters. 
%
% Here we use the example structure that mathes the experimental design of
% our initial experiments. 
load('ColorMaterialExampleStructure.mat')

% After iniatial parameters are imported we need to specify the following info 
% and add it to the params structure
%
% Initial material and color positions.  If we don't at some point muck
% with the example structure, these go from -3 to 3 in steps of 1 for a
% total of 7 stimuli arrayed along each dimension.
params.materialMatchColorCoords  =  params.competitorsRangeNegative(1):1:params.competitorsRangePositive(end); 
params.colorMatchMaterialCoords  =  params.competitorsRangeNegative(1):1:params.competitorsRangePositive(end); 

% What sort of position fitting are we doing, and if smooth the order of the polynomial.
% Options:
%  'full' - Weights vary
%  'smoothSpacing' - Weights computed according to a polynomial fit.
params.whichPositions = 'full';
params.smoothOrder = 3;

% Initial position spacing values to try.
trySpacingValues =  [0.5 1 2];
params.trySpacingValues = trySpacingValues; 

% Does material/color weight vary in fit?
%  'weightVary' - yes, it does.
%  'weightFixed' - fix weight to specified value in tryWeightValues(1);
tryWeightValues = [0.5 0.2 0.8];
params.tryWeightValues = tryWeightValues; 

% Set figure directories
figDir = pwd; 
saveFig = 1; 
weibullplots = 0; 

%% We can use simulated data (DEMO == true) or some real data (DEMO == false)
if (DEMO)
    
    % Make the random number generator seed start at the same place each
    % time we do this.
    rng('default');
    
    % Make a stimulus list and set underlying parameters.
    targetMaterialCoord = 0;
    targetColorCoord = 0;
    stimuliMaterialMatch = [];
    stimuliColorMatch = [];
    scalePositions = 1; % scaling factor for input positions (we can try different ones to match our noise i.e. sigma of 1).
    sigma = 1;
    w = 0.75; 
    params.whichWeight = 'weightFixed';
    params.scalePositions  = scalePositions; 
    params.subjectName = ['demoFixed' num2str(w)]; 
    params.conditionCode = 'demo';
    params.materialMatchColorCoords = scalePositions*params.materialMatchColorCoords;
    params.colorMatchMaterialCoords = scalePositions*params.colorMatchMaterialCoords;
   
    % set up params for probablility computation
    params.F = colorMaterialInterpolatorFunction; % for lookup.
    params.whichMethod = 'lookup'; % could be also 'simulate' or 'analytic'
    params.nSimulate = 1000; % for method 'simulate'
    
    % These are the coordinates of the color matches.  The color coordinate always matches the
    % target and the matrial coordinate varies.
    for i = 1:length(params.colorMatchMaterialCoords)
        stimuliColorMatch = [stimuliColorMatch, {[targetColorCoord, params.colorMatchMaterialCoords(i)]}];
    end
    
    % These are the coordinates of the material matches.  The color
    % coordinate varies and the material coordinate always matches the
    % target.
    for i = 1:length(params.materialMatchColorCoords)
        stimuliMaterialMatch = [stimuliMaterialMatch, {[params.materialMatchColorCoords(i), targetMaterialCoord]}];
    end
    pair = [];
    
    % Simulate the data
    %
    % Initialize the response structure
    colorCoordIndex = 1;
    materialCoordIndex = 2;
    colorMatchIndexInPair = 1;
    materialMatchIndexInPair = 2;
    nBlocks = 100;
    
    % Loop over blocks and stimulus pairs and simulate responses
    % We pair each color-difference stimulus with each material-difference stimulus
    n = 0; 
    clear rowIndex columnIndex overallIndex
    for whichColorOfTheMaterialMatch = 1:length(params.materialMatchColorCoords)
        for whichMaterialOfTheColorMatch = 1:length(params.colorMatchMaterialCoords)
            rowIndex(whichColorOfTheMaterialMatch, whichMaterialOfTheColorMatch) = [whichColorOfTheMaterialMatch]; 
            columnIndex(whichColorOfTheMaterialMatch, whichMaterialOfTheColorMatch) = [whichMaterialOfTheColorMatch]; 
            n = n + 1; 
            overallColorMaterialPairIndices(whichColorOfTheMaterialMatch, whichMaterialOfTheColorMatch) = n;
            
            % The pair is a cell array containing two vectors.  The
            % first vector is the coordinates of the color match, the
            % second is the coordinates of the material match.  There
            % is one such pair for each trial type.
            pair = [pair; ...
                {stimuliColorMatch{whichMaterialOfTheColorMatch}, ...
                stimuliMaterialMatch{whichColorOfTheMaterialMatch} }];
        end
    end
        
    % Within color category (so material cooredinate == target material coord)
    withinCategoryPairsColor  =  nchoosek(1:length(params.materialMatchColorCoords),2);
    for whichWithinColorPair = 1:size(withinCategoryPairsColor,1)
        pair = [pair; ...
            {[params.materialMatchColorCoords(withinCategoryPairsColor(whichWithinColorPair, 1)), targetMaterialCoord]}, ...
            {[params.materialMatchColorCoords(withinCategoryPairsColor(whichWithinColorPair, 2)), targetMaterialCoord]}];
    end
   
    % Within material category (so color cooredinate == target color coord)
    withinCategoryPairsMaterial  =  nchoosek(1:length(params.colorMatchMaterialCoords),2);
    for whichWithinMaterialPair = 1:size(withinCategoryPairsMaterial,1)
        pair = [pair; ...
            {[targetColorCoord, params.colorMatchMaterialCoords(withinCategoryPairsMaterial(whichWithinMaterialPair, 1))]}, ...
            {[targetColorCoord, params.colorMatchMaterialCoords(withinCategoryPairsMaterial(whichWithinMaterialPair, 2))]}]; 
    end
    
    % Simulate out what the response is for this pair in this
    % block.
    %
    % Note that the first competitor passed is always a color
    % match that differs in material. so the response1 == 1
    % means that the color match was chosen
    nPairs = size(pair,1);
    responsesFromSimulatedData  = zeros(nPairs,1);
    for b = 1:nBlocks
        responsesForOneBlock = zeros(nPairs,1);
        for whichPair = 1:nPairs
            
            % Get the color and material coordiantes for each member of
            % this pair.
            pairColorMatchColorCoords(whichPair) = pair{whichPair, 1}(colorCoordIndex);
            pairMaterialMatchColorCoords(whichPair) = pair{whichPair, 2}(colorCoordIndex);
            pairColorMatchMaterialCoords(whichPair) = pair{whichPair, 1}(materialCoordIndex);
            pairMaterialMatchMaterialCoords(whichPair) = pair{whichPair, 2}(materialCoordIndex);
            
            % Simulate one response.
            responsesForOneBlock(whichPair) = ColorMaterialModelSimulateResponse(targetColorCoord, targetMaterialCoord, ...
                pairColorMatchColorCoords(whichPair), pairMaterialMatchColorCoords(whichPair), ...
                pairColorMatchMaterialCoords(whichPair), pairMaterialMatchMaterialCoords(whichPair), w, sigma); 
        end
        
        % Track cummulative response over blocks
        responsesFromSimulatedData = responsesFromSimulatedData+responsesForOneBlock;
    end
    
    % Compute response probabilities for each pair, just divide by nBlocks
    probabilitiesFromSimulatedData = responsesFromSimulatedData ./ nBlocks;
    
    % Use identical loop to compute probabilities, based on our analytic
    % function.  These ought to be close to the simulated probabilities.
    % This mainly serves as a check that our analytic function works
    % correctly.  Note that analytic is a bit too strong, there is some
    % numerical integration and approximation involved. 
    probabilitiesForActualPositions = zeros(nPairs,1);
    for whichPair = 1:nPairs
        probabilitiesForActualPositions(whichPair) = colorMaterialInterpolatorFunction(pairColorMatchColorCoords(whichPair), pairMaterialMatchColorCoords(whichPair), ...
                    pairColorMatchMaterialCoords(whichPair) , pairMaterialMatchMaterialCoords(whichPair), w);
        
        %         probabilitiesComputedForSimulatedData(whichPair) = ColorMaterialModelComputeProb(targetColorCoord, targetMaterialCoord, ...
        %             pairColorMatchColorCoords(whichPair), pairMaterialMatchColorCoords(whichPair), ...
        %             pairColorMatchMaterialCoords(whichPair) , pairMaterialMatchMaterialCoords(whichPair), w, sigma);
    end
     
    nTrials = nBlocks*ones(size(responsesFromSimulatedData));
    [logLikely, predictedResponses] = ColorMaterialModelComputeLogLikelihood(pairColorMatchColorCoords, pairMaterialMatchColorCoords,...
        pairColorMatchMaterialCoords, pairMaterialMatchMaterialCoords,...
        responsesFromSimulatedData, nTrials,...
        params.materialMatchColorCoords(params.targetIndex), params.colorMatchMaterialCoords(params.targetIndex), ...
        w,sigma,'Fobj', colorMaterialInterpolatorFunction, 'whichMethod', 'lookup');
    fprintf('True position log likelihood %0.2f.\n', logLikely);
    
% Here you could enter some real data and fit it, either to see the fit or to figure
% out why the fitting is not working.
else
    
    % Set up some params
    % All this should be in the pair indices matrix. 
    colorCoordIndex = 1;
    materialCoordIndex = 2;
    colorMatchIndexInPair = 1;
    materialMatchIndexInPair = 2;
    load('pairIndicesPilot.mat')
    
    whichOption = 'option1'; 
    params.subjectName = whichOption; 
    params.conditionCode = 'demo';
    switch whichOption
        case 'option1'
            responsesFromSimulatedData = [       3     1     5     4     1     0     2     5     6     0 , ...
                2    13     0    12     4     3     0     1, ...
                4    14     1     7    22    21    22     6     0     8    22    23     5    22    25     2     0     0, ...
                1     8    14     0    11    21     2     0     2    10    21     2    17    24     0    15    23    24, ...
                8    22    24    22    25    25    23    25    25    25    25     6    24    25    23     0    17    20, ...
                1    12    21    24    25    25];
            nBlocks = 25;
            nTrials = nBlocks*[ones(size(responsesFromSimulatedData))];
            pairColorMatchColorCoords = colorMatchColorCoord;
            pairMaterialMatchColorCoords = materialMatchColorCoord;
            pairColorMatchMaterialCoords = colorMatchMaterialCoord;
            pairMaterialMatchMaterialCoords  = materialMatchMaterialCoord;
            params.whichWeight = 'weightVary';
            params.whichPositions = 'full';
            params.F = colorMaterialInterpolatorFunction; % for lookup.
            params.whichMethod = 'lookup'; % could be also 'simulate' or 'analytic'
            params.nSimulate = 1000; 
            
    end
    probabilitiesFromSimulatedData = responsesFromSimulatedData./nTrials;
    params.subjectName = whichOption; 
    
    % String out the responses for fitting. 
    responsesFromSimulatedData = responsesFromSimulatedData(:);
    nTrials  = nTrials(:);
end

%% Fit the data and extract parameters and other useful things from the solution
%
% We put the method into the params structure, so it flows to where we need
% it.  This isn't beautiful, but saves us figuring out how to pass the
% various key value pairs all the way down into the functions called by
% fmincon, which is actually somewhat hard to do in a more elegant way.
[returnedParams, logLikelyFit, predictedProbabilitiesBasedOnSolution, k] = FitColorMaterialModelMLDS(...
    pairColorMatchColorCoords, pairMaterialMatchColorCoords,...
    pairColorMatchMaterialCoords, pairMaterialMatchMaterialCoords,...
    responsesFromSimulatedData,nTrials,params, ...
    'whichPositions',params.whichPositions,'whichWeight',params.whichWeight, ...
    'tryWeightValues',tryWeightValues,'trySpacingValues',trySpacingValues); %#ok<SAGROW>
[returnedMaterialMatchColorCoords,returnedColorMatchMaterialCoords,returnedW,returnedSigma]  = ColorMaterialModelXToParams(returnedParams, params); 
fprintf('Returned weight: %0.2f.\n', returnedW);  
fprintf('Log likelyhood of the solution: %0.2f.\n', logLikelyFit);

%% Plot the solution
%
% Reformat probabilities to look only at color/material tradeoff
if DEMO
    overallColorMaterialPairIndices = overallColorMaterialPairIndices(:);
    rowIndex = rowIndex(:);
    columnIndex = columnIndex(:);
    for i = 1:length(rowIndex)
        resizedDataProb(rowIndex((i)), columnIndex((i))) = probabilitiesFromSimulatedData(overallColorMaterialPairIndices(i));
        resizedSolutionProb(rowIndex((i)), columnIndex((i))) = predictedProbabilitiesBasedOnSolution(overallColorMaterialPairIndices(i));
        resizedProbabilitiesForActualPositions(rowIndex((i)), columnIndex((i))) = probabilitiesForActualPositions(overallColorMaterialPairIndices(i));
    end
else
    load('pilotIndices.mat')
    % entry % row % column % first or second
    resizedDataProb = nan(7,7);
    resizedSolutionProb = nan(7,7);
    for i = 1:size(pilotIndices,1)
        entryIndex = pilotIndices(i,1);
        if pilotIndices(i,end) == 1
            resizedDataProb(pilotIndices(i,2), pilotIndices(i,3)) = probabilitiesFromSimulatedData(pilotIndices(i,1));
            resizedSolutionProb(pilotIndices(i,2), pilotIndices(i,3)) = predictedProbabilitiesBasedOnSolution(pilotIndices(i,1));
        elseif pilotIndices(i,end) == 2
            resizedDataProb(pilotIndices(i,2), pilotIndices(i,3)) = 1- probabilitiesFromSimulatedData(pilotIndices(i,1));
            resizedSolutionProb(pilotIndices(i,2), pilotIndices(i,3)) = 1 - predictedProbabilitiesBasedOnSolution(pilotIndices(i,1));
        end
    end
    resizedDataProb(4,4) = 0.5;
    resizedSolutionProb(4,4) = 0.5;
end

% Make the big figure
figure; hold on
plot(probabilitiesFromSimulatedData,predictedProbabilitiesBasedOnSolution(:),'ro','MarkerSize',12,'MarkerFaceColor','r');
rmse = ComputeRealRMSE(probabilitiesFromSimulatedData,predictedProbabilitiesBasedOnSolution);
plot(resizedDataProb,resizedSolutionProb,'ko','MarkerSize',12,'MarkerFaceColor','k');
text(0.07, 0.87, sprintf('RMSEFit = %.4f', rmse), 'FontSize', 12);
if DEMO
    plot(probabilitiesFromSimulatedData,probabilitiesForActualPositions(:),'bo','MarkerSize',12);
    rmseComp = ComputeRealRMSE(probabilitiesFromSimulatedData,probabilitiesForActualPositions);
    text(0.07, 0.82, sprintf('RMSEActual = %.4f', rmseComp), 'FontSize', 12);
    logLikely2 = ColorMaterialModelComputeLogLikelihoodSimple(responsesFromSimulatedData,probabilitiesForActualPositions,nTrials);
    fprintf('Log likelyhood 2: %0.2f.\n', logLikely2);
    
    legend('Fit Parameters', 'Actual Parameters', 'Location', 'NorthWest')
    legend boxoff
else
    legend('Fit Parameters', 'Location', 'NorthWest')
    legend boxoff
end
thisFontSize = 12;
line([0, 1], [0,1], 'color', 'k');
axis('square')
axis([0 1 0 1]);
set(gca,  'FontSize', thisFontSize);
xlabel('Measured p');
ylabel('Predicted p');
set(gca, 'xTick', [0, 0.5, 1]);
set(gca, 'yTick', [0, 0.5, 1]);
if saveFig
    cd(figDir)
    FigureSave([params.subjectName, params.conditionCode, 'MeasuredVsPredictedProb'], gcf, 'pdf');
end

if DEMO
     ColorMaterialModelPlotSolution(resizedDataProb, resizedSolutionProb, ...
        returnedParams, params, params.subjectName, params.conditionCode, figDir, saveFig, weibullplots,resizedProbabilitiesForActualPositions);
else
    ColorMaterialModelPlotSolution(resizedDataProb, resizedSolutionProb, ...
        returnedParams, params, params.subjectName, params.conditionCode, figDir, saveFig, weibullplots);
end
