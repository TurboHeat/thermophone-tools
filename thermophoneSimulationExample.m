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
for i=1:numel(results)
 Backend_codes.plot_res(results(i).PRES1, results(i).PRES2, results(i).ETA1, results(i).ETA2, results(i).T, results(i).q, results(i).v, results(i).p, results(i).TM, results(i).qM, results(i).vM, results(i).pM, results(i).T_m, results(i).T_Mm, results(i).Omega, results(i).Posx, results(i).cumLo, results(i).MDM(:, 1), results(i).N_layers);
end

end


%% ==================================================================== %%
