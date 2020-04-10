function [field, interval] = Interrogation(Hamat, Hbmat, Smat, cumLo, que, N_layers, BCI, T_mean, MDM, Omega, w1_c, w2_c, SCALE)
if floor(que) == que
  
  %% ==================================================================== %%
  
  %% Identifying the layer containing of the x-interrogation point
  [interval, posx] = Backend_codes.findinterval(cumLo, cumLo(que), N_layers);
else
  [interval, posx] = Backend_codes.findinterval(cumLo, que, N_layers);
end

%% ==================================================================== %%

%% Evaluating the matrix at the interrogation conditions

field = Hamat(:,:,interval) * (diag(diag((double(Hbmat{interval}.^(posx / SCALE)))))) * BCI(:, interval) + ...
  Smat{interval};

field(1, :) = field(1, :);
field(2, :) = field(2, :);
field(3, :) = field(3, :);
field(4, :) = field(4, :);

%% ==================================================================== %%
if (interval == 1 || interval == N_layers)
  field(5, :) = T_mean{interval};
else
  field(5, :) = feval(T_mean{interval}, posx);
end
end
