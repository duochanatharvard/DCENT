function  [Loss,Loss_sta,zscore,ita] = GA_local_optimization...
                       (x,tim,ita,numeric,Loss,Loss_sta,zscore,model_type, do_additional_check)

    if ~exist('do_additional_check','var')
        do_additional_check = 0;
    end

    ita_in = ita;

    small_list = find(zscore > 0 & zscore <= 0.5);
    N_sm       = numel(small_list);

    if ~isempty(small_list)

        % Check if kickout all small breakpoints improves the fitting
        ita_temp       = ita_in;
        ita_temp(small_list,1) = false;
        [Loss_prop, Loss_sta_prop, ~, zscore_prop] = ...
            GA_fit_mu_given_other_para_SNG(x,tim,ita_temp,numeric,model_type);
        if (Loss - Loss_prop) > 1e-4
            Loss       = Loss_prop;
            Loss_sta   = Loss_sta_prop;
            zscore     = zscore_prop;
            ita        = ita_temp;
        end

        % Check if kickout each small breakpoint improves the fitting
        for ct_rm = 1:N_sm
            ita_temp       = ita_in;
            ita_temp(small_list(ct_rm),1) = false;
            [Loss_prop, Loss_sta_prop, ~, zscore_prop] = ...
                GA_fit_mu_given_other_para_SNG(x,tim,ita_temp,numeric,model_type);
            if (Loss - Loss_prop) > 1e-4
                Loss       = Loss_prop;
                Loss_sta   = Loss_sta_prop;
                zscore     = zscore_prop;
                ita        = ita_temp;
            end
        end

    elseif do_additional_check == 1

        % Check if kickout the smallest breakpoint improves the fitting
        [~,smallest]   = min(zscore(zscore>0));
        ita_temp       = ita_in;
        bp_loc         = find(ita_temp);
        ita_temp(bp_loc(smallest),1) = false;
        [Loss_prop, Loss_sta_prop, ~, zscore_prop] = ...
            GA_fit_mu_given_other_para_SNG(x,tim,ita_temp,numeric,model_type);
        if (Loss - Loss_prop) > 1e-4
            Loss       = Loss_prop;
            Loss_sta   = Loss_sta_prop;
            zscore     = zscore_prop;
            ita        = ita_temp;
        end

        small_list = find(zscore > 0);
        N_sm       = numel(small_list);
        % Check if kickout each of the breakpoints improves the fitting
        for ct_rm = 1:N_sm
            ita_temp       = ita_in;
            ita_temp(small_list(ct_rm),1) = false;
            [Loss_prop, Loss_sta_prop, ~, zscore_prop] = ...
                GA_fit_mu_given_other_para_SNG(x,tim,ita_temp,numeric,model_type);
            if (Loss - Loss_prop) > 1e-4
                Loss       = Loss_prop;
                Loss_sta   = Loss_sta_prop;
                zscore     = zscore_prop;
                ita        = ita_temp;
            end
        end
    end
end