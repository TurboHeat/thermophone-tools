function [Mcalib, Acalib, Tcalib, Pcalib] = getCalibOpts(Tc)

%% Sensor calibration parameters
%Microphone calibration
Mcalib = 3.41; %mV/Pa
%Accelerometer calibration
Acalib = 10.2; %mV/m/s2
%Thermopile calibration
Scalib = (1.36 * 10^-6); %V/(W/m2)
Tcalib = (0.00334 * Tc + 0.917) * Scalib;
%Pressure sensor calibration
Pcalib = 0.16 * 100000; %Pa/V
end