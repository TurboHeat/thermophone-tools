classdef Layer < handle & matlab.mixin.Heterogeneous & matlab.mixin.CustomDisplay
  %LAYER Superclass for all thermophone layer types
  %   <Detailed explanation goes here>
  properties (GetAccess = public, SetAccess = public) % Actually, SetAccess = protected
    %% Thermophysical properties
    % 1) L, Layer thickness [m]:
    L(1,1) double {mustBeNonempty} = NaN
    % 2) ρ, Density [kg m⁻³]:
    rho(1,1) double {mustBeNonempty} = NaN
    % 3) B, Bulk modulus [Pa]:
    B(1,1) double {mustBeNonempty} = NaN
    % 4) α, Coefficient of volumetric expansion [K⁻¹]:
    alpha(1,1) double {mustBeNonempty} = NaN
    % 5) λ, First viscosity coefficient / Lamé first elastic parameter [kg m⁻¹ s⁻¹]:
    lambda(1,1) double {mustBeNonempty} = NaN
    % 6) μ, Second viscosity coefficient / Lamé second elastic parameter [kg m⁻¹ s⁻¹]:
    mu(1,1) double {mustBeNonempty} = NaN
    % 7) cₚ, Specific heat at constant pressure [J kg⁻¹ K⁻¹]:
    Cp(1,1) double {mustBeNonempty} = NaN
    % 8) cᵥ, Specific heat at constant volume [J kg⁻¹ K⁻¹]:
    Cv(1,1) double {mustBeNonempty} = NaN
    % 9) κ, Thermal conductivity [W m⁻¹ K⁻¹]:
    k(1,1) double {mustBeNonempty} = NaN
    %% Forcing parameters
    % 10) Left edge boundary generation [W]:
    sL(1,1) double {mustBeNonempty} = NaN
    % 11) Internal generation [W]:
    s0(1,1) double {mustBeNonempty} = NaN
    % 12) Right edge boundary generation [W]:
    sR(1,1) double {mustBeNonempty} = NaN
    %% Experimental parameters
    % 13) Left edge heat transfer coefficient [W m⁻¹ K⁻²]:
    hL(1,1) double {mustBeNonempty} = NaN
    % 14) Internal mean temperature [K]:
    T0(1,1) double {mustBeNonempty} = NaN
    % 15) Right edge heat transfer coefficient [W m⁻¹ K⁻²]:
    hR(1,1) double {mustBeNonempty} = NaN
  end
  
  properties (Access = public) % These properties don't require setters    
    label(1,1) string {mustBeNonempty} = "DEFAULT NAME"
  end
  
  %% Constructor
  methods (Access = protected)

    function layerObj = Layer(props)
      % A protected/private constructor means this class cannot be instantiated
      % externally, but only through a subclass.
      arguments
        props.?ThermophoneModels.Layers.Layer
      end
      
      %% Special initialization:
      % If T0 was not supplied, compute using equation
      if ~isfield(props, 'T0') && all(isfield(props, {'rho', 'Cp', 'Cv', 'alpha', 'B'}))
        props.T0 = props.rho * (props.Cp - props.Cv) / ((props.alpha^2) * props.B);
      end
      
      %% Copy field contents into object properties
      fn = fieldnames(props);
      for idxF = 1:numel(fn)
        layerObj.(fn{idxF}) = props.(fn{idxF});
      end
    end % constructor
            
  end % protected methods  

  %% Setters & Getters  
  methods
    
    function set.L(obj, val)
      obj.(ThermophoneModels.Layers.Layer.protectedSet(dbstack('-completenames'))) = val;
    end 
    
    function set.rho(obj, val)
      obj.(ThermophoneModels.Layers.Layer.protectedSet(dbstack('-completenames'))) = val;
    end
        
    function set.B(obj, val)
      obj.(ThermophoneModels.Layers.Layer.protectedSet(dbstack('-completenames'))) = val;
    end
        
    function set.alpha(obj, val)
      obj.(ThermophoneModels.Layers.Layer.protectedSet(dbstack('-completenames'))) = val;
    end
        
    function set.mu(obj, val)
      obj.(ThermophoneModels.Layers.Layer.protectedSet(dbstack('-completenames'))) = val;
    end
        
    function set.lambda(obj, val)
      obj.(ThermophoneModels.Layers.Layer.protectedSet(dbstack('-completenames'))) = val;
    end
        
    function set.Cp(obj, val)
      obj.(ThermophoneModels.Layers.Layer.protectedSet(dbstack('-completenames'))) = val;
    end
        
    function set.Cv(obj, val)
      obj.(ThermophoneModels.Layers.Layer.protectedSet(dbstack('-completenames'))) = val;
    end
        
    function set.k(obj, val)
      obj.(ThermophoneModels.Layers.Layer.protectedSet(dbstack('-completenames'))) = val;
    end
        
    function set.sL(obj, val)
      obj.(ThermophoneModels.Layers.Layer.protectedSet(dbstack('-completenames'))) = val;
    end
        
    function set.s0(obj, val)
      obj.(ThermophoneModels.Layers.Layer.protectedSet(dbstack('-completenames'))) = val;
    end
            
    function set.sR(obj, val)
      obj.(ThermophoneModels.Layers.Layer.protectedSet(dbstack('-completenames'))) = val;
    end
            
    function set.hL(obj, val)
      obj.(ThermophoneModels.Layers.Layer.protectedSet(dbstack('-completenames'))) = val;
    end
            
    function set.T0(obj, val)
      obj.(ThermophoneModels.Layers.Layer.protectedSet(dbstack('-completenames'))) = val;
    end
            
    function set.hR(obj, val)
      obj.(ThermophoneModels.Layers.Layer.protectedSet(dbstack('-completenames'))) = val;
    end
    
  end % no-attribute methods

  %% Pseudo-protected implementation
  methods (Access = protected, Static = true)
    function name = protectedSet(callstack)
      name = ThermophoneModels.Layers.Layer.propnameFromCallstack(callstack);
      if ~(ThermophoneModels.Layers.Layer.getCallerMetaclass(callstack(2:end)) <= ?ThermophoneModels.Layers.Layer)
        ThermophoneModels.Layers.Layer.throwUnprotectedAccess(name);
      end
    end
    
    function throwUnprotectedAccess(name)
      throw(MException('Layer:unprotectedPropertyAccess',...
        ['Unable to set "', name, '", as it is a protected property!']));
    end
    
    function mc = getCallerMetaclass(callstack)
      if isempty(callstack)
        mc = ?meta.class;
      else
        [pkg,className,~] = fileparts(callstack(1).file);
        pkg = strrep(extractAfter(pkg, '+'), [filesep '+'], '.');
        if isempty(pkg)
          mc = meta.class.fromName(className);
        else
          mc = meta.class.fromName(strjoin({pkg, className}, '.'));
        end
      end
    end
    
    function name = propnameFromCallstack(callstack)
      [~,~,name] = fileparts(callstack(1).name);
      name = name(2:end); % removing the leading "."
    end
    
  end % protected static methods
  
  %% Actual public methods
  methods (Access = public, Sealed = true)
    function MDM = toMatrix(obj)
      % !! Temporary function !! until the solver function is refactored to use object
      % fields directly.
      MDM = [[obj.L].', [obj.rho].', [obj.B].', [obj.alpha].', [obj.lambda].',...
        [obj.mu].', [obj.Cp].', [obj.Cv].', [obj.k].', [obj.sL].', [obj.s0].', ...
        [obj.sR].', [obj.hL].', [obj.T0].', [obj.hR].'];
    end
    
    function applySimOptions(layers, opts)
      % This function initializes some layer parameters based on the simulation options
      arguments
        layers(:,1) ThermophoneModels.Layers.Layer
        opts(1,1) ThermophoneSimOpts
      end
      
      area = opts.Ly * opts.Lz;
      for indL = 1:numel(layers)
        %% Overall power input:        
        layers(indL).sL = layers(indL).sL / area;
        layers(indL).s0 = layers(indL).s0 / area / layers(indL).L;
        layers(indL).sR = layers(indL).sR / area;
        
        %% Internal mean temperature:
        if layers(indL).T0 == 0
          if layers(indL).Cp == layers(indL).Cv % The case of a solid
            layers(indL).T0 = opts.T_amb;
          else
            layers(indL).T0 = layers(indL).rho * ...
              (layers(indL).Cp - layers(indL).Cv) / ...
              (layers(indL).B * layers(indL).alpha.^2);
          end
        end
      end
      
    end
    
    function ct = getCumulativeThickness(layers)
      L0 = vertcat(layers.L);
      % (Semi-)infinite layers are excluded from the summation
      ct = cumsum( L0 .* isfinite(L0), 'omitnan');
    end
  end
  %% Custom display methods
  methods (Access = protected, Sealed = true)

    function header = getHeader(obj)
      header = getHeader@matlab.mixin.CustomDisplay(obj);
    end
    
    function displayNonScalarObject(obj)
      tab = [table(string(erase(arrayfun(@class, obj, 'UniformOutput', false), 'LayerModels.')), ...
              [obj.label].', 'VariableNames', ["Type", "Label"]), ...
             array2table(obj.toMatrix(), 'VariableNames', ["L", "ρ", "B", "α_T",...
               "λ", "μ", "c_p", "c_v", "κ", "S_L", "S_0", "S_R", "h_L", "T_0", "h_R"])];
      disp(tab);
    end
  end  
  
end % classdef