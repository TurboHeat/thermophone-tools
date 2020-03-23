%% Solving the Boundary Conditions
function [aN, b1, cN, d1, BCI] = SolveCONSTS(const, const2, N_layers, aaN, bb1, ccN, dd1)

%% Solving for the boundary conditions
[aN, b1, cN, d1] = vpasolve((const{round(N_layers/2)} - const2{round(N_layers/2)}), [aaN, bb1, ccN, dd1]);

if any(isempty([aN, b1, cN, d1])) %We expect the unknowns to be small (<1) - a lack of precision would make them large
  [aN, b1, cN, d1] = solve(const{round(N_layers/2)}-const2{round(N_layers/2)}, [aaN, bb1, ccN, dd1]);
end

Comp = const{1};
for k = 2:N_layers
  if isempty(const{k})
    const{k} = const2{k};
  end
  Comp = [Comp, const{k}];
end

% BCI = double(arrayfun(@(x)mp(char(x)), subs(Comp, [bb1, dd1, aaN, ccN], [b1, d1, aN, cN])));
BCI = double(subs(Comp, [bb1, dd1, aaN, ccN], [b1, d1, aN, cN]));

end
