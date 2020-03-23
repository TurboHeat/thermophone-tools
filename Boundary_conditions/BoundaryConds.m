function [const,const2,aaN,ccN,bb1,dd1] = BoundaryConds(Omega,MDM,Hamat,invHamat,invHb_f,Hb_f,Smat,N_layers,cumLo,aaN,ccN,bb1,dd1,Dimensions,w1_c,w2_c)

% p  - Pressure    field
% qf - Heat Flux   field
% v  - Velocity    field
% Tf - Temperature field

%% -----------------------------------------------------------%%
% Written twice - once for the solution starting from the first layer, and
% one starting from the last layer

const{1}=[0;bb1;0;dd1];
const2{1}=const{1};

const{N_layers}=[aaN;0;ccN;0];
const2{N_layers}=const{N_layers};

    if N_layers/2==round(N_layers/2)
        Nrounds=round(N_layers/2)+1;
    else
        Nrounds=round(N_layers/2);
    end
    
% Dimensions(13)=1;
    
%     load('Layer_function_DPL.mat')    
    %% ----------------------------------------------------------------------%%
    %% Temperature at the Edge boundaries (1)
    % Written twice - once for the solution starting from the first layer, and
    % one starting from the last layer
    Tes{1}=Hamat{1}*feval(Hb_f,w1_c{1},w2_c{1},cumLo(2));
    Tn{1}=(Tes{1}(4,1:4)*const{1});
    Tes{N_layers}=Hamat{N_layers}*feval(Hb_f,w1_c{N_layers},w2_c{N_layers},cumLo(N_layers+1));
    Tn{N_layers}=(Tes{N_layers}(4,1:4)*const{N_layers});

    Tbeta{1}=(MDM(1,15)+MDM(2,13))*[0; 0; Tn{1}; 0];
    Tbeta{N_layers}=(MDM(N_layers-1,15)+MDM(N_layers,13))*[0; 0; Tn{N_layers}; 0];
    
    %% Temperature at the Edge boundaries (2)
    
    Tn2{1}=(Tes{1}(4,1:4)*const{1});
    Tn2{N_layers}=(Tes{N_layers}(4,1:4)*const{N_layers});
    
    Tbeta2{1}=(MDM(1,15)+MDM(2,13))*[0; 0; Tn2{1}; 0];
    Tbeta2{N_layers}=(MDM(N_layers-1,15)+MDM(N_layers,13))*[0; 0; Tn2{N_layers}; 0];
    
    %% Inverted index for Layer Boundary Condition Calculations
    
    f=fliplr(1:N_layers);
    
    %%
    % p  - Pressure    field
    % qf - Heat Flux   field
    % v  - Velocity    field
    % Tf - Temperature field
%  Dimensions(13)=1; 
 
%     load('Layer_function_DPL.mat') 
    for i=2:Nrounds
        
        
        %% Calculating the boundary conditions (1)
        const{i}=((feval(invHb_f,w1_c{i},w2_c{i},cumLo(i)))*invHamat{i}*...
            (((Hamat{i-1}*feval(Hb_f,w1_c{i-1},w2_c{i-1},cumLo(i))))*const{i-1}...
            +( (Smat{i-1}-Smat{i}) + [0;0;(MDM(i-1,12)-MDM(i,10));0] - Tbeta{i-1} ) ));
        
        Tes{i}=Hamat{i}*feval(Hb_f,w1_c{i},w2_c{i},cumLo(i+1));
        Tn{i}=(Tes{i}(4,1:4)*const{i});
        Tbeta{i}=(MDM(i,15)+MDM(i+1,13))*[0; 0; Tn{i}; 0];
        
        %% Calculating the boundary conditions (2)
        const2{f(i)}=((feval(invHb_f,w1_c{f(i)},w2_c{f(i)},cumLo(f(i)+1)))*invHamat{f(i)}*...
            ((Hamat{f(i)+1}*feval(Hb_f,w1_c{f(i)+1},w2_c{f(i)+1},cumLo(f(i)+1)))*const2{f(i)+1}...
            +( (Smat{f(i)+1}-Smat{f(i)}) + [0;0;(MDM(f(i)+1,10)-MDM(f(i),12));0] + Tbeta2{f(i)+1} ) ));
        
        Tes{f(i)}=Hamat{f(i)}*feval(Hb_f,w1_c{f(i)},w2_c{f(i)},cumLo(f(i)));
        Tn2{f(i)}=(Tes{f(i)}(4,1:4)*const2{f(i)});
        Tbeta2{f(i)}=(MDM(f(i),15)+MDM(f(i)+1,13))*[0; 0; Tn2{f(i)}; 0];
        
    end

%% ----------------------------------------------------------------------%%

end
