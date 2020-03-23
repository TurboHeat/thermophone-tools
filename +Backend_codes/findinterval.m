function [interval, posx] = findinterval(cumLo, posx, N_layers)

interval = find(posx > cumLo, 1, 'last');

if interval > N_layers
  interval = N_layers;
elseif isempty(interval)
  interval = 1;
end

end
