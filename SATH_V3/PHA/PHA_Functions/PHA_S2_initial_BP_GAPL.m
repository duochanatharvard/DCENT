% =========================================================================
% BP_pair = PHA_S2_initial_BP_GAPL(D, NET, pair_list, Para)
% 
% Identify breakpoints in each difference series using penalized likelihood
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
% BP_out  :: A list of breakpoint identified in the initial screening
%
% [Format of output data]
% 1. UID1   2. UID2   3.TID   4.TYPE   5.BP_MAG  6.Z-score
% 7-8.RMV Data  9. Assigned BP?  10. IBP UID  11. auto-correlation
%
% -------------------------------------------------------------------------
% By Duo Chan
% Last Modified: Otc. 8, 2023 in Southampton
% =========================================================================

function [BP_pair, BP_pair_flt] = ...
                PHA_S2_initial_BP_GAPL(D, NET, pair_list, Para)

    BP_pair         = nan(0,11);
    BP_pair_flt     = nan(0,11); 

    N_pair          = numel(pair_list);

    for ct_pair     = pair_list 

        disp(num2str([ct_pair-pair_list(1) + 1, N_pair],...
            'Processing the %6.0f / %6.0f pair'))

        tic;
        [bp_pair, bp_pair_flt] = ...
            PHA_S2_initial_BP_GAPL_single(D,NET,ct_pair,Para);
        toc;

        if ~isempty(bp_pair) 
            BP_pair  = [BP_pair; bp_pair];  
        end

        if ~isempty(bp_pair_flt)
            BP_pair_flt  = [BP_pair_flt; bp_pair_flt];  
        end
    end
end

% #########################################################################
% The following function does analysis for a single station
% #########################################################################
function [bp_pair, bp_pair_flt] = ...
                          PHA_S2_initial_BP_GAPL_single(D,NET,ct_pair,Para)

    [Dif_T, Tg_anm, Tn_anm] = PHA_func_get_dif(D,NET,ct_pair,Para);

    % Setup calculation ===================================================
    tim         = 1:numel(Dif_T);
    UID1        = NET(ct_pair,1);
    UID2        = NET(ct_pair,2);
    bp_pair     = PHA_func_GAPL_single_diff_series...
                                          (Dif_T,tim,Para.try_trend,UID1,UID2);

    % Filter the output using whatever it is ==============================
    if ~isempty(bp_pair)
        yrs         = [0  sort(bp_pair(:,3))' Para.Nt];
        bp_pair_flt = PHA_func_BIC_KTH...
                      (Dif_T, yrs, [], NET, ct_pair, Para, Tg_anm, Tn_anm);
        if ~isempty(bp_pair_flt)
            bp_pair_flt(:,end+1) = bp_pair(1,11);
        end
    else
        bp_pair_flt = zeros(0,11);
    end

    % Although GAPL does not remove any uncertain periods =================
    % It is necessary account for nan values in the raw data
    if nnz(~isnan(Dif_T))
        BP_infill               = bp_pair;
        for ct  = 1:size(bp_pair,1)
            tim                 = bp_pair(ct,3);
    
            % Duplicate nan values ----------------------------------------
            if isnan(Dif_T(tim+1))
    
                % find the last point of the missing segment
                tid             = tim+1;
                while isnan(Dif_T(tid))
                    tid         = tid + 1;
                end
                tid             = tid - 1;
                bp_infill       = repmat(bp_pair(ct,:),tid-tim,1);
                bp_infill(:,3)  = (tim+1):tid;
                bp_infill(:,9)  = 1;
                BP_infill       = [BP_infill; bp_infill];
            end
        end
        bp_pair = BP_infill;
        bp_pair = unique(bp_pair,'rows');
    end
end