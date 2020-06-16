function [BCI, Hamat, w1_c, w2_c, Smat, Hbmat, SCALE] = systemSolver(Omega, MDM, nLayers, cumLo)
% Preallocation
[w1_c, w2_c] = deal(mp(complex(zeros(nLayers, 1))));
Hamat = mp(complex(ones(4, 4, nLayers)));
[Hbmat, invHbmat] = deal(mp(complex(zeros(4, 4, nLayers))));
Smat = mp(complex(zeros(4, nLayers)));

for k = 1:nLayers

    % Spatial scaling parameter (improves the precision of the code by reducing the
    % size of the exponential terms
    SCALE = 10^-3;

    % Decoding from MDM matrix in ith layer into the parameter space
    omega = Omega;
    rho = MDM(k, 2);
    B = MDM(k, 3);
    alphaT = MDM(k, 4);
    lambda = MDM(k, 5);
    meu = MDM(k, 6);
    Cp = MDM(k, 7);
    Cv = MDM(k, 8);
    kappa = MDM(k, 9);
    So = MDM(k, 11);
    To = MDM(k, 14);

    % Preliminary quantities
    gamma = Cp / Cv; %Ratio of specific heats
    Co = sqrt(B*gamma/rho); %Phase velocity
    lk = Co * kappa / (B * Cp); %characteristic length of conduction processes
    lv = (lambda + 2 * meu) / (rho * Co); %characteristic length of viscous processes
    visc = ((B ./ (1i .* omega)) + lambda + 2 * meu); %viscous terms

    % Exponential coefficients
    w1_c(k) = ((omega / Co) * (1 - (1i .* omega * lv / (2 * Co)) - ((1i * omega * lk * (1 - (1 / gamma))) / (2 * Co))));
    w2_c(k) = (sqrt(1i * omega * gamma / (Co * lk)) * (1 + (((1i * omega * lk * (1 - (1 / gamma))) / (2 * Co)) + ((1i * omega * lv / (2 * Co)) * (1 - gamma)))));

    % L1 and L2 see Guiraud paper https://doi.org/10.1016/j.jsv.2019.05.001
    L1 = ((-1i * (B * (Cv - Cp) - Cv * omega * 1i * visc)) / (omega * alphaT * To * B));
    L2 = -(visc) * kappa * 1i / (omega * alphaT * To * B * rho);

    % Gmik and Gmsig see Guiraud paper https://doi.org/10.1016/j.jsv.2019.05.001
    Gmik = -(L1 + L2 * ((w1_c(k)).^2)) * (w1_c(k));
    Gmsig = -(L1 + L2 * ((w2_c(k)).^2)) * (w2_c(k));

    % Fik and Fsig see Guiraud paper https://doi.org/10.1016/j.jsv.2019.05.001
    Fik = (alphaT * B) + ((visc) * (Gmik) * (w1_c(k)));
    Fsig = (alphaT * B) + ((visc) * (Gmsig) * (w2_c(k)));

    % Hik and Hsig see Guiraud paper https://doi.org/10.1016/j.jsv.2019.05.001
    Hik = kappa * w1_c(k);
    Hisig = kappa * w2_c(k);

    % Internal Forcing array
    Smat(1, k) = alphaT * B * So / (1i * omega * rho * Cv);
    Smat(end, k) = So / (1i * omega * rho * Cv);

    % Ha see Guiraud paper https://doi.org/10.1016/j.jsv.2019.05.001
    Hamat(1:end-1, :, k) = [Fik, Fik, Fsig, Fsig; ...
        Gmik, -Gmik, Gmsig, -Gmsig; ...
        Hik, -Hik, Hisig, -Hisig];

    % Hb see Guiraud paper https://doi.org/10.1016/j.jsv.2019.05.001
    tmp = exp([-w1_c(k), w1_c(k), -w2_c(k), w2_c(k)]).^SCALE;
    Hbmat(:, :, k) = diag(tmp);

    % Inverse of Hb matrix
    invHbmat(:, :, k) = diag(tmp([2, 1, 4, 3]));
end

%% Calculation of the constants via the boundary conditions
[BCI] = Lib.boundaryConds(double(MDM), Hamat, Smat, nLayers, cumLo, Hbmat, invHbmat, SCALE);

%Conversion of pertinent parameters to double for the following stages of calculation
BCI = double(BCI);
w1_c = double(w1_c);
w2_c = double(w2_c);
Hamat = double(Hamat);

end