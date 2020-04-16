classdef SubstrateLayer < Layer_models.Layer
  %SUBSTRATELAYER The substrate layer is any other non-thermophone layer that 
  %provides a structural base upon which thermophone layers are built.

  properties (GetAccess = public, SetAccess = public)
    % Subclass-specific properties
    
  end % properties
  
  methods (Access = public)
    %% Constructor
    function layerObj = SubstrateLayer(props)
      arguments
        props.?Layer_models.SubstrateLayer
      end
      
      % Create superclass:
      propsKV = namedargs2cell(props);
      layerObj = layerObj@Layer_models.Layer(propsKV{:});
      
      % Custom modifications:
      
    end % constructor
    
  end % public methods
end % classdef