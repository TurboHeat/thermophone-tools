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
expOpts = ThermophoneModels.ComputationOptions(); % options object with default settings, details can be changed later
expOpts.N_Omega = 1; % Example of "changing it later"
% simOpts.optim = 0; % Example of "changing it later"
[configs] = Exp.verificationCases();

%% Prepare the solver
nConf = numel(configs);
results(nConf, 1) = ThermophoneModels.ExperimentResults();

% input the text file name here with the 'zero' index position
snippet = 'Air_3400_06_05_20_0'; % TODO: INPUT!!!
% what if there is an overflow? _1 _2 etc...
expfilenames{1} = fullfile(pwd, ['Temp_Gamma_exp_Data_', snippet]);
expfilenames{2} = fullfile(pwd, ['Gamma_exp_Data_', snippet]);

co = ThermophoneModels.CalibrationOptions('Mic', 3.41, 'Acc', 10.2, 'Scalib', 1.36E-6, 'P', 0.16E5);

%% Download the data files if they don't exist:
% THESE SHOULD NOT BE STORED ON GITHUB!
fname = expfilenames{1} + ".mat";
if ~isfile(fname)
  wo = weboptions('UserAgent', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:78.0) Gecko/20100101 Firefox/78.0');
  URL = 'https://technionmail-my.sharepoint.com/:u:/g/personal/iliya_campus_technion_ac_il/Edd48QXUon1PreDQO84_DywBc7U4JMf6GfTbIs7DbL-pGA';
  d = webread(URL + "?download=1", wo);
  fid = fopen(fname, 'w'); fwrite(fid, d); fclose(fid);
end
fname = expfilenames{2} + ".mat";
if ~isfile(expfilenames{2} + ".mat")
  wo = weboptions('UserAgent', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:78.0) Gecko/20100101 Firefox/78.0');
  URL = 'https://technionmail-my.sharepoint.com/:u:/g/personal/iliya_campus_technion_ac_il/ESSn-PsGzq9Nq0R7kObTi80B9y1tyP5yg6UGhXHLF-drZA';
  d = webread(URL + "?download=1", wo);
  fid = fopen(fname, 'w'); fwrite(fid, d); fclose(fid);
end

%% Run the solver (process the files)
for indC = 1:nConf
    % Here we usually solve for 1 frequency
    applyCompOptions(configs{indC}, expOpts);
    results(indC) = Exp.backend.solutionFunc(configs{indC}, expOpts.toMatrix(), co, expfilenames);
end

end

%% ==================================================================== %%
