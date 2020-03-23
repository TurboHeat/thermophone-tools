function [T, q] = Mean_temp(MDM, N_layers, cumLo, x, cc1)

Mean_Const1a{2} = cc1;
Mean_Const2a{2} = (MDM(2, 11)) * (cumLo(2)) * (((cumLo(2)) / (2 * MDM(2, 9))) - (1 / (MDM(1, 15) + MDM(2, 13)))) + ...
  Mean_Const1a{2} * ((MDM(2, 9) / (MDM(1, 15) + MDM(2, 13))) - cumLo(2)) + (MDM(1, 12) - (MDM(2, 10)));
%% Temperature in the second layer
T_mean{2} = Mean_Const1a{2} * (x) + Mean_Const2a{2} - ((MDM(2, 11)) * (x)^2) / (2 * MDM(2, 9));

%% Heat-Flux in the second layer
q_mean{2} = -MDM(2, 9) * (Mean_Const1a{2}) + ((MDM(2, 11)) * (x));

%% Temperature at the boundary between layers 1-2
pTa{1} = subs(T_mean{2}, x, (cumLo(2)));
pqa{1} = subs(q_mean{2}, x, (cumLo(2))) + (MDM(1, 12) - MDM(2, 10));

%% Temperature at the boundary between layers 2-3
pTa{2} = subs(T_mean{2}, x, cumLo(3));
pqa{2} = subs(q_mean{2}, x, cumLo(3)) + (MDM(2, 12) - MDM(3, 10)) - (MDM(2, 15) + MDM(3, 13)) * pTa{2};


if N_layers > 3
  for i = 3:N_layers - 1
    
    % mid-layer location % For debugging purposes
    po(i) = 0 * (cumLo(i) + cumLo(i+1)) / 2;
    
    %% Constants for i-th layer
    Mean_Const1a{i} = ((MDM(i, 10)) - pqa{i-1} + ((MDM(i, 11)) * (cumLo(i)))) / MDM(i, 9);
    Mean_Const2a{i} = pTa{i-1} + (((MDM(i, 11)) * ((cumLo(i))^2)) / (2 * MDM(i, 9))) - (Mean_Const1a{i} * (cumLo(i)));
    
    %% Temperature in the i-th layer
    T_mean{i} = Mean_Const1a{i} * (x) + Mean_Const2a{i} - ((MDM(i, 11)) * (x)^2) / (2 * MDM(i, 9));
    
    %% Heat-flux in the i-th layer
    q_mean{i} = -MDM(i, 9) * (Mean_Const1a{i}) + ((MDM(i, 11)) * (x));
    
    %% Temperature at the boundary between layers i and i-1
    pTa{i} = subs(T_mean{i}, x, (cumLo(i+1)));
    
    %% Heat-Flux at the boundary between layers i and i-1
    pqa{i} = subs(q_mean{i}, x, (cumLo(i+1))) + (MDM(i, 12) - MDM(i+1, 10)) - (MDM(i, 15) + MDM(i+1, 13)) * pTa{i};
    
  end
end
sol = subs(-((MDM(N_layers-1, 15) + MDM(N_layers, 13)))*T_mean{N_layers-1}+q_mean{N_layers-1}+(MDM(N_layers-1, 12) - MDM(N_layers, 10)), x, cumLo(N_layers));

c1 = mp(char(vpasolve(sol, cc1)));
c2 = (MDM(2, 10)) * (cumLo(2)) * (((cumLo(2)) / (2 * MDM(2, 9))) - (1 / (MDM(1, 15) + MDM(2, 13)))) + ...
  c1 * ((MDM(2, 9) / (MDM(1, 15) + MDM(2, 13))) - cumLo(2)) + (MDM(1, 12) - (MDM(2, 10)));

[T,q] = deal(cell(N_layers,1));
for i = 2:N_layers - 1
  
  %% Temperature solution with solved coefficients
  T{i} = matlabFunction((subs(T_mean{i}, [cc1], [c1])));
  
  %% Heat-Flux solution with solved coefficients
  q{i} = matlabFunction((subs(q_mean{i}, [cc1], [c1])));
  
  %     figure(1)
  %     hold on
  %     %plot(Posx,subs(T{i},x,Posx))
  %     plotfuncN(N_layers,subs(T{i},x,Posx),L0,Posx,cumLo);
  %
  %     figure(2)
  %     hold on
  %     %plot(Posx,subs(q{i},x,Posx))
  %     plotfuncN(N_layers,subs(q{i},x,Posx),L0,Posx,cumLo);
end

%% Temperature solution in extremity layers

% T{1} = vpa(c2);
% q{1} = vpa(c1);
% T{N_layers} = vpa(subs(pTa{N_layers-1}, [cc1], [c1]));
% q{N_layers} = vpa(subs(pqa{N_layers-1}, [cc1], [c1]));

T{1} = mp(c2);
q{1} = mp(c1);
T{N_layers} = mp(char(subs(pTa{N_layers-1}, cc1, c1)));
q{N_layers} = mp(char(subs(pqa{N_layers-1}, cc1, c1)));
end
