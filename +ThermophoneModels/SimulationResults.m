classdef SimulationResults < ThermophoneModels.Results
  % THERMOPHONESIMRESULTS Simple data class for holding simulation results
  
  properties (GetAccess = public, SetAccess = protected)
    ETA2     % Array of efficiencies from front side [thermal product, thermal, acoustic, gamma, total]
    PRES2    % Array of pressures from back side [pk Far Field, rms Far Field, rms Near Field, Phase]
    T        % Oscillating Temperature result at interrogation point(s)
    q        % Oscillating Heat-flux result at interrogation point(s)
    v        % Oscillating velocity result at interrogation point(s)
    p        % Oscillating pressure result at interrogation point(s)
    T_m      % Steady-State Mean temperature at interrogation point(s)
    T_Mm     % Steady-State Mean temperature at Layer boundaries
    Posx     % X-location array
  end
  
  methods (Access = public)
    
    function optsObj = SimulationResults(optsKW)
      arguments % must contain ALL properties (including superclass')
        optsKW.ETA1
        optsKW.ETA2
        optsKW.PRES1
        optsKW.PRES2
        optsKW.T
        optsKW.q
        optsKW.v
        optsKW.p
        optsKW.TM
        optsKW.qM
        optsKW.vM
        optsKW.pM
        optsKW.T_m
        optsKW.T_Mm
        optsKW.Omega
        optsKW.Posx
        optsKW.cumLo
        optsKW.layers
      end
      
      % Copy field contents into object properties
      fn = fieldnames(optsKW);
      for idxF = 1:numel(fn)
        optsObj.(fn{idxF}) = optsKW.(fn{idxF});
      end
    end
    
    function varargout = plot(resObj)
      %% Input validation:
      arguments
        resObj(1,1) ThermophoneModels.SimulationResults
      end
      %% Preallocation / Initialization:
      % hA = gobjects(13,1);
      % hF = gobjects(13,1);
      % TODO: store intermediate hF & hA in the gobjects vectors.
      
      %% Unpacking:
      L0 = vertcat(resObj.layers.L); L0(isinf(L0)) = 0;
      nLayers = numel(resObj.layers);
      
      %% Plotting frequency dependent plot
      if numel(resObj.Omega) ~= 1
%{        
        if false % TBD
          [hF, hAx] = getAx(); %#ok<*UNRCH>
          plot(Omega,abs(T));
          title(hAx, 'Medium 1 Oscillating Temperature field');
          xlabel(hAx, '$\omega$','fontsize',14,'interpreter','latex')
          ylabel(hAx, '$|T_f|$','fontsize',14,'interpreter','latex')
          movegui(hF,'south');
          
          [hF, hAx] = getAx();
          plot(hAx, Omega,abs(q));
          title(hAx, 'Medium 1 Oscillating Heat flux field');
          xlabel(hAx, '$\omega$','fontsize',14,'interpreter','latex')
          ylabel(hAx, '$|q_f|$','fontsize',14,'interpreter','latex')
          movegui(hF,'north');
          
          [hF, hAx] = getAx();
          plot(hAx, Omega,abs(v));
          title(hAx, 'Oscillating Velocity field');
          xlabel(hAx, '$\omega$','fontsize',14,'interpreter','latex')
          ylabel(hAx, '$|v|$','fontsize',14,'interpreter','latex')
          movegui(hF,'southeast');
          
          [hF, hAx] = getAx();
          plot(hAx, Omega,abs(p));
          title(hAx, 'Oscillating Pressure field');
          xlabel(hAx, '$\omega$','fontsize',14,'interpreter','latex')
          ylabel(hAx, '$|p|$','fontsize',14,'interpreter','latex')
          movegui(hF,'northeast');
          
          [hF, hAx] = getAx();
          plot(hAx, Omega/(2*pi), PRES1(:,2), Omega/(2*pi), PRES2(:,2));
          title(hAx, 'RMS Pressure field');
          xlabel(hAx, '$f[Hz]$','fontsize',14,'interpreter','latex')
          ylabel(hAx, '$|P_{rms}|$','fontsize',14,'interpreter','latex')
          movegui(hF,'south');
        end
%}        
        [hF, hAx] = getAx();
        plot(hAx, resObj.Omega/(2 * pi), 20*log10(resObj.PRES1(:, 2)/(2 * 10^-5)), ...
          resObj.Omega/(2 * pi), 20*log10(resObj.PRES2(:, 2)/(2 * 10^-5)));
        legend(hAx, 'FAR-FIELD 1', 'FAR-FIELD 2')
        title(hAx, 'RMS Pressure field');
        xlabel(hAx, '$f[Hz]$', 'fontsize', 14, 'interpreter', 'latex')
        ylabel(hAx, '$SPL=20 \cdot log_{_{10}}\left[\frac{|P_{rms}|}{P_{ref}}\right]$', 'fontsize', 14, 'interpreter', 'latex')
        movegui(hF, 'southeast');
        %ylim([30 inf])
%{        
        if false %TBD
          [hF, hAx] = getAx();
          plot(hAx, Omega/(2*pi),PRES1(:,4), Omega/(2*pi),PRES2(:,4));
          title(hAx, 'Phase field');
          xlabel(hAx, '$f[Hz]$','fontsize',14,'interpreter','latex')
          ylabel(hAx, '$\phi$','fontsize',14,'interpreter','latex')
          movegui(hF,'southwest');
          
          [hF, hAx] = getAx();
          plot(hAx, Omega/(2*pi), ETA1(:,2), Omega/(2*pi), ETA1(:,1),...
            Omega/(2*pi), ETA2(:,1), Omega/(2*pi), ETA1(:,4),...
            Omega/(2*pi), ETA2(:,4), Omega/(2*pi), ETA1(:,5),...
            Omega/(2*pi), ETA2(:,5), Omega/(2*pi), ETA1(:,3), ...
            Omega/(2*pi), ETA2(:,3));
          
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
%}        
      end
      
      %% Plotting x-location dependent plot
      if numel(resObj.Posx) ~= 1
        
        [hF, hAx] = getAx();
        plotFunc(hAx, nLayers, resObj.T(1, :), L0, resObj.Posx, resObj.cumLo);
        plot(hAx, resObj.cumLo(2:nLayers)-(max(cumsum(L0)) / 2), abs(resObj.TM(1, 2:nLayers)), 'o');
        title(hAx, 'Medium 1 Oscillating Temperature field');
        xlabel(hAx, '$x$-location', 'fontsize', 14, 'interpreter', 'latex')
        ylabel(hAx, '$|T_f|$', 'fontsize', 14, 'interpreter', 'latex')
        movegui(hF, 'south');
        
        [hF, hAx] = getAx();
        plotFunc(hAx, nLayers, resObj.q(1, :), L0, resObj.Posx, resObj.cumLo);
        plot(hAx, resObj.cumLo(2:nLayers)-(max(cumsum(L0)) / 2), abs(resObj.qM(1, 2:nLayers)), 'o');
        title(hAx, 'Medium 1 Oscillating Heat flux field');
        xlabel(hAx, '$x$-location', 'fontsize', 14, 'interpreter', 'latex')
        ylabel(hAx, '$|q_f|$', 'fontsize', 14, 'interpreter', 'latex')
        movegui(hF, 'north');
        
        [hF, hAx] = getAx();
        plotFunc(hAx, nLayers, resObj.v(1, :), L0, resObj.Posx, resObj.cumLo);
        plot(hAx, resObj.cumLo(2:nLayers)-(max(cumsum(L0)) / 2), abs(resObj.vM(1, 2:nLayers)), 'o');
        title(hAx, 'Oscillating Velocity field');
        xlabel(hAx, '$x$-location', 'fontsize', 14, 'interpreter', 'latex')
        ylabel(hAx, '$|v|$', 'fontsize', 14, 'interpreter', 'latex')
        movegui(hF, 'southeast');
        
        [hF, hAx] = getAx();
        plotFunc(hAx, nLayers, resObj.p(1, :), L0, resObj.Posx, resObj.cumLo);
        plot(hAx, resObj.cumLo(2:nLayers)-(max(cumsum(L0)) / 2), abs(resObj.pM(1, 2:nLayers)), 'o');
        title(hAx, 'Oscillating Pressure field');
        xlabel(hAx, '$x$-location', 'fontsize', 14, 'interpreter', 'latex')
        ylabel(hAx, '$|p|$', 'fontsize', 14, 'interpreter', 'latex')
        movegui(hF, 'northeast');
        
        [hF, hAx] = getAx();
        plotFunc(hAx, nLayers, resObj.T_m(1, :), L0, resObj.Posx, resObj.cumLo);
        plot(hAx, resObj.cumLo(2:nLayers)-(max(cumsum(L0)) / 2), abs(resObj.T_Mm(1, 2:nLayers)), 'o');
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
    
    function plotFunc(hAx, nLayers, G, L0, Posx, cumLo)
      for k = 2:1:(nLayers)
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
  end
  
end

end