function [BP_adj,D] = PHA_func_comb_BP_and_mask_data(BP_comb,BP_pair,D,Para)

    thshld      = Para.ADJ_CONS;

    % remove nearby combined bp if within 24 months
    % This function ignores missing values in the counting
    BP_adj      = zeros(0,size(BP_comb,2));
    for ct_sta  = 1:max(D.UID)

        l_sta   = BP_comb(:,1)==ct_sta;

        if nnz(l_sta)

            bp_comb = BP_comb(l_sta,:);

            tim_nan = cumsum(~isnan(D.T(ct_sta,:)));
            bp_comb(:,10) = tim_nan(bp_comb(:,2));

            t1          = find(~isnan(D.T(ct_sta,:)),1,'first');
            te          = find(~isnan(D.T(ct_sta,:)),1,'last');
            t1_nan      = min(tim_nan);
            te_nan      = max(tim_nan);

            tc          = [t1-1 bp_comb(:,2)' te];
            tc_nan      = [t1_nan-1 bp_comb(:,10)' te_nan];

            l_rm        = find(diff(tc_nan) < thshld);

            if ~isempty(l_rm)
                for ct_rm = l_rm
                    D.T(ct_sta,(tc(ct_rm)+1) : tc(ct_rm+1)) = nan;
                end

                if max(l_rm) == (numel(tc)-1) 
                    l_rm(l_rm == (numel(tc)-1)) = numel(tc)-2;  
                end

                bp_comb(l_rm,:) = [];
            end

            BP_adj = [BP_adj; bp_comb];
        end
    end

    % mask problematic segments in pairwise comparisons
    bp_rmv  = BP_pair(BP_pair(:,9)==0 & BP_pair(:,7)~=0,[1 2 7 8]);
    c       = zeros(size(D.T(:,:)));
    for ct  = 1:size(bp_rmv,1)
        c(bp_rmv(ct,1),bp_rmv(ct,3):bp_rmv(ct,4)) = ...
                    c(bp_rmv(ct,1),bp_rmv(ct,3):bp_rmv(ct,4)) + 1;
        c(bp_rmv(ct,2),bp_rmv(ct,3):bp_rmv(ct,4)) = ...
                    c(bp_rmv(ct,2),bp_rmv(ct,3):bp_rmv(ct,4)) + 1;
    end
    l_rm = c >= 5;
    D.T(l_rm) = nan;
    
end