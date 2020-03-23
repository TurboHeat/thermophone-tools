
%% Multilayer model of thermoacoustic sound generation in steady periodic operation
% ==================================================================== %%

addpath('Layer_models', 'Layer_function', 'Boundary_conditions')

%close all
clear
%clc

% This code is based upon the work of Pierre Guiraud et al., published in
% May 2019
% "Multilayer modeling of thermoacoustic sound generation for thermophone
% analysis and design"
% https://doi.org/10.1016/j.jsv.2019.05.001

% What this model can do:
% Constant volumetric generation
% Boundary generation
% Convective losses

% % Material_Data_matrix=[...
% %     Lo rho B alphaT lambda meu Cp Cv kappa,... % Material 1
% %     Lo rho B alphaT lambda meu Cp Cv kappa,... % Material 2
% %     Lo rho B alphaT lambda meu Cp Cv kappa,... % Material 3
% %     ];
% %
% % Forcing_matrix=[...
% %     So1 So So2,... % Material 1
% %     So1 So So2,... % Material 2
% %     So1 So So2,... % Material 3
% %     ];
% %
% % Exp_conditions=[...
% %     Beta1 To Beta2,...  % Material 1
% %     Beta1 To Beta2,...  % Material 2
% %     Beta1 To Beta2,...  % Material 3
% %     ];
% %
% % Dimensions=[...
% %     Ly,Lz,...                 %Source Dimensions
% %     x_int,y_int,z_int,...     %Microphone Position (Acoustic interrogation point)
% %     omega];

load('Air.mat')
Lo = 0;
So1 = 0;
So = 0;
So2 = 0;
Beta1 = 0;
To = 0;
Beta2 = 10;
Material_Data_matrix(1, :) = [0, rho, B, alphaT, lambda, meu, Cp, Cv, kappa, So1, So, So2, Beta1, To, Beta2]; % Material 1

load('Titanium.mat')
Lo = 10^-8;
So1 = 0;
So = 1;
So2 = 0;
Beta1 = 0;
To = 0;
Beta2 = 0;
Material_Data_matrix = vertcat(Material_Data_matrix, [Lo, rho, B, alphaT, lambda, meu, Cp, Cv, kappa, So1, So, So2, Beta1, To, Beta2]); % Material 2

load('Air.mat')
Lo = 0;
So1 = 0;
So = 0;
So2 = 0;
Beta1 = 10;
To = 0;
Beta2 = 0;
Material_Data_matrix = vertcat(Material_Data_matrix, [Lo, rho, B, alphaT, lambda, meu, Cp, Cv, kappa, So1, So, So2, Beta1, To, Beta2]); % Material 2

omega = 1;
Dimensions = [0.01, 0.01, 0.05, 0, 0, omega];

function [Hmat, BCImat, Fmat] = T_Solver_function(Material_Data_matrix, Dimensions)

Material_Data_matrix(:, 10:12) = Material_Data_matrix(:, 10:12) / (Dimensions(1) * Dimensions(2))


end
