function [interval, posx] = findInterval(cumLo, posx, nLayers)

interval = find(posx > cumLo, 1, 'last');
if isempty(interval)
    interval = 1;
else
    interval = min(interval, nLayers);
end