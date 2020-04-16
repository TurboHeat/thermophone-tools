classdef ThermophoneLayer < Layer_models.Layer
  %THERMOPHONELAYER A layer representing the electrically conductive material where
  %power is put in.
  
  properties (GetAccess = public, SetAccess = public)
    % Subclass-specific properties
    
  end % properties
  
  methods (Access = public)
    %% Constructor
    function layerObj = ThermophoneLayer(props)
      arguments
        props.?Layer_models.ThermophoneLayer
      end
      
      % Create superclass:
      propsKV = namedargs2cell(props);
      layerObj = layerObj@Layer_models.Layer(propsKV{:});
      
      % Custom modifications:
      
    end % constructor
    
  end % public methods
end % classdef