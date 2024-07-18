% =========================================================================
% BP = PHA_extract_BP_staion_level(T_raw,T_corred,yrs)

% Compute breakpoints in the dataset
% 
% This function goes through individual stations and
% picks out BP information
% When T_corred is true data, the function returns the true answer of bps
%
%
% [output]
% BP  : a list of breakpoints [nx3]  UID, timing, magnitude  
% 
% =========================================================================

function BP = PHA_extract_BP_station_level(T_raw,T_corred,yrs)

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
    T_c         = T_corr';                   % [Nt x Ns]
    sta         = repmat(1:size(T_corr,1),size(T_corr,2),1);
    tim         = repmat((1:size(T_corr,2))',1,size(T_corr,1));

    i_non_nan   = find(~isnan(T_c));
    sta         = sta(i_non_nan);
    tim         = tim(i_non_nan);
    jumps       = diff(T_c(i_non_nan),[],1);
    jumps(abs(jumps)<1e-5) = 0;

    i_jumps     = find(jumps~=0);
    sta_jump    = sta(i_jumps);
    mag_jump    = jumps(i_jumps);
    tim_jump    = tim(i_jumps);
    sta_next    = sta(i_jumps+1);

    l_out       = find(sta_jump == sta_next);
    BP          = [sta_jump(l_out) tim_jump(l_out) -mag_jump(l_out)];

    % Calculate breakpoint mangitude from correction ----------------------
    % BP      = [];
    % for ct  = 1:size(T_corr,1)
    %     l       = ~isnan(T_corr(ct,:));
    %     l_loc   = find(l);
    %     temp    = T_corr(ct,l);
    %     jumps   = diff(temp,[],2);
    %     l_corr  = find(abs(jumps)>1e-5);
    %     bp      = [repmat(ct,nnz(l_corr),1)...
    %                l_loc(l_corr)' jumps(l_corr)'];
    %     BP      = [BP; bp];
    % end
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
