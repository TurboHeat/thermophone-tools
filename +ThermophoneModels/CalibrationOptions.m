classdef CalibrationOptions < handle
  % CALIBRATIONOPTIONS Simple data class for holding the calibration options
  
  properties (GetAccess = public, SetAccess = private)
    % TODO: add ref for default values.
    Mic (1,1) double    = 3.41; % Microphone calibration [mV/Pa]
    Acc (1,1) double    = 10.2; % Accelerometer calibration [mV/m/s2]
    % Thermopile calibration (https://turbo-heat.slack.com/archives/C010AC9H00K/p1592300175039700):
    Scalib (1,1) double = 1.36E-6; % Calibration for the temperature dependece [V/(W/m2)]
    Tcalib (1,1) double = NaN; % "overall" calibration [?] 
    P (1,1) double      = 0.16E5; % Pressure sensor calibration [Pa/V]
  end
  
  methods (Access = public)
    
    function optsObj = CalibrationOptions(optsKW)
      arguments
        optsKW.Mic
        optsKW.Acc
        optsKW.Scalib        
        optsKW.P
      end
      
      % Copy field contents into object properties
      fn = fieldnames(optsKW);
      for idxF = 1:numel(fn)
        optsObj.(fn{idxF}) = optsKW.(fn{idxF});
      end
    end
    
    function setT_A(coObj, T_A_in_C)
      arguments
        coObj (1,1) ThermophoneModels.CalibrationOptions
        T_A_in_C (1,1) double {mustBeNonNan} = NaN
      end
      coObj.Tcalib = (0.00334 * T_A_in_C + 0.917) * coObj.Scalib;
    end
    
    function [Tpile, P0, T0] = applyToData(coObj, Tpile, P0, T_A_in_C)
      % This function applies the calibrations to data
      %% Input handling
      narginchk(3,4);
      if nargin == 4, coObj.setT_A(T_A_in_C); end
      assert(~isnan(coObj.Tcalib), 'T_A must not be NaN!')  
      
      %% Computation
      Tpile = coObj.Tcalib * Tpile; % Thermopile [V]
      REF_P = 101325; % Temporary reference pressure
      P0 = (P0 * coObj.P) + REF_P; % [Pa]
      T0 = T_A_in_C + 273.15; % Temperature [°C]->[K]
    end
    
  end
  
end