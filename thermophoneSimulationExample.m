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
mp.Digits(50); % mp toolbox precision
warning('off', 'MATLAB:nearlySingularMatrix') % matrix warning toggle

% If planning to run on multiple cores:
gcp(); % Create a pool with the default settings
spmd       % Issue commands to all workers in pool (Single Program, Multiple Data)
  warning('off', 'MATLAB:nearlySingularMatrix') % Precision warning toggle
  mp.Digits(50);                                % mp toolbox precision setup
end
%}
function [results] = thermophoneSimulationExample()
%% Configure simulation options:
simOpts = thermophoneSimOpts(); % options object with default settings, details can be changed later
simOpts.N_Omega = 1; % Example for "changing it later"
% simOpts.optim = 0; % Example for "changing it later"
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
for k=1:numel(results)
 Backend_codes.plot_res(results(k).PRES1, results(k).PRES2, results(k).ETA1, results(k).ETA2, results(k).T, results(k).q, results(k).v, results(k).p, results(k).TM, results(k).qM, results(k).vM, results(k).pM, results(k).T_m, results(k).T_Mm, results(k).Omega, results(k).Posx, results(k).cumLo, results(k).MDM(:, 1), results(k).N_layers); ...
end

end


%% ==================================================================== %%
