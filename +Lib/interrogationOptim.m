function [field] = interrogationOptim(Hamat, Hbmat, Smat, cumLo, que, nLayers, BCI, SCALE)
if floor(que) == que

    %% ==================================================================== %%

    %% Identifying the layer containing of the x-interrogation point
    [interval, posx] = Backend.findInterval(cumLo, cumLo(que), nLayers);
else
    [interval, posx] = Backend.findInterval(cumLo, que, nLayers);
end

%% ==================================================================== %%

%% Evaluating the matrix at the interrogation conditions
field = [Hamat(:, :, interval) * (diag(diag((double(Hbmat(:, :, interval).^(posx / SCALE)))))) * BCI(:, interval) + ...
    Smat(:, interval); NaN];

% if interval==1
%
%  Heitch=Hamat(:,:,interval) * (diag(diag((double(Hbmat(:,:,interval).^(posx / SCALE))))));
%
%  [Heitch(2,2)*BCI(2, interval); Heitch(2,4)*BCI(4, interval); double(field(2))]
%
% end

end
