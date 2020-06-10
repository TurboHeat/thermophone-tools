classdef Results < matlab.mixin.CustomDisplay
  % RESULTS Simple data class for holding thermophone-related "results"
  
  properties (GetAccess = public, SetAccess = protected)
    ETA1 % Array of efficiencies from back side [thermal product, thermal, acoustic, gamma, total]
    PRES1 % Array of pressures from front side [pk Far Field, rms Far Field, rms Near Field, Phase]
    TM % Oscillating Temperature result at Layer boundaries
    qM % Oscillating Heat-flux result at Layer boundaries
    vM % Oscillating velocity result at Layer boundaries
    pM % Oscillating pressure result at Layer boundaries
    Omega % Angular frequency array
    cumLo % Cumulative layer thickness
    layers % Layers structure (vector) used in the computation
  end
  
  methods (Access = public)
    
    function optsObj = Results(optsKW)
      arguments
        optsKW.ETA1
        optsKW.PRES1
        optsKW.TM
        optsKW.qM
        optsKW.vM
        optsKW.pM
        optsKW.Omega
        optsKW.cumLo
      end
      
      % Copy field contents into object properties
      fn = fieldnames(optsKW);
      for idxF = 1:numel(fn)
        optsObj.(fn{idxF}) = optsKW.(fn{idxF});
      end
    end
    
  end
  
  methods (Access = protected)
    function propgrp = getPropertyGroups(obj)      
      if isscalar(obj)
        propgrp = matlab.mixin.util.PropertyGroup(sort(string(properties(obj))), '');
      else
        propgrp = matlab.mixin.util.PropertyGroup(sort(string(properties(obj))), '');
      end
    end
  end
  
end