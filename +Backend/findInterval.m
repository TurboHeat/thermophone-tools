function [interval, posx] = findInterval(cumLo, posx, N_layers)

interval = find(posx > cumLo, 1, 'last');
if isempty(interval)
  interval = 1;
else
  interval = min(interval, N_layers);
end