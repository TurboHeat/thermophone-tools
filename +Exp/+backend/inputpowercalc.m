function [ThermoPwr] = inputpowercalc(Va, Vb, Vc, Datapoints)

%% This code determines the input power to the Thermophone

[Va_rms, Va_f] = Backend.Discrete_Fourier_transform(Va, Datapoints(1, 13:16));
[Vb_rms, Vb_f] = Backend.Discrete_Fourier_transform(Vb, Datapoints(1, 13:16));
[Vc_rms, Vc_f] = Backend.Discrete_Fourier_transform(Vc, Datapoints(1, 13:16));

suntR = Datapoints(1, 8); % Manual input shunt resistance
ShuntVdrop = abs(Va_rms-Vb_rms); % Voltage drop over the shunt
curr1 = ShuntVdrop / suntR; % Current
ThermoR1 = abs((Vb_rms-Vc_rms)) / curr1; % Thermophone resistance

internalR = Datapoints(1, 10); % Manual input amplifier internal resistance
internalVdrop = abs(Va_rms); % Voltage drop over the shunt
curr2 = internalVdrop / internalR; % Current
ThermoR2 = abs((Vb_rms-Vc_rms)) / curr2; % Thermophone resistance

ThermoR = max(ThermoR1, ThermoR2); % selected resistance
curr = min(curr1, curr2); % selected current

ThermoPwr = abs((Vb_rms-Vc_rms)) * curr; %Thermophone power

end