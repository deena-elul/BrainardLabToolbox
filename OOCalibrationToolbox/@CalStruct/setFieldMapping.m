function setFieldMapping(obj)
    % Contruct an empty map that will hold the values of the different fields
    obj.fieldMap = containers.Map;
    
    % General info
    obj.fieldMap('computer') = struct(...
        'propertyName', 'describe___computerInfo', ...
        'oldCalPath',   'describe.computer', ...
        'newCalPath',   'describe.computerInfo', ...
        'access',       'read_only'...
        );
                                         
    obj.fieldMap('matlabInfo') = struct(...
        'propertyName',  'describe___matlabInfo', ...
        'oldCalPath',    '', ...                            % only in new-style cal, so do not export in old-style cal
        'newCalPath',    'describe.matlabInfo', ...
        'access',       'read_only'...
        );
                                                                                                                     
    obj.fieldMap('svnInfo') = struct(...
        'propertyName', 'describe___svnInfo', ...
        'oldCalPath',   'describe.svnInfo', ...
        'newCalPath',   'describe.svnInfo', ...
        'newToOldConversionFname',  @obj.SVNconversion,...  % different structure in old- vs. new-style cal, so supply conversion function
        'access',       'read_only'...
        );
                                         
    obj.fieldMap('monitor') = struct(...
        'propertyName', 'describe___displayDeviceName', ...
        'oldCalPath',   'describe.monitor', ...
        'newCalPath',   'describe.displayDeviceName', ...
        'access',       'read_only'...
        );
                                         
    obj.fieldMap('caltype') = struct(...
        'propertyName', 'describe___displayDeviceType', ...
        'oldCalPath',   'describe.caltype', ...
        'newCalPath',   'describe.displayDeviceType', ...
        'access',       'read_only'...
    );

    obj.fieldMap('calibrationType') = struct(...
        'propertyName',  'describe___calibrationType', ...
        'oldCalPath',    'describe.calibrationType', ...
        'newCalPath',    '', ...                          % The 'calibrationType' field has been eliminated in OOC calibration as potentially confusing and un-necessary.
        'access',       'read_only'...
    );         

    obj.fieldMap('driver') = struct(...
        'propertyName', 'describe___driver', ...
        'oldCalPath',   'describe.driver', ...
        'newCalPath',   'describe.driver', ...
        'access',       'read_only'...
    );

    obj.fieldMap('who') = struct(...
        'propertyName', 'describe___who', ...
        'oldCalPath',   'describe.who', ...
        'newCalPath',   'describe.who', ...
        'access',       'read_only'...
    );

    obj.fieldMap('date') = struct(...
        'propertyName', 'describe___date', ...
        'oldCalPath',   'describe.date', ...
        'newCalPath',   'describe.date', ...
        'access',       'read_only'...
    );

    obj.fieldMap('program') = struct(...
        'propertyName', 'describe___executiveScriptName', ...
        'oldCalPath',   'describe.program', ...
        'newCalPath',   'describe.executiveScriptName', ...
        'access',       'read_only'...
    );

    obj.fieldMap('comment') = struct(...
        'propertyName', 'describe___comment', ...
        'oldCalPath',   'describe.comment', ...
        'newCalPath',   'describe.comment', ...
        'access',       'read_only'...
    );

    obj.fieldMap('promptforname') = struct(...
        'propertyName',  'describe___promptForName', ...
        'oldCalPath',    'describe.promptforname', ...
        'newCalPath',    '', ...                          % The 'promptforname' field has been eliminated in OOC calibration as un-necessary.
        'access',       'read_only'...
    );


    % Screen configuration
    obj.fieldMap('displayDescription') = struct(...
        'propertyName', 'describe___displaysDescription', ...
        'oldCalPath',   'describe.displayDescription', ...
        'newCalPath',   'describe.displaysDescription', ...
        'newToOldConversionFname',  @obj.DisplaysDescriptionConversion,...  % different structure in old- vs. new-style cal, so supply conversion function
        'access',       'read_only'...
    );

    obj.fieldMap('whichScreen') = struct(...
        'propertyName', 'describe___whichScreen', ...
        'oldCalPath',   'describe.whichScreen', ...
        'newCalPath',   'describe.whichScreen', ...
        'access',       'read_only'...
    );

    obj.fieldMap('blankOtherScreen') = struct(...
        'propertyName', 'describe___blankOtherScreen', ...
        'oldCalPath',   'describe.blankOtherScreen', ...
        'newCalPath',   'describe.blankOtherScreen', ...
        'access',       'read_only'...
    );

    obj.fieldMap('whichBlankScreen') = struct(...
        'propertyName', 'describe___whichBlankScreen', ...
        'oldCalPath',   'describe.whichBlankScreen', ...
        'newCalPath',   'describe.whichBlankScreen', ...
        'access',       'read_only'...
    );

    obj.fieldMap('blankSettings') = struct(...
        'propertyName', 'describe___blankSettings', ...
        'oldCalPath',   'describe.blankSettings', ...
        'newCalPath',   'describe.blankSettings', ...
        'access',       'read_only'...
    );

    obj.fieldMap('dacsize') = struct(...
        'propertyName', 'describe___dacsize', ...
        'oldCalPath',   'describe.dacsize', ...
        'newCalPath',   'describe.dacsize', ...
        'access',       'read_only'...
    );

    obj.fieldMap('hz') = struct(...
        'propertyName', 'describe___hz', ...
        'oldCalPath',   'describe.hz', ...
        'newCalPath',   'describe.hz', ...
        'access',       'read_only'...
    );

    obj.fieldMap('screenSizePixel') = struct(...
        'propertyName', 'describe___screenSizePixel', ...
        'oldCalPath',   'describe.screenSizePixel', ...
        'newCalPath',   'describe.screenSizePixel', ...
        'access',       'read_only'...
    );

    obj.fieldMap('HDRProjector') = struct(...
        'propertyName',  'describe___HDRProjector', ...
        'oldCalPath',    'describe.HDRProjector', ...
        'newCalPath',    '', ...                          % The HDR_projector field has been eliminated in OOC calibration, as we do not think we'll be using the HDR projector any more.
        'access',       'read_only'...
    );
      
        
    % Calibration params
    obj.fieldMap('boxSize') = struct(...
        'propertyName', 'describe___boxSize', ...
        'oldCalPath',   'describe.boxSize', ...
        'newCalPath',   'describe.boxSize', ...
        'access',       'read_only'...
    );

    obj.fieldMap('boxOffsetX') = struct(...
        'propertyName', 'describe___boxOffsetX', ...
        'oldCalPath',   'describe.boxOffsetX', ...
        'newCalPath',   'describe.boxOffsetX', ...
        'access',       'read_only'...
    );

    obj.fieldMap('boxOffsetY') = struct(...
        'propertyName', 'describe___boxOffsetY', ...
        'oldCalPath',   'describe.boxOffsetY', ...
        'newCalPath',   'describe.boxOffsetY', ...
        'access',       'read_only'...
    );


    obj.fieldMap('nAverage') = struct(...
        'propertyName', 'describe___nAverage', ...
        'oldCalPath',   'describe.nAverage', ...
        'newCalPath',   'describe.nAverage', ...
        'access',       'read_only'...
    );

    obj.fieldMap('nMeas') = struct(...
        'propertyName', 'describe___nMeas', ...
        'oldCalPath',   'describe.nMeas', ...
        'newCalPath',   'describe.nMeas', ...
        'access',       'read_only'...
    );

    obj.fieldMap('bgColor') = struct(...
        'propertyName', 'describe___bgColor', ...
        'oldCalPath',   'bgColor', ...
        'newCalPath',   'describe.bgColor', ...
        'access',       'read_only'...
    );

    obj.fieldMap('fgColor') = struct(...
        'propertyName', 'describe___fgColor', ...
        'oldCalPath',   'fgColor', ...
        'newCalPath',   'describe.fgColor', ...
        'access',       'read_only'...
    );

    obj.fieldMap('usebitspp') = struct(...
        'propertyName', 'describe___useBitsPP', ...
        'oldCalPath',   'usebitspp', ...
        'newCalPath',   'describe.useBitsPP', ...
        'access',       'read_only'...
    );

    
    obj.fieldMap('nDevices') = struct(...
        'propertyName', 'describe___displayPrimariesNum', ...
        'oldCalPath',   'nDevices', ...
        'newCalPath',   'describe.displayPrimariesNum', ...
        'access',       'read_only'...
    );

    obj.fieldMap('nPrimaryBases') = struct(...
        'propertyName', 'describe___primaryBasesNum', ...
        'oldCalPath',   'nPrimaryBases', ...
        'newCalPath',   'describe.primaryBasesNum', ...
        'access',       'read_write'...
    );

    
    % Gamma-fit params
    obj.fieldMap('gamma') = struct(...
        'propertyName', 'describe___gamma', ...
        'oldCalPath',   'describe.gamma', ...
        'newCalPath',   'describe.gamma', ...
        'access',       'read_write'...
    );

    obj.fieldMap('gamma.fitType') = struct(...
        'propertyName', 'describe___gamma___fitType', ...
        'oldCalPath',   'describe.gamma.fitType', ...
        'newCalPath',   'describe.gamma.fitType', ...
        'access',       'read_write'...
    );

    obj.fieldMap('gamma.exponents') = struct(...
         'propertyName', 'describe___gamma___exponents', ...
         'oldCalPath',   'describe.gamma.exponents', ...
         'newCalPath',   'describe.gamma.exponents', ...
         'access',       'read_only'...
    );


    % Radiometer params
    obj.fieldMap('leaveRoomTime') = struct(...
        'propertyName', 'describe___leaveRoomTime', ...
        'oldCalPath',   'describe.leaveRoomTime', ...
        'newCalPath',   'describe.leaveRoomTime', ...
        'access',       'read_only'...
    );

    % Radiometer params
    obj.fieldMap('meterDistance') = struct(...
        'propertyName', 'describe___meterDistance', ...
        'oldCalPath',   'describe.meterDistance', ...
        'newCalPath',   'describe.meterDistance', ...
        'access',       'read_only'...
    );


    obj.fieldMap('whichMeterType') = struct(...
        'propertyName', 'describe___meterModel', ...
        'oldCalPath',   'describe.whichMeterType', ...
        'newCalPath',   'describe.meterModel', ...
        'newToOldConversionFname',  @obj.MeterTypeConversion,...  % Meter model string (in new-style) vs. a number (in old-style), so supply conversion function
        'access',       'read_only'...
    );

    obj.fieldMap('meterSerialNumber') = struct(...
        'propertyName', 'describe___meterSerialNumber', ...
        'oldCalPath',    '', ...                                  % only in new-style cal, so do not export in old-style cal
        'newCalPath',   'describe.meterSerialNumber', ...
        'access',       'read_only'...
    );


    % Raw data (gamma measurements)
    obj.fieldMap('S') = struct(...
        'propertyName', 'rawData___S', ...
        'oldCalPath',   'describe.S', ...
        'newCalPath',   'rawData.S', ...
        'access',       'read_only'...
    );

    obj.fieldMap('monIndex') = struct(...
        'propertyName', 'rawData___gammaCurveSortIndices', ...
        'oldCalPath',   'rawdata.monIndex', ...
        'newCalPath',   'rawData.gammaCurveSortIndices', ...
        'newToOldConversionFname',  @obj.MonIndexConversion,...  % data are packed differently in new-style cal, so supply conversion function
        'access',       'read_only'...
    );

    obj.fieldMap('monSpd') = struct(...
        'propertyName', 'rawData___gammaCurveMeasurements', ...
        'oldCalPath',   'rawdata.monSpd', ...
        'newCalPath',   'rawData.gammaCurveMeasurements', ...
        'newToOldConversionFname',  @obj.MonSpdConversion,...  % data are packed differently in new-style cal, so supply conversion function
        'access',       'read_only'...
    );

    obj.fieldMap('mon') = struct(...
        'propertyName', 'rawData___gammaCurveMeanMeasurements', ...
        'oldCalPath',   'rawdata.mon', ...
        'newCalPath',   'rawData.gammaCurveMeanMeasurements', ...
        'newToOldConversionFname',  @obj.MonConversion,...  % data are packed differently in new-style cal, so supply conversion function
        'access',       'read_only'...
    );

    obj.fieldMap('rawGammaInput') = struct(...
        'propertyName', 'rawData___gammaInput', ...
        'oldCalPath',   'rawdata.rawGammaInput', ...
        'newCalPath',   'rawData.gammaInput', ...
        'newToOldConversionFname',  @obj.GammaInputConversion,...  % data are packed differently in new-style cal, so supply conversion function
        'access',       'read_only'...
    );

    obj.fieldMap('rawGammaTable') = struct(...
        'propertyName', 'rawData___gammaTable', ...
        'oldCalPath',   'rawdata.rawGammaTable', ...
        'newCalPath',   'rawData.gammaTable', ...
        'access',       'read_only'...
    );
        
    
    % RawData (basic linearity measurements)
    obj.fieldMap('basicmeas.settings') = struct(...
        'propertyName', 'basicLinearitySetup___settings', ...
        'oldCalPath',   'basicmeas.settings', ...
        'newCalPath',   'basicLinearitySetup.settings', ...
        'access',       'read_only'...
    );

    obj.fieldMap('basicmeas.spectra1') = struct(...
        'propertyName', 'rawData___basicLinearityMeasurements1', ...
        'oldCalPath',   'basicmeas.spectra1', ...
        'newCalPath',   'rawData.basicLinearityMeasurements1', ...
        'newToOldConversionFname',  @obj.BasicLinSpectraConversion,...  % data are packed differently in new-style cal, so supply conversion function
        'access',       'read_only'...
    );

    obj.fieldMap('basicmeas.spectra2') = struct(...
        'propertyName', 'rawData___basicLinearityMeasurements2', ...
        'oldCalPath',   'basicmeas.spectra2', ...
        'newCalPath',   'rawData.basicLinearityMeasurements2', ...
        'newToOldConversionFname',  @obj.BasicLinSpectraConversion,...  % data are packed differently in new-style cal, so supply conversion function
        'access',       'read_only'...
    );


    % RawData (background-dependence measurements)
    obj.fieldMap('bgmeas.settings') = struct(...
        'propertyName', 'backgroundDependenceSetup___settings', ...
        'oldCalPath',   'bgmeas.settings', ...
        'newCalPath',   'backgroundDependenceSetup.settings', ...
        'access',       'read_only'...
    );

    obj.fieldMap('bgmeas.bgSettings') = struct(...
        'propertyName', 'backgroundDependenceSetup___bgSettings', ...
        'oldCalPath',   'bgmeas.bgSettings', ...
        'newCalPath',   'backgroundDependenceSetup.bgSettings', ...
        'access',       'read_only'...
    );

    obj.fieldMap('bgmeas.spectra') = struct(...
        'propertyName', 'rawData___backgroundDependenceMeasurements', ...
        'oldCalPath',   'bgmeas.spectra', ...
        'newCalPath',   'rawData.backgroundDependenceMeasurements', ...
        'newToOldConversionFname',  @obj.BGspectraConversion,...  % data are packed differently in new-style cal, so supply conversion function
        'access',       'read_only'...
    );


    % RawData (background-dependence measurements)
    obj.fieldMap('ambient.spectra') = struct(...
        'propertyName',  'rawData___ambientMeasurements', ...
        'oldCalPath',    '', ...                                % only in new-style cal, so do not export in old-style cal
        'newCalPath',    'rawData.ambientMeasurements', ...
        'access',        'read_only'...
        );
    
    
    % ProcessedData
    obj.fieldMap('monSVs') = struct(...
        'propertyName', 'processedData___monSVs', ...
        'oldCalPath',   'rawdata.monSVs', ...
        'newCalPath',   'processedData.monSVs', ...
        'access',       'read_only'...
    );

    obj.fieldMap('gammaFormat') = struct(...
        'propertyName', 'processedData___gammaFormat', ...
        'oldCalPath',   'gammaFormat', ...
        'newCalPath',   'processedData.gammaFormat', ...
        'access',       'read_only'...
    );

    obj.fieldMap('gammaInput') = struct(...
        'propertyName', 'processedData___gammaInput', ...
        'oldCalPath',   'gammaInput', ...
        'newCalPath',   'processedData.gammaInput', ...
        'access',       'read_only'...
    );

    obj.fieldMap('gammaTable') = struct(...
        'propertyName', 'processedData___gammaTable', ...
        'oldCalPath',   'gammaTable', ...
        'newCalPath',   'processedData.gammaTable', ...
        'access',       'read_only'...
    );

    obj.fieldMap('S_device') = struct(...
        'propertyName', 'processedData___S_device', ...
        'oldCalPath',   'S_device', ...
        'newCalPath',   'processedData.S_device', ...
        'access',       'read_write'...
    );

    obj.fieldMap('P_device') = struct(...
        'propertyName', 'processedData___P_device', ...
        'oldCalPath',   'P_device', ...
        'newCalPath',   'processedData.P_device', ...
        'access',       'read_only'...
    );

    obj.fieldMap('T_device') = struct(...
        'propertyName', 'processedData___T_device', ...
        'oldCalPath',   'T_device', ...
        'newCalPath',   'processedData.T_device', ...
        'access',       'read_only'...
    );

    obj.fieldMap('S_ambient') = struct(...
        'propertyName', 'processedData___S_ambient', ...
        'oldCalPath',   'S_ambient', ...
        'newCalPath',   'processedData.S_ambient', ...
        'access',       'read_only'...
    );

    obj.fieldMap('P_ambient') = struct(...
        'propertyName', 'processedData___P_ambient', ...
        'oldCalPath',   'P_ambient', ...
        'newCalPath',   'processedData.P_ambient', ...
        'access',       'read_only'...
    );

    obj.fieldMap('T_ambient') = struct(...
        'propertyName', 'processedData___T_ambient', ...
        'oldCalPath',   'T_ambient', ...
        'newCalPath',   'processedData.T_ambient', ...
        'access',       'read_only'...
    );
        

    % RuntimeData
    obj.fieldMap('gammaMode') = struct(...
        'propertyName', 'runtimeData___gammaMode', ...
        'oldCalPath',   'gammaMode', ...
        'newCalPath',   'runtimeData.gammaMode', ...
        'access',       'read_write'...
    );


    obj.fieldMap('iGammaTable') = struct(...
        'propertyName', 'runtimeData___iGammaTable', ...
        'oldCalPath',   'iGammaTable', ...
        'newCalPath',   'runtimeData.iGammaTable', ...
        'access',       'read_write'...
    );


    obj.fieldMap('T_sensor') = struct(...
        'propertyName', 'runtimeData___T_sensor', ...
        'oldCalPath',   'T_sensor', ...
        'newCalPath',   'runtimeData.T_sensor', ...
        'access',       'read_write'...
    );

    obj.fieldMap('S_sensor') = struct(...
        'propertyName', 'runtimeData___S_sensor', ...
        'oldCalPath',   'S_sensor', ...
        'newCalPath',   'runtimeData.S_sensor', ...
        'access',       'read_write'...
    );

    obj.fieldMap('T_linear') = struct(...
        'propertyName', 'runtimeData___T_linear', ...
        'oldCalPath',   'T_linear', ...
        'newCalPath',   'runtimeData.T_linear', ...
        'access',       'read_write'...
    );

    obj.fieldMap('S_linear') = struct(...
        'propertyName', 'runtimeData___S_linear', ...
        'oldCalPath',   'S_linear', ...
        'newCalPath',   'runtimeData.S_linear', ...
        'access',       'read_write'...
    );

    obj.fieldMap('M_device_linear') = struct(...
        'propertyName', 'runtimeData___M_device_linear', ...
        'oldCalPath',   'M_device_linear', ...
        'newCalPath',   'runtimeData.M_device_linear', ...
        'access',       'read_write'...
    );
    
    obj.fieldMap('M_linear_device') = struct(...
        'propertyName', 'runtimeData___M_linear_device', ...
        'oldCalPath',   'M_linear_device', ...
        'newCalPath',   'runtimeData.M_linear_device', ...
        'access',       'read_write'...
    );

    obj.fieldMap('M_ambient_linear') = struct(...
        'propertyName', 'runtimeData___M_ambient_linear', ...
        'oldCalPath',   'M_ambient_linear', ...
        'newCalPath',   'runtimeData.M_ambient_linear', ...
        'access',       'read_write'...
    );

    obj.fieldMap('ambient_linear') = struct(...
        'propertyName', 'runtimeData___ambient_linear', ...
        'oldCalPath',   'ambient_linear', ...
        'newCalPath',   'runtimeData.ambient_linear', ...
        'access',       'read_write'...
    );


end