function [eta_TP_1, eta_TP_2, eta_Therm, ...
  eta_aco_1, eta_aco_2, ...
  eta_Conv_1, eta_Conv_2, ...
  eta_Tot_1, eta_Tot_2] = ...
  efficiencyCalc(qM, vM, TH_layer_number, nLayers, P_in, MDM)
%% ==================================================================== %%

%% Efficiency Calculation

%% 'Thermal product' efficiency - Across the thermophone layer
eta_TP_1 = (abs(real(qM(:, TH_layer_number)))) ./ (abs(real(qM(:, TH_layer_number))) + abs(real(qM(:, TH_layer_number+1))));
eta_TP_2 = (abs(real(qM(:, TH_layer_number+1)))) ./ (abs(real(qM(:, TH_layer_number))) + abs(real(qM(:, TH_layer_number+1))));

%% 'Thermal' efficiency - Across the thermophone layer
eta_Therm = (abs(real(qM(:, TH_layer_number))) + abs(real(qM(:, TH_layer_number+1)))) ./ P_in;

%% Idealised maximum Acoustic efficiency (radiation ratio = 1)
eta_aco_1 = (sqrt(MDM(1, 3).*MDM(1, 7)./(MDM(1, 8) .* MDM(1, 2))) .* MDM(1, 2) .* abs((vM(:, 1)).^2) ./ 2) ./ (P_in);
eta_aco_2 = (sqrt(MDM(end, 3).*MDM(end, 7)./(MDM(end, 8) .* MDM(end, 2))) .* MDM(end, 2) .* abs((vM(:, nLayers+1)).^2) ./ 2) ./ (P_in);

%% 'Conversion' efficiency - Across all layers
gam1 = MDM(1, 7) / MDM(1, 8);
gam2 = MDM(end, 7) / MDM(end, 8);

Co1 = sqrt(MDM(1, 3)*MDM(1, 7)/(MDM(1, 8) * MDM(1, 2))); % speed of sound
Coth1 = Co1 * sqrt(2*MDM(1, 8)/MDM(1, 7)); % Thermal speed

Co2 = sqrt(MDM(end, 3)*MDM(end, 7)/(MDM(end, 8) * MDM(end, 2))); % speed of sound
Coth2 = Co2 * sqrt(2*MDM(end, 8)/MDM(end, 7)); % Thermal speed

eta_Conv_1 = (2 * (gam1 - 1)) / (gam1); %Gamma ratio
eta_Conv_2 = (2 * (gam2 - 1)) / (gam2); %
​
% The collapse with varying gamma is not perfect, which suggests to me that
% there is more to this expression that is needed. eg.
% (3/2)*(gam-1)/(gam^(3/2)) but this is what Avshalom wrote in the paper.

Jth1 = eta_Conv_1 / (MDM(1, 2) * Coth1^3); % accounting for heat flux non-dimensionalisation
Jth2 = eta_Conv_2 / (MDM(end, 2) * Coth2^3);

gamcoeff1 = Coth1 * Jth1; % accounting for velocity non-dimensionalisation
gamcoeff2 = Coth2 * Jth2;

vqM1 = (gamcoeff1 .* qM(:, TH_layer_number)); %velocity resulting from heat-flux due to gamma
vqM2 = (gamcoeff2 .* qM(:, end-1));

%% 'Total' efficiency - Front and Back
eta_Tot_1 = (sqrt(MDM(1, 3).*MDM(1, 7)./(MDM(1, 8) .* MDM(1, 2))) .* MDM(1, 2) .* abs(vqM1.^2) ./ 2) ./ (P_in);
eta_Tot_2 = (sqrt(MDM(end, 3).*MDM(end, 7)./(MDM(end, 8) .* MDM(end, 2))) .* MDM(end, 2) .* abs((vqM2).^2) ./ 2) ./ (P_in);

end