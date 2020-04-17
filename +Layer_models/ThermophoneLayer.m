classdef ThermophoneLayer < Layer_models.Layer
  %THERMOPHONELAYER A layer representing the electrically conductive material where
  %power is put in.
  
  properties (GetAccess = public, SetAccess = public)
    % Subclass-specific properties
    % Young's modulus [Pa]:
    Y(1,1) double {mustBeNonempty} = NaN
  end % properties
  
  methods (Access = public)
    %% Constructor
    function layerObj = ThermophoneLayer(props)
      arguments
        props.?Layer_models.ThermophoneLayer
      end
      
      %% Special initialization:
      if ~isfield(props, 'lambda') && isfield(props, 'Y') && isfield(props, 'B')
        props.lambda = 3 * props.B * (3 * props.B - props.Y) / (9 * props.B - props.Y);
      end
      if ~isfield(props, 'mu') && isfield(props, 'lambda') && isfield(props, 'B')
        props.mu = (3 / 2) * (props.B - props.lambda);
      end
      
      %% Create superclass:
      propsKV = namedargs2cell(rmfield(props, 'Y'));
      layerObj = layerObj@Layer_models.Layer(propsKV{:});
      
      %% Custom modifications:
      % Bring back the field(s) not passed to the superclass constructor
      if isfield(props, 'Y')
        layerObj.Y = props.Y;
      end
      
    end % constructor
    
  end % public methods
  
  %% Setters & Getters
  methods
    
    function set.Y(obj, val)
      obj.(Layer_models.Layer.protectedSet(dbstack('-completenames'))) = val;
    end
    
  end
end % classdef