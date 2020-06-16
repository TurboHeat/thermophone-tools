classdef CalibrationOptions < handle
  % CALIBRATIONOPTIONS Simple data class for holding the calibration options
  
  properties (GetAccess = public, SetAccess = private)
    % TODO: add references for these values:
    Mic (1,1) double  = 3.41;    % Microphone calibration [mV/Pa]
    Acc (1,1) double  = 10.2;    % Accelerometer calibration [mV/m/s2]
    
    % Thermopile (heat flux sensor) calibration 
    %  (https://turbo-heat.slack.com/archives/C010AC9H00K/p1592302486042500):
    S (1,1) double    = 1.36E-6; % Heat flux sensor sensitivity [V/(W/m2)]
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
      coObj.Tcalib = (coObj.MF * T_in_C + coObj.OF) * coObj.S;
    end
    
    function [Tpile, P0, T0] = applyToData(coObj, Tpile, P0, T_in_C)
      % This function applies the calibrations to data
      %% Input handling
      narginchk(3,4);
      if nargin == 4, coObj.setT_A(T_in_C); end
      assert(~isnan(coObj.Tcalib), 'T_A must not be NaN!')  
      
      %% Computation
      Tpile = coObj.Tcal * Tpile; % Thermopile [V]
      REF_P = 101325; % Temporary reference pressure
      P0 = (P0 * coObj.P) + REF_P; % [Pa]
      T0 = T_in_C + 273.15; % Temperature [°C]->[K]
    end
    
  end
  
end