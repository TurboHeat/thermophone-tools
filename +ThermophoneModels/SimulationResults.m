classdef SimulationResults < ThermophoneModels.Results
  % THERMOPHONESIMRESULTS Simple data class for holding simulation results
  
  properties (GetAccess = public, SetAccess = protected)
    ETA2     % Array of efficiencies from front side [thermal product, thermal, acoustic, gamma, total]
    PRES2    % Array of pressures from back side [pk Far Field, rms Far Field, rms Near Field, Phase]
    T        % Oscillating Temperature result at interrogation point(s)
    q        % Oscillating Heat-flux result at interrogation point(s)
    v        % Oscillating velocity result at interrogation point(s)
    p        % Oscillating pressure result at interrogation point(s)
    T_m      % Steady-State Mean temperature at interrogation point(s)
    T_Mm     % Steady-State Mean temperature at Layer boundaries
    Posx     % X-location array
  end
  
  methods (Access = public)
    
    function optsObj = SimulationResults(optsKW)
      arguments % must contain ALL properties (including superclass')
        optsKW.ETA1
        optsKW.ETA2
        optsKW.PRES1
        optsKW.PRES2
        optsKW.T
        optsKW.q
        optsKW.v
        optsKW.p
        optsKW.TM
        optsKW.qM
        optsKW.vM
        optsKW.pM
        optsKW.T_m
        optsKW.T_Mm
        optsKW.Omega
        optsKW.Posx
        optsKW.cumLo
        optsKW.layers
      end
      
      % Copy field contents into object properties
      fn = fieldnames(optsKW);
      for idxF = 1:numel(fn)
        optsObj.(fn{idxF}) = optsKW.(fn{idxF});
      end
    end
    
  end
  
end