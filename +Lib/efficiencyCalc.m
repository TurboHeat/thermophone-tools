function [eta_TP_1, eta_TP_2, eta_Therm, ...
    eta_aco_1, eta_aco_2, ...
    eta_Conv_1, eta_Conv_2, ...
    eta_Tot_1, eta_Tot_2] = ...
    efficiencyCalc(qM, vM, TH_layer_number, nLayers, P_in, MDM)

%% ==================================================================== %%

%% Boundary Values

% Complex velocity
cVwave = (vM);

%% ==================================================================== %%

%% Efficiency Calculation

%% 'Thermal product' efficiency - Across the thermophone layer
eta_TP_1 = (abs(real(qM(:, TH_layer_number)))) ./ (abs(real(qM(:, TH_layer_number))) + abs(real(qM(:, TH_layer_number + 1))));
eta_TP_2 = (abs(real(qM(:, TH_layer_number + 1)))) ./ (abs(real(qM(:, TH_layer_number))) + abs(real(qM(:, TH_layer_number + 1))));

%% 'Thermal' efficiency - Across the thermophone layer
eta_Therm = (abs(real(qM(:, TH_layer_number))) + abs(real(qM(:, TH_layer_number + 1)))) ./ P_in;

%% Idealised maximum Acoustic efficiency (radiation ratio = 1)
eta_aco_1 = (sqrt(MDM(1, 3) .* MDM(1, 7) ./ (MDM(1, 8) .* MDM(1, 2))) .* MDM(1, 2) .* abs((cVwave(:, 1)).^2) ./ 2) ./ (P_in);
eta_aco_2 = (sqrt(MDM(end, 3) .* MDM(end, 7) ./ (MDM(end, 8) .* MDM(end, 2))) .* MDM(end, 2) .* abs((cVwave(:, nLayers + 1)).^2) ./ 2) ./ (P_in);

%% 'Conversion' efficiency - Across all layers
eta_Conv_1 = ((MDM(1, 7) ./ (MDM(1, 8))) - 1) ./ (MDM(1, 7) ./ (MDM(1, 8)));
eta_Conv_2 = ((MDM(end, 7) ./ (MDM(end, 8))) - 1) ./ (MDM(end, 7) ./ (MDM(end, 8)));

%% 'Total' efficiency - Front and Back
eta_Tot_1 = eta_Conv_1 .* eta_TP_1 .* eta_Therm;
eta_Tot_2 = eta_Conv_2 .* eta_TP_2 .* eta_Therm;
end
