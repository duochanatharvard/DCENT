function P = LME_function_adjust_WWII(P)

    % Druing WWII, if not GB deck 245, and not ERI, and not US/JP, 
    % and if nighttime, then deduct 0.2 degree Celcius from SST
    l_WWII         = P.C0_YR >= 1941 & P.C0_YR <= 1945;
    l_non_ERI      = P.SI_Std ~= 1;
    l_non_US_JP    = ~ismember(P.C0_CTY_CRT,['US';'JP'],'rows');
    l_non_Royal_UK = P.C1_DCK ~= 245;
    l_night        = P.C1_ND ==1;

    l = l_WWII & l_non_ERI & l_non_US_JP & l_non_Royal_UK & l_night;

    P.C0_SST(l) = P.C0_SST(l) - 0.2;
    
end