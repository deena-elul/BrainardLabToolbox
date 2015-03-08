% Executive script for object-oriented-based monitor calibration.
%
% 3/27/2014  npc   Wrote it.
% 8/05/2014  npc   Added option to conduct PsychImaging - based calibration
% 3/02/2015  npc   Re-organized script so that settings and options are set in 
%                  a single function.

function OOC_calibrateMonitor
    
    
    % Select a calibration configuration name
    AvailableCalibrationConfigs = {  'ViewSonicProbe' 
                            'BOLDscreen'
                            'Left_SONY_PVM2541A'
                            'Right_SONY_PVM2541A'
                            };
    
    defaultCalibrationConfig = AvailableCalibrationConfigs{1};
    while (true)
        fprintf('Available calibration configurations \n');
        for k = 1:numel(AvailableCalibrationConfigs)
            fprintf('\t %s\n', AvailableCalibrationConfigs{k});
        end
        calibrationConfig = input(sprintf('Select a calibration config [%s]: ', defaultCalibrationConfig),'s');
        if (ismember(calibrationConfig, AvailableCalibrationConfigs))
            break;
        else
           fprintf(2,'** %s ** is not an available calibration configuration. Try again. \n\n', calibrationConfig);
        end
    end
    
    calibrationConfig
    pause;
    
    % Generate calibration options and settings
    runtimeParams = [];
    switch calibrationConfig
        
        case 'ViewSonicProbe'
            configFunctionHandle = @generateConfigurationForViewSonicProbe;
            
        case 'BOLDscreen'
            configFunctionHandle = @generateConfigurationForBOLDScreen;
            
        case 'Left_SONY_PVM2541A'
            configFunctionHandle = @generateConfigurationForSONY_PVM2541A;
            runtimeParams = 'Left';
        
        case 'Right_SONY_PVM2541A'
            configFunctionHandle = @generateConfigurationForSONY_PVM2541A;
            runtimeParams = 'Right';
            
        default
            configFunctionHandle = @generateConfigurationForViewSonicProbe;
    end
    
    if (isempty(runtimeParams))
        [displaySettings, calibratorOptions] = configFunctionHandle();
    else
        [displaySettings, calibratorOptions] = configFunctionHandle(runtimeParams);
    end
    
    % Generate the Radiometer object, here a PR650obj.
    radiometerOBJ = generateRadiometerObject();
    
    % Generate the calibrator object
    calibratorOBJ = generateCalibratorObject(displaySettings, radiometerOBJ, mfilename);
    
    % Set the calibrator options
    calibratorOBJ.options = calibratorOptions;
        
    % display calStruct if so desired
    beVerbose = false;
    if (beVerbose)
        % Optionally, display the cal struct before measurement
        calibratorOBJ.displayCalStruct();
    end
        
    try 
        % Calibrate !
        calibratorOBJ.calibrate();
            
        if (beVerbose)
            % Optionally, display the updated cal struct after the measurement
            calibratorOBJ.displayCalStruct();
        end
        
        % Optionally, export cal struct in old format, for backwards compatibility with old programs.
        % calibratorOBJ.exportOldFormatCal();
        
        disp('All done with the calibration ...');

        % Shutdown DBLab_Calibrator
        calibratorOBJ.shutDown();
        
        % Shutdown DBLab_Radiometer object
        calibratorOBJ.shutDown();
    
    catch err
        % Shutdown DBLab_Radiometer object  
        if (~isempty(calibratorOBJ))
            % Shutdown calibratorOBJ
            calibratorOBJ.shutDown();
        end
        
        rethrow(err)
    end % end try/catch
end


% configuration function for BoldScreen
function [displaySettings, calibratorOptions] = generateConfigurationForSONY_PVM2541A(LeftOrRight)
    % Specify where to send the 'Calibration Done' notification email
    emailAddressForNotification = 'cottaris@sas.upenn.edu';
    
    if strcmp(LeftOrRight, 'Left')
        displayDeviceName = 'Left_SONY_PVM_OLED';
        calibrationFileName = 'Left_SONY_PVM_OLED';
    elseif strcmp(LeftOrRight, 'Right')
        displayDeviceName = 'Right_SONY_PVM_OLED';
        calibrationFileName = 'Right_SONY_PVM_OLED';
    else
        error('You must specify Left or Right screen');
    end
    % Specify the @Calibrator's initialization params. 
    % Users should tailor these according to their hardware specs. 
    % These can be set once only, at the time the @Calibrator object is instantiated.
    displaySettings = { ...
        'screenToCalibrate',        2, ...                          % which display to calibrate. main screen = 1, second display = 2
        'desiredScreenSizePixel',   [1920 1080], ...                % pixels along the width and height of the display to be calibrated
        'desiredRefreshRate',       60, ...                         % refresh rate in Hz
        'displayPrimariesNum',      3, ...                          % for regular displays this is always 3 (RGB) 
        'displayDeviceType',        'monitor', ...                  % this should always be set to 'monitor' for now
        'displayDeviceName',        displayDeviceName, ...          % a name for the display been calibrated
        'calibrationFile',          calibrationFileName, ...        % name of calibration file to be generated
        'comment',                  'Stereo HDR Rig' ...            % some comment, could be anything
        };
    
    % Specify the @Calibrator's optional params using a CalibratorOptions object
    % To see what options are available type: doc CalibratorOptions
    % Users should tailor these according to their experimental needs.
    calibratorOptions = CalibratorOptions( ...
        'verbosity',                        2, ...
        'whoIsDoingTheCalibration',         input('Enter your name: ','s'), ...
        'emailAddressForDoneNotification',  GetWithDefault('Enter email address for done notification',  emailAddressForNotification), ...
        'blankOtherScreen',                 0, ...                          % whether to blank other displays attached to the host computer (1=yes, 0 = no), ...
        'whichBlankScreen',                 1, ...                          % screen number of the display to be blanked  (main screen = 1, second display = 2)
        'blankSettings',                    [0.25 0.25 0.25], ...           % color of the whichBlankScreen 
        'bgColor',                          [0.3962 0.3787 0.4039], ...     % color of the background  
        'fgColor',                          [0.3962 0.3787 0.4039], ...     % color of the foreground
        'meterDistance',                    0.5, ...                        % distance between radiometer and screen in meters
        'leaveRoomTime',                    1, ...                          % seconds allowed to leave room
        'nAverage',                         5, ...                          % number of repeated measurements for averaging
        'nMeas',                            15, ...                         % samples along gamma curve
        'boxSize',                          150, ...                        % size of calibration stimulus in pixels
        'boxOffsetX',                       0, ...                          % x-offset from center of screen (neg: leftwards, pos:rightwards)         
        'boxOffsetY',                       0 ...                           % y-offset from center of screen (neg: upwards, pos: downwards)                      
    );
end


% configuration function for BOLDScreen
function [displaySettings, calibratorOptions] = generateConfigurationForBOLDScreen()
    % Specify where to send the 'Calibration Done' notification email
    emailAddressForNotification = 'mspits@sas.upenn.edu';
    
    % Specify the @Calibrator's initialization params. 
    % Users should tailor these according to their hardware specs. 
    % These can be set once only, at the time the @Calibrator object is instantiated.
    displaySettings = { ...
        'screenToCalibrate',        2, ...                          % which display to calibrate. main screen = 1, second display = 2
        'desiredScreenSizePixel',   [1920 1080], ...                % pixels along the width and height of the display to be calibrated
        'desiredRefreshRate',       60, ...                         % refresh rate in Hz
        'displayPrimariesNum',      3, ...                          % for regular displays this is always 3 (RGB) 
        'displayDeviceType',        'monitor', ...                  % this should always be set to 'monitor' for now
        'displayDeviceName',        'BOLDScreen', ...               % a name for the display been calibrated
        'calibrationFile',          'BOLDScreen', ...               % name of calibration file to be generated
        'comment',                  'BOLDScreen' ...                % some comment, could be anything
        };
    
    % Specify the @Calibrator's optional params using a CalibratorOptions object
    % To see what options are available type: doc CalibratorOptions
    % Users should tailor these according to their experimental needs.
    calibratorOptions = CalibratorOptions( ...
        'verbosity',                        2, ...
        'whoIsDoingTheCalibration',         input('Enter your name: ','s'), ...
        'emailAddressForDoneNotification',  GetWithDefault('Enter email address for done notification',  emailAddressForNotification), ...
        'blankOtherScreen',                 0, ...                          % whether to blank other displays attached to the host computer (1=yes, 0 = no), ...
        'whichBlankScreen',                 1, ...                          % screen number of the display to be blanked  (main screen = 1, second display = 2)
        'blankSettings',                    [0.25 0.25 0.25], ...           % color of the whichBlankScreen 
        'bgColor',                          [0.3962 0.3787 0.4039], ...     % color of the background  
        'fgColor',                          [0.3962 0.3787 0.4039], ...     % color of the foreground
        'meterDistance',                    0.5, ...                        % distance between radiometer and screen in meters
        'leaveRoomTime',                    1, ...                          % seconds allowed to leave room
        'nAverage',                         1, ...                          % number of repeated measurements for averaging
        'nMeas',                            15, ...                         % samples along gamma curve
        'boxSize',                          150, ...                        % size of calibration stimulus in pixels
        'boxOffsetX',                       0, ...                          % x-offset from center of screen (neg: leftwards, pos:rightwards)         
        'boxOffsetY',                       0 ...                           % y-offset from center of screen (neg: upwards, pos: downwards)                      
    );
end


% configuration function for ViewSonicProbe
function [displaySettings, calibratorOptions] = generateConfigurationForViewSonicProbe()

    % Specify where to send the 'Calibration Done' notification email
    emailAddressForNotification = 'cottaris@sas.upenn.edu';
    
    % Specify the @Calibrator's initialization params. 
    % Users should tailor these according to their hardware specs. 
    % These can be set once only, at the time the @Calibrator object is instantiated.
    displaySettings = { ...
        'screenToCalibrate',        2, ...                          % which display to calibrate. main screen = 1, second display = 2
        'desiredScreenSizePixel',   [1920 1080], ...                % pixels along the width and height of the display to be calibrated
        'desiredRefreshRate',       60, ...                         % refresh rate in Hz
        'displayPrimariesNum',      3, ...                          % for regular displays this is always 3 (RGB) 
        'displayDeviceType',        'monitor', ...                  % this should always be set to 'monitor' for now
        'displayDeviceName',        'ViewSonicProbe', ...           % a name for the display been calibrated
        'calibrationFile',          'ViewSonicProbe', ...           % name of calibration file to be generated
        'comment',                  'Scallops display' ...          % some comment, could be anything
        };
    
    % Specify the @Calibrator's optional params using a CalibratorOptions object
    % To see what options are available type: doc CalibratorOptions
    % Users should tailor these according to their experimental needs.
    calibratorOptions = CalibratorOptions( ...
        'verbosity',                        2, ...
        'whoIsDoingTheCalibration',         input('Enter your name: ','s'), ...
        'emailAddressForDoneNotification',  GetWithDefault('Enter email address for done notification',  emailAddressForNotification), ...
        'blankOtherScreen',                 0, ...                          % whether to blank other displays attached to the host computer (1=yes, 0 = no), ...
        'whichBlankScreen',                 1, ...                          % screen number of the display to be blanked  (main screen = 1, second display = 2)
        'blankSettings',                    [0.25 0.25 0.25], ...           % color of the whichBlankScreen 
        'bgColor',                          [0.3962 0.3787 0.4039], ...     % color of the background  
        'fgColor',                          [0.3962 0.3787 0.4039], ...     % color of the foreground
        'meterDistance',                    0.5, ...                        % distance between radiometer and screen in meters
        'leaveRoomTime',                    1, ...                          % seconds allowed to leave room
        'nAverage',                         3, ...                          % number of repeated measurements for averaging
        'nMeas',                            11, ...                         % samples along gamma curve
        'boxSize',                          150, ...                        % size of calibration stimulus in pixels
        'boxOffsetX',                       0, ...                          % x-offset from center of screen (neg: leftwards, pos:rightwards)         
        'boxOffsetY',                       0 ...                           % y-offset from center of screen (neg: upwards, pos: downwards)                      
    );
end


% Function to generate the calibrator object.
% Users should not modify this function unless they know what they are doing.
function calibratorOBJ = generateCalibratorObject(displaySettings, radiometerOBJ, execScriptFileName)

    % set init params
    calibratorInitParams = displaySettings;
    
    % add radiometerOBJ
    calibratorInitParams{numel(calibratorInitParams)+1} = 'radiometerObj';
    calibratorInitParams{numel(calibratorInitParams)+1} = radiometerOBJ;
    
    % add executive script name
    calibratorInitParams{numel(calibratorInitParams)+1} ='executiveScriptName';
    calibratorInitParams{numel(calibratorInitParams)+1} = execScriptFileName;
        
    % Select and instantiate the calibrator object
    calibratorOBJ = selectAndInstantiateCalibrator(calibratorInitParams);
end


function radiometerOBJ = generateRadiometerObject()
    radiometerOBJ = PR650dev(...
        'verbosity',        1, ...       % 1 -> minimum verbosity
        'devicePortString', [] ...       % empty -> automatic port detection
        );
    
end

% Function to select and instantiate a particular calibrator type
% Currently either MGL-based or PTB-3 based.
% Users should not modify this function unless they know what they are doing.
function calibratorOBJ = selectAndInstantiateCalibrator(calibratorInitParams)
    % List of available @Calibrator objects
    calibratorTypes = {'MGL-based', 'PsychImaging-based (8-bit)'};
    calibratorsNum  = numel(calibratorTypes);
    
    % Ask the user to select a calibrator type
    fprintf('\n\n Available calibrator types:\n');
    for k = 1:calibratorsNum
        fprintf('\t[%3d]. %s\n', k, calibratorTypes{k});
    end
    defaultCalibratorIndex = 1;
    calibratorIndex = input(sprintf('\tSelect a calibrator type (1-%d) [%d]: ', calibratorsNum, defaultCalibratorIndex));
    if isempty(calibratorIndex) || (calibratorIndex < 1) || (calibratorIndex > calibratorsNum)
        calibratorIndex = defaultCalibratorIndex;
    end
    fprintf('\n\t-------------------------\n');
    selectedCalibratorType = calibratorTypes{calibratorIndex};
    fprintf('Will employ an %s calibrator object [%d].\n', selectedCalibratorType, calibratorIndex);
    
    calibratorOBJ = [];
    try
        % Instantiate an Calibrator object with the required configration variables.
        if strcmp(selectedCalibratorType, 'MGL-based')
            calibratorOBJ = MGLcalibrator(calibratorInitParams);
            
        elseif strcmp(selectedCalibratorType, 'PsychImaging-based (8-bit)')
            calibratorOBJ = PsychImagingCalibrator(calibratorInitParams);
        end
        
    catch err
        % Shutdown DBLab_Radiometer object  
        if (~isempty(calibratorOBJ))
            % Shutdown calibratorOBJ
            calibratorOBJ.shutDown();
        end
        
        rethrow(err)
    end % end try/catch
end

