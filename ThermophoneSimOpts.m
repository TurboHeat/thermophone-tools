classdef ThermophoneSimOpts
  % THERMOPHONESIMOPTS Simple data class for holding simulation settings
  
  properties (Access = public)
    %% Thermophone dimensions
    Ly(1,1) double {mustBeNonnegative} = 0.01; % [m]
    Lz(1,1) double {mustBeNonnegative} = 0.01; % [m]
    %% Microphone location [x_int,y_int,z_int]
    x_int(1,1) double {mustBeReal, mustBeFinite} = 0.05; % [m]
    y_int(1,1) double {mustBeReal, mustBeFinite} = 0;    % [m]
    z_int(1,1) double {mustBeReal, mustBeFinite} = 0;    % [m]
    %% Frequency sweep
    OmegaF(1,1) double {mustBeNonnegative, mustBeFinite} = 200 * 2 * pi;   % [rad/s]
    OmegaL(1,1) double {mustBeNonnegative, mustBeFinite} = 50000 * 2 * pi; % [rad/s]
    N_Omega(1,1) uint16 {mustBeInteger} = 300; % [unitless]
    %% x-location sweep
    maxX(1,1) double {mustBeNonnegative, mustBeFinite} = 20 * 10^-7; % [m]
    N_x(1,1) uint16 {mustBePositive, mustBeInteger} = 1000; % [unitless]
    %% Switches / flags
    xres(1,1) logical = true; % switch for calculating spatial information (only really needed for in-depth analysis)
    optim(1,1) logical = false; % are you performing an optimization analysis?
    %% Initial Ambient temperature
    T_amb(1,1) double {mustBeNonnegative, mustBeFinite} = 3 * 10^2; % [K]
    %% Location of Thermophone layer (used in the efficiency calculation)
    TH_layer_number(1,1) uint8 {mustBePositive, mustBeInteger} = 2; % [1 ... size(MDM,1)]    
  end
  
  methods (Access = public)

    function optsObj = ThermophoneSimOpts(optsKW)
      arguments
        optsKW.?ThermophoneSimOpts
      end
      
      % Copy field contents into object properties
      fn = fieldnames(optsKW);
      for idxF = 1:numel(fn)
        optsObj.(fn{idxF}) = props.(fn{idxF});
      end      
    end
    
    function out = toMatrix(obj)
      % !! Temporary function !! until the solver function is refactored to use object
      % fields directly.
      mustBeScalarOrEmpty(obj);
      out = [obj.Ly, obj.Lz, obj.x_int, obj.y_int, obj.z_int, obj.OmegaF, ...
             obj.OmegaL, double(obj.N_Omega), obj.maxX, double(obj.N_x), obj.T_amb,...
             double(obj.TH_layer_number), obj.xres, obj.optim];
    end
  end
  
end