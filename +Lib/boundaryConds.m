function [BCI] = boundaryConds(MDM, Hamat, Smat, nLayers, cumLo, Hbmat, invHbmat, SCALE)
cumLo = cumLo / SCALE;

%% ----------------------------------------------------------------------%%
% p  - Pressure    field
% qf - Heat Flux   field
% v  - Velocity    field
% Tf - Temperature field

%% -----------------------------------------------------------%%
%Using this pad matrix allows for the computing of the robin boundary
%conditions without the need for an iterative or symbolic solution
pad = [0, 0, 0, 0; 0, 0, 0, 0; 1, 1, 1, 1; 0, 0, 0, 0];

%iterating for the least possible number of times in order to obtain the
%solution Nrounds
if nLayers / 2 == round(nLayers/2)
    Nrounds = round(nLayers/2) + 1;
else
    Nrounds = round(nLayers/2);
end

% Inverted index for Layer Boundary Condition Calculations
f = fliplr(1:nLayers);

% Preallocation
[invH, H, HH, S, invaS, SuminvaS, Mo] = deal(cell(Nrounds, 1));
[invHb, Hb, HHb, Sb, invaSb, SuminvaSb, Mob] = deal(cell(Nrounds, 1));

% First layer Initialisation of the solution kernels
[Mo{1}, Mob{1}, Mob{nLayers}] = deal(eye(size(Hamat(:, :, 1))));
[SuminvaS{1}, SuminvaSb{1}, SuminvaSb{nLayers}] = deal([0; 0; 0; 0]);

% Invert Hamat
%{
invHamat = mp(zeros(size(Hamat)));
for k = 1:size(Hamat,3)
  invHamat(:,:,k) = inv( Hamat(:,:,k) );
end
%}

% Looping over the layers
for k = 2:Nrounds
    % Forward solution
    invH{k} = (diag(diag(invHbmat(:, :, k).^cumLo(k)))) / Hamat(:, :, k); %inv(Hb(L1))
    %   invH{k} = (diag(diag(invHbmat(:,:,k).^cumLo(k)))) * invHamat(:,:,k); %inv(Hb(L1))
    H{k} = (Hamat(:, :, k - 1) + ((MDM(k - 1, 15) + MDM(k, 13)) * pad)) * (diag(diag(Hbmat(:, :, k - 1).^cumLo(k)))); %
    HH{k} = invH{k} * H{k};
    S{k} = ((Smat(:, k - 1) - Smat(:, k)) + [0; 0; (MDM(k - 1, 12) - MDM(k, 10)); 0]);
    invaS{k} = invH{k} * S{k};
    SuminvaS{k} = HH{k} * SuminvaS{k-1} + invaS{k};
    Mo{k} = (HH{k} * Mo{k - 1});

    % Reverse solution
    invHb{f(k)} = (diag(diag(invHbmat(:, :, f(k)).^cumLo(f(k)+1)))) / Hamat(:, :, f(k));
    %   invHb{f(k)} = (diag(diag(invHbmat(:,:,f(k)).^cumLo(f(k)+1)))) * invHamat(:,:,f(k));
    Hb{f(k)} = (Hamat(:, :, f(k) + 1) - ((MDM(f(k), 15) + MDM(f(k) + 1, 13)) * pad)) * (diag(diag(Hbmat(:, :, f(k) + 1).^cumLo(f(k) + 1))));
    HHb{f(k)} = invHb{f(k)} * Hb{f(k)};
    Sb{f(k)} = ((Smat(:, f(k) + 1) - Smat(:, f(k))) + [0; 0; (MDM(f(k) + 1, 10) - MDM(f(k), 12)); 0]);
    invaSb{f(k)} = invHb{f(k)} * Sb{f(k)};
    SuminvaSb{f(k)} = HHb{f(k)} * SuminvaSb{f(k)+1} + invaSb{f(k)};
    Mob{f(k)} = HHb{f(k)} * Mob{f(k)+1};
end
inerog = Nrounds; %meet-in-the-middle between forward an backward solutions


% Analytically determined solution matrix kernel 1
Finmat = [Mo{inerog}(:, [2, 4]), -Mob{inerog}(:, [1, 3])];

% Analytically determined solution matrix kernel 2
Finmat2 = SuminvaSb{inerog} - SuminvaS{inerog};

% Analytic determination of the constants
res = Finmat \ Finmat2;

% boundary constants
b1 = res(1);
d1 = res(2);
aN = res(3);
cN = res(4);

% Populating matrix of constants (solutions) for each layer;
[BCI, BCI2] = deal(mp(complex(zeros(4, Nrounds + 1))));
tmp = [0, aN; b1, 0; 0, cN; d1, 0];
BCI(:, [1, k]) = tmp;
BCI2(:, [1, f(1)]) = tmp;

% TEST: BCI and BCI2 should be the same.

for k = 2:Nrounds
    BCI(:, k) = Mo{k} * tmp(:, 1) + SuminvaS{k};
    BCI2(:, f(k)) = Mob{f(k)} * tmp(:, 2) + SuminvaSb{f(k)};
end


BCI = [BCI(:, 1:Nrounds), BCI2(:, Nrounds + 1:nLayers)];

end
