classdef OtherLayer < LayerModels.Layer
  %OTHERLAYER A layer that doesn't fit in other categories (for e.g. a glue/bonding
  %layer that joins smooth and rough surfaces together).

  properties (GetAccess = public, SetAccess = public)
    % Subclass-specific properties
    
  end % properties
  
  methods (Access = public)
    %% Constructor
    function layerObj = OtherLayer(props)
      arguments
        props.?LayerModels.OtherLayer
      end
      
      % Create superclass:
      propsKV = namedargs2cell(props);
      layerObj = layerObj@LayerModels.Layer(propsKV{:});
      
      % Custom modifications:
      
    end % constructor
    
  end % public methods
end % classdef