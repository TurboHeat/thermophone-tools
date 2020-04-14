classdef Layer < handle & matlab.mixin.Heterogeneous
  %LAYER Superclass for other thermophone layer types
  %   <Detailed explanation goes here>
  
  properties (GetAccess = public, SetAccess = protected)
    %% Thermophysical properties
    % Note: the "0" suffix has been omitted from parameter names
    % ρ, Density:
    rho(1,1) {mustBeNonempty}
    % Bulk modulus:
    B(1,1) {mustBeNonempty}
    % Young's modulus:
    Y(1,1) {mustBeNonempty}
    % Coefficient of volumetric expansion:
    alpha(1,1) {mustBeNonempty}
    % μ, First viscosity coefficient / Lamé first elastic parameter:
    mu(1,1) {mustBeNonempty}
    % λ, Second viscosity coefficient / Lamé second elastic parameter:
    lambda(1,1) {mustBeNonempty}
    % cₚ, Specific heat at constant pressure:
    Cp(1,1) {mustBeNonempty}
    % cᵥ, Specific heat at constant volume:
    Cv(1,1) {mustBeNonempty}
    % κ, Thermal conductivity:
    k(1,1) {mustBeNonempty}
    % τ_q, Heat-flux time-lag:
    tauQ(1,1) {mustBeNonempty}
    % τ_T, Temperature time-lag:
    tauT(1,1) {mustBeNonempty}
  end
  
  methods (Access = protected)
    
    function layerObj = Layer(props)
      % A protected/private constructor means this class cannot be instantiated
      % externally, but only through a subclass.
      arguments
        props.rho(1,1) = NaN
        props.B(1,1) = NaN
        props.Y(1,1) = NaN
        props.alpha(1,1) = NaN
        props.mu(1,1) = NaN
        props.lambda(1,1) = NaN
        props.Cp(1,1) = NaN
        props.Cv(1,1) = NaN
        props.k(1,1) = NaN
        props.tauQ(1,1) = NaN
        props.tauT(1,1) = NaN
      end
      
      % Copy field contents (dynamically)
      fn = fieldnames(props);
      for idxF = 1:numel(fn)
        layerObj.(fn{idxF}) = props.(fn{idxF});
      end
    end
  end
  
end