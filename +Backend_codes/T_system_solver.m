function [BCI, Hamat, w1_c, w2_c] = T_system_solver(Omega, invHa_f, invHb_f, Ha_f, Hb_f, w1_f, w2_f, S_f, MDM, N_layers, cumLo, aaN, ccN, bb1, dd1, Dimensions);

[w1_c, w2_c] = deal(zeros(N_layers,1));
[Smat, Hamat, invHamat] = deal(cell(N_layers,1)); % TODO: turn to multidimensional arrays

for idx = 1:N_layers
  w1_c(idx) = feval(w1_f, MDM(idx, 3), MDM(idx, 7), MDM(idx, 8), MDM(idx, 9), MDM(idx, 5), MDM(idx, 6), Omega, MDM(idx, 2));
  w2_c(idx) = feval(w2_f, MDM(idx, 3), MDM(idx, 7), MDM(idx, 8), MDM(idx, 9), MDM(idx, 5), MDM(idx, 6), Omega, MDM(idx, 2));
  Smat{idx} = feval(S_f, MDM(idx, 3), MDM(idx, 8), MDM(idx, 11), MDM(idx, 4), Omega, MDM(idx, 2));
  Hamat{idx} = feval(Ha_f, MDM(idx, 3), MDM(idx, 7), MDM(idx, 8), MDM(idx, 14), MDM(idx, 4), MDM(idx, 9), MDM(idx, 5), MDM(idx, 6), Omega, MDM(idx, 2), w1_c(idx), w2_c(idx));
  invHamat{idx} = feval(invHa_f, MDM(idx, 3), MDM(idx, 7), MDM(idx, 8), MDM(idx, 14), MDM(idx, 4), MDM(idx, 9), MDM(idx, 5), MDM(idx, 6), Omega, MDM(idx, 2), w1_c(idx), w2_c(idx));
end

[const, const2, aaN, ccN, bb1, dd1] = Boundary_conditions.BoundaryConds(...
  Omega, MDM, Hamat, invHamat, invHb_f, Hb_f, Smat, N_layers, cumLo, aaN, ccN, bb1, dd1, Dimensions, w1_c, w2_c);

[aN, b1, cN, d1, BCI] = Boundary_conditions.SolveCONSTS(const, const2, N_layers, aaN, bb1, ccN, dd1);

end
