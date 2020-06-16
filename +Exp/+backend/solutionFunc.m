function [results] = solutionFuncEXP(layers, simConfigMat, expfilenames)

%% Preliminary computations
nLayers = numel(layers);
MDM = layers.toMatrix();

%% Cumulative thickness
cumLo = layers.getCumulativeThickness();
cumLo = [cumLo(1); cumLo]; % fix for indexing in the boundary conditions calculation later

%% ==================================================================== %%
% Loading the experimental data
[MIC, ACC, Va, Vb, Vc, datapoints] = Exp.backend.loadData(expfilenames);

% Number of omega-interrogation points
Omega = 2 * pi * Datapoints(1, 15);

%Updating the generation with the experimental data
[Sth] = Backend.inputpowercalc(Va, Vb, Vc, Datapoints);
MDM(simConfigMat(12), 11) = Sth / (MDM(simConfigMat(12), 1) * simConfigMat(1) * simConfigMat(2));

%% Minimum distance between points: min_dis=2*pi*c/(5*omega)
% for correct resolution of discrete point source pressure propagation
% calculation there needs to be enough point mesh density
min_dis = max(2*pi*sqrt(MDM(1, 3) * MDM(1, 7) / (MDM(1, 2) * MDM(1, 8)))/(5 * Omega(end)), ...
    2*pi*sqrt(MDM(nLayers, 3) * MDM(nLayers, 7) / (MDM(nLayers, 2) * MDM(nLayers, 8)))/(5 * Omega(end)));

% To be on the safe side, take a minimum of 100x100 points
Ny = max(100, round(simConfigMat(1) / min_dis)); % Number of point sources in width
Nz = max(100, round(simConfigMat(2) / min_dis)); % Number of point sources in length

% Variable initialisation
[pM, TM, vM, qM] = deal(zeros(1, nLayers + 1));
% T_m  - x-positions
% T_Mm - Boundary layer interface positions

% Using mp toolbox, we convert the key datatypes to mp
MDMmp = mp(MDM);
Omegamp = mp(Omega);
cumLomp = mp(cumLo);

%% Looking for frequency
% Create local variables
[lpM, lTM, lvM, lqM, lT_Mm] = deal(complex(zeros(1, nLayers + 1)));

% Function that solves the boundary conditions dan finds the matrix of constants (solutions) for each layer
[BCI, Hamat, w1_c, ~, Smat, Hbmat, SCALE] = Backend.systemSolver(Omegamp, MDMmp, nLayers, cumLomp);

%% ==================================================================== %%

for que = simConfigMat(12):simConfigMat(12) + 2 % x-position loop
    % Finding the solution at the boundary interfaces either side of the
    % thermophone layer
    field = Backend.interrogationOptim(Hamat, Hbmat, Smat, cumLo, que, nLayers, BCI, SCALE);
    lpM(que) = field(1, :);
    lvM(que) = field(2, :);
    lqM(que) = field(3, :);
    lTM(que) = field(4, :);
    lT_Mm(que) = field(5, :);
end

%% At the maximum velocity position in the first and last layers (thermal thickness)
% These are needed to determine the propagation from the front and back
% boundaries

field = Backend.interrogationOptim(Hamat, Hbmat, Smat, cumLo, ...
    cumLo(1)-(2 * (MDM(1, 9) / (2 * MDM(1, 7) * Omega * MDM(1, 2)))^0.5), nLayers, BCI, SCALE);
lpM(1) = field(1, :);
lvM(1) = field(2, :);
lqM(1) = field(3, :);
lTM(1) = field(4, :);

%% ==================================================================== %%
% Assign iteration results into main matrices:
pM(1, :) = lpM;
vM(1, :) = lvM;
qM(1, :) = lqM;
TM(1, :) = lTM;

% Decay coefficient for the propagation calculation
kay1 = double(w1_c(1));
kay2 = double(w1_c(end));

% Calculation of the various efficiency parameters (OPTIONAL!)
[eta_TP_1, ~, eta_Therm, ...
    eta_aco_1, ~, ...
    eta_Conv_1, ~, ...
    eta_Tot_1, ~] = ...
    Backend.efficiencyCalc(qM, vM, simConfigMat(12), nLayers, ...
    sum(MDM(:, 1) .* MDM(:, +10:+12), 'all', 'omitnan'), MDM);

% Array with all the different efficiency calculations collated together
ETA1 = [eta_TP_1, eta_Therm, eta_aco_1, ones(size(eta_aco_1)) .* eta_Conv_1, eta_Tot_1];

% Calculation of the acoustic propagation
[Mag_Pff_1, Mag_Prms_ff_1, Mag_Prms_nf_ff_1, Ph_Pff_1, ...
    ~, ~, ~, ~] = ...
    Backend.rayleighFunc(Ny, Nz, simConfigMat, MDM, kay1, kay2, vM, cumLo, 1, Omega);

%% ---------------------------------------------------------%%
% Calibration of instruments
[MIC, ACC, Tpile, P0, T0] = Backend.calibfunc(MIC, ACC, Datapoints(:, 2), Datapoints(1, 5), Datapoints(1, 3));

%% ---------------------------------------------------------%%
% Calculation of experimentally measured rms sound pressure
[Mag_Prms_EXP, ~] = Backend.Discrete_Fourier_transform(MIC, Datapoints(1, 13:16));

%% Check for Bugs
%Mag_Prms_EXP=Mag_Prms_ff_1;
%Mag_Prms_ff_1
% 20*log10(Mag_Prms_ff_1/(2*10^-5))
% 20*log10(Mag_Prms_EXP/(2*10^-5))

%%

% Calculation of experimentally measured rms sound pressure
[Mag_ACCrms_EXP, acc_freq] = Backend.Discrete_Fourier_transform(ACC, Datapoints(1, 13:16));

%Mag_Prms_EXP=Mag_Prms_ff_1; %for testing purposes

%% ---------------------------------------------------------%%
% Inverse calculation of acoustic propagation and determination of boundary
%heat-flux, pressure and temperature oscillations. Velocity measure is at
%Lth location.
[~, V_front, Q_front, ~] = ...
    Exp.backend.inverseRayleighFunc(Ny, Nz, simConfigMat, MDM, kay1, kay2, Mag_Prms_EXP, cumLo, 1, Omega, Hamat, Hbmat, SCALE, BCI, vM);

% Calculating vibroacoustic energy input
[W_front, V_rms, Jth, Jv, Ratio_pred] = Backend.vibroFunc(P0, T0, simConfigMat, MDM, Mag_ACCrms_EXP, 2*pi*acc_freq, V_front);

% Calculating heat flux (per unit area) out front from the thermopile data
Q_thpilefront = (Sth / (simConfigMat(1) * simConfigMat(2))) - Tpile(1); %taking the first thermopile reading

%% ---------------------------------------------------------%%

%% Checking ratio
ndQ = Jth * abs(Q_front);
ndV = Jv * abs(V_rms);
Ratio1 = ndQ / ndV;

%% Ratio of Power per unit area
Ratio2 = abs(Q_front) / (2 * abs(W_front));

% Array with all the different Pressure calculations collated together
PRES1 = [Mag_Pff_1.', Mag_Prms_ff_1.', Mag_Prms_nf_ff_1.', Ph_Pff_1.'];

Ratio = [Ratio_pred, Ratio1, Ratio2]

%% Create output object
results = ThermophoneEXPResults("ETA1", ETA1, "PRES1", PRES1, ...
    "TM", TM, "qM", qM, "vM", vM, "pM", pM, "Omega", Omega, "cumLo", cumLo, "layers", layers, ...
    "PQ", Q_front, "PW", W_front, "Ratio", Ratio, "VQ", V_front, "VW", V_rms);
%{
ETA1     - Array of efficiencies from back side [thermal product, thermal, acoustic, gamma, total]
PRES1    - Array of pressures from front side [pk Far Field, rms Far Field, rms Near Field, Phase]
TM       - Oscillating Temperature result at Layer boundaries
qM       - Oscillating Heat-flux result at Layer boundaries
vM       - Oscillating velocity result at Layer boundaries
pM       - Oscillating pressure result at Layer boundaries
Omega    - Angular frequency array
cumLo    - Cumulative layer thickness
layers   - Layers (vector) used in this simulation
    %}
end