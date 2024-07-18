% =========================================================================
% mask = PHA_func_remove_info(BP_pair, Para)
%
% Generate a mask of data to be removed from interim breakpoints
% =========================================================================

function mask = PHA_func_remove_info(BP_pair, Para, ndellim)

    % Subset rows indicate data needs to be removed -----------------------
    l_rmv       = BP_pair(:,7) > 0 & BP_pair(:,8) > 0;
    BP_rmv      = unique(BP_pair(l_rmv,[1 2 7 8]),'rows');

    % Generate a list of station-time included ----------------------------
    RMV_lst     = zeros(0,2);
    for ct = 1:size(BP_rmv,1)
        temp    = (BP_rmv(ct,3):BP_rmv(ct,4))';
        temp1   = [repmat(BP_rmv(ct,1),numel(temp),1) temp];
        temp2   = [repmat(BP_rmv(ct,2),numel(temp),1) temp];
        RMV_lst = [RMV_lst; temp1; temp2];
    end

    % Get the histogram of station-time combinations ----------------------
    [uni,~,J]   = unique(RMV_lst, 'rows', 'stable');
    RMV_hist    = [uni accumarray(J, 1)];

    % Keep those whose count is greater than ndellim ----------------------
    % ndellim     = 5;
    l_rmv       = RMV_hist(:,3) >= ndellim;
    RMV_hist    = RMV_hist(l_rmv,:);

    % Generate a mask for data to be removed ------------------------------
    mask        = false(Para.Ns, Para.Nt);
    ind         = sub2ind([Para.Ns,Para.Nt],RMV_hist(:,1),RMV_hist(:,2));
    mask(ind)   = true;
end