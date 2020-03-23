function [ETA1, ETA2, PRES1, PRES2, T, q, v, p, TM, qM, vM, pM, T_m, T_Mm, Omega, Posx, cumLo, MDM, N_layers] = ...
  Solution_function(MDM, Dimensions, aaN, ccN, bb1, dd1, cc1, invHa_f, invHb_f, Ha_f, Hb_f, w1_f, w2_f, S_f, x)
%% Overall power input
MDM(:, 10:12) = MDM(:, 10:12) / (Dimensions(1) * Dimensions(2));
P_in = sum(MDM(:, 10:12), 'all');
MDM(:, 11) = MDM(:, 11) ./ (MDM(:, 1));
MDM(isnan(MDM(:, 11)), 11) = 0;

MDM(MDM(:, 14) == 0, 14) = MDM(MDM(:, 14) == 0, 2) .* (MDM(MDM(:, 14) == 0, 7) - MDM(MDM(:, 14) == 0, 8)) ./ (MDM(MDM(:, 14) == 0, 3) .* MDM(MDM(:, 14) == 0, 4).^2); %Ambient temperature
MDM(MDM(:, 14) == 0, 14) = Dimensions(11);

N_layers = size(MDM, 1);

%% Cumulative thickness
cumLo = cumsum(MDM(:, 1));
cumLo = [cumLo(1); cumLo];

%%

[T_mean, ~] = Backend_codes.Mean_temp(MDM, N_layers, cumLo, x, cc1);

%% ==================================================================== %%

%% Determining results at position x, frequency omega

Nq = Dimensions(10); % Number of x-interrogation points
maxX = Dimensions(9); % Range of interrogation points

% Array of x-interrogation points
Posx = linspace(-maxX+(max(cumLo(end)) / 2), maxX+(max(cumLo(end)) / 2), Nq);

maxO = Dimensions(8);
% Number of omega-interrogation points
Omega = linspace(Dimensions(6), Dimensions(7), maxO);

%% Minimum distance between points: min_dis=2*pi*c/(5*omega)
min_dis = max(2*pi*sqrt(MDM(1, 3)*MDM(1, 7)/(MDM(1, 2) * MDM(1, 8)))/(5 * Omega(end)), ...
  2*pi*sqrt(MDM(end, 3)*MDM(end, 7)/(MDM(end, 2) * MDM(end, 8)))/(5 * Omega(end)));

Ny = max(100, round(Dimensions(1)/min_dis)); % Number of point sources in width
Nz = max(100, round(Dimensions(2)/min_dis)); % Number of point sources in length

p = zeros(maxO, Nq);
q = p;
T = p;
v = p;
T_m = p;
pM = zeros(maxO, N_layers+1);
TM = pM;
vM = pM;
qM = pM;
T_Mm = pM;

BCI = ones(4, N_layers);

for j = 1:maxO
  [BCI, Hamat, w1_c, w2_c] = Backend_codes.T_system_solver( ...
    Omega(j), invHa_f, invHb_f, Ha_f, Hb_f, w1_f, w2_f, S_f, MDM, N_layers, cumLo, aaN, ccN, bb1, dd1, Dimensions);
  
  for que = 1:Nq % x-position loop
    
    [field, interval] = Backend_codes.Interrogation( ...
      Hamat, Hb_f, S_f, cumLo, Posx(que), N_layers, BCI, T_mean, MDM, Omega(j), w1_c, w2_c);
    
    p(j, que) = field(1, :);
    v(j, que) = field(2, :);
    q(j, que) = field(3, :);
    T(j, que) = field(4, :);
    T_m(j, que) = field(5, :);
    
  end
  
  %% ==================================================================== %%
  
  for que = 2:N_layers % x-position loop
    
    [field, interval] = Backend_codes.Interrogation( ...
      Hamat, Hb_f, S_f, cumLo, que, N_layers, BCI, T_mean, MDM, Omega(j), w1_c, w2_c);
    pM(j, que) = field(1, :);
    vM(j, que) = field(2, :);
    qM(j, que) = field(3, :);
    TM(j, que) = field(4, :);
    T_Mm(j, que) = field(5, :);
    
  end
  
  %% At the maximum velocity position in the first and last layers (thermal thickness)
  [field, ~] = Backend_codes.Interrogation(Hamat, Hb_f, S_f, cumLo, cumLo(1)-(2 * (MDM(1, 9) / (2 * MDM(1, 7) * Omega(j) * MDM(1, 2)))^(1 / 2)), N_layers, BCI, T_mean, MDM, Omega(j), w1_c, w2_c);
  pM(j, 1) = field(1, :);
  vM(j, 1) = field(2, :);
  qM(j, 1) = field(3, :);
  TM(j, 1) = field(4, :);
  T_Mm(j, 1) = field(5, :);
  
  [field, ~] = Backend_codes.Interrogation(Hamat, Hb_f, S_f, cumLo, cumLo(end)+(2 * (MDM(1, 9) / (2 * MDM(1, 7) * Omega(j) * MDM(1, 2)))^(1 / 2)), N_layers, BCI, T_mean, MDM, Omega(j), w1_c, w2_c);
  pM(j, N_layers+1) = field(1, :);
  vM(j, N_layers+1) = field(2, :);
  qM(j, N_layers+1) = field(3, :);
  TM(j, N_layers+1) = field(4, :);
  T_Mm(j, N_layers+1) = field(5, :);
  
  %% ==================================================================== %%
  
  %Decay coefficient
  kay1(j) = w1_c{1};
  kay2(j) = w1_c{end};
  
  %% Update Progressbar:
  progressbar(j/maxO)
end

[eta_TP_1_A, eta_TP_2_A, eta_TP_1, ...
  eta_TP_2, eta_Therm_A, eta_Therm, ...
  eta_aco_1, eta_aco_2, ...
  eta_Conv_1, eta_Conv_2, ...
  eta_Tot_1, eta_Tot_2] = ...
  Backend_codes.Efficiency_calc(pM, TM, qM, vM, Dimensions(12), N_layers, P_in, MDM);

[Mag_Pff_1, Mag_Prms_ff_1, Mag_Prms_nf_ff_1, Ph_Pff_1, ...
  Mag_Pff_2, Mag_Prms_ff_2, Mag_Prms_nf_ff_2, Ph_Pff_2] = ...
  Backend_codes.Rayleigh_func(Ny, Nz, Dimensions, MDM, kay1, kay2, vM, cumLo, maxO, x, Omega);

ETA1 = [eta_TP_1, eta_Therm, eta_aco_1, ones(size(eta_aco_1)) .* eta_Conv_1, eta_Tot_1];
ETA2 = [eta_TP_2, eta_Therm, eta_aco_2, ones(size(eta_aco_1)) .* eta_Conv_2, eta_Tot_2];

PRES1 = [Mag_Pff_1', Mag_Prms_ff_1', Mag_Prms_nf_ff_1', Ph_Pff_1'];
PRES2 = [Mag_Pff_2', Mag_Prms_ff_2', Mag_Prms_nf_ff_2', Ph_Pff_2'];

end