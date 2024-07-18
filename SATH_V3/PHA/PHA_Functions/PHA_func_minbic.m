function BIC_info = PHA_func_minbic(seg,last_good,task_type,Para)

    % task_type   0. use all models when possible
    %             1. do_adjustment (exclude M1 & M2)
    %             2. split_merge (exclude M1)
    %             3/4/5/6/7. Only evaluate M3/4/5/6/7

    PHA_func_debug_flag;

    % Min length for activating trend estimates on a side of a bp >>>>>>>>>
    X = 2; 

    if nnz(~isnan(seg(1:last_good))) >= X,     f_l = 1; else, f_l = 0; end
    if nnz(~isnan(seg(last_good+1:end))) >= X, f_r = 1; else, f_r = 0; end
    if ~exist('task_type','var'), task_type = 0; end

    tid       = 1:numel(seg);

    l_rm      = isnan(seg);
    seg(l_rm) = [];
    tid(l_rm) = [];
    l1        = tid<=last_good;
    l2        = tid>last_good;

    % Mask out evaluations not required according to task type >>>>>>>>>>>>
    do_eval   = true(1,7);
    switch task_type
        case 1, do_eval([1 2])         = false;
        case 2, do_eval(1)             = false;
        case 3, do_eval([1 2 4 5 6 7]) = false;
        case 4, do_eval([1 2 3 5 6 7]) = false;
        case 5, do_eval([1 2 3 4 6 7]) = false;
        case 6, do_eval([1 2 3 4 5 7]) = false;
        case 7, do_eval([1 2 3 4 5 6]) = false;
    end
    BIC       = repmat(9999,1,7);

    % Mask models according to data length --------------------------------
    if f_l == 0 && f_r == 1      % left short
        do_eval([4 5 6]) = false;
    elseif f_l == 1 && f_r == 0  % right short
        do_eval([4 5 7]) = false;
    elseif f_l == 0 && f_r == 0  % both short
        do_eval([4 5 6 7]) = false;
    end

    if all(~do_eval), do_eval(3) = true;  end

    % calculate the fit for the seven models >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    % M1: median value
    if do_eval(1)
        mu1 = median(seg);
        M1  = repmat(mu1,size(seg));
        BIC(1) = do_bayes(seg,M1,1);
    end

    % M2: line with slope -------------------------------------------------
    if do_eval(2)
        k2  = median(KTH_slope(tid,seg));
        mu2 = median(seg) - median(tid)*k2;
        M2  = tid * k2 + mu2;
        BIC(2) = do_bayes(seg,M2,2);
    end

    % M3: two median values -----------------------------------------------
    if do_eval(3)
        mu31 = median(seg(l1));  
        mu32 = median(seg(l2));
        M3   = [repmat(mu31,1,nnz(l1)) repmat(mu32,1,nnz(l2))];
        BIC(3) = do_bayes(seg,M3,3);
    end

    % M4: jump with the same slope on both ends ---------------------------
    if do_eval(4)
        k4   = median([KTH_slope(tid(l1),seg(l1)); ...
            KTH_slope(tid(l2),seg(l2))]);
        mu41 = median(seg(l1)) - median(tid(l1) * k4);
        mu42 = median(seg(l2)) - median(tid(l2) * k4);
        M4   = [tid(l1) * k4 + mu41   tid(l2) * k4 + mu42];
        BIC(4) = do_bayes(seg,M4,4);
    end

    % M5: jump with the different slope on both ends ----------------------
    if do_eval(5)
        k51  = median(KTH_slope(tid(l1),seg(l1)));
        k52  = median(KTH_slope(tid(l2),seg(l2)));
        mu51 = median(seg(l1)) - median(tid(l1) *k51);
        mu52 = median(seg(l2)) - median(tid(l2) *k52);
        M5  = [tid(l1) * k51 + mu51   tid(l2) * k52 + mu52]; 
        BIC(5) = do_bayes(seg,M5,5);
    end

    % M6: jump with the different slope on both ends but left slope is zero
    if do_eval(6)
        k61  = 0;
        k62  = median(KTH_slope(tid(l2),seg(l2)));
        mu61 = median(seg(l1));
        mu62 = median(seg(l2)) - median(tid(l2) * k62);
        M6  = [tid(l1) * k61 + mu61   tid(l2) * k62 + mu62]; 
        BIC(6) = do_bayes(seg,M6,4);
    end

    % M7: jump with the different slope on both ends but right slope is zero
    if do_eval(7)
        k71  = median(KTH_slope(tid(l1),seg(l1)));
        k72  = 0;
        mu71 = median(seg(l1)) - median(tid(l1) * k71);
        mu72 = median(seg(l2));
        M7  = [tid(l1) * k71 + mu71   tid(l2) * k72 + mu72]; 
        BIC(7) = do_bayes(seg,M7,4);
    end

    % >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    [~,bp_type] = min(BIC);
    switch bp_type
        case 1, M = M1;  bp_mag = 0;
        case 2, M = M2;  bp_mag = 0;
        case 3, M = M3;  bp_mag = mu32 - mu31;
        case 4, M = M4;  bp_mag = mu42 - mu41 + k4;
        case 5, M = M5;  bp_mag = mu52 - mu51 + last_good * (k52 - k51) + k52;
        case 6, M = M6;  bp_mag = mu62 - mu61 + (last_good + 1) * k62;
        case 7, M = M7;  bp_mag = mu72 - mu71 - last_good * k71;
    end
    bp_std     = sqrt(nanmean((seg - M).^2));    % standard error
    bp_mag_std = bp_mag ./ bp_std; 
    
    bic_score  = min(BIC);
    
    BIC_info   = [bp_type; bp_mag; bp_std; bp_mag_std; bic_score];
    % 1.TYPE   2.BP_MAG   3.STD   4.ZSCORE   5.BIC SCORE
end

% *************************************************************************
function bic = do_bayes(Y,Y_hat,p)
    n   = nnz(~isnan(Y));
    SSE = nansum((Y - Y_hat).^2);
    bic = n * log10(SSE/n) + log10(n) * p;
    
    % disp(num2str(bic,'>>LOSS %6.4f'))
    % disp(num2str(SSE,'  |_SSE %6.4f'))
    % disp(num2str(n * log10(SSE/n),'  |_likelihood %6.4f'))
    % disp(num2str(log10(n) * p,'  |_penalty %6.4f'))
    % disp(num2str(p,'  |_dof %4.0f'))
    % disp(num2str(n,'  |_length %4.0f'))
    % disp([n * log10(SSE/n) log10(n) * p]);
end

% *************************************************************************
function trd = KTH_slope(X,Y)
    L   = triu(true(numel(X)));
    trd = (Y - Y') ./(X- X');
    trd = trd(L);
    trd(isnan(trd)) = [];

    % disp(numel(X))
    % disp(num2str(median(trd),'%10.5f'))
    % disp(num2str(median(X),'%10.5f'))
    % disp(num2str(median(Y),'%10.5f'))
end