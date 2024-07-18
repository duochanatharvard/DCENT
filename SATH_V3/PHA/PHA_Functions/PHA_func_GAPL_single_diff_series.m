function bp_pair = PHA_func_GAPL_single_diff_series(Dif_T,tim,try_trend,UID1,UID2)

    if size(Dif_T,1)   ~= 1, Dif_T = Dif_T'; end

    Dif_T               = remove_outlier(Dif_T);

    l_use               = ~isnan(Dif_T);
    Dif_use             = Dif_T(l_use);
    tim_use             = tim(l_use);

    % Fitting the data ----------------------------------------------------
    [beta, ita_best, numeric_best, T_hat, Loss] = ...
                             GA_fit_chan(Dif_use,tim_use,'no_slope');

    if try_trend == 1

        [beta2, ita_best2, numeric_best2, T_hat2, Loss2] = ...
                                 GA_fit_chan(Dif_use,tim_use,'one_trend');

        if Loss2(end) < Loss(end)
            beta          = beta2;
            ita_best      = ita_best2;
            numeric_best  = numeric_best2;
            T_hat         = T_hat2;
            Loss          = Loss2;
        end
    end

    % Post-processing the estimates ---------------------------------------
     if nnz(ita_best) > 0
        N_bp                = numel(find(ita_best));
        bp_pair(1:N_bp,1:2) = repmat([UID1 UID2],N_bp,1);
        bp_pair(:,3)        = tim_use(ita_best);
        bp_pair(:,4)        = 3;
        bp_pair(:,5)        = beta(beta~=0);
        bp_pair(:,6)        = abs(bp_pair(:,5)) ./ std(Dif_use - T_hat',"omitnan");
        bp_pair(:,7:9)      = 0;
        bp_pair(:,10)       = UID1*10000000 + UID2*100 + (1:N_bp)';
        bp_pair(:,11)       = numeric_best(1);
    else
        bp_pair             = zeros(0,11);
    end
end

function output = remove_outlier(input)

    % 1. Normalize time series --------------------------------------------
    N      = numel(input);
    in_anm = input - nanmean(input,2);
    n_ntnan= nnz(~isnan(in_anm)); 
    std    = sqrt(nansum(in_anm.^2) ./ (n_ntnan-2));
    in_std = in_anm / std;

    output  = input;
    output(abs(in_std) > 5) = nan;
end