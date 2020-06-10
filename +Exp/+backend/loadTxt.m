function [MIC, ACC, Va, Vb, Vc, Datapoints] = loadTxt(expfilenames)
%% This code reads data from file

warning('off', 'MATLAB:table:ModifiedAndSavedVarnames')

Datapoints = table2array(readtable(expfilenames{1}, 'FileType', 'text'));
Dataset = table2array(readtable(expfilenames{2}, 'FileType', 'text'));

%check for overflow
exitloop = 0;
counter = 1;
while exitloop == 0
    overflow = [expfilenames{2}(1:end - 1), num2str(counter), '.txt'];
    if isfile(overflow)
        Dataset = vertcat(Dataset, table2array(readtable(overflow)));
        counter = counter + 1;
    else
        exitloop = 1;
    end
end

disp([num2str(counter), ' signal file(s) loaded'])

MIC = (Dataset(:, 1));
ACC = (Dataset(:, 2));
Va = (Dataset(:, 3));
Vb = (Dataset(:, 4));
Vc = (Dataset(:, 5));

end