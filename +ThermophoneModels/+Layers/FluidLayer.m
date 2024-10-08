classdef FluidLayer < ThermophoneModels.Layers.Layer
  %FLUIDLAYER A layer representing some gas/liquid in which sound propagtes
  % This is the only type of layer where lambda and mu cannot be set to 0.
  
  properties (GetAccess = public, SetAccess = public)
    % Subclass-specific properties
    
  end % properties
  
  methods (Access = public)
    %% Constructor
    function layerObj = FluidLayer(props)
      arguments
        props.?ThermophoneModels.Layers.FluidLayer
      end
      
      % Create superclass:
      propsKV = namedargs2cell(props);
      layerObj = layerObj@ThermophoneModels.Layers.Layer(propsKV{:});
      
      % Custom modifications:
      
    end % constructor
    
  end % public methods
end % classdef