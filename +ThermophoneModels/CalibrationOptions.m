classdef CalibrationOptions < handle
  % CALIBRATIONOPTIONS Simple data class for holding the calibration options
  
  properties (GetAccess = public, SetAccess = private)
    % The values below were taken from \\TurboLab\Laboratory Administration\Manuals\...
    % ...\Heat Exchanger Test Rig\G.R.A.S Microphone\Microphone - Calibration Chart.pdf:
    Mic (1,1) double  = 3.41;    % Microphone calibration [mV/Pa]
    % ...Thermophone\\Wilcoxon‏ Accelerometer 736\Calibration and Data Sheet.pdf:
    Acc (1,1) double  = 10.2;    % Accelerometer sensitivity [mV/m/s2]       
    % ...Thermophone\\Heat Flux Sensor\Calibration‏.pdf:
    S (1,1) double    = 1.36E-6; % Heat flux sensor ("thermopile") sensitivity [V/(W/m2)]
    Tcal (1,1) double = NaN;     % Sensor temperature at time of calibration [C]
    P (1,1) double    = 0.16E5;  % Pressure sensor calibration [Pa/V]    
    MF (1,1) double   = 0.00334; % Sensitivity Multiplication Factor
    OF (1,1) double   = 0.917;   % Sensitivity Offset Factor    
  end
  
  methods (Access = public)
    
    function optsObj = CalibrationOptions(optsKW)
      arguments
        optsKW.Mic
        optsKW.Acc
        optsKW.S     
        optsKW.P
        optsKW.MF
        optsKW.OF
      end
      
      % Copy field contents into object properties
      fn = fieldnames(optsKW);
      for idxF = 1:numel(fn)
        optsObj.(fn{idxF}) = optsKW.(fn{idxF});
      end
    end
    
    function setT_A(coObj, T_in_C)
      % This function sets the calibration temperature according to the manufacturer's 
      %   certificate of calibration.
      arguments
        coObj (1,1) ThermophoneModels.CalibrationOptions
        T_in_C (1,1) double {mustBeNonNan} = NaN
      end
      coObj.Tcal = (coObj.MF * T_in_C + coObj.OF) * coObj.S;
    end
    
    function [Tpile, P0, T0] = applyToData(coObj, Tpile, P0, T_in_C)
      % This function applies the calibrations to data
      %% Input handling
      narginchk(3,4);
      if nargin == 4, coObj.setT_A(T_in_C); end
      assert(~isnan(coObj.Tcal), 'T_A must not be NaN!')  
      
      %% Computation
      Tpile = coObj.Tcal * Tpile; % Thermopile [V]
      REF_P = 101325; % Temporary reference pressure
      P0 = (P0 * coObj.P) + REF_P; % [Pa]
      T0 = T_in_C + 273.15; % Temperature [°C]->[K]
    end
    
    function [calibdMic] = applyToMic(coObj, uncalibdMic)
      calibdMic = uncalibdMic ./ coObj.Mic;
    end
    
    function [calibdAcc] = applyToAcc(coObj, uncalibdAcc)
      calibdAcc = uncalibdAcc ./ coObj.Acc;
    end
      
  end
  
end