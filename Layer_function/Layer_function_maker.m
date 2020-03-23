%close all
clear all
clc

syms Lo So rho B alphaT lambda meu Cp Cv To kappa omega x w1s w2s

gamma=Cp/Cv;                  %Ratio of specific heats
Co=sqrt(B*gamma/rho);         %Phase velocity
lk=Co*kappa/(B*Cp);           %characteristic length of conduction processes
lv=(lambda+2*meu)/(rho*Co);   %characteristic length of viscous processes


% % To=rho*(Cp-Cv)/(B*alphaT^2);  %Ambient temperature
% % if (Cp-Cv)==0                 %1in the event a solid is used to compute pressure and velocity.
% %     To=300;                   %Artificial temperature is imposed to avoid errors
% % end

%% Computing the coefficients

w1=(omega/Co)*(1 - (1i*omega*lv/(2*Co)) -  ((1i*omega*lk*(1-(1/gamma)))/(2*Co)) );
w2=sqrt(1i*omega*gamma/(Co*lk) )*(1 + (((1i*omega*lk*(1-(1/gamma)))/(2*Co)) + ((1i*omega*lv/(2*Co))*(1-gamma)))  );

L1=-2*1i*(-rho*Cv*(meu + lambda/2)*omega*1i - B*Cp*rho/2)/(omega*alphaT*To*B*rho);
L2=kappa*((-2*meu - lambda)*omega + B*1i)*1i/(omega^2*alphaT*To*B*rho);

Fmik= (alphaT*B)-(( (B/(1i*omega)) + lambda + 2*meu )*( L1 + (L2*((-w1s).^2)) )*((-w1s).^2));
Fik=  (alphaT*B)-(( (B/(1i*omega)) + lambda + 2*meu )*( L1 + (L2*(( w1s).^2)) )*(( w1s).^2));
Fmsig=(alphaT*B)-(( (B/(1i*omega)) + lambda + 2*meu )*( L1 + (L2*((-w2s).^2)) )*((-w2s).^2));
Fsig= (alphaT*B)-(( (B/(1i*omega)) + lambda + 2*meu )*( L1 + (L2*(( w2s).^2)) )*(( w2s).^2));

Gmik= ( L1 + L2*((-w1s).^2) )*(-w1s);
Gik=  ( L1 + L2*(( w1s).^2) )*( w1s);
Gmsig=( L1 + L2*((-w2s).^2) )*(-w2s);
Gsig= ( L1 + L2*(( w2s).^2) )*( w2s);

S=[alphaT*B*So/(1i*omega*rho*Cv); 0; 0; So/(1i*omega*rho*Cv)];

    %% First matrix with coefficients
    Ha=[Fmik Fik Fmsig Fsig;...
        Gmik Gik Gmsig Gsig;...
        kappa*w1s -kappa*w1s kappa*w2s -kappa*w2s;...
        1           1           1         1 ];

    %% Second matrix with exponential terms
%     Hb=[exp(-w1*x)      0 0 0;...
%         0   exp(w1*x)     0 0;...
%         0 0    exp(-w2*x)   0;...
%         0 0 0      exp(w2*x)];
%     
        Hb=exp((w1s+w2s)*x)*[ exp(-(2*w1s+w2s)*x)      0 0 0;...
                            0   exp(-w2s*x)           0 0;...
                            0 0    exp(-(2*w2s+w1s)*x)   0;...
                            0 0 0            exp(-w1s*x)];
    
    Hbs=[exp(-w1s*x)      0 0 0;...
        0   exp(w1s*x)     0 0;...
        0 0    exp(-w2s*x)   0;...
        0 0 0      exp(w2s*x)];
    
     Ha_f = matlabFunction(Ha);
     Hb_f = matlabFunction(Hb);
     Hbs_f = matlabFunction(Hbs);
     w1_f = matlabFunction(w1);
     w2_f = matlabFunction(w2); 
     S_f=matlabFunction(S);
    %% Overall matrix        
    H=(Ha*Hb);
    
    syms A11 A12 A13 A14  A21 A22 A23 A24 A31 A32 A33 A34 A41 A42 A43 A44
    
    Hprototype=[A11 A12 A13 A14;...
                A21 A22 A23 A24;...
                A31 A32 A33 A34;...
                A41 A42 A43 A44];
    
    invHprototype=inv(Hprototype);
    
invH=subs(invHprototype,...
[A11    A12    A13    A14    A21    A22    A23    A24    A31    A32    A33    A34    A41    A42    A43    A44],...
[H(1,1) H(1,2) H(1,3) H(1,4) H(2,1) H(2,2) H(2,3) H(2,4) H(3,1) H(3,2) H(3,3) H(3,4) H(4,1) H(4,2) H(4,3) H(4,4)]);

invHa=subs(invHprototype,...
[A11    A12    A13    A14    A21    A22    A23    A24    A31    A32    A33    A34    A41    A42    A43    A44],...
[Ha(1,1) Ha(1,2) Ha(1,3) Ha(1,4) Ha(2,1) Ha(2,2) Ha(2,3) Ha(2,4) Ha(3,1) Ha(3,2) Ha(3,3) Ha(3,4) Ha(4,1) Ha(4,2) Ha(4,3) Ha(4,4)]);

invHb=subs(invHprototype,...
[A11    A12    A13    A14    A21    A22    A23    A24    A31    A32    A33    A34    A41    A42    A43    A44],...
[Hb(1,1) Hb(1,2) Hb(1,3) Hb(1,4) Hb(2,1) Hb(2,2) Hb(2,3) Hb(2,4) Hb(3,1) Hb(3,2) Hb(3,3) Hb(3,4) Hb(4,1) Hb(4,2) Hb(4,3) Hb(4,4)]);


     invHa_f = matlabFunction(invHa);
     invHb_f = matlabFunction(invHb);

 %% Thermal layer thickness
 Lth=2*sqrt(Co*lk./(2*omega*gamma));

syms aaN ccN bb1 dd1 cc1
    
    save('Layer_function',...
        'aaN','ccN','bb1','dd1','cc1','x','Lth','Ha_f','Hb_f','w1_f','w2_f','S_f','invHa_f','invHb_f')


