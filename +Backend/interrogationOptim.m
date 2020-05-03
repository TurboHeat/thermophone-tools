function [field] = interrogationOptim(Hamat, Hbmat, Smat, cumLo, que, N_layers, BCI, SCALE)
if floor(que) == que
  
  %% ==================================================================== %%
  
  %% Identifying the layer containing of the x-interrogation point
  [interval, posx] = Backend.findInterval(cumLo, cumLo(que), N_layers);
else
  [interval, posx] = Backend.findInterval(cumLo, que, N_layers);
end

%% ==================================================================== %%

%% Evaluating the matrix at the interrogation conditions
field = [Hamat(:,:,interval) * (diag(diag((double(Hbmat(:,:,interval).^(posx / SCALE)))))) * BCI(:, interval) + ...
  Smat(:,interval); NaN];

end
