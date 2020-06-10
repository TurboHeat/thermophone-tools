classdef ThermophoneEXPResults
    % THERMOPHONESIMRESULTS Simple data class for holding simulation results

    properties (GetAccess = public, SetAccess = private)
        ETA1 % Array of efficiencies from back side [thermal product, thermal, acoustic, gamma, total]
        PRES1 % Array of pressures from front side [pk Far Field, rms Far Field, rms Near Field, Phase]
        TM % Oscillating Temperature result at Layer boundaries
        qM % Oscillating Heat-flux result at Layer boundaries
        vM % Oscillating velocity result at Layer boundaries
        pM % Oscillating pressure result at Layer boundaries
        Omega % Angular frequency array
        cumLo % Cumulative layer thickness
        layers % Layers (vector) used in the simulation
        PQ % Power/area delivered by thermophone
        PW % Power/area delivered by Solid-drive
        Ratio % Ratio of powers
        VQ % Thermophone rms velocity of flow at Lth
        VW % Solid drive rms velocity of flow at surface
    end

    methods (Access = public)

        function optsObj = ThermophoneEXPResults(optsKW)
            arguments
                optsKW.ETA1
                optsKW.PRES1
                optsKW.TM
                optsKW.qM
                optsKW.vM
                optsKW.pM
                optsKW.Omega
                optsKW.cumLo
                optsKW.layers
                optsKW.PQ
                optsKW.PW
                optsKW.Ratio
                optsKW.VQ
                optsKW.VW
            end

            % Copy field contents into object properties
            fn = fieldnames(optsKW);
            for idxF = 1:numel(fn)
                optsObj.(fn{idxF}) = optsKW.(fn{idxF});
            end
        end

    end

end