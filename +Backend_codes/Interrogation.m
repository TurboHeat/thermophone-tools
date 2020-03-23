function [field, interval] = Interrogation(Hamat, Hb_f, S_f, cumLo, que, N_layers, BCI, T_mean, MDM, Omega, w1_c, w2_c)
if floor(que) == que % test if integer
  
  %% ==================================================================== %%
  
  %% Identifying the layer containing of the x-interrogation point
  [interval, posx] = Backend_codes.findinterval(cumLo, cumLo(que), N_layers);
else
  [interval, posx] = Backend_codes.findinterval(cumLo, que, N_layers);
end

%% ==================================================================== %%

%% Evaluating the matrix at the interrogation conditions
field = complex(zeros(5,1));
field(1:4,:) = Hamat{interval} * feval(Hb_f, w1_c(interval), w2_c(interval), posx) * BCI(:, interval) + ...
  feval(S_f, MDM(interval, 3), MDM(interval, 8), MDM(interval, 11), MDM(interval, 4), Omega, MDM(interval, 2));
%% ==================================================================== %%
if (interval == 1 || interval == N_layers)
  field(5, :) = T_mean{interval};
else
  field(5, :) = feval(T_mean{interval}, posx);
end
end
