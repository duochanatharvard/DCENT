% =========================================================================
% [ADJ_f, D] = PHA_S5_est_adj (BP_comb, BP_pair, D, NET_adj, sta_list, Para)
% 
% Estimate adjustment for individual stations, the code runs for two passes
% in the first, we exclude points not adjustable, and in the second, we
% determine the final estimate of adjustment.  When tringgering parallel
% computing, we allow users to choose between running only the first or the
% second pass.
%
% -------------------------------------------------------------------------
% [Input]
% BP_toadj    :: the final list of combined breakpoints to be adjusted
%                for higher iterations, this would be left-over 
%                from previous runs        
% BP_pair     :: the initial list of pair-wise breakpoints
% D           :: data structure
% NET_adj     :: target-neighbour network
% Para        :: Parameter structure
% 
% [Format of BP_comb]
% 1.UID  2.TID  3.YR  4.MO  5. TYPE  6.MADJ  7.Z-score  8. auto  9.#NB
% The columns that used are 1, 2, 5
% 
% [Format of BP_pair]
% 1. UID1   2. UID2   3.TID   4.TYPE   5.BP_MAG  6.Z-score
% 7-8.RMV Data  9. Assigned BP?  10. IBP UID  11. auto-correlation
% 
% -------------------------------------------------------------------------
% [Output]
% ADJ         :: A list of final adjustment
% DD          :: Output data containing T_corr and CORR
% BP_rmn      :: Unadjusted BPs in this round, for the next iteration
% 
% [Format of output data]
% 1.UID  2.TID  3.YR  4.MO  5. TYPE  6.MADJ  7.Z-score  8. auto  9.#NB
% 10. Central estimate of adjustment   
% 11-X. randomized estimate of adjustments
%
% -------------------------------------------------------------------------
% By Duo Chan
% Last Modified: Otc. 8, 2023 in Southampton
% =========================================================================
function [ADJ, DD, BP_rmn] = PHA_S5_est_adj...
                                      (BP_toadj, BP_pair, D, NET_adj, Para)

    if isfield(D,'T_corr'), D.T = D.T_corr; end

    % Combine nearby breakpoints and mask data inbetween
    [BP_adj,DD]     = PHA_func_comb_BP_and_mask_data(BP_toadj, BP_pair, D, Para);

    % Estimate adjustments
    [ADJ, DD]       = PHA_S5_est_1_itr(BP_adj, BP_pair, DD, NET_adj, Para);

    % Get a list of unadjusted bps
    l_unadj         = ~ismember(BP_adj(:,1:2),ADJ(:,1:2),'rows');
    BP_rmn          = BP_adj(l_unadj,:);
end

% #########################################################################
% The following function does analysis for a single iteration
% #########################################################################
function [ADJ_f, D] = PHA_S5_est_1_itr(BP_comb, BP_pair, D, NET_adj, Para)

    N_disp   = 1000;
    sta_list = 1:max(D.UID);

    % >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    disp('   >> Do the first round')
    ADJ = nan(0,11+Para.N_rnd);
    for sta_id = sta_list
        if rem(sta_id,N_disp) == 0, disp(sta_id); end
        adj = PHA_S5_estimate_adj_single...
                       (BP_comb, BP_pair, D, NET_adj, sta_id, Para);
        if ~isempty(adj),  ADJ = [ADJ; adj]; end
    end

    % ---------------------------------------------------------------------
    disp('   >> Do the second round')
    ADJ_f = nan(0,11+Para.N_rnd);
    for sta_id = sta_list        
        if rem(sta_id,N_disp) == 0, disp(sta_id); end
        adj = PHA_S5_estimate_adj_single...
                    (ADJ(:,1:9), BP_pair, D, NET_adj, sta_id, Para);
        if ~isempty(adj),  ADJ_f = [ADJ_f; adj]; end
    end

    % Generate final output >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    Ns      = size(D.T,1);
    Nt      = size(D.T(:,:),2);
    D.CORR  = zeros(Ns,Nt);
    if ~isempty(ADJ_f)
        temp        = ADJ_f(:,[1 2 10 + Para.do_rnd]);
        I           = sub2ind([Ns, Nt],temp(:,1),temp(:,2));    
        D.CORR(I)   = temp(:,3);
        D.CORR      = PHA_func_jump2adj(D.CORR, 'backward');
    end

    % Mask out segments that are required to be removed -------------------
    ndellim         = 5;
    mask            = PHA_func_remove_info(BP_pair, Para, ndellim);
    D.CORR(mask)    = nan;

    % Output is the summation between the raw and correction/adjustment ---
    D.T_corr        = D.CORR + D.T(:,:);
end

% #########################################################################
% The following function does analysis for a single station
% #########################################################################
function ADJ = PHA_S5_estimate_adj_single...
                        (BP_comb, BP_pair, D, NET_adj, sta_id, Para)

    PHA_func_debug_flag;

    % The analysis starts from here >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    ADJ        = [];

    % Get confirmed breakpoints for this target
    BP_tg      = BP_comb(ismember(BP_comb(:,1),sta_id),:);  
    BP_tg      = sortrows(BP_tg,2);

    % [Format of BP_comb]
    % 1.UID  2.TID  3.YR  4.MO  5. TYPE  6.MADJ  7.Z-score  8. auto  9.#NB
    % The columns that used are 1, 2, 5
    % 
    % [Format of BP_pair]
    % 1. UID1   2. UID2   3.TID   4.TYPE   5.BP_MAG  6.Z-score
    % 7-8.RMV Data  9. Assigned BP?  10. IBP UID  11. auto-correlation

    if ~isempty(BP_tg) % >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

        % Subset remove info if any
        l_sta1      = BP_pair(:,1) == sta_id;
        l_sta2      = BP_pair(:,2) == sta_id;
        l_rm1       = l_sta1 & BP_pair(:,7) > 0 & BP_pair(:,8) > 0;
        l_rm2       = l_sta2 & BP_pair(:,7) > 0 & BP_pair(:,8) > 0;
        Data_RMV    = [BP_pair(l_rm1,[1 2 7 8]); BP_pair(l_rm2,[2 1 7 8])];

        % Get neighboring time series -------------------------------------
        UID_nb      = NET_adj(sta_id,:);
        UID_nb(isnan(UID_nb)) = [];
        sz          = size(D.T(:,:));   
        sz(1)       = numel(UID_nb);
        Dif_T       = nan(sz);
        Tg          = nan(sz);
        for ct      = 1:sz(1)
            [Dif_T(ct,:),Tg(ct,:)] = PHA_func_get_dif...
                                         (D, [sta_id UID_nb(ct)], 1, Para);
        end

        % Find breakpoints of neighbors -----------------------------------
        BP_nbs = BP_comb(ismember(BP_comb(:,1),UID_nb),:);

        % Remove data for this local network ------------------------------
        Dif_T  = mask_out_data(Dif_T,sta_id,UID_nb,Data_RMV);
        Tg(isnan(Dif_T)) = nan;             

        % Find the timing of BP segments for the target station -----------
        Tg_mean = mean(Tg(:,:),1,"omitnan");  % for determine if sufficient 
             % number of non-nan data is available for making an adjustment
        temp    = mean(Dif_T,1,"omitnan");
        l_data  = ~isnan(temp);
        tim_tg  = [find(l_data,1)-1 BP_tg(:,2)' find(l_data,1,'last')];
        tim_tg  = unique(tim_tg);

        % Loop over individual breakpoints >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        for ct_bp = (numel(tim_tg)-1):-1:2

            if reproduce_NOAA == 1
                rmv_current_bp = 0;            % assume this bp is adjusted
            else
                rmv_current_bp = 0;            % assume bp is not adjusted
            end

            tc_tg   = tim_tg(ct_bp);           % time of target break
            typ_tg  = BP_tg(ct_bp-1,5);        % BIC type of target break
            bp_tg   = BP_tg(ct_bp-1,:);        % info of the target bp
            tr_tg   = tim_tg(ct_bp+1);         % time of the next break
            tl_tg   = tim_tg(ct_bp-1)+1;       % time of the last break
            
            % If any segment has less than [Para.ADJ_MIN_SIDE] data
            % Skip this break point for now
            X  = Para.ADJ_MIN_SIDE - 1;       
            n1 = nnz(~isnan(Tg_mean(tl_tg:tc_tg)));
            n2 = nnz(~isnan(Tg_mean((tc_tg+1):tr_tg)));
            if all([n1 n2] >= X)

                % Set the time interval for breakpoint check
                tim_itv = tc_tg + (-X:1:X);
            
                % Loop over individual neighbours and estimates breaks >>>>
                adj_info  = [];
                for ct_nb = 1:size(Dif_T,1)

                    dif_T       = Dif_T(ct_nb,:);

                    clear('adj_temp','dif_temp','bp_id','tl','tr')
                    clear('tim_nb_bp','tim_nb_st','tim_nb_ed')
                    tim_nb_bp   = BP_nbs(BP_nbs(:,1) == UID_nb(ct_nb),2); 
                    tim_nb_st   = find(~isnan(dif_T),1);
                    tim_nb_ed   = find(~isnan(dif_T),1,'last');

                    % If there is things overlap with the target and has no
                    % breakpoints inside the check interval -> continue
                    if any(~isnan(dif_T))
                    if all(~ismember(tim_nb_bp,tim_itv)) && ...
                                    tim_nb_st < tc_tg && tim_nb_ed > tc_tg

                        % Subset by the longest possible homogeneous 
                        % series around the breakpoint
                        if all(tim_nb_bp > tc_tg)
                            tl = tl_tg;
                        else
                            temp = tim_nb_bp(tim_nb_bp < tc_tg)+1;
                            tl = max([temp; tl_tg]);
                        end
                        
                        if all(tim_nb_bp < tc_tg)
                            tr = tr_tg;
                        else
                            temp = tim_nb_bp(tim_nb_bp > tc_tg);
                            tr = min([temp; tr_tg]);
                        end

                        dif_temp = dif_T(tl:tr);
                        bp_id    = tc_tg - tl + 1;
                        
                        % Perform minbic test -----------------------------
                        if nnz(~isnan(dif_temp(1:bp_id))) >= Para.ADJ_MINLEN && ...
                           nnz(~isnan(dif_temp((bp_id+1):end))) >= Para.ADJ_MINLEN
                            adj_temp = PHA_func_minbic...
                                              (dif_temp,bp_id,typ_tg,Para);
                            % 1.TYPE   2.BP_MAG   3.STD   
                            % 4.ZSCORE   5.BIC SCORE
                            adj_info = [adj_info; [adj_temp'  UID_nb(ct_nb)]];
                        end
                    end
                    end
                    clear('adj_temp','dif_temp','bp_id','tl','tr')
                    clear('tim_nb_bp','tim_nb_st','tim_nb_ed')
                end

                if any(ismember([5 9], do_debug)) % ~~~~~~~~~~~~~~~~~~~~~~~
                    disp('target    neighbor    type    magnitude   counter')
                    data_show = [repmat(sta_id,size(adj_info,1),1) ...
                         adj_info(:,[6 1]) -adj_info(:,2) (1:size(adj_info,1))'];
                    disp(num2str(data_show,'%5.0f %5.0f %5.0f %10.2f %5.0f'));
                end
                % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

                % >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                % Process the collection of BP estimates from neighbors
                if size(adj_info,1) >= Para.ADJ_MINPAIR

                    % Trim data 
                    qs       = tukey(adj_info(:,2));
                    l_trim   = adj_info(:,2)>qs(end) | adj_info(:,2)<qs(1);
                    adj_trim = adj_info(~l_trim,:); 

                    if any(ismember([5 9], do_debug)) % ~~~~~~~~~~~~~~~~~~~
                        disp('statistics before trimming');
                        disp(num2str(-qs([4 2 3 5 1])','%6.2f')); 

                        if nnz(l_trim)
                            disp('Removed ...............................')
                            disp(num2str(adj_info(l_trim,1:2),'%6.0f %6.2f')); 
                            disp('.......................................')
                        end
                    end
                    % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

                    if size(adj_trim,1) >= Para.ADJ_MINPAIR
                        % Estimate adjustments
                        qs       = tukey(adj_trim(:,2));
                        if any(ismember([5 9], do_debug)) % ~~~~~~~~~~~~~~~
                             disp('statistics after trimming');
                             disp(num2str(-qs([4 2 3 5 1])','%6.2f')); 
                        end
                        % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

                        if qs(1) * qs(end) > 0  % -------------------------
                            % Finally, we can estimate adjustment !!! 
                            % When adjustment is significant
                            [~,boot_sample] = bootstrp(Para.N_rnd, ...
                                     @(x) [mean(x)], 1:size(adj_trim,1));
                            proposed_adjs   = adj_trim(:,2);
                            proposed_boot   = proposed_adjs(boot_sample);

                            if strcmp(Para.ADJ_EST,'median')
                                adj     = qs(3);
                                adj_rnd = quantile(proposed_boot,0.5,1);

                            elseif strcmp(Para.ADJ_EST,'mean')
                                adj     = mean(proposed_adjs,"omitnan");
                                adj_rnd = mean(proposed_boot,1,"omitnan");

                            elseif strcmp(Para.ADJ_EST,'Qavg')
                                adj     = (qs(2) + qs(4)) / 2;
                                adj_rnd = mean(quantile(proposed_boot, ...
                                               [.25, .75],1),1,"omitnan");
                            end
                            ADJ         = [ADJ; [bp_tg adj adj_rnd]];
                            rmv_current_bp = 0;
                        end
                    end
                end
            end

            % If a breakpoint is skipped, then remove it from the list and
            % the next correction will ignore this bp
            if rmv_current_bp == 1, tim_tg(ct_bp) = [];  end
        end
    end
end

% *************************************************************************
% input has the dimention of [neighbors x bootstrapping id]
function  qs = tukey(input)
    scl         = 1.46;
    qs          = quartile_CD(input);
    q05         = qs(1,:) - (qs(2,:)-qs(1,:)) * scl;
    q95         = qs(3,:) + (qs(3,:)-qs(2,:)) * scl;
    qs          = [q05; qs; q95];
end

% To be consistent with the NOAA calculation, hard code quartile function
function qs = quartile_CD(input)

    input       = sort(input);
    qs50        = median_CD(input);

    N           = numel(input);
    if mod(N,2) == 0
        input   = sort([input; qs50]);
    end

    N           = numel(input);
    id_median   = (N+1)/2;

    qs25        = median_CD(input(1:id_median));
    qs75        = median_CD(input(id_median:end));

    qs          = [qs25; qs50; qs75];
end

function md     = median_CD(input)

    input       = sort(input);
    N           = numel(input);

    if rem(N,2) == 1
        md      = input((N+1)/2);
    else
        md      = (input(N/2) + input(N/2 + 1))/2;
    end
end

% *************************************************************************
function Dif_T  = mask_out_data(Dif_T,sta_id,UID_nb,Data_RMV)
    if ~isempty(Data_RMV)
        for ct = 1:size(Dif_T,1)
            [~,pst] = ismember([sta_id UID_nb(ct)],Data_RMV(:,1:2),'rows');
            if pst > 0
                Dif_T(ct,Data_RMV(pst,3):Data_RMV(pst,4)) = nan;
            end
        end
    end
end