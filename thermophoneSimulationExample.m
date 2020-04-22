%% Benchmark
%{
# Simple benchmarking:
tic; thermophoneSimulationExample; toc

# More accurate benchmarking:
timeit(@thermophoneSimulationExample)
%}
%% Preparations:
%{
# If planning to run on a single core:
mp.Digits(150); % mp toolbox precision
warning('off', 'MATLAB:nearlySingularMatrix') % matrix warning toggle

% If planning to run on multiple cores:
gcp(); % Create a pool with the default settings
spmd       % Issue commands to all workers in pool (Single Program, Multiple Data)
  warning('off', 'MATLAB:nearlySingularMatrix') % Precision warning toggle
  mp.Digits(150);                                % mp toolbox precision setup
end
%}
function [results] = thermophoneSimulationExample()
close all
%% Configure simulation options:
simOpts = thermophoneSimOpts(); % options object with default settings, details can be changed later
simOpts.N_Omega = 1; % Example for "changing it later"
% simOpts.optim = 0; % Example for "changing it later"

%{
%% Configure thermophone layer structure(s):
TPH = [Layer_models.FluidLayer("label", "Air", 'L', 0, ...
        'rho', 1.2, 'B', 1.01E5, 'alpha', 3.33E-3, 'lambda', 1.68E-5,...
        'mu', 5.61E-6, 'Cp', 9.96E2, 'Cv', 7.17E2, 'k', 2.62E-2,...
        'sL', 0, 's0', 0, 'sR', 0, 'hL', 0, 'hR', 10);
       Layer_models.ThermophoneLayer("label", "Gold", 'L', 40E-9, ...
        'rho', mean([19.25, 19.35]) * 1E3, 'B', mean([148, 180]) * 1E9, ...
        'Y', mean([76, 81]) * 1E9, 'alpha', mean([13.5, 14.5]) * 1E-6, ...
        'Cp', mean([125, 135]), 'Cv', mean([125, 135]), 'k', mean([305, 319]),...
        'sL', 0, 's0', 200, 'sR', 0, 'hL', 0, 'hR', 0);
       Layer_models.SubstrateLayer("label", "Silica", 'L', 200E-6, ...
        'rho', mean([2.17, 2.65])*1E3, 'B', mean([33.5, 36.8]) * 1E9, ...
        'Y', mean([66.3, 74.8]) * 1E9, 'alpha', mean([0.55, 0.75]) * 1E-6, ...
        'Cp', mean([680, 730]), 'Cv', mean([680, 730]), 'k', mean([1.3, 1.5]),...
        'sL', 0, 's0', 0, 'sR', 0, 'hL', 0, 'T0', 0, 'hR', 0);
       Layer_models.FluidLayer("label", "Air", 'L', 0, ...
        'rho', 1.2, 'B', 1.01 * 10^5, 'alpha', 3.33 * 10^-3, 'lambda', 1.68 * 10^-5,...
        'mu', 5.61 * 10^-6, 'Cp', 9.96 * 10^2, 'Cv', 7.17 * 10^2, 'k', 2.62 * 10^-2,...
        'sL', 0, 's0', 0, 'sR', 0, 'hL', 10, 'hR', 0)];

    % This is the 20 different cases we see
configs = repmat({TPH}, 1, 20); % This simulates defining additional configurations
%}
[configs] = Verification_cases();
%% Run the solver
nConf = numel(configs);
results(nConf,1) = thermophoneSimResults;
tmp = simOpts.toMatrix(); % temporary hack
if simOpts.optim  
  parfor indC = 1:nConf
    % Here we usually solve for 1 frequency
    results(indC) = Backend_codes.Solution_function_opt(configs{indC}.toMatrix(), tmp);
  end
else
  for indC = 1:nConf
    % Here we usually solve for many frequencies, internal parfor will kick in
    results(indC) = Backend_codes.Solution_function(configs{indC}.toMatrix(), tmp);
    
  end  
end

%% Plot the results
for i=1:numel(results)
 Backend_codes.plot_res(results(i).PRES1, results(i).PRES2, results(i).ETA1, results(i).ETA2, results(i).T, results(i).q, results(i).v, results(i).p, results(i).TM, results(i).qM, results(i).vM, results(i).pM, results(i).T_m, results(i).T_Mm, results(i).Omega, results(i).Posx, results(i).cumLo, results(i).MDM(:, 1), results(i).N_layers);
end

end


%% ==================================================================== %%
