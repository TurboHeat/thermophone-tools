function [P_front, V_front, Q_front, T_front] = ...
  inverseRayleighFunc(Ny, Nz, Dimensions, MDM, kay1, kay2, Mag_Prms_EXP, cumLo, maxO, Omega, Hamat, Hbmat, SCALE, BCIverify, vM)
%{
 ====================================================================
 - Inverse application of Rayleigh's second integral
 - Determination of thermophone boundary conditions (particularly heat flux)
 ====================================================================
%}
  
  y2 = linspace(-Dimensions(1)/2, Dimensions(1)/2, Ny);
  z2 = linspace(-Dimensions(2)/2, Dimensions(2)/2, Nz);
  
  [Y2, Z2] = meshgrid(y2, z2);
  
  %% Define reference height consistently
  % to change the suface curvature, you can make x2 a function of Y2 and Z2
  x2 = cumLo(end);
  
  %% Radial distance to interrogation point
  r = sqrt((Dimensions(3) - x2).^2+(Dimensions(4) - Y2).^2+(Dimensions(5) - Z2).^2);
  
  %% Where is the microphone WRT thermophone? near field or far-field?
  
  %Near-field distance calculation
  Co = sqrt(MDM(1, 3)*MDM(1, 7)/(MDM(1, 8) * MDM(1, 2))); %speed of sound
  Dia = sqrt(2*(Dimensions(1)^2)); %effective transducer diameter
  xff = Dia^2 / (8 * pi * Co / Omega);
  
  if (Dimensions(3) - x2) > xff
    %if in far-field
    % RMS pressure to far-field pressure
    Mag_Pff_1 = Mag_Prms_EXP .* sqrt(2);
    disp('the microphone is extimated to be in the far field')
  else
    %the recorded SPL is actually near field
    %if in near field
    % Near field RMS pressure to far field pressure
    Ro1 = (Dimensions(1)) .* (Dimensions(2)) .* Omega ./ (4 * pi * sqrt(MDM(1, 3)*MDM(1, 7)/(MDM(1, 8) * MDM(1, 2))));
    Mag_Pff_1 = sqrt(2) * Ro1 .* Mag_Prms_EXP ./ (Dimensions(3) - x2);
    disp('the microphone is estimated to be in the near field: consider moving the microphone further away.')
  end
  
  %% Factor in Rayleigh integral
  Factor1 = (Dimensions(1)) .* (Dimensions(2)) .* (1i .* Omega .* MDM(1, 2) / (2 * pi * numel(r)));
  
  % Velocity at the front of the multilayer slab (at Lth)
  % Assuming constant velocity on the whole surface
  V_front = ((Mag_Pff_1)) ./ (Factor1 * sum(sum((1 ./ r).*exp(-1i*kay1.*r))));
  
  %Recalibrating the phase to 45 degrees (means the real and imaginary parts
  %can be used to give two simultaneous equations later
  %V_front=-(abs(V_front)/sqrt(2))+1i*abs(V_front)/sqrt(2);
  
  %Recalibrating the phase to the phase angle in the simulated case
  %V_front=vM(:, 1)
  phase = angle(vM(:, 1));
  V_front = (abs(V_front) * cos(phase)) + 1i * abs(V_front) * sin(phase);
  
  
  %Position of Lth
  Lth = cumLo(1) - (2 * (MDM(1, 9) / (2 * MDM(1, 7) * Omega * MDM(1, 2)))^0.5);
  
  %% Back calculation of Boundary condition constants B and D
  % H matrix at Lth
  HmatLth = Hamat(:, :, 1) * (diag(diag((double(Hbmat(:, :, 1).^(Lth / SCALE))))));
  % H matrix on front boundary
  HmatB = Hamat(:, :, 1);
  
  syms B1 B2 D1 D2 real
  BCI = [0; B1 + 1i * B2; 0; D1 + 1i * D2];
  Resmat = HmatLth * BCI;
  J = Resmat(2);
  reJ = real(J); %interested in solving the real part
  imJ = imag(J); %This is just the phase of the signal
  % let us assume that the real and phase are opposite (we have made them this way)
  % we have reJ=real(V_front)
  % we have imJ=imag(V_front)
  % so we can write the answer in terms of B1 and D1 (real numbers)
  
  % first condition: reJ=real(V_front) gives B2 in terms of B1,D1 and D2
  vD1 = rhs(isolate(reJ-real(V_front) == 0, D1));
  %Substituting in for B2 in terms of B1,D1 and D2 into the imag part
  imJ2 = subs(imJ, D1, vD1);
  % second condition: imJ=imag(V_front) gives D2 in terms of B1 and D1
  vD2 = rhs(isolate(imJ2-imag(V_front) == 0, D2));
  %Substituting back in for B2 in terms of B1 and D1
  vD1 = subs(vD1, D2, vD2);
  
  % Re-evaluating the matrix with the substitutions
  % At the interface v=0
  % Real part
  BCI = [0; B1 + 1i * B2; 0; vD1 + 1i * vD2];
  Resmat = HmatB * BCI;
  vB1 = rhs(isolate(real(Resmat(2)) == 0, B1));
  vD2 = subs(vD2, B1, vB1);
  vD1 = subs(vD1, B1, vB1);
  % Re-evaluating the matrix with the substitutions
  % At the interface v=0
  % Imaginary part
  BCI = [0; vB1 + 1i * B2; 0; vD1 + 1i * vD2];
  Resmat = HmatB * BCI;
  vB2 = rhs(isolate(imag(Resmat(2)) == 0, B2));
  vD2 = subs(vD2, B2, vB2);
  vD1 = subs(vD1, B2, vB2);
  vB1 = subs(vB1, B2, vB2);
  
  %Final boundary conditions
  BCI = double([0; vB1 + 1i * vB2; 0; vD1 + 1i * vD2]);
  Resmat = HmatB * BCI;
  
  ResmatCheck = vpa([HmatB * BCI, HmatB * BCIverify(:, 1)]); %We see that there is very good agreement!
  BCICheck = ([BCI, BCIverify(:, 1)]); %We see that there is very good agreement.
  % However, it depends on the angle between the real and complex parts of the heat-flux.
  % The simulation case allows for an estimate for the correct phase angle. The error is the
  % largest on the temperature, since this one is the smallest number.
  
  %Frontside oscillating heat flux per unit area
  Q_front = Resmat(3);
  P_front = Resmat(1);
  T_front = Resmat(4);
  
  %%
  
end
