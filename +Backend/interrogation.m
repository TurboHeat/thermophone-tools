function [field] = interrogation(Hamat, Hbmat, Smat, cumLo, que, nLayers, BCI, mBCI, SCALE, MDM)
if floor(que) == que
  
  %% ==================================================================== %%
  
  %% Identifying the layer containing of the x-interrogation point
  [interval, posx] = Backend.findInterval(cumLo, cumLo(que), nLayers);
else
  [interval, posx] = Backend.findInterval(cumLo, que, nLayers);
end

%% ==================================================================== %%

%% Evaluating the matrix at the interrogation conditions
field = Hamat(:,:,interval) * (diag(diag((double(Hbmat(:,:,interval).^(posx / SCALE)))))) * BCI(:, interval) + ...
  Smat(:,interval);

%% ==================================================================== %%
if interval == 1 
  field(5, :) = mBCI(1, 2) + MDM(1, 14);
elseif interval == nLayers
  field(5, :) = mBCI(end, 1) * cumLo(end-1) + mBCI(end, 2) - ...
      ((MDM(end-1, 11)) * (cumLo(end-1))^2) / (2 * MDM(end -1, 9)) + ...
      MDM(1, 14);
else
  field(5, :) =  (mBCI(interval - 1, 1)*(posx)+mBCI(interval - 1, 2)...
      -((MDM(interval, 11)) * (posx)^2)/(2 * MDM(interval, 9)))+MDM(1, 14);
end
end
