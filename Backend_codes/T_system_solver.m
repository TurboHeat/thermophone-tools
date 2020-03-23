function [BCI,Hamat,w1_c,w2_c]=T_system_solver(Omega,invHa_f,invHb_f,Ha_f,Hb_f,w1_f,w2_f,S_f,MDM,N_layers,cumLo,aaN,ccN,bb1,dd1,Dimensions);

    for i=1:N_layers
        w1_c{i}=feval(w1_f,MDM(i,3),MDM(i,7),MDM(i,8),MDM(i,9),MDM(i,5),MDM(i,6),Omega,MDM(i,2));
        w2_c{i}=feval(w2_f,MDM(i,3),MDM(i,7),MDM(i,8),MDM(i,9),MDM(i,5),MDM(i,6),Omega,MDM(i,2));
        Smat{i}=feval(S_f,MDM(i,3),MDM(i,8),MDM(i,11),MDM(i,4),Omega,MDM(i,2));
        Hamat{i}=feval(Ha_f,MDM(i,3),MDM(i,7),MDM(i,8),MDM(i,14),MDM(i,4),MDM(i,9),MDM(i,5),MDM(i,6),Omega,MDM(i,2),w1_c{i},w2_c{i});
        invHamat{i}=feval(invHa_f,MDM(i,3),MDM(i,7),MDM(i,8),MDM(i,14),MDM(i,4),MDM(i,9),MDM(i,5),MDM(i,6),Omega,MDM(i,2),w1_c{i},w2_c{i});        
    end

[const,const2,aaN,ccN,bb1,dd1] = BoundaryConds(Omega,MDM,Hamat,invHamat,invHb_f,Hb_f,Smat,N_layers,cumLo,aaN,ccN,bb1,dd1,Dimensions,w1_c,w2_c);
[aN, b1, cN, d1,BCI] = SolveCONSTS(const,const2,N_layers,aaN, bb1, ccN, dd1);

end
