function [MDM] = Example_cases

%{
New syntax:
TPH = [Layer_models.FluidLayer("label","Air");
       Layer_models.ThermophoneLayer("label","Gold");
       Layer_models.SubstrateLayer("label","Silica");
       Layer_models.FluidLayer("label","Air")]
%}

MATERIAL_PATH = fullfile(fileparts(mfilename('fullpath')), '..', '+Layer_models');

load(fullfile(MATERIAL_PATH, 'Air.mat')) % loading a specific material from a .mat file
Loo = 0;    % Thickness [m]
So1 = 0;    % Lt. edge boundary generation
Soo = 0;    % Internal generation 
So2 = 0;    % Rt. edge boundary generation
Beta1 = 0;  % Lt. edge heat transfer coeff.
Too = rhoo * (Cpo - Cvo) / ((alphaTo^2) * Bo); % Internal mean temperature
Beta2 = 10; % Rt. edge heat transfer coeff.	
MDM(1, :) = [Loo, rhoo, Bo, alphaTo, lambdao, meuo, Cpo, Cvo, kappao, So1, Soo, So2, Beta1, Too, Beta2]; % Material 1
%           | 1 |  2  | 3 |    4   |    5   |  6  |  7 |  8 |   9   | 10 | 11 | 12 |  13  | 14 |  15  |
% FluidLayer

load(fullfile(MATERIAL_PATH, 'Gold.mat'))
Loo = 40 * 10^-9;
So1 = 0;
Soo = 200;
So2 = 0;
Beta1 = 0;
Too = rhoo * (Cpo - Cvo) / ((alphaTo^2) * Bo);
Beta2 = 0;
MDM = vertcat(MDM, [Loo, rhoo, Bo, alphaTo, lambdao, meuo, Cpo, Cvo, kappao, So1, Soo, So2, Beta1, Too, Beta2]); % Material 1
%                  | 1 |  2  | 3 |    4   |    5   |  6  |  7 |  8 |   9   | 10 | 11 | 12 |  13  | 14 |  15 |
% ThermophoneLayer {/ InsulationLayer / BaseLayer }


% load(fullfile(MATERIAL_PATH, 'Titanium.mat'))
% Loo=5*10^-9;So1=0;Soo=0;So2=0;Beta1=0;Too=0;Beta2=0;
% MDM=vertcat(MDM,[Loo, rhoo, Bo, alphaTo, lambdao, meuo, Cpo, Cvo, kappao, So1, Soo, So2, Beta1, Too, Beta2]); % Material 2
%               | 1 |  2  | 3 |    4   |    5   |  6  |  7 |  8 |   9   | 10 | 11 | 12 |  13  | 14 |  15  |
%     load(fullfile(MATERIAL_PATH, 'Air.mat'))
%     Loo=5*10^-9;So1=0;Soo=0;So2=0;Beta1=0;Too=0;Beta2=0;
%     MDM=vertcat(MDM,[Loo, rhoo, Bo, alphaTo, lambdao, meuo, Cpo, Cvo, kappao, So1, Soo, So2, Beta1, Too, Beta2]); % Material 2
% %               | 1 |  2  | 3 |    4   |    5   |  6  |  7 |  8 |   9   | 10 | 11 | 12 |  13  | 14 |  15  |

%
% load(fullfile(MATERIAL_PATH, 'Silica_aerogel.mat'))
% Loo=10*10^-8;So1=0;Soo=0;So2=0;Beta1=0;Too=rhoo*(Cpo-Cvo)/((alphaTo^2)*Bo);Beta2=0;
% MDM=vertcat(MDM,[Loo, rhoo, Bo, alphaTo, lambdao, meuo, Cpo, Cvo, kappao, So1, Soo, So2, Beta1, Too, Beta2]); % Material 2
% %               | 1 |  2  | 3 |    4   |    5   |  6  |  7 |  8 |   9   | 10 | 11 | 12 |  13  | 14 |  15  |
%
load(fullfile(MATERIAL_PATH, 'Silica.mat'))
Loo = 200 * 10^-6;
So1 = 0;
Soo = 0;
So2 = 0;
Beta1 = 0;
Too = 0;
Beta2 = 0;
MDM = vertcat(MDM, [Loo, rhoo, Bo, alphaTo, lambdao, meuo, Cpo, Cvo, kappao, So1, Soo, So2, Beta1, Too, Beta2]); % Material 1
% %                | 1 |  2  | 3 | c   4  |    5   |  6  |  7 |  8 |   9   | 10 | 11 | 12 |  13  | 14 |  15  |
%
% load(fullfile(MATERIAL_PATH, 'Titanium.mat'))
% Loo=2*10^-3;So1=0;Soo=0;So2=0;Beta1=0;Too=0;Beta2=0;
% MDM=vertcat(MDM,[Loo, rhoo, Bo, alphaTo, lambdao, meuo, Cpo, Cvo, kappao, So1, Soo, So2, Beta1, Too, Beta2]); % Material 1
% %               | 1 |  2  | 3 |    4   |    5   |  6  |  7 |  8 |   9   | 10 | 11 | 12 |  13  | 14 |  15  |
% SubstrateLayer {InsulationLayer}

load(fullfile(MATERIAL_PATH, 'Air.mat'))
Loo = 0;
So1 = 0;
Soo = 0;
So2 = 0;
Beta1 = 10;
Too = rhoo * (Cpo - Cvo) / ((alphaTo^2) * Bo);
Beta2 = 0;
MDM = vertcat(MDM, [Loo, rhoo, Bo, alphaTo, lambdao, meuo, Cpo, Cvo, kappao, So1, Soo, So2, Beta1, Too, Beta2]); % Material 1
%                  | 1 |  2  | 3 |    4   |    5   |  6  |  7 |  8 |   9   | 10 | 11 | 12 |  13  | 14 |  15  |
% FluidLayer
end
