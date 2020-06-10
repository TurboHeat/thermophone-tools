classdef LayerPropEnum < uint8
  % LayerPropEnum is a mapping between the properties of ThermophoneModels.Layers.Layer and their numeric positions
  % This was created as an intermediate refactoring stage
  
  enumeration
    % 1) L, Layer thickness [m]:
    L      (1)
    % 2) ρ, Density [kg m⁻³]:
    rho    (2)
    % 3) B, Bulk modulus [Pa]:
    B      (3)
    % 4) α, Coefficient of volumetric expansion [K⁻¹]:
    alpha  (4)
    % 5) λ, First viscosity coefficient / Lamé first elastic parameter [kg m⁻¹ s⁻¹]:
    lambda (5)
    % 6) μ, Second viscosity coefficient / Lamé second elastic parameter [kg m⁻¹ s⁻¹]:
    mu     (6)
    % 7) cₚ, Specific heat at constant pressure [J kg⁻¹ K⁻¹]:
    Cp     (7)
    % 8) cᵥ, Specific heat at constant volume [J kg⁻¹ K⁻¹]:
    Cv     (8)
    % 9) κ, Thermal conductivity [W m⁻¹ K⁻¹]:
    k      (9)
    %% Forcing parameters
    % 10) Left edge boundary generation [W]:
    sL     (10)
    % 11) Internal generation [W]:
    s0     (11)
    % 12) Right edge boundary generation [W]:
    sR     (12)
    %% Experimental parameters
    % 13) Left edge heat transfer coefficient [W m⁻¹ K⁻²]:
    hL     (13)
    % 14) Internal mean temperature [K]:
    T0     (14)
    % 15) Right edge heat transfer coefficient [W m⁻¹ K⁻²]:
    hR     (15)
  end
  
end