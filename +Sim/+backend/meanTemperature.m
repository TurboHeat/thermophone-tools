function [mean_c] = meanTemperature(MDM, N_layers, cumLo, dimensions)

%% Initialising variables
dK = zeros(1, N_layers-2);
dL = zeros(1, N_layers-1);
ProddK = zeros(1, N_layers-2);
Sb = zeros(1, N_layers-2);
S = zeros(1, N_layers-2);
JoN = zeros(1, N_layers-2);
T = cell(1, 4);
q = cell(1, 4);

%% Black-body radiation
SIGMA = 5.670373 * 10^-8; %Stephan-Boltzmann constant
EPSILON = 1; %Emissivity

%% Sum of all input power per unit area
G = sum(MDM(:, 10)+(MDM(:, 11) .* [0; MDM(2:end-1, 1); 0])+MDM(:, 12)); %sum of all input generation

%% Energy Budget estimation
%{
This section calculates an estimate temperature for the thermophone,
based on the overall energy budget (energy in = energy out).
If control_h is set to true, it estimates the radiation loss for given loss
coefficients. If control_h is set to false, it estimates the radiation and
the natural-convection heat transfer coefficient aswell.
%}

if dimensions(15) %if h is defined by the user

    h1 = MDM(2, 13) + MDM(1, 15);
    h2 = MDM(end, 13) + MDM(end-1, 15);

    p = [1, 0, 0, (h1 + h2) / (2 * SIGMA * EPSILON), (((h1 + h2) / (2 * SIGMA * EPSILON) * MDM(1, 14)) - G / (2 * SIGMA * EPSILON) - (MDM(1, 14)^4))];
    temp = (roots(p));
    temp = temp(imag(temp) == 0);
    T_est = temp(temp > 0);
    
%{
If the heat transfer coefficient is unphysically large,
it is possible that there are only negative solutions but we still want the
code to run so we will select the smallest of the negative solutions and
display a warning
%}
    if isempty(T_est)
        T_est = min(abs(real(temp)));
        warning('Check that the heat transfer coefficients are realistic');
    end
    
else %if h is defined by natural convection and is dictated by the code.

    syms Temp

    PB = 0.54 * (MDM(1, 7) * (dimensions(1)^3) * (dimensions(2)^3) * MDM(1, 4) * 9.81 * (MDM(1, 2)^2) / ((2 * (dimensions(1)) + 2 * (dimensions(2)))^3 * MDM(1, 5) * MDM(1, 9)))^(1 / 4) * MDM(1, 9) * (2 * dimensions(1) + 2 * dimensions(2)) / (dimensions(1) * dimensions(2));
    T_est = double(vpasolve(SIGMA * EPSILON * (Temp^4 - MDM(1, 14)^4) + PB * ((Temp - MDM(1, 14))^(5 / 4)) - G / 2));
    h1 = PB * ((T_est - MDM(1, 14))^(0.25));
    h2 = h1;
    
end

%% Spatial Temperature solution

% Heat-flux at the boundaries
q1 = (MDM(1, 12) + MDM(2, 10)) - SIGMA * EPSILON * (T_est^4 - MDM(1, 14)^4);
q2 = (MDM(end, 10) + MDM(end -1, 12)) - SIGMA * EPSILON * (T_est^4 - MDM(1, 14)^4);

%Boundary coefficients
Vo = (MDM(2, 9) - ((h1) * cumLo(2))) / (h1);
Bo = (q1 + (MDM(2, 11) * cumLo(2) * (((h1) * cumLo(2) / (2 * MDM(2, 9))) - 1))) / (h1);
Ro = (q2 + (MDM(end-1, 11) * cumLo(end-1) * (((h2) * cumLo(end -1) / (2 * MDM(end -1, 9))) + 1))) / (h2);
Uo = -(MDM(end -1, 9) + ((h2) * cumLo(end-1))) / (h2);

%Internal Boundary conditions calculation
ProddK(1) = 1;
Mo = cumLo(2);

if N_layers > 3
    for k = 2:N_layers - 2

        dK(k) = MDM(k, 9) / MDM(k+1, 9);

        dL(k) = cumLo(k+1) - cumLo(k);

        ProddK(k) = ProddK(k-1) * dK(k);

        Mo = Mo + ProddK(k-1) * dL(k);

        Sb(k) = ((MDM(k + 1, 11) - MDM(k, 11)) * cumLo(k + 1) / MDM(k + 1, 9)) + (MDM(k + 1, 10) - MDM(k, 12));

        S(k) = ((cumLo(k)^2) - (cumLo(k + 1)^2)) * MDM(k, 11) / (2 * MDM(k, 9));

    end

    dL(k+1) = cumLo(k+2) - cumLo(k+1);
    Mo = Mo + ProddK(k) * dL(k+1);

end

Po = ProddK(end);
Qo = 0;

JoN(1) = Mo;
Jo = 0;

for k = 2:N_layers - 2

    JoN(k) = ((JoN(k-1) - dL(k)) / dK(k)) * Sb(k);

    Qo = Qo + ProddK(end) * Sb(k) / ProddK(k);

    Jo = Jo + JoN(k) + S(k);
end

%% Calculation of constants
mean_c(1, 1) = (Bo + Jo - ((Ro + (Qo * Uo))) - (cumLo(end -1) * Qo)) / ...
    ((cumLo(end -1) * Po) + (Po * Uo) - Vo - Mo);

mean_c(1, 2) = (Bo + (mean_c(1, 1) * Vo));

for k = 2:N_layers - 2
    mean_c(k, 1) = dK(k) * mean_c(k-1, 1) + Sb(k);
    mean_c(k, 2) = (mean_c(k - 1, 1) - mean_c(k, 1)) * cumLo(k+1) + (((MDM(k + 1, 11) / MDM(k + 1, 9)) - (MDM(k, 11) / MDM(k, 9))) * (cumLo(k+1)^2) / 2) + mean_c(k-1, 2);
end

%This is a check to make sure the algorithm is correct
%mean_c(N_layers - 2, 2)=(Ro+(Qo*Uo)+(Po*Uo*mean_c(1, 1))); %this line is to check it is correct

end
