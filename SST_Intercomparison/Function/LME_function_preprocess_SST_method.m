function P = LME_function_preprocess_SST_method(P)

    l = P.C0_SI_4 >0 & P.C0_SI_4 <= 0.05;
    P.C0_SI_4(l) = 0;
    
    l = P.C0_SI_4 >= 0.95 & P.C0_SI_4 < 1;
    P.C0_SI_4(l) = 1;
    
    l = P.C0_SI_4 >0.05 & P.C0_SI_4 <= 0.5;
    P.C0_SI_4(l) = 13;
    
    l = P.C0_SI_4 > 0.5 & P.C0_SI_4 < 0.95;
    P.C0_SI_4(l) = 14;

    l = P.C0_SI_4 == 4;
    P.C0_SI_4(l) = 3;

    l = P.C0_SI_4 == 7 | P.C0_SI_4 == 9;
    P.C0_SI_4(l) = -1;
end