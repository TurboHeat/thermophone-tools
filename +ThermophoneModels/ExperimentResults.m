classdef ExperimentResults < ThermophoneModels.Results
  % THERMOPHONESIMRESULTS Simple data class for holding simulation results
  
  properties (GetAccess = public, SetAccess = protected)
    PQ % Power/area delivered by thermophone
    PW % Power/area delivered by Solid-drive
    Ratio % Ratio of powers
    VQ % Thermophone rms velocity of flow at Lth
    VW % Solid drive rms velocity of flow at surface
  end
  
  methods (Access = public)
    
    function optsObj = ExperimentResults(optsKW)
      arguments
        optsKW.ETA1
        optsKW.PRES1
        optsKW.TM
        optsKW.qM
        optsKW.vM
        optsKW.pM
        optsKW.Omega
        optsKW.cumLo
        optsKW.layers
        optsKW.PQ
        optsKW.PW
        optsKW.Ratio
        optsKW.VQ
        optsKW.VW
      end
      
      % Copy field contents into object properties
      fn = fieldnames(optsKW);
      for idxF = 1:numel(fn)
        optsObj.(fn{idxF}) = optsKW.(fn{idxF});
      end
    end
    
  end
  
end