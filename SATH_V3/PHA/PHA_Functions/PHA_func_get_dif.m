% [Dif_T, Tg_anm, Tn_anm] = PHA_func_get_dif(D,NET,ct_pair,Para)

function [Dif_T, Tg_anm, Tn_anm] = PHA_func_get_dif(D,NET,ct_pair,Para)

    PHA_func_debug_flag;

    % Prepare data for evaluation -----------------------------------------
    Tg        = D.T(NET(ct_pair,1),:);
    Tn        = D.T(NET(ct_pair,2),:);

    % Calculate anomalies using common coverage ---------------------------
    Tg_anm    = CDC_demean(Tg,2,12);
    Tn_anm    = CDC_demean(Tn,2,12);    
    Dif_T     = Tg_anm - Tn_anm;

    
end