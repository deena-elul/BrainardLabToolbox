function [f,predictedResponses] = FitColorMaterialScalingFun(x,pairColorMatchMatrialCoordIndices,pairMaterialMatchColorCoordIndices,theResponses,nTrials,params)
% [f,predictedResponses] = FitColorMaterialScalingFun(x,pairColorMatchMatrialCoordIndices,pairMaterialMatchColorCoordIndices,theResponses,nTrials,params)

% The error function we are minimizing in the numerical search.
% Computes the negative log likelyhood of the current solution i.e. the weights and the inferred
% position of the competitors on color and material axes.
% Input:
%   x           - returned parameters vector.
%   pairColorMatchMatrialCoordIndices - index to get color match material coordinate for each trial type.
%   pairMaterialMatchColorCoordIndices - index to get material match color coordinate for each trial type.
%   theResponses- set of responses for this pair (number of times first competitor is chosen).
%   nTrialsPerPair - total number of trials run.
%   targetIndex    - index of the target position in the color and material space.
%   pairSpecs - defines each pair - w
% Output:
%   f - negative log likelihood for the current solution.

% Sanity check - is the solution to any of our parameters NaN
if (any(isnan(x)))
    error('Entry of x is NaN');
end

% We need to convert X to params here
[materialMatchColorCoords,colorMatchMaterialCoords,w,sigma] = ColorMaterialModelXToParams(x,params); 
           
% Compute negative log likelyhood of the current solution
[logLikely,predictedResponses] = ColorMaterialModelComputeLogLikelihood(pairColorMatchMatrialCoordIndices,pairMaterialMatchColorCoordIndices,theResponses,nTrials,colorMatchMaterialCoords,materialMatchColorCoords,params.targetIndex,w,sigma);
f = -logLikely;

end