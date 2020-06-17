function [MIC, ACC, Va, Vb, Vc, datapoints] = loadData(expfilenames)
% This code reads data experimental results
% In the case of the 2nd type of data, there can be several files that need to be 
%   concatenated for historic reasons:
%   https://turbo-heat.slack.com/archives/C010AC9H00K/p1592295737021200
% TODO: combine "datapoints" and "dataset" into a single class with aptly named fields!

%% Read the first type of data:
datapoints = table2array(readFile( string(dir(expfilenames{1} + "*").name) ));

%% Read the 2nd type of data:
% Determine how many files there are:
files = dir(expfilenames{2}(1:end - 1) + "*");
nF = numel(files);
% Preallocate storage:
ds = cell(nF,1);
% Read files:
for indF = 1:nF
  ds{indF} = readFile( string(fullfile(files(indF).folder, files(indF).name)) );
end
% Report result:
disp(nF + " signal file(s) loaded.")
dataset = vertcat(ds{:}); % If this fails, the contents probably have different formats (i.e. column names/quantity)

%% Prepare output (unbox):
MIC = dataset.("Microphone [Pa]");
ACC = dataset.("Accelerometer [m/s2]");
Va = dataset.("Voltage A [V]");
Vb = dataset.("Voltage B [V]");
Vc = dataset.("Voltage C [V]");
end

function data = readFile(fname)
assert(isstring(fname) && isscalar(fname), 'Input must be a string scalar!');
switch true
  case contains(fname, ".txt") || contains(fname, ".xls")
    data = readtable(fname, 'FileType', 'text', 'PreserveVariableNames', true);
  case contains(fname, ".mat")
    data = struct2array(load(fname));
  otherwise
    throw(MException('loadData:invalidFile',...
      'The specified file (%s) has an unsupported extension!',...
      fname));
end
end