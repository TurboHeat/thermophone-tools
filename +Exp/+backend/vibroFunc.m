function [W_front, V_rms, Jth, Jv, Ratio_pred] = vibroFunc(P0, T0, simConfigMat, MDM, ACC_rms, Omega, V_front)
%{
This code calculates the mechanical work done by the 'solid drive' and also calculates the relevant experimental conditions
%}

%using ideal gas law as an estimate
%method 1
P1 = MDM(1, 2) * (MDM(1, 7) - MDM(1, 8)) * (T0);
%method 2
P2 = MDM(1, 4) * MDM(1, 4) * MDM(1, 3) * (T0) * (T0);

if P0 < 70000 %if the pressure sensor has issues
  % taking the mean of the two methods
  P0 = mean([P1, P2]);
else
  P0 = mean([P0, P1, P2]);
end

Co = sqrt(MDM(1, 3)*MDM(1, 7)/(MDM(1, 8) * MDM(1, 2))); % speed of sound
R = 8.3145; % Universal Gas Constant
Mm = MDM(1, 2) * R * T0 / P0; % molar mass
gam = MDM(1, 7) / MDM(1, 8); % Ratio of specific heats
% http://dx.doi.org/10.1063/1.864095
MFP = (MDM(1, 5) / MDM(1, 2)) * sqrt(pi*Mm/(2 * R * T0)); % Mean Free Path
Coth = Co * sqrt(2*MDM(1, 8)/MDM(1, 7)); % Thermal speed
alfa = MDM(1, 2) * Coth * MFP / MDM(1, 5); % Reynolds number
Pr = MDM(1, 5) * MDM(1, 7) / MDM(1, 9); % Prandtl number
Jth = gam * MFP / (2 * (gam - 1) * alfa * Pr * T0 * MDM(1, 9)); % Thermal Non-dimensionalisation
Jv = 1 / Coth; % Velocity Non-dimensionalisation
Ratio_pred = gam / (gam - 1); % Predicted ratio

G = ACC_rms * sqrt(2) / (Omega^2); % peak displacement

V_pk = G * Omega; % peak velocity
V_rms = V_pk / sqrt(2); % rms velocity
p_rms = MDM(1, 2) * Co * V_rms; % rms Fluctuating pressure

W_front = P0 * V_rms;

%W_front=(V_rms*p_rms/(simConfigMat(1)*simConfigMat(2)))/(simConfigMat(1)*simConfigMat(2)); %Watts per unit area


end