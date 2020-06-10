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
spmd   % Issue commands to all workers in pool (Single Program, Multiple Data)
  warning('off', 'MATLAB:nearlySingularMatrix') % Precision warning toggle
  mp.Digits(50);                                % mp toolbox precision setup
end
%}
function [results] = thermophoneSimulationExample()
%% Configure simulation options:
simOpts = ThermophoneModels.ComputationOptions(); % options object with default settings, details can be changed later
simOpts.N_Omega = 1; % Example of "changing it later"
% simOpts.optim = 0; % Example of "changing it later"
[configs] = verificationCases();

%% Run the solver
nConf = numel(configs);
results(nConf,1) = ThermophoneSimResults();
tmp = simOpts.toMatrix(); % temporary hack
if simOpts.optim  
  parfor indC = 1:nConf
    % Here we usually solve for 1 frequency
    applyCompOptions(configs{indC}, simOpts);
    results(indC) = Backend.solutionFuncOptim(configs{indC}, tmp);
  end
else
  for indC = 1:nConf
    % Here we usually solve for many frequencies, internal parfor will kick in
    applyCompOptions(configs{indC}, simOpts);
    results(indC) = Backend.solutionFunc(configs{indC}, tmp);
  end  
end

%% Plot the results
for k = 1:numel(results)
 Plotting.plotResultsObj(results(k));
end

end


%% ==================================================================== %%
