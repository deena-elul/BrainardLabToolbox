function LUTinversionTutorial
    %% Load a calibration file (generated by running OOC_calibrateMonitor)
    calFileName = 'ViewSonicProbe';
    calStruct = LoadCalFile(calFileName);

    %% Instantiate a @CalStruct object that will handle controlled access to the calibration data.
    [calStructOBJ, ~] = ObjectToHandleCalOrCalStruct(calStruct); 
    % Clear the imported calStruct. From now on, all access to cal data is via the calStructOBJ.
    clear 'calStruct';

    % Compute 11-bit gamma curves for all channels
    nInputLevels = 2048;
    CalibrateFitGamma(calStructOBJ, nInputLevels);

    % Set gamma inversion parameters 
    gammaMethod = 1;
    SetGammaMethod(calStructOBJ, gammaMethod, nInputLevels);

    % Get the 11-bit data    
    settingsInput = calStructOBJ.get('gammaInput');
    gamma         = calStructOBJ.get('gammaTable');
    inverseGamma  = calStructOBJ.get('iGammaTable');

    % Plot the Red channel gamma curve and its inverse
    figure()
    plot(settingsInput, gamma(:,1), 'r-'); hold on
    plot(settingsInput, inverseGamma(:,1), 'r--');
    legend('gamma', 'inverse gamma');
    set(gca, 'FontSize', 14, 'FontName', 'Helvetica');
    set(gca, 'XTick', [0:0.1:10], 'YTick', [0:0.1:10]);
    xlabel('settings value', 'FontWeight', 'b'); 
    ylabel('primary activation', 'FontWeight', 'b');
    grid on; box on;
    axis 'square'

end


function loadRawData
    % Load the calibration file
    calFile = 'ViewSonicProbe';
    cal = LoadCalFile(calFile);

    % generate a calStructOBJ to access the calibration data
    calStructOBJ = ObjectToHandleCalOrCalStruct(cal);
    clear 'cal'

    % Get the wavelength sampling and the (linear model-based) SPDs for all channels 
    S = calStructOBJ.get('S');
    SPDs = calStructOBJ.get('P_device');

    % Get the measured gamma curves for all channels
    settingsInput = calStructOBJ.get('rawGammaInput');
    primaryOutput = calStructOBJ.get('rawGammaTable');

    figure();
    spectralAxis = SToWls(S);
    subplot(1,2,1);
    % Plot the Red channel SPD
    plot(spectralAxis, SPDs(:,1), 'r-');
    set(gca, 'FontSize', 14, 'FontName', 'Helvetica');
    set(gca, 'XLim', [spectralAxis(1) spectralAxis(end)], 'XTick', [0:50:1000]);
    xlabel('wavelength (nm)', 'FontWeight', 'b'); 
    ylabel('energy', 'FontWeight', 'b');
    grid on; box on;
    axis 'square';


    subplot(1,2,2);
    % Plot the Red channel gamma curve
    plot(settingsInput, primaryOutput(:,1), 'rs');
    set(gca, 'FontSize', 14, 'FontName', 'Helvetica');
    set(gca, 'XTick', [0:0.1:1], 'YTick', [0:0.1:1], 'YLim', [0 1]);
    xlabel('settings value', 'FontWeight', 'b'); 
    ylabel('primary activation', 'FontWeight', 'b');
    grid on; box on;
    axis 'square'

end