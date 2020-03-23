function [const, const2, aaN, ccN, bb1, dd1] = BoundaryConds(Omega, MDM, Hamat, invHamat, invHb_f, Hb_f, Smat, N_layers, cumLo, aaN, ccN, bb1, dd1, Dimensions, w1_c, w2_c)

% p  - Pressure    field
% qf - Heat Flux   field
% v  - Velocity    field
% Tf - Temperature field

%% -----------------------------------------------------------%%
% Written twice - once for the solution starting from the first layer, and
% one starting from the last layer

const{1} = [0; bb1; 0; dd1];
const2{1} = const{1};

const{N_layers} = [aaN; 0; ccN; 0];
const2{N_layers} = const{N_layers};

if N_layers / 2 == round(N_layers/2)
  Nrounds = round(N_layers/2) + 1;
else
  Nrounds = round(N_layers/2);
end

% Dimensions(13)=1;

%     load('Layer_function_DPL.mat')

%% ----------------------------------------------------------------------%%

%% Temperature at the Edge boundaries (1)
% Written twice - once for the solution starting from the first layer, and
% one starting from the last layer

Tes{1} = Hamat{1} * feval(Hb_f, w1_c(1), w2_c(1), cumLo(2));
tmp = double(Tes{1}(4, 1:4));
Tn{1} = tmp * const{1};
Tn{N_layers} = tmp * const{N_layers};
Tes{N_layers} = Hamat{N_layers} * feval(Hb_f, w1_c(N_layers), w2_c(N_layers), cumLo(N_layers+1));

Tbeta{1} = double(MDM(1, 15) + MDM(2, 13)) * [0; 0; Tn{1}; 0];
Tbeta{N_layers} = double(MDM(N_layers-1, 15) + MDM(N_layers, 13)) * [0; 0; Tn{N_layers}; 0];

%% Temperature at the Edge boundaries (2)
Tn2{1} = Tn{1};
Tn2{N_layers} = Tn{N_layers};
Tbeta2{1} = Tbeta{1};
Tbeta2{N_layers} = Tbeta{N_layers};

%% Inverted index for Layer Boundary Condition Calculations
f = fliplr(1:N_layers);

%%
% p  - Pressure    field
% qf - Heat Flux   field
% v  - Velocity    field
% Tf - Temperature field
%  Dimensions(13)=1;

%     load('Layer_function_DPL.mat')
for k = 2:Nrounds
  
  %% Calculating the boundary conditions (1)
  const{k} = ( double(feval(invHb_f, w1_c(k), w2_c(k), cumLo(k)) * invHamat{k})) * ...
    ( double(Hamat{k-1} * feval(Hb_f, w1_c(k-1), w2_c(k-1), cumLo(k))) * const{k-1} + ...
     (double((Smat{k-1} - Smat{k}) + [0; 0; (MDM(k-1, 12) - MDM(k, 10)); 0]) - Tbeta{k-1}) );
  
  Tes{k} = Hamat{k} * feval(Hb_f, w1_c(k), w2_c(k), cumLo(k+1));
  Tn{k} = double(Tes{k}(4, 1:4)) * const{k};
  Tbeta{k} = double(MDM(k, 15) + MDM(k+1, 13)) * [0; 0; Tn{k}; 0];
  
  %% Calculating the boundary conditions (2)
  const2{f(k)} = double(feval(invHb_f, w1_c(f(k)), w2_c(f(k)), cumLo(f(k)+1)) * invHamat{f(k)}) * ...
    ( double(Hamat{f(k)+1} * feval(Hb_f, w1_c(f(k)+1), w2_c(f(k)+1), cumLo(f(k)+1))) * const2{f(k)+1} +...
     (double((Smat{f(k)+1} - Smat{f(k)}) + [0; 0; (MDM(f(k)+1, 10) - MDM(f(k), 12)); 0]) + Tbeta2{f(k)+1}) ...
    );

  Tes{f(k)} = Hamat{f(k)} * feval(Hb_f, w1_c(f(k)), w2_c(f(k)), cumLo(f(k)));
  Tn2{f(k)} = double(Tes{f(k)}(4, 1:4)) * const2{f(k)};
  Tbeta2{f(k)} = double(MDM(f(k), 15) + MDM(f(k)+1, 13)) * [0; 0; Tn2{f(k)}; 0];
  
end

%% ----------------------------------------------------------------------%%

end
