%
% Demo of basic analog digital aquisition via a LabJackU6 device.
% 
% Jan 6, 2015     npc    Wrote it . 
%                        

function LabJackDemo

    addpath(genpath(pwd));
    
    % Instantiate a LabJack object to handle communication with the device
    labjackOBJ = LabJackU6('verbosity', 1);
    
    % Set up sampling parameters
    samplingParams = struct(...
        'channelIDs', [1], ...         % list of  channels to aquire from (AIN1, AIN2, AIN3)
        'frequencyInHz', 7*1000 ...    % using an 7 KHz sampling rate
        );
    
    try
        % Configure analog input sampling
        labjackOBJ.configureAnalogDataStream(samplingParams.channelIDs, samplingParams.frequencyInHz);

        % Loop for ever
        while (1)
            % 2 second aquisitions
            durationInSeconds = 2;
            
            % Aquire the data
            labjackOBJ.startDataStreamingForSpecifiedDuration(durationInSeconds);

            % Plot the data
            figure(1);
            clf;
            plot(labjackOBJ.timeAxis,labjackOBJ.data(:,1), 'r-');
            hold on;
            %plot(labjackOBJ.timeAxis,labjackOBJ.data(:,2), 'g-');
            %plot(labjackOBJ.timeAxis,labjackOBJ.data(:,3), 'b-');
            hold off;
            set(gca, 'YLim', 5*[-1 1]);
            ylabel('input signal (volts)');
            xlabel('time (seconds)');
        end
        
        % Close-up shop
        labjackOBJ.shutdown();
        
    catch err 
        % Close up shop
        labjackOBJ.shutdown();
        rethrow(err)
    end
end



