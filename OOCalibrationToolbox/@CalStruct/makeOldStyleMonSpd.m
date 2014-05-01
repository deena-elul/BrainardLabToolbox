function [monSpd, path] = makeOldStyleMonSpd(obj)
    trialsNum           = size(obj.inputCal.rawData.gammaCurveMeasurements,1);
    primariesNum        = size(obj.inputCal.rawData.gammaCurveMeasurements,2); 
    gammaSamples        = size(obj.inputCal.rawData.gammaCurveMeasurements,3); 
    spectralSamples     = size(obj.inputCal.rawData.gammaCurveMeasurements,4);
    
    for trialIndex = 1:trialsNum 
        for primaryIndex = 1:primariesNum   
            tmp = zeros(spectralSamples*gammaSamples,1);
            for gammaPointIndex = 1:gammaSamples
                firstSample = (gammaPointIndex-1)*spectralSamples + 1;
                lastSample  = gammaPointIndex*spectralSamples;
                tmp(firstSample:lastSample) = ...
                    reshape(obj.inputCal.rawData.gammaCurveMeasurements(trialIndex, primaryIndex, gammaPointIndex, :), ...
                    [1 spectralSamples]);
            end  
            monSpd{trialIndex, primaryIndex} = tmp;
        end
    end
    
    path = 'cal.rawData.monSpd';
end
