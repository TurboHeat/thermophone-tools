function [ETA1, ETA2, PRES1, PRES2, T, q, v, p, TM, qM, vM, pM, T_m, T_Mm, Omega, Posx, cumLo, MDM, N_layers] = ...
  Solution_function(MDM, dimensions)
%% Outputs
% ETA1     - Array of efficiencies from back side [thermal product, thermal, acoustic, gamma, total]
% ETA2     - Array of efficiencies from front side [thermal product, thermal, acoustic, gamma, total]
% PRES1    - Array of pressures from front side [pk Far Field, rms Far Field, rms Near Field, Phase]
% PRES2    - Array of pressures from back side [pk Far Field, rms Far Field, rms Near Field, Phase]
% T        - Oscillating Temperature result at interrogation point(s)
% q        - Oscillating Heat-flux result at interrogation point(s)
% v        - Oscillating velocity result at interrogation point(s)
% p        - Oscillating pressure result at interrogation point(s)
% TM       - Oscillating Temperature result at Layer boundaries
% qM       - Oscillating Heat-flux result at Layer boundaries
% vM       - Oscillating velocity result at Layer boundaries
% pM       - Oscillating pressure result at Layer boundaries
% T_m      - Steady-State Mean temperature at interrogation point(s)
% T_Mm     - Steady-State Mean temperature at Layer boundaries
% Omega    - Angular frequency array
% Posx     - X-location array
% cumLo    - Cumulative layer thickness
% MDM      - OUTPUT of parameter-layer matrix
% N_layers - Number of Layers in build

%% Overall power input
MDM(:, 10:12) = MDM(:, 10:12) / (dimensions(1) * dimensions(2));
P_in = sum(MDM(:, 10:12), 'all');
MDM(:, 11) = MDM(:, 11) ./ (MDM(:, 1));
MDM(isnan(MDM(:, 11)), 11) = 0;

%% set Layer internal mean temperature
MDM(MDM(:, 14) == 0, 14) = MDM(MDM(:, 14) == 0, 2) .* (MDM(MDM(:, 14) == 0, 7) - MDM(MDM(:, 14) == 0, 8)) ./ (MDM(MDM(:, 14) == 0, 3) .* MDM(MDM(:, 14) == 0, 4).^2); %Ambient temperature
MDM(MDM(:, 14) == 0, 14) = dimensions(11);

N_layers = size(MDM, 1);

%% Cumulative thickness
cumLo = cumsum(MDM(:, 1));
cumLo = [cumLo(1); cumLo];

%% steady-State mean temperature calculation
[T_mean, ~] = Backend_codes.Mean_temp6(double(MDM), double(N_layers), double(cumLo));

%% ==================================================================== %%

%% Determining results at position x, frequency omega
Nq = dimensions(10); % Number of x-interrogation points
maxX = dimensions(9); % Range of interrogation points

% Array of x-interrogation points
Posx = linspace(-maxX+(max(cumLo(end)) / 2), maxX+(max(cumLo(end)) / 2), Nq);
maxO = dimensions(8);
% Number of omega-interrogation points
Omega = (linspace(dimensions(6), dimensions(7), maxO));

%% Minimum distance between points: min_dis=2*pi*c/(5*omega)
% for correct resolution of discrete point source pressure propagation
% calculation there needs to be enough point mesh density
min_dis = max(2*pi*sqrt(MDM(1, 3)*MDM(1, 7)/(MDM(1, 2) * MDM(1, 8)))/(5 * Omega(end)), ...
  2*pi*sqrt(MDM(end, 3)*MDM(end, 7)/(MDM(end, 2) * MDM(end, 8)))/(5 * Omega(end)));

% To be on the safe side, take a minimum of 100x100 points
Ny = max(100, round(dimensions(1)/min_dis)); % Number of point sources in width
Nz = max(100, round(dimensions(2)/min_dis)); % Number of point sources in length

% Variable initialisation
[p, q, T, v, T_m] = deal(zeros(maxO, Nq));
[pM, TM, vM, qM, T_Mm] = deal(zeros(maxO, N_layers+1));
% T_m  - x-positions
% T_Mm - Boundary layer interface positions

% Using mp toolbox, we convert the key datatypes to mp
MDMmp = mp(MDM);
Omegamp = mp(Omega);
cumLomp = mp(cumLo);

[kay1, kay2] = deal(zeros(1,maxO));

%% Looking for frequency
% Prepare for parfor:
MDM_2 = MDM(1,2);
MDM_7 = MDM(1,7);
MDM_9 = MDM(1,9);
d13 = dimensions(13);

ppm = ParforProgressbar(maxO, 'showWorkerProgress', true, 'progressBarUpdatePeriod', 0.5);
parfor k = 1:maxO
  % Create local variables
  [lpM, lTM, lvM, lqM, lT_Mm] = deal(complex(zeros(1, N_layers+1)));
  
  % Function that solves the boundary conditions dan finds the matrix of constants (solutions) for each layer
  [BCI, Hamat, w1_c, ~, Smat, Hbmat, SCALE] = Backend_codes.T_system_solver2(Omegamp(k), MDMmp, N_layers, cumLomp);
  
  %% ==================================================================== %%
  if d13 == 1
    
    % If the user is not interested in viewing the spatial distribution
    % of the result, this loop can be removed.
    for que = 1:Nq % x-position loop
      % Applying the solution to a specific x-location (not vital)
      field = Backend_codes.Interrogation(Hamat, Hbmat, Smat, cumLo, Posx(que), N_layers, BCI, T_mean, SCALE);
      p(k, que) = field(1, :);
      v(k, que) = field(2, :);
      q(k, que) = field(3, :); ...
        T(k, que) = field(4, :);
      T_m(k, que) = field(5, :);
    end
    
    % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    % If the user is not interested in obtaining the spatial interface conditions, this loop can be removed.
    % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    for que = 2:N_layers % x-position loop
      % Finding the solution at the boundary interfaces (not vital)
      field = Backend_codes.Interrogation(Hamat, Hbmat, Smat, cumLo, que, N_layers, BCI, T_mean, SCALE);
      lpM(que) = field(1, :);
      lvM(que) = field(2, :);
      lqM(que) = field(3, :);
      lTM(que) = field(4, :);
      lT_Mm(que) = field(5, :);
    end
    
  end
  
  %% ==================================================================== %%
  
  %% At the maximum velocity position in the first and last layers (thermal thickness)
  % These are needed to determine the propagation from the front and back
  % boundaries
  
  field = Backend_codes.Interrogation(Hamat, Hbmat, Smat, cumLo, cumLo(1)-(2 * (MDM_9 / (2 * MDM_7 * Omega(k) * MDM_2))^(1 / 2)), N_layers, BCI, T_mean, SCALE);
  lpM(1) = field(1, :);
  lvM(1) = field(2, :);
  lqM(1) = field(3, :);
  lTM(1) = field(4, :);
  lT_Mm(1) = field(5, :);
  
  field = Backend_codes.Interrogation(Hamat, Hbmat, Smat, cumLo, cumLo(end)+(2 * (MDM_9 / (2 * MDM_7 * Omega(k) * MDM_2))^(1 / 2)), N_layers, BCI, T_mean, SCALE);
  lpM(N_layers+1) = field(1, :);
  lvM(N_layers+1) = field(2, :);
  lqM(N_layers+1) = field(3, :);
  lTM(N_layers+1) = field(4, :);
  lT_Mm(N_layers+1) = field(5, :);
  
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
	ppm.increment(); %#ok<PFBNS>
end

% the rest of the code is double precision (mp is not required)
kay1 = double(kay1);
kay2 = double(kay2);

% Calculation of the various efficiency parameters
[eta_TP_1, eta_TP_2, eta_Therm, ...
  eta_aco_1, eta_aco_2, ...
  eta_Conv_1, eta_Conv_2, ...
  eta_Tot_1, eta_Tot_2] = ...
  Backend_codes.Efficiency_calc(qM, vM, dimensions(12), N_layers, P_in, MDM);

% Array with all the different efficiency calculations collated together
ETA1 = [eta_TP_1, eta_Therm, eta_aco_1, ones(size(eta_aco_1)) .* eta_Conv_1, eta_Tot_1];
ETA2 = [eta_TP_2, eta_Therm, eta_aco_2, ones(size(eta_aco_1)) .* eta_Conv_2, eta_Tot_2];

% Calculation of the acoustic propagation
[Mag_Pff_1, Mag_Prms_ff_1, Mag_Prms_nf_ff_1, Ph_Pff_1, ...
  Mag_Pff_2, Mag_Prms_ff_2, Mag_Prms_nf_ff_2, Ph_Pff_2] = ...
  Backend_codes.Rayleigh_func(Ny, Nz, dimensions, MDM, kay1, kay2, vM, cumLo, maxO, Omega);

% Array with all the different Pressure calculations collated together
PRES1 = [Mag_Pff_1.', Mag_Prms_ff_1.', Mag_Prms_nf_ff_1.', Ph_Pff_1.'];
PRES2 = [Mag_Pff_2.', Mag_Prms_ff_2.', Mag_Prms_nf_ff_2.', Ph_Pff_2.'];

end