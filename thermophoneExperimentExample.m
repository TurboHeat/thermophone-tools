%% Benchmark
%{
# Simple benchmarking:
tic; thermophoneExperimentExample; toc

# More accurate benchmarking:
timeit(@thermophoneExperimentExample)
%}

%% Preparations:
%{
# If planning to run on a single core:
mp.Digits(150); % mp toolbox precision
warning('off', 'MATLAB:nearlySingularMatrix') % matrix warning toggle
addpath('C:\Users\sasson\Documents\Multiprecision Computing Toolbox')
% If planning to run on multiple cores:
gcp(); % Create a pool with the default settings
spmd   % Issue commands to all workers in pool (Single Program, Multiple Data)
  warning('off', 'MATLAB:nearlySingularMatrix') % Precision warning toggle
  mp.Digits(150);                                % mp toolbox precision setup
end
%}
function [results] = thermophoneExperimentExample()

%% Configure simulation options:
simOpts = ThermophoneSimOpts(); % options object with default settings, details can be changed later
simOpts.N_Omega = 1; % Example of "changing it later"
% simOpts.optim = 0; % Example of "changing it later"
[configs] = verificationCase_exp();

%% Run the solver
nConf = numel(configs);
results(nConf, 1) = ThermophoneEXPResults();
tmp = simOpts.toMatrix(); % temporary hack

%intut the text file name here with the 'zero' index position
snippet = 'Air_3400_06_05_20_0';
% what if there is an overflow? _1 _2 etc...
expfilenames{1} = ['Temp_Gamma_exp_Data_', snippet];
expfilenames{2} = ['Gamma_exp_Data_', snippet];

for indC = 1:nConf
    % Here we usually solve for 1 frequency
    applySimOptions(configs{indC}, simOpts);
    results(indC) = Backend.solutionFuncEXP(configs{indC}, tmp, expfilenames);
end

end

%% ==================================================================== %%
