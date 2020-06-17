classdef BaseLayer < ThermophoneModels.Layers.Layer
  %BASELAYER A solid layer that is situated at the very bottom of a thermophone,
  %stack and is therefore modelled as a semi-infinite layer.
  
  properties (GetAccess = public, SetAccess = public)
    % Subclass-specific properties
    
  end % properties
  
  methods (Access = public)
    %% Constructor
    function layerObj = BaseLayer(props)
      arguments
        props.?ThermophoneModels.Layers.BaseLayer
      end
      
      % Create superclass:
      propsKV = namedargs2cell(props);
      layerObj = layerObj@ThermophoneModels.Layers.Layer(propsKV{:});
      
      % Custom modifications:
      
    end % constructor
    
  end % public methods
end % classdef