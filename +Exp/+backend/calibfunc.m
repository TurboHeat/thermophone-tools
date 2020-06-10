function [MIC, ACC, Tpile, P0, T0] = calibfunc(MIC, ACC, Tpile, P0, Tc)

%% This code applies the calibrations to the data files
[Mcalib, Acalib, Tcalib, Pcalib] = CalibOpts(Tc);
%
% MIC=MIC/Mcalib; %Mic is in mV
%
% ACC=ACC/Acalib; %Acc is in mV

Tpile = Tcalib * Tpile; %Thermopile is in V

REF_P = 101325; %Temporary reference pressure
P0 = (P0 * Pcalib) + REF_P; %in Pa

T0 = Tc + 273.15; %temperature in Kelvin

end