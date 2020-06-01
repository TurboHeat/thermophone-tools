function [results] = solutionFuncOptim(layers, simConfigMat)
%% Preliminary computations
nLayers = numel(layers);
MDM = layers.toMatrix();

%% Constants
TOP = 1; % This represents the top or "first" layer.
BOT = nLayers; % This represents the bottom, or "last" layer.
% Dirty hack so we could use a shorter name ("LP") instead of "LayerModels.LayerPropEnum":
LP = enumeration('LayerModels.LayerPropEnum'); LP = [cellstr(LP), num2cell(LP)].'; LP = struct(LP{:});

%% Cumulative thickness
cumLo = layers.getCumulativeThickness();
cumLo = [cumLo(1); cumLo]; % fix for indexing in the boundary conditions calculation later

%% ==================================================================== %%

%% Determining results at position x, frequency omega
Nq = simConfigMat(10); % Number of x-interrogation points
maxX = simConfigMat(9); % Range of interrogation points

% Array of x-interrogation points
Posx = linspace(-maxX+(max(cumLo(end)) / 2), maxX+(max(cumLo(end)) / 2), Nq);
maxO = simConfigMat(8);
% Number of omega-interrogation points
Omega = (linspace(simConfigMat(6), simConfigMat(7), maxO));

%% Minimum distance between points: min_dis=2*pi*c/(5*omega)
% for correct resolution of discrete point source pressure propagation
% calculation there needs to be enough point mesh density
min_dis = max(2*pi*sqrt(MDM(TOP, LP.B)*MDM(TOP, LP.Cp)/(MDM(TOP, LP.rho) * MDM(TOP, LP.Cv)))/(5 * Omega(end)), ...
              2*pi*sqrt(MDM(BOT, LP.B)*MDM(BOT, LP.Cp)/(MDM(BOT, LP.rho) * MDM(BOT, LP.Cv)))/(5 * Omega(end)));

% To be on the safe side, take a minimum of 100x100 points
Ny = max(100, round(simConfigMat(1)/min_dis)); % Number of point sources in width
Nz = max(100, round(simConfigMat(2)/min_dis)); % Number of point sources in length

% Variable initialisation
[p, q, T, v, T_m] = deal(zeros(maxO, Nq));
[pM, TM, vM, qM, T_Mm] = deal(zeros(maxO, nLayers+1));
% T_m  - x-positions
% T_Mm - Boundary layer interface positions

% Using mp toolbox, we convert the key datatypes to mp
MDMmp = mp(MDM);
Omegamp = mp(Omega);
cumLomp = mp(cumLo);

[kay1, kay2] = deal(zeros(1,maxO));

%% Looking for frequency
% Prepare for parfor:
rhoTop = MDM(TOP, LP.rho);
CpTop = MDM(TOP, LP.Cp);
kTop = MDM(TOP, LP.k);
d13 = simConfigMat(13);

% ppm = ParforProgressbar(maxO, 'showWorkerProgress', true, 'progressBarUpdatePeriod', 0.5);
parfor k = 1:maxO
  % Create local variables
  [lpM, lTM, lvM, lqM, lT_Mm] = deal(complex(zeros(1, nLayers+1)));
  
  % Function that solves the boundary conditions dan finds the matrix of constants (solutions) for each layer
  [BCI, Hamat, w1_c, ~, Smat, Hbmat, SCALE] = Backend.systemSolver(Omegamp(k), MDMmp, nLayers, cumLomp);
  %% ==================================================================== %%
  
    for que = simConfigMat(12):simConfigMat(12)+1 % x-position loop
      % Finding the solution at the boundary interfaces either side of the
      % thermophone layer
      field = Backend.interrogationOptim(Hamat, Hbmat, Smat, cumLo, que, nLayers, BCI, SCALE);
      lpM(que)   = field(1, :);
      lvM(que)   = field(2, :);
      lqM(que)   = field(3, :);
      lTM(que)   = field(4, :);
      lT_Mm(que) = field(5, :);
    end
  
  %% At the maximum velocity position in the first and last layers (thermal thickness)
  % These are needed to determine the propagation from the front and back
  % boundaries
  
  field = Backend.interrogationOptim(Hamat, Hbmat, Smat, cumLo, ...
    cumLo(1)-(2 * (kTop / (2 * CpTop * Omega(k) * rhoTop))^0.5), nLayers, BCI, SCALE);
  lpM(1) = field(1, :);
  lvM(1) = field(2, :);
  lqM(1) = field(3, :);
  lTM(1) = field(4, :);
  lT_Mm(1) = field(5, :);
  
  field = Backend.interrogationOptim(Hamat, Hbmat, Smat, cumLo, ...
    cumLo(end)+(2 * (kTop / (2 * CpTop * Omega(k) * rhoTop))^0.5), nLayers, BCI, SCALE);
  lpM(nLayers+1) = field(1, :);
  lvM(nLayers+1) = field(2, :);
  lqM(nLayers+1) = field(3, :);
  lTM(nLayers+1) = field(4, :);
  lT_Mm(nLayers+1) = field(5, :);
  
  %% ==================================================================== %%
  % Assign iteration results into main matrices:
  pM(k,:) = lpM;
  vM(k,:) = lvM;
  qM(k,:) = lqM;
  TM(k,:) = lTM;
  T_Mm(k,:) = lT_Mm;  
  
  % Decay coefficient for the propagation calculation
  kay1(k) = w1_c(1);
  kay2(k) = w1_c(end);
  
  % Showing progress
% 	ppm.increment(); %#ok<PFBNS>
end
% delete(ppm);

% the rest of the code is double precision (mp is not required)
kay1 = double(kay1);
kay2 = double(kay2);

% Calculation of the various efficiency parameters (OPTIONAL!)
[eta_TP_1, eta_TP_2, eta_Therm, ...
  eta_aco_1, eta_aco_2, ...
  eta_Conv_1, eta_Conv_2, ...
  eta_Tot_1, eta_Tot_2] = ...
  Backend.efficiencyCalc(qM, vM, simConfigMat(12), nLayers, ...
  sum(MDM(:, LP.L).*MDM(:, +LP.sL:+LP.sR), 'all', 'omitnan'), MDM);

% Array with all the different efficiency calculations collated together
ETA1 = [eta_TP_1, eta_Therm, eta_aco_1, ones(size(eta_aco_1)) .* eta_Conv_1, eta_Tot_1];
ETA2 = [eta_TP_2, eta_Therm, eta_aco_2, ones(size(eta_aco_1)) .* eta_Conv_2, eta_Tot_2];

% Calculation of the acoustic propagation
[Mag_Pff_1, Mag_Prms_ff_1, Mag_Prms_nf_ff_1, Ph_Pff_1, ...
  Mag_Pff_2, Mag_Prms_ff_2, Mag_Prms_nf_ff_2, Ph_Pff_2] = ...
  Backend.rayleighFunc(Ny, Nz, simConfigMat, MDM, kay1, kay2, vM, cumLo, maxO, Omega);

% Array with all the different Pressure calculations collated together
PRES1 = [Mag_Pff_1.', Mag_Prms_ff_1.', Mag_Prms_nf_ff_1.', Ph_Pff_1.'];
PRES2 = [Mag_Pff_2.', Mag_Prms_ff_2.', Mag_Prms_nf_ff_2.', Ph_Pff_2.'];

%% Create output object
% TODO: add the results as they are computed.
%{
p = string(properties(ThermophoneSimResults)).';
disp(join(reshape(["""" + p + """"; p],[],1), ', '));
%}
results = ThermophoneSimResults("ETA1", ETA1, "ETA2", ETA2, "PRES1", PRES1, "PRES2", PRES2, ...
  "T", T, "q", q, "v", v, "p", p, "TM", TM, "qM", qM, "vM", vM, "pM", pM, "T_m", T_m, ...
  "T_Mm", T_Mm, "Omega", Omega, "Posx", Posx, "cumLo", cumLo, "layers", layers);
%{
ETA1     - Array of efficiencies from back side [thermal product, thermal, acoustic, gamma, total]
ETA2     - Array of efficiencies from front side [thermal product, thermal, acoustic, gamma, total]
PRES1    - Array of pressures from front side [pk Far Field, rms Far Field, rms Near Field, Phase]
PRES2    - Array of pressures from back side [pk Far Field, rms Far Field, rms Near Field, Phase]
T        - Oscillating Temperature result at interrogation point(s)
q        - Oscillating Heat-flux result at interrogation point(s)
v        - Oscillating velocity result at interrogation point(s)
p        - Oscillating pressure result at interrogation point(s)
TM       - Oscillating Temperature result at Layer boundaries
qM       - Oscillating Heat-flux result at Layer boundaries
vM       - Oscillating velocity result at Layer boundaries
pM       - Oscillating pressure result at Layer boundaries
T_m      - Steady-State Mean temperature at interrogation point(s)
T_Mm     - Steady-State Mean temperature at Layer boundaries
Omega    - Angular frequency array
Posx     - X-location array
cumLo    - Cumulative layer thickness
layers   - Layers (vector) used in this simulation
%}
end