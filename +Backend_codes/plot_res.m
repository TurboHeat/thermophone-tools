function plot_res(PRES1, PRES2, ETA1, ETA2, T, q, v, p, TM, qM, vM, pM, T_m, T_Mm, Omega, Posx, cumLo, L0, N_layers)

%% Plotting frequency dependent plot
if numel(Omega) ~= 1
  
  %     f=figure(1);hold all;plot(Omega,abs(T));title('Medium 1 Oscillating Temperature field');
  %     xlabel('$\omega$','fontsize',14,'interpreter','latex')
  %     ylabel('$|T_f|$','fontsize',14,'interpreter','latex')
  %     movegui(f,'south');
  %
  %     f=figure(2);hold all;plot(Omega,abs(q));title('Medium 1 Oscillating Heat flux field');
  %     xlabel('$\omega$','fontsize',14,'interpreter','latex')
  %     ylabel('$|q_f|$','fontsize',14,'interpreter','latex')
  %     movegui(f,'north');
  %
  %     f=figure(3);hold all;plot(Omega,abs(v));title('Oscillating Velocity field');
  %     xlabel('$\omega$','fontsize',14,'interpreter','latex')
  %     ylabel('$|v|$','fontsize',14,'interpreter','latex')
  %     movegui(f,'southeast');
  %
  %     f=figure(4);hold all;plot(Omega,abs(p));title('Oscillating Pressure field');
  %     xlabel('$\omega$','fontsize',14,'interpreter','latex')
  %     ylabel('$|p|$','fontsize',14,'interpreter','latex')
  %     movegui(f,'northeast');
  
  %         f=figure(13);hold all;plot(Omega/(2*pi),PRES1(:,2));plot(Omega/(2*pi),PRES2(:,2));
  %     title('RMS Pressure field');
  %     xlabel('$f[Hz]$','fontsize',14,'interpreter','latex')
  %     ylabel('$|P_{rms}|$','fontsize',14,'interpreter','latex')
  %     movegui(f,'south');
  
  f = figure(14);
  hold all;
  plot(Omega/(2 * pi), 20*log10(PRES1(:, 2)/(2 * 10^-5)));
  plot(Omega/(2 * pi), 20*log10(PRES2(:, 2)/(2 * 10^-5)));
  legend('FAR-FIELD 1', ...
    'FAR-FIELD 2')
  title('RMS Pressure field');
  xlabel('$f[Hz]$', 'fontsize', 14, 'interpreter', 'latex')
  ylabel('$SPL=20 \cdot log_{_{10}}\left[\frac{|P_{rms}|}{P_{ref}}\right]$', 'fontsize', 14, 'interpreter', 'latex')
  movegui(f, 'southeast');
  %ylim([30 inf])
  
  %     f=figure(15);hold all;plot(Omega/(2*pi),PRES1(:,4));plot(Omega/(2*pi),PRES2(:,4));
  %     title('Phase field');
  %     xlabel('$f[Hz]$','fontsize',14,'interpreter','latex')
  %     ylabel('$\phi$','fontsize',14,'interpreter','latex')
  %     movegui(f,'southwest');
  %
  %     f=figure(16);hold all;
  %     plot(Omega/(2*pi),ETA1(:,2));
  %     plot(Omega/(2*pi),ETA1(:,1));plot(Omega/(2*pi),ETA2(:,1));
  %     plot(Omega/(2*pi),ETA1(:,4));plot(Omega/(2*pi),ETA2(:,4));
  %     plot(Omega/(2*pi),ETA1(:,5));plot(Omega/(2*pi),ETA2(:,5));
  %     plot(Omega/(2*pi),ETA1(:,3));plot(Omega/(2*pi),ETA2(:,3));
  %
  %     legend('$\eta_{Therm}$-thermophone',...
  %         '$\eta_{TP}1$-thermophone','$\eta_{TP}2$-thermophone',...
  %         '$\eta_{Conv}1$','$\eta_{Conv}2$',...
  %         '$\eta_{Tot}1$','$\eta_{Tot}2$',...
  %         '$\eta_{aco}1$','$\eta_{aco}2$',...
  %         'interpreter','latex')
  %     title('Efficiencies');
  %     xlabel('$f[Hz]$','fontsize',14,'interpreter','latex')
  %     ylabel('$\phi$','fontsize',14,'interpreter','latex')
  %     movegui(f,'southwest');
  
  
end

%% Plotting x-location dependent plot
if numel(Posx) ~= 1
  
  f = figure(7);
  hold all;
  plotfunc(N_layers, T(1, :), L0, Posx, cumLo);
  plot(cumLo(2:N_layers)-(max(cumsum(L0)) / 2), abs(TM(1, 2:N_layers)), 'o');
  title('Medium 1 Oscillating Temperature field');
  xlabel('$x$-location', 'fontsize', 14, 'interpreter', 'latex')
  ylabel('$|T_f|$', 'fontsize', 14, 'interpreter', 'latex')
  movegui(f, 'south');
  
  f = figure(8);
  hold all;
  plotfunc(N_layers, q(1, :), L0, Posx, cumLo);
  plot(cumLo(2:N_layers)-(max(cumsum(L0)) / 2), abs(qM(1, 2:N_layers)), 'o');
  title('Medium 1 Oscillating Heat flux field');
  xlabel('$x$-location', 'fontsize', 14, 'interpreter', 'latex')
  ylabel('$|q_f|$', 'fontsize', 14, 'interpreter', 'latex')
  movegui(f, 'north');
  
  f = figure(9);
  hold all;
  plotfunc(N_layers, v(1, :), L0, Posx, cumLo);
  plot(cumLo(2:N_layers)-(max(cumsum(L0)) / 2), abs(vM(1, 2:N_layers)), 'o');
  title('Oscillating Velocity field');
  xlabel('$x$-location', 'fontsize', 14, 'interpreter', 'latex')
  ylabel('$|v|$', 'fontsize', 14, 'interpreter', 'latex')
  movegui(f, 'southeast');
  
  f = figure(10);
  hold all;
  plotfunc(N_layers, p(1, :), L0, Posx, cumLo);
  plot(cumLo(2:N_layers)-(max(cumsum(L0)) / 2), abs(pM(1, 2:N_layers)), 'o');
  title('Oscillating Pressure field');
  xlabel('$x$-location', 'fontsize', 14, 'interpreter', 'latex')
  ylabel('$|p|$', 'fontsize', 14, 'interpreter', 'latex')
  movegui(f, 'northeast');
  
  f = figure(13);
  hold all;
  plotfunc(N_layers, T_m(1, :), L0, Posx, cumLo);
  plot(cumLo(2:N_layers)-(max(cumsum(L0)) / 2), abs(T_Mm(1, 2:N_layers)), 'o');
  title('Mean temperature distribution');
  xlabel('$x$-location', 'fontsize', 14, 'interpreter', 'latex')
  ylabel('$T_{MEAN}$', 'fontsize', 14, 'interpreter', 'latex')
  movegui(f, 'northwest');
  
  
end

end
