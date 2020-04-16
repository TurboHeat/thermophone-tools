classdef InsulationLayer < Layer_models.Layer
  %INSULATIONLAYER A layer whose sole purpose is to provide electrical insulation
  %between a thermophone layer and another layer.

  properties (GetAccess = public, SetAccess = public)
    % Subclass-specific properties
    
  end % properties
  
  methods (Access = public)
    %% Constructor
    function layerObj = InsulationLayer(props)
      arguments
        props.?Layer_models.InsulationLayer
      end
      
      % Create superclass:
      propsKV = namedargs2cell(props);
      layerObj = layerObj@Layer_models.Layer(propsKV{:});
      
      % Custom modifications:
      
    end % constructor
    
  end % public methods
end % classdef