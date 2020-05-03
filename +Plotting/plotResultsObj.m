function [varargout] = plotResultsObj(resObj)
%% Input validation:
arguments
  resObj(1,1) thermophoneSimResults
end

%% Unpacking:
L0 = resObj.MDM(:, 1);

%% Plotting frequency dependent plot
if numel(resObj.Omega) ~= 1
  
  if false % TBD
  [hF, hAx] = getAx(1); %#ok<*UNRCH>
  plot(Omega,abs(T));
  title(hAx, 'Medium 1 Oscillating Temperature field');
  xlabel(hAx, '$\omega$','fontsize',14,'interpreter','latex')
  ylabel(hAx, '$|T_f|$','fontsize',14,'interpreter','latex')
  movegui(hF,'south');

  [hF, hAx] = getAx(2);
  plot(Omega,abs(q));
  title(hAx, 'Medium 1 Oscillating Heat flux field');
  xlabel(hAx, '$\omega$','fontsize',14,'interpreter','latex')
  ylabel(hAx, '$|q_f|$','fontsize',14,'interpreter','latex')
  movegui(hF,'north');

  [hF, hAx] = getAx(3);
  plot(Omega,abs(v));
  title(hAx, 'Oscillating Velocity field');
  xlabel(hAx, '$\omega$','fontsize',14,'interpreter','latex')
  ylabel(hAx, '$|v|$','fontsize',14,'interpreter','latex')
  movegui(hF,'southeast');

  [hF, hAx] = getAx(4);
  plot(Omega,abs(p));
  title(hAx, 'Oscillating Pressure field');
  xlabel(hAx, '$\omega$','fontsize',14,'interpreter','latex')
  ylabel(hAx, '$|p|$','fontsize',14,'interpreter','latex')
  movegui(hF,'northeast');

  [hF, hAx] = getAx(13);
  plot(Omega/(2*pi),PRES1(:,2));plot(Omega/(2*pi),PRES2(:,2));
  title(hAx, 'RMS Pressure field');
  xlabel(hAx, '$f[Hz]$','fontsize',14,'interpreter','latex')
  ylabel(hAx, '$|P_{rms}|$','fontsize',14,'interpreter','latex')
  movegui(hF,'south');
  end
  
  [hF, hAx] = getAx(14);
  plot(hAx, resObj.Omega/(2 * pi), 20*log10(resObj.PRES1(:, 2)/(2 * 10^-5)));
  plot(hAx, resObj.Omega/(2 * pi), 20*log10(resObj.PRES2(:, 2)/(2 * 10^-5)));
  legend(hAx, 'FAR-FIELD 1', 'FAR-FIELD 2')
  title(hAx, 'RMS Pressure field');
  xlabel(hAx, '$f[Hz]$', 'fontsize', 14, 'interpreter', 'latex')
  ylabel(hAx, '$SPL=20 \cdot log_{_{10}}\left[\frac{|P_{rms}|}{P_{ref}}\right]$', 'fontsize', 14, 'interpreter', 'latex')
  movegui(hF, 'southeast');
  %ylim([30 inf])
  
  if false %TBD
  [hF, hAx] = getAx(15);
  plot(hAx, Omega/(2*pi),PRES1(:,4));
  plot(hAx, Omega/(2*pi),PRES2(:,4));
  title(hAx, 'Phase field');
  xlabel(hAx, '$f[Hz]$','fontsize',14,'interpreter','latex')
  ylabel(hAx, '$\phi$','fontsize',14,'interpreter','latex')
  movegui(hF,'southwest');

  [hF, hAx] = getAx(16);
  plot(hAx, Omega/(2*pi),ETA1(:,2));
  plot(hAx, Omega/(2*pi),ETA1(:,1));plot(Omega/(2*pi),ETA2(:,1));
  plot(hAx, Omega/(2*pi),ETA1(:,4));plot(Omega/(2*pi),ETA2(:,4));
  plot(hAx, Omega/(2*pi),ETA1(:,5));plot(Omega/(2*pi),ETA2(:,5));
  plot(hAx, Omega/(2*pi),ETA1(:,3));plot(Omega/(2*pi),ETA2(:,3));

  legend(hAx, '$\eta_{Therm}$-thermophone',...
         '$\eta_{TP}1$-thermophone','$\eta_{TP}2$-thermophone',...
         '$\eta_{Conv}1$','$\eta_{Conv}2$',...
         '$\eta_{Tot}1$','$\eta_{Tot}2$',...
         '$\eta_{aco}1$','$\eta_{aco}2$',...
         'interpreter','latex')
  title(hAx, 'Efficiencies');
  xlabel(hAx, '$f[Hz]$','fontsize',14,'interpreter','latex')
  ylabel(hAx, '$\phi$','fontsize',14,'interpreter','latex')
  movegui(hF,'southwest');
  end
  
end

%% Plotting x-location dependent plot
if numel(resObj.Posx) ~= 1
  
  [hF, hAx] = getAx(7);
  plotFunc(hAx, resObj.N_layers, resObj.T(1, :), L0, resObj.Posx, resObj.cumLo);
  plot(hAx, resObj.cumLo(2:resObj.N_layers)-(max(cumsum(L0)) / 2), abs(resObj.TM(1, 2:resObj.N_layers)), 'o');
  title(hAx, 'Medium 1 Oscillating Temperature field');
  xlabel(hAx, '$x$-location', 'fontsize', 14, 'interpreter', 'latex')
  ylabel(hAx, '$|T_f|$', 'fontsize', 14, 'interpreter', 'latex')
  movegui(hF, 'south');
  
  [hF, hAx] = getAx(8);
  plotFunc(hAx, resObj.N_layers, resObj.q(1, :), L0, resObj.Posx, resObj.cumLo);
  plot(hAx, resObj.cumLo(2:resObj.N_layers)-(max(cumsum(L0)) / 2), abs(resObj.qM(1, 2:resObj.N_layers)), 'o');
  title(hAx, 'Medium 1 Oscillating Heat flux field');
  xlabel(hAx, '$x$-location', 'fontsize', 14, 'interpreter', 'latex')
  ylabel(hAx, '$|q_f|$', 'fontsize', 14, 'interpreter', 'latex')
  movegui(hF, 'north');
  
  [hF, hAx] = getAx(9);
  plotFunc(hAx, resObj.N_layers, resObj.v(1, :), L0, resObj.Posx, resObj.cumLo);
  plot(hAx, resObj.cumLo(2:resObj.N_layers)-(max(cumsum(L0)) / 2), abs(resObj.vM(1, 2:resObj.N_layers)), 'o');
  title(hAx, 'Oscillating Velocity field');
  xlabel(hAx, '$x$-location', 'fontsize', 14, 'interpreter', 'latex')
  ylabel(hAx, '$|v|$', 'fontsize', 14, 'interpreter', 'latex')
  movegui(hF, 'southeast');
  
  [hF, hAx] = getAx(10);
  plotFunc(hAx, resObj.N_layers, resObj.p(1, :), L0, resObj.Posx, resObj.cumLo);
  plot(hAx, resObj.cumLo(2:resObj.N_layers)-(max(cumsum(L0)) / 2), abs(resObj.pM(1, 2:resObj.N_layers)), 'o');
  title(hAx, 'Oscillating Pressure field');
  xlabel(hAx, '$x$-location', 'fontsize', 14, 'interpreter', 'latex')
  ylabel(hAx, '$|p|$', 'fontsize', 14, 'interpreter', 'latex')
  movegui(hF, 'northeast');
  
  [hF, hAx] = getAx(13);
  plotFunc(hAx, resObj.N_layers, resObj.T_m(1, :), L0, resObj.Posx, resObj.cumLo);
  plot(hAx, resObj.cumLo(2:resObj.N_layers)-(max(cumsum(L0)) / 2), abs(resObj.T_Mm(1, 2:resObj.N_layers)), 'o');
  title(hAx, 'Mean temperature distribution');
  xlabel(hAx, '$x$-location', 'fontsize', 14, 'interpreter', 'latex')
  ylabel(hAx, '$T_{MEAN}$', 'fontsize', 14, 'interpreter', 'latex')
  movegui(hF, 'northwest');
  
  
end

%% Assign outputs:
if nargout >= 1
  varargout{1} = hF;
end
if nargout >= 2
  varargout{2} = hA;
end

end

function plotFunc(hAx, N_layers, G, L0, Posx, cumLo)
  for k = 2:1:(N_layers)
    plot(hAx, [cumLo(k), cumLo(k)]-(max(cumsum(L0)) / 2), [min(abs(G)), max(abs(G))], '-r')
  end
  plot(hAx, Posx-(max(cumsum(L0)) / 2), abs(G))
  grid(hAx, 'on')
end

function [hF, hA] = getAx(figNo)
if ~nargin
  hF = figure();
else
  hF = figure(figNo);
end
hA = axes(hF);
hold(hA, 'on');
end