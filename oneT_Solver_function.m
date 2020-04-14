%{
# Simple benchmarking:
tic; oneT_Solver_function; toc

# Better Benchmarking:
timeit(@oneT_Solver_function)
%}
function [] = oneT_Solver_function()
% warning('off', 'MATLAB:singularMatrix') % matrix warning toggle
warning('off', 'MATLAB:nearlySingularMatrix') % matrix warning toggle

%% ******* The mp precision must be changed until the solution is unchanging ******* %%
mp.Digits(50); % mp toolbox precision

%% ******* ******* ******* ******* *******  ******* *******  ******* ******* ******* %%

% Example run cases
MDM = Backend_codes.Example_cases();

%% Thermophone dimensions
Ly = 0.01; % [m]
Lz = 0.01; % [m]

%% Microphone location [x_int,y_int,z_int]
x_int = 0.05; % [m]
y_int = 0;    % [m]
z_int = 0;    % [m]

%% Frequency sweep
OmegaF = 200 * 2 * pi;   % [rad/s]
OmegaL = 50000 * 2 * pi; % [rad/s]
N_Omega = 300;           % [unitless]

%% x-location sweep
maxX = 20 * 10^-5; % [m]
N_x = 1;           % [unitless]
xres = false; % switch for calculating spatial information (only really needed for in-depth analysis)

%% Initialise Ambient temperature
T_amb = 3 * 10^2; % [K]

%% Location of Thermophone layer (used in the efficiency calculation)
TH_layer_number = 2; % [1 ... size(MDM,1)]

%% Storing all the run parameters into an array
Dimensions = [Ly, Lz, x_int, y_int, z_int, OmegaF, OmegaL, N_Omega, maxX, N_x, T_amb, TH_layer_number, xres];
%            | 1| 2 |   3  |   4  |   5  |   6   |   7   |    8   |   9 | 10 |  11  |       12       |  13 |

%% Keeping it clean
clearvars -except MDM Dimensions

%% ** Solution function **
[ETA1, ETA2, PRES1, PRES2, T, q, v, p, TM, qM, vM, pM, T_m, T_Mm, Omega, Posx, cumLo, MDM, N_layers] = ...
  Backend_codes.Solution_function(MDM, Dimensions);
%% Outputs
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
MDM      - OUTPUT of parameter-layer matrix
N_layers - Number of Layers in build
%}

%% Plotting the results
% Backend_codes.plot_res(PRES1, PRES2, ETA1, ETA2, T, q, v, p, TM, qM, vM, pM, T_m, T_Mm, Omega, Posx, cumLo, MDM(:, 1), N_layers);

%% ==================================================================== %%
