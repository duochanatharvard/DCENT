% =========================================================================
% [BP,x,h,h_t] = PHA_extract_BP_pair_level(T_raw,T_corred,NET,yrs)

% Compute breakpoints in the dataset
% 
% This function goes through each individual pairs of comparison and
% picks out BP information in each pair-wise difference series
% When T_corred is true data, the function returns the true answer of bps
%
%
% [output]
% BP  : a list of breakpoints [nx4]  UID1, UID2, timing, magnitude  
% 
% =========================================================================

function BP = PHA_extract_BP_pair_level(T_raw,T_corred,NET,yrs)

    % ---------------------------------------------------------------------
    % Calculate the adjustments
    T_corr      = T_corred(:,:) - T_raw(:,:);

    % Subset years that you are interested in -----------------------------
    if numel(size(T_corr)) == 2
        T_corr  = reshape(T_corr,size(T_corr,1),12,size(T_corr,2)/12);
    end
    if ~exist('yrs','var'),  yrs = 1:size(T_corr,3); end
    T_corr  = T_corr(:,:,yrs);

    % Remove very small bumps in the data abs less than 0.015C ------------
    T_corr  = round_Tcorr(T_corr(:,:));    

    % Calculate breakpoint mangitude from correction ----------------------
    T_c         = T_corr(NET(:,1),:)' - T_corr(NET(:,2),:)';  % [Nt x Np]
    n1          = repmat(NET(:,1)',size(T_corr,2),1);
    n2          = repmat(NET(:,2)',size(T_corr,2),1);
    p           = repmat(1:size(NET,1),size(T_corr,2),1);
    tim         = repmat((1:size(T_corr,2))',1,size(NET,1));

    i_non_nan   = find(~isnan(T_c));
    n1          = n1(i_non_nan);
    n2          = n2(i_non_nan);
    p           = p(i_non_nan);
    tim         = tim(i_non_nan);
    jumps       = diff(T_c(i_non_nan),[],1);
    jumps(abs(jumps)<1e-5) = 0;

    i_jumps     = find(jumps~=0);
    n1_jump     = n1(i_jumps);
    n2_jump     = n2(i_jumps);
    mag_jump    = jumps(i_jumps);
    tim_jump    = tim(i_jumps);
    p_jump      = p(i_jumps);
    p_next      = p(i_jumps+1);

    l_out       = find(p_jump == p_next);
    BP          = [n1_jump(l_out)  n2_jump(l_out) ...
                   tim_jump(l_out) -mag_jump(l_out)];
end

% *************************************************************************
function T_corr_round = round_Tcorr(T_corr)

    % Go through each time step, and substitute nan values
    % with the first non-nan value before it
    T_corr_temp = T_corr;
    for ct_tim = 2:size(T_corr,2)
        temp1 = T_corr_temp(:,ct_tim);
        temp2 = T_corr_temp(:,ct_tim-1);
        l     = isnan(temp1);
        temp1(l) = temp2(l);
        T_corr_temp(:,ct_tim) = temp1;
    end

    % Calculate time difference of the substituted T corr
    T_corr_diff     = diff(T_corr_temp,1,2);

    % If the nan values are at the beginning, difference will
    % also be nan, in this case, substitue these nan values 
    % by zero
    T_corr_diff(isnan(T_corr_diff)) = 0;

    % When using cumsum, need to find the initial value 
    % Go through individual stations to find each initial
    for ct_sta = 1:size(T_corr,1)
        temp = T_corr(ct_sta,:);
        l    = find(~isnan(temp),1);
        if nnz(l) >= 1
            st(ct_sta,1) = temp(l);
        else
            st(ct_sta,1) = 0;
        end
    end

    % Suppress very small bumps in the difference data
    T_corr_diff(abs(T_corr_diff) <= 0.015) = 0;

    % Converting things back into the correction space
    T_corr_round    = cumsum([st T_corr_diff],2);

    % Mask things using the orginal data coverage
    T_corr_round(isnan(T_corr)) = nan;
end
