function [T, q] = meanTemperature(MDM, nLayers, cumLo)

%Initialisation of all Kernels
A = zeros(1, nLayers);
B = A;
C = A;
D = A;
M = A;
N = A;
O = A;

% Calculation of kernels from the Temperature and heat flux equations at the boundary between layers 2-3
A(2) = (cumLo(3) + ((MDM(2, 9) / (MDM(1, 15) + MDM(2, 13))) - cumLo(2)));
B(2) = ((MDM(2, 11)) * (cumLo(2)) * ((cumLo(2) / (2 * MDM(2, 9))) - (1 / (MDM(1, 15) + MDM(2, 13)))) + (MDM(1, 12) - (MDM(2, 10)))) - (MDM(2, 11) * (cumLo(3)^2)) / (2 * MDM(2, 9));
C(2) = -(((MDM(2, 15) + MDM(3, 13)) * (cumLo(3) + ((MDM(2, 9) / (MDM(1, 15) + MDM(2, 13))) - cumLo(2)))) + MDM(2, 9));
D(2) = ((MDM(2, 11)) * (cumLo(3))) + (MDM(2, 12) - MDM(3, 10)) - (MDM(2, 15) + MDM(3, 13)) * (((MDM(2, 11)) * (cumLo(2)) * ((cumLo(2) / (2 * MDM(2, 9))) - (1 / (MDM(1, 15) + MDM(2, 13)))) + (MDM(1, 12) - (MDM(2, 10)))) - (MDM(2, 11) * (cumLo(3)^2)) / (2 * MDM(2, 9)));

M(2) = ((MDM(2, 10) + (MDM(2, 11) * cumLo(2))) / MDM(2, 9));
N(2) = -1 / MDM(2, 9);
O(2) = (((MDM(2, 11)) * ((cumLo(2))^2)) / (2 * MDM(2, 9)));

% If there are more than 3 layers, we compute the rest iteratively
if nLayers > 3
  for k = 3:nLayers - 1

    %Calculation of kernels from the Temperature and heat flux
    %equations at the boundary between ith and i+1th layer

    M(k) = ((MDM(k, 10) + (MDM(k, 11) * cumLo(k))) / MDM(k, 9));
    N(k) = -1 / MDM(k, 9);
    O(k) = (((MDM(k, 11)) * ((cumLo(k))^2)) / (2 * MDM(k, 9)));

    A(k) = ((cumLo(k+1) - cumLo(k)) * N(k)) * C(k-1) + A(k-1);
    B(k) = ((cumLo(k+1) - cumLo(k)) * N(k)) * D(k-1) + B(k-1) + ((O(k) - ((MDM(k, 11)) * (cumLo(k+1))^2) / (2 * MDM(k, 9))) + (cumLo(k+1) - cumLo(k)) * M(k));
    C(k) = ((-(MDM(k, 9) + ((MDM(k, 15) + MDM(k+1, 13))) * (cumLo(k+1) - cumLo(k)))) * N(k)) * C(k-1) - ((MDM(k, 15) + MDM(k+1, 13))) * A(k-1);
    D(k) = ((-(MDM(k, 9) + ((MDM(k, 15) + MDM(k+1, 13))) * (cumLo(k+1) - cumLo(k)))) * N(k)) * D(k-1) - ((MDM(k, 15) + MDM(k+1, 13))) * B(k-1) + (((-(MDM(k, 9) + ((MDM(k, 15) + MDM(k+1, 13))) * (cumLo(k+1) - cumLo(k)))) * M(k)) + ((MDM(k, 11) * (cumLo(k+1))) + (MDM(k, 12) - MDM(k+1, 10)) - ((MDM(k, 15) + MDM(k+1, 13))) * (O(k) - ((MDM(k, 11)) * (cumLo(k+1))^2) / (2 * MDM(k, 9)))));

  end
end

% Closing the problem with the boundary conditions
res1 = cumLo(nLayers) * M(nLayers-1) - M(nLayers-1) * cumLo(nLayers-1) + O(nLayers-1) - ((MDM(nLayers-1, 11)) * (cumLo(nLayers))^2) / (2 * MDM(nLayers-1, 9));
res2 = (MDM(nLayers-1, 11) * (cumLo(nLayers))) - MDM(nLayers-1, 9) * M(nLayers-1);
res3 = -((MDM(nLayers-1, 15) + MDM(nLayers, 13)));
res4 = res2 + (MDM(nLayers-1, 12) - MDM(nLayers, 10)) + res3 * res1;
res5 = ((res3 * (cumLo(nLayers) - cumLo(nLayers-1)) * N(nLayers-1)) - MDM(nLayers-1, 9) * N(nLayers-1));

% Determining the constants of the first layer
mean_c(1, 1) = -(res5 * D(nLayers-2) + res3 * B(nLayers-2) + res4) / ((res5 * C(nLayers-2) + res3 * A(nLayers-2)));
mean_c(1, 2) = (MDM(2, 10)) * (cumLo(2)) * (((cumLo(2)) / (2 * MDM(2, 9))) - (1 / (MDM(1, 15) + MDM(2, 13)))) + ...
               mean_c(1, 1) * ((MDM(2, 9) / (MDM(1, 15) + MDM(2, 13))) - cumLo(2)) + (MDM(1, 12) - (MDM(2, 10)));

% Preallocation:
[T,q] = deal(cell(nLayers,1));
[pTa,pqa] = deal(cell(nLayers-1,1));

% Temperature and heat-flux at the first interface
pTa{1} = mean_c(1, 1) * (cumLo(2) + ((MDM(2, 9) / (MDM(1, 15) + MDM(2, 13))) - cumLo(2))) + ((MDM(2, 11)) * (cumLo(2)) * ((cumLo(2) / (2 * MDM(2, 9))) - (1 / (MDM(1, 15) + MDM(2, 13)))) + (MDM(1, 12) - (MDM(2, 10)))) - (MDM(2, 11) * (cumLo(2)^2)) / (2 * MDM(2, 9));
pqa{1} = -MDM(2, 9) * (mean_c(1, 1)) + ((MDM(2, 11)) * (cumLo(2))) + (MDM(1, 12) - MDM(2, 10));

syms x
for k = 2:nLayers - 1
  % Determining the constants of the ith layer
  mean_c(k, 1) = M(k) + N(k) * pqa{k-1};
  mean_c(k, 2) = pTa{k-1} - N(k) * pqa{k-1} * cumLo(k) - M(k) * cumLo(k) + O(k);

  % Temperature and heat-flux at the ith interface
  pTa{k} = A(k) * mean_c(1, 1) + B(k);
  pqa{k} = C(k) * mean_c(1, 1) + D(k);

  % Temperature solution with solved coefficients prepared into matlab function for future use
  T{k} = matlabFunction(mean_c(k, 1)*(x)+mean_c(k, 2)-((MDM(k, 11)) * (x)^2)/(2 * MDM(k, 9)));
  % Heat-Flux solution with solved coefficients prepared into matlab function for future use
  q{k} = matlabFunction(-MDM(k, 9)*(mean_c(k, 1))+(MDM(k, 11) * (x)));

end

%% Temperature and heat-flux solution in extremity layers
T{1} = double(mean_c(1, 2));
q{1} = double(mean_c(1, 1));
T{nLayers} = A(nLayers-1) * mean_c(1, 1) + B(nLayers-1);
q{nLayers} = C(nLayers-1) * mean_c(1, 1) + D(nLayers-1);

end
