% Analyzing synthetic results / we have the answer of BPs

% ......................................................................... 
% [Format of BP.pair]
% 1. UID1   2. UID2   3.TID   4.TYPE   5.BP_MAG  6.Z-score
% 7-8.RMV Data  9. Assigned BP?  10. IBP UID  11.auto-correlation
%
% ......................................................................... 
% [Format of BP.att / BP.comb / BP.adj]
% 1.UID  2.TID  3.YR  4.MO  5. TYPE  6.MADJ  7.Z-score  8. auto  9.#NB

function [trd_err, mon_err, N_rmv, hist_adj, hist_hmf] = ...
                             PHA_evaluate_synthetic_anaysis(D,NET,BP,epoch)

    if ~exist('epoch','var'), epoch = 6; end

    % Find the true value BP information ----------------------------------
    BP.pair_key = PHA_extract_BP_pair_level(D.T,D.T_t,NET.pair);

    % Find the true value BP information
    BP.sta_key  = PHA_extract_BP_station_level(D.T,D.T_t);

    % Calculate hit, miss, and false alarm
    hist_hmf(:,:,1) = PHA_hmf(BP.pair_key, BP.pair, D.T_t(:,:), epoch);
    hist_hmf(:,:,2) = PHA_hmf(BP.sta_key,  BP.comb, D.T_t(:,:), epoch);
    for ct = 1:numel(BP.ADJ_out)
        temp = zeros(0,10);
        for i = 1:ct, temp = [temp; BP.ADJ_out{i}(:,1:10)]; end
        hist_adj(:,ct) = hist(temp(:,10), -4.95:0.1:4.95);
        hist_hmf(:,:,ct+2) = PHA_hmf(BP.sta_key, temp, D.T_corr(:,:,ct), epoch);
    end

    % Calculate statistics ------------------------------------------------
    err        = D.T_corr - D.T_t(:,:);
    trd        = CDC_trend(err, 1:size(D.T_corr,2),2);
    trd_err    = squeeze(trd{1} * 1200);
    mon_err    = squeeze(sqrt(mean(CDC_demean(err,2).^2,2,"omitnan")));
    N_rmv      = squeeze(sum(isnan(D.T_corr),2) - sum(isnan(D.T_t(:,:)),2));
end