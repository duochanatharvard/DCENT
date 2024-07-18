% Should exclude suez from deck 193 until 1893,
% exclude deck 195 during WWII,
% and exclude deck 780 platform 5 for all times.
        
function [C0_QC_ME_1,C0_AT] = ICOADS_NC_function_get_NMAT(yr,mon,C0_LON,C0_LAT,C0_AT,C0_QC_ME_1,C1_DCK,C1_PT,C1_ND)

    C0_QC_ME_1(C1_DCK == 780 & C1_PT == 5) = 0;

    logic_WWII = (yr >= 1942 & yr <= 1945) | (yr == 1946 & ismember(mon,[1,2])); 
    if logic_WWII == 1

        dir_era   = ICOADS_NC_OI('Mis');
        dmat1 = load([dir_era,'/Dif_DMAT_NMAT_1929_1941.mat']);
        dmat2 = load([dir_era,'/Dif_DMAT_NMAT_1947_1956.mat']);

        corr1 = re_function_general_grd2pnt(C0_LON,C0_LAT,[],dmat1.Dif_DMAT_NMAT,5,5,1);
        corr2 = re_function_general_grd2pnt(C0_LON,C0_LAT,[],dmat2.Dif_DMAT_NMAT,5,5,1);
        corr = corr1 * (yr - 1941)/6 + corr2 * (1 - (yr - 1941)/6);

        C0_AT = C0_AT - corr;
        C0_QC_ME_1(C1_ND == 1) = 0;
        C0_QC_ME_1(C1_DCK == 195) = 0;

    else

        if yr <= 1892  % Also need to throw away the deck 193
            mask = zeros(72,36);
            mask([57:72],[27:29])     = 1;
            mask([71:72 1:9],[26:27]) = 1;
            mask([3:9],[17:26])       = 1;
            mask([10:19],[17:21])     = 1;
            mask([20:21],[17:19])     = 1;
            logic_bad_193 = re_function_general_grd2pnt(C0_LON,C0_LAT,[],mask,5,5,1);
            logic_remove  = C1_DCK == 193 & logic_bad_193 == 1;
            C0_QC_ME_1(logic_remove) = 0;
        end

        C0_QC_ME_1(C1_ND == 2) = 0;
    end
end