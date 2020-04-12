function [Mag_Pff_1, Mag_Prms_ff_1, Mag_Prms_nf_ff_1, Ph_Pff_1, ...
  Mag_Pff_2, Mag_Prms_ff_2, Mag_Prms_nf_ff_2, Ph_Pff_2] = ...
  Rayleigh_func(Ny, Nz, Dimensions, MDM, kay1, kay2, vM, cumLo, maxO, Omega)
%% ==================================================================== %%

%% Application of Rayleigh's second integral

y2 = linspace(-Dimensions(1)/2, Dimensions(1)/2, Ny);
z2 = linspace(-Dimensions(2)/2, Dimensions(2)/2, Nz);

[Y2, Z2] = meshgrid(y2, z2);

%% Define reference height consistently
% to change the suface curvature, you can make x2 a function of Y2 and Z2
x2 = cumLo(end);

%% Radial distance to interrogation point
r = sqrt((Dimensions(3) - x2).^2+(Dimensions(4) - Y2).^2 + (Dimensions(5) - Z2).^2);

% Assuming constant velocity
% Velocity at the front of the multilayer slab
V_front = vM(:, 1);
% Velocity at the back of the multilayer slab
V_back = vM(:, end);

% Factor in Rayleigh integral
Factor1 = (Dimensions(1)) .* (Dimensions(2)) .* (1i .* Omega .* MDM(1, 2) / (4 * pi * numel(r)));
Factor2 = (Dimensions(1)) .* (Dimensions(2)) .* (1i .* Omega .* MDM(end, 2) / (4 * pi * numel(r)));

Ro1 = (Dimensions(1)) .* (Dimensions(2)) .* Omega ./ (2 * pi * sqrt(MDM(1, 3)*MDM(1, 7)/(MDM(1, 8) * MDM(1, 2))));
Ro2 = (Dimensions(1)) .* (Dimensions(2)) .* Omega ./ (2 * pi * sqrt(MDM(end, 3)*MDM(end, 7)/(MDM(end, 8) * MDM(end, 2))));

% Preallocation:
[Mag_Pff_1, Mag_Pff_2, Ph_Pff_1, Ph_Pff_2] = deal(zeros(1, maxO));

for k = 1:maxO
  Mag_Pff_1(k) = abs(Factor1(k)*sum(sum((V_front(k) ./ r).*exp(-1i*kay1(k).*r))));
  Mag_Pff_2(k) = abs(Factor2(k)*sum(sum((V_back(k) ./ r).*exp(-1i*kay2(k).*r))));
  %Phase
  Ph_Pff_1(k) = angle(Factor1(k)*sum(sum((V_front(k) ./ r).*exp(-1i*kay1(k).*r))));
  Ph_Pff_2(k) = angle(Factor2(k)*sum(sum((V_back(k) ./ r).*exp(-1i*kay2(k).*r))));
end

% RMS pressure
Mag_Prms_ff_1 = Mag_Pff_1 ./ sqrt(2);
Mag_Prms_ff_2 = Mag_Pff_2 ./ sqrt(2);
% Near field RMS pressure
Mag_Prms_nf_ff_1 = Mag_Prms_ff_1 .* (Dimensions(3) - x2) ./ Ro1;
Mag_Prms_nf_ff_2 = Mag_Prms_ff_2 .* (Dimensions(3) - x2) ./ Ro2;

end
