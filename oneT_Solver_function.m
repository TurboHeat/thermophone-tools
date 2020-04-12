%{
# Optional preparations:
1) Multiprecision Computing Toolbox for MATLAB
  Download links:
  Windows:  https://www.advanpix.com/wp-content/plugins/download-monitor/download.php?id=1 
  Linux:    https://www.advanpix.com/wp-content/plugins/download-monitor/download.php?id=8 
  Mac:      https://www.advanpix.com/wp-content/plugins/download-monitor/download.php?id=9

  % Toolbox path - must be changed per-user!
  addpath('/Users/SEJ/Desktop/Thermophone_models/25_3_20_General_1-Temperature_solver/AdvanpixMCT-4.7.0-1.13589')

2) Running in parfor mode (see Solution_function.m L85):
parpool();
spmd
  warning('off', 'MATLAB:nearlySingularMatrix') % matrix warning toggle
  mp.Digits(50); % mp toolbox precision
end
% addpath(fullfile(pwd, 'progressbar'));

# Simple benchmarking:
tic; oneT_Solver_function; toc

# Better Benchmarking:
timeit(@oneT_Solver_function)
%}
function [] = oneT_Solver_function()
%% Multilayer model of thermoacoustic sound generation in steady periodic operation
% ==================================================================== %%
% warning('off', 'MATLAB:singularMatrix') % matrix warning toggle
warning('off', 'MATLAB:nearlySingularMatrix') % matrix warning toggle

%% ******* The mp precision must be changed until the solution is unchanging ******* %%
mp.Digits(50); % mp toolbox precision

%% ******* ******* ******* ******* *******  ******* *******  ******* ******* ******* %%

%% Instructions of use
%{
This code is based upon the work of Pierre Guiraud et al., published in
May 2019
"Multilayer modeling of thermoacoustic sound generation for thermophone
analysis and design"
https://doi.org/10.1016/j.jsv.2019.05.001

What this model can do:
Constant volumetric generation
Boundary generation
Convective losses

Data of each material layer is included in a matrix called MDM. Each row
represents the properties of a different layer of the thermophone design,
in the order in which they appear.
The column inputs are as follows:
Column No:
~~~ Material Properties ~~~
1 - Layer thickness
2 - Layer density
3 - Layer coefficient of thermal expansion
4 - Layer 1st viscosity coefficient (1st Lame coefficient for solids)
5 - Layer 2nd viscosity coefficient (2nd Lame coefficient for solids)
6 - Constant pressure specific heat capacity (same as Cv for a solid)
7 - Constant volume specific heat capacity
8 - Layer thermal conductivity
~~~ Forcing parameters ~~~
9 - Layer left edge boundary generation (W)
10 - Layer internal generation  (W)
11 - Layer right edge boundary generation (W)
~~~ Experimental Conditions ~~~
12 - Layer left edge heat transfer coefficient [h]
13 - Layer internal mean temperature (calculated automatically for gases, set for solids)
14 - Layer right edge heat transfer coefficient [h]
%
Visualised example structure
MDM = [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14;... (layer 1)
        1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14;... (layer 1)
        1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14;... (layer 1)
        1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14;... (layer 1)];
%}
% Example run cases
MDM = Backend_codes.Example_cases();

%% Thermophone dimensions in m [Ly,Lz], microphone location [x_int,y_int,z_int]
Ly = 0.01;
Lz = 0.01;
x_int = 0.05;
y_int = 0;
z_int = 0;

%% Frequency sweep
OmegaF = 200 * 2 * pi;
OmegaL = 50000 * 2 * pi;
N_Omega = 300;

%% x-location sweep
maxX = 20 * 10^-5;
N_x = 1;

%% Are you interested in calculating any spatial information? (only really needed for in-depth analysis)
xres = 0;

%% Initialise Ambient temperature
T_amb = 3 * 10^2;

%% Location of Thermophone layer (used in the efficiency calculation)
TH_layer_number = 2;

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
