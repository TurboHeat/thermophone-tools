function [MDM] = Example_cases
MATERIAL_PATH = fullfile(fileparts(mfilename('fullpath')), '..', '+Layer_models');

load(fullfile(MATERIAL_PATH, 'Air.mat')) % loading a specific material from a .mat file
Loo = 0;
So1 = 0;
Soo = 0;
So2 = 0;
Beta1 = 0;
Too = rhoo * (Cpo - Cvo) / ((alphaTo^2) * Bo);
Beta2 = 10;
MDM(1, :) = [Loo, rhoo, Bo, alphaTo, lambdao, meuo, Cpo, Cvo, kappao, So1, Soo, So2, Beta1, Too, Beta2]; % Material 1
%           | 1 |  2  | 3 |    4   |    5   |  6  |  7 |  8 |   9   | 10 | 11 | 12 |  13  | 14 |  15  |

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

end
