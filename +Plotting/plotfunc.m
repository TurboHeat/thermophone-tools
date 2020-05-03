function plotfunc(N_layers, G, L0, Posx, cumLo)
hold all
for k = 2:1:(N_layers)
  plot([cumLo(k), cumLo(k)]-(max(cumsum(L0)) / 2), [min(abs(G)), max(abs(G))], '-r')
end
plot(Posx-(max(cumsum(L0)) / 2), abs(G))
grid on
end
