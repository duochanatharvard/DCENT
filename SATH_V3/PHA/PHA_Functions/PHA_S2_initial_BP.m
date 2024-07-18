% =========================================================================
% BP_pair = PHA_S2_initial_BP(D,NET,pair_list,Para)
% 
% Identify breakpoints in each difference series
%
% -------------------------------------------------------------------------
% [Input]
% D       :: Data structure
% NET     :: Station Network
% ct_pair :: counter of the pair to be processed
% Para    :: Parameter structure
%
% -------------------------------------------------------------------------
% [Output]
% BP_pair :: A list of breakpoint identified in the initial screening
%
% [Format of output data]
% 1. UID1   2. UID2   3.TID   4.TYPE   5.BP_MAG  6.Z-score
% 7-8.RMV Data  9. Assigned BP?  10. IBP UID  11. auto-correlation
%
% -------------------------------------------------------------------------
% By Duo Chan
% Last Modified: Otc. 8, 2023 in Southampton
% =========================================================================

function BP_pair = PHA_S2_initial_BP(D, NET, pair_list, Para)

    BP_pair      = nan(0,11);

    N_pair          = numel(pair_list);

    for ct_pair  = pair_list 

        if rem(ct_pair-pair_list(1) + 1,100) == 0
        disp(num2str([ct_pair-pair_list(1) + 1, N_pair],...
            'Processing the %6.0f / %6.0f pair'))
        end

        bp_pair  = PHA_S2_initial_BP_single(D,NET,ct_pair,Para);
        if ~isempty(bp_pair), BP_pair  = [BP_pair; bp_pair];  end
    end
end

% #########################################################################
% The following function does analysis for a single station
% #########################################################################
function bp_pair = PHA_S2_initial_BP_single(D, NET, ct_pair, Para)

    PHA_func_debug_flag;

    [Dif_T, Tg_anm, Tn_anm] = PHA_func_get_dif(D, NET, ct_pair, Para);
    [yrs, rmv, auto] = PHA_func_SNHT_split_merge(Dif_T, NET, ct_pair, Para);

    if any(ismember([2 9], do_debug))
        disp(repmat('!',1,100))
        disp(yrs)
        disp(repmat('!',1,100))
    end

    bp_pair         = PHA_func_BIC_KTH(Dif_T, yrs, rmv, NET, ct_pair,...
                                                     Para, Tg_anm, Tn_anm);
    bp_pair(:,end+1)= auto;
end