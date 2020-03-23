function varargout = oneT_Solver_function()
%% Multilayer model of thermoacoustic sound generation in steady periodic operation
% ==================================================================== %%

warning('off', 'MATLAB:nearlySingularMatrix')

% This code is based upon the work of Pierre Guiraud et al., published in
% May 2019
% "Multilayer modeling of thermoacoustic sound generation for thermophone
% analysis and design"
% https://doi.org/10.1016/j.jsv.2019.05.001

% What this model can do:
% Constant volumetric generation
% Boundary generation
% Convective losses

% % MDM=[...
% %     Lo rho B alphaT lambda meu Cp Cv kappa,... % Material 1
% %     Lo rho B alphaT lambda meu Cp Cv kappa,... % Material 2
% %     Lo rho B alphaT lambda meu Cp Cv kappa,... % Material 3
% %
% %
% % Forcing parameters...
% %     So1 So So2,... % Material 1
% %     So1 So So2,... % Material 2
% %     So1 So So2,... % Material 3
% %
% %
% % Exp_conditions...
% %     Beta1 To Beta2,...  % Material 1
% %     Beta1 To Beta2,...  % Material 2
% %     Beta1 To Beta2,...  % Material 3
% %     ];
% %
% % Dimensions=[...
% %     Ly,Lz,...                 %Source Dimensions
% %     x_int,y_int,z_int,...     %Microphone Position (Acoustic interrogation point)
% %     omega];

load('Air.mat'); % TODO: Make class
Loo = 0; So1 = 0; Soo = 0; So2 = 0; Beta1 = 0; Beta2 = 10; 
Too = rhoo * (Cpo - Cvo) / ((alphaTo^2) * Bo);
MDM(1, :) = [Loo, rhoo, Bo, alphaTo, lambdao, meuo, Cpo, Cvo, kappao, So1, Soo, So2, Beta1, Too, Beta2]; % Material 1
%           |1|  2  | 3 |    4   |    5   |  6  |  7 |  8 |   9   | 10 | 11 | 12 |  13  | 14 |  15  |

load('Gold.mat'); % TODO: Make class
Loo = 40 * 10^-9; So1 = 0; Soo = 20; So2 = 0; Beta1 = 0; Beta2 = 0;
Too = rhoo * (Cpo - Cvo) / ((alphaTo^2) * Bo);
MDM = vertcat(MDM, [Loo, rhoo, Bo, alphaTo, lambdao, meuo, Cpo, Cvo, kappao, So1, Soo, So2, Beta1, Too, Beta2]); % Material 1
%                | 1 |  2  | 3 |    4   |    5   |  6  |  7 |  8 |   9   | 10 | 11 | 12 |  13  | 14 |  15 |

load('Titanium.mat'); % TODO: Make class
Loo = 5 * 10^-9; So1 = 0; Soo = 0; So2 = 0; Beta1 = 0;Beta2 = 0;
Too = 0;
MDM = vertcat(MDM, [Loo, rhoo, Bo, alphaTo, lambdao, meuo, Cpo, Cvo, kappao, So1, Soo, So2, Beta1, Too, Beta2]); % Material 2
%               | 1 |  2  | 3 |    4   |    5   |  6  |  7 |  8 |   9   | 10 | 11 | 12 |  13  | 14 |  15  |

load('Silica_aerogel.mat'); % TODO: Make class
Loo = 10 * 10^-8; So1 = 0; Soo = 0; So2 = 0; Beta1 = 0; Beta2 = 0;
Too = rhoo * (Cpo - Cvo) / ((alphaTo^2) * Bo);
MDM = vertcat(MDM, [Loo, rhoo, Bo, alphaTo, lambdao, meuo, Cpo, Cvo, kappao, So1, Soo, So2, Beta1, Too, Beta2]); % Material 2
%               | 1 |  2  | 3 |    4   |    5   |  6  |  7 |  8 |   9   | 10 | 11 | 12 |  13  | 14 |  15  |

load('Silica.mat'); % TODO: Make class
Loo = 10 * 10^-6; So1 = 0; Soo = 0; So2 = 0; Beta1 = 0; Beta2 = 0; Too = 0;
MDM = vertcat(MDM, [Loo, rhoo, Bo, alphaTo, lambdao, meuo, Cpo, Cvo, kappao, So1, Soo, So2, Beta1, Too, Beta2]); % Material 1
%                 | 1 |  2  | 3 |    4   |    5   |  6  |  7 |  8 |   9   | 10 | 11 | 12 |  13  | 14 |  15  |

load('Titanium.mat'); % TODO: Make class
Loo = 0; So1 = 0; Soo = 0; So2 = 0; Beta1 = 0; Beta2 = 0; Too = 0 * 10^-10;
MDM = vertcat(MDM, [Loo, rhoo, Bo, alphaTo, lambdao, meuo, Cpo, Cvo, kappao, So1, Soo, So2, Beta1, Too, Beta2]); % Material 1
%               | 1 |  2  | 3 |    4   |    5   |  6  |  7 |  8 |   9   | 10 | 11 | 12 |  13  | 14 |  15  |

% load ('Air.mat')
% Loo=0;So1=0;Soo=0;So2=0;Beta1=10;Too=rhoo*(Cpo-Cvo)/((alphaTo^2)*Bo);Beta2=0;
% MDM=vertcat(MDM,[Loo, rhoo, Bo, alphaTo, lambdao, meuo, Cpo, Cvo, kappao, So1, Soo, So2, Beta1, Too, Beta2]); % Material 1
%               | 1 |  2  | 3 |    4   |    5   |  6  |  7 |  8 |   9   | 10 | 11 | 12 |  13  | 14 |  15  |

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

%% Initialise Ambient temperature
T_amb = 3 * 10^2;

%% Location of Thermophone layer (used in the efficiency calculation)
TH_layer_number = 2;

%% Storing all the run parameters into an array
Dimensions = [Ly, Lz, x_int, y_int, z_int, OmegaF, OmegaL, N_Omega, maxX, N_x, T_amb, TH_layer_number];
%          | 1| 2|  3  |  4  |   5 |   6  |   7  |   8   |  9 |10 |  11 |      12       |

%% Keeping it clean
clearvars -except MDM Dimensions

load('Layer_function.mat'); % TODO: Make class (but different)

%% **Solution function**
[ETA1, ETA2, PRES1, PRES2, T, q, v, p, TM, qM, vM, pM, T_m, T_Mm, Omega, Posx, cumLo, MDM, N_layers] = ...
  Backend_codes.Solution_function(MDM, Dimensions, aaN, ccN, bb1, dd1, cc1, invHa_f, invHb_f, Ha_f, Hb_f, w1_f, w2_f, S_f, x);
%% Outputs
% ETA1    - Array of efficiencies from back side [thermal product, thermal, acoustic, gamma, total]
% ETA2    - Array of efficiencies from front side [thermal product, thermal, acoustic, gamma, total]
% PRES1   - Array of pressures from front side [pk Far Field, rms Far Field, rms Near Field, Phase]
% PRES2   - Array of pressures from back side [pk Far Field, rms Far Field, rms Near Field, Phase]
% T       - Oscillating Temperature result at interrogation point(s)
% q       - Oscillating Heat-flux result at interrogation point(s)
% v       - Oscillating velocity result at interrogation point(s)
% p       - Oscillating pressure result at interrogation point(s)
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

%% Plotting the results
% plot_res(PRES1,PRES2,ETA1,ETA2,T,q,v,p,TM,qM,vM,pM,T_m,T_Mm,Omega,Posx,cumLo,MDM(:,1),N_layers)

%% ==================================================================== %%

%% Assigning outputs
if nargout > 0
  varargout = {ETA1, ETA2, PRES1, PRES2, T, q, v, p, TM, qM, vM, pM, T_m, T_Mm, Omega, Posx, cumLo, MDM, N_layers};
end