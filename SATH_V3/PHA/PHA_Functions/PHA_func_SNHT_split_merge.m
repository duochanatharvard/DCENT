% =========================================================================
% [yrs, PW_rmv, auto] = PHA_func_SNHT_split_merge(input,NET,ct_pair,Para)
% 
% Standard Normal Homogeneity Test (SNHT) following Alexandersson (1986),
% using a split/merge approach as in Menne and Williams (JClim, 2009).
%
% -------------------------------------------------------------------------
% [Input]
% input   :: time series of data to be analyzed [1xn]
% NET     :: network of pairs (for providing UID of stations, which is then
%            used for assigning UID for individual breakpoints [nx2]
% ct_pair :: counter for the pairs analyzed (also for providing UID of bp)
% Para    :: Parameter structure
% 
% -------------------------------------------------------------------------
% [Output]
% loc    :: identified breakpoints, including the begining (0) and ending
%           Note that the location of a breakpoint suggest that since the 
%           next time step, data have a different mean, so the first one is
%           0 rather than 1.
% PW_rmv :: breakpoints to be removed in specific pairs
%           Note that his PW_rmv is only used in the next step, that is
%           testing each BP using BIC, it is not used when estimating final
%           adjustments.
% auto   :: estimated lag-1 auto-correlation
%
% -------------------------------------------------------------------------
% By Duo Chan
% Last Modified: Otc. 8, 2023 in Southampton
% =========================================================================

function [yrs, PW_rmv, auto] = ...
                          PHA_func_SNHT_split_merge(input,NET,ct_pair,Para)

    UID1 = NET(ct_pair,1);
    UID2 = NET(ct_pair,2);

    PHA_func_debug_flag;

    % find begining and ending years >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    yrs      = [find(~isnan(input),1)-1  find(~isnan(input),1,'last')];
    
    tested   = zeros(0,2);
      
    % As the first step, split and force the split >>>>>>>>>>>>>>>>>>>>>>>>
    if any(ismember([2 9], do_debug)),  disp('First split');  end
    [yrs, ~, ~, auto] = split_or_merge(input,yrs,tested,1,1,0,Para); 
    tested            = zeros(0,2);   % do not remember this first pair
    if any(ismember([2 9], do_debug)),  disp(yrs);  end
    
    % Then itrates between split and merge >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    do_ana = true;
    ct     = 1;
    while do_ana 
        ct = ct + 1;
        
        if any(ismember([2 9], do_debug)),  disp(num2str(ct,'Split %6.0f'));  end
        [yrs, n_chg_s, tested, auto] = split_or_merge...
            (input,yrs,tested,1,0,auto,Para);       % split
        if any(ismember([2 9], do_debug)),  disp(yrs);  end
        
        if any(ismember([2 9], do_debug)),  disp(num2str(ct,'Merge %6.0f'));  end
        [yrs, n_chg_m, tested, auto] = split_or_merge...
            (input,yrs,tested,0,0,auto,Para);       % merge
        if any(ismember([2 9], do_debug)),  disp(yrs);  end
        
        if (n_chg_s + n_chg_m) == 0 || ct >= 10
            do_ana = false;
        end
    end
    
    % remove the beginning of a segment if it has less than 5 data pnts >>>
    PW_rmv  = [];
    yrs2    = yrs;
    l_rm    = false(size(yrs2));
    for ct  = 1:(numel(yrs)-1)
        seg_tim = (yrs2(ct)+1) : yrs2(ct+1);
        seg     = input(seg_tim);
        if nnz(~isnan(seg)) < 5
            % Do not remove the first seg
            if ct == 1, l_rm(ct+1) = true; else,  l_rm(ct) = true;  end
            PW_rmv = [PW_rmv; [UID1 UID2 seg_tim(1) seg_tim(end)]];
        end
    end
    yrs2(l_rm) = [];
    yrs        = yrs2;
end

% *************************************************************************
function [yrs, n_chg, tested, auto] = split_or_merge...
                       (input,yrs,tested,do_split,first_itr,auto,Para)

    PHA_func_debug_flag;

    n_chg = 0;   % Number of changes made in this iterations >>>>>>>>>>>>>>
    
    if do_split == 1, n_seg = 1; else,  n_seg = 2;  end
    if do_split == 0, l_rm  = []; end
    
    if do_split == 1
        % Update auto-correlation estimates according to detected breaks --
        auto_prop   = PHA_func_auto_corr(input,yrs);
        if ~isnan(auto_prop)
            auto    = auto_prop;
            if any(ismember([2 9], do_debug)) % ~~~~~~~~~~~~~~~~~~~~~~~~~~~
                disp(["auto updated: ",num2str(auto)]); 
            end
            % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        end
    end

    % Go through each segnment and operate depending on split or merge >>>>
    for ct_st   = 1:(numel(yrs)-n_seg)
        
        % get the current segment or nearby segments
        seg_tim = (yrs(ct_st)+1) : yrs(ct_st + n_seg);
        seg     = input(seg_tim);

        if any(ismember([2 9], do_debug)), disp([num2str(seg_tim([1 end]),'Seg: %5.0f-%5.0f')]); end

        % Skip if the interval is too short -------------------------------
        if (do_split == 1 && length(seg) >= 5 ) ||...
           (do_split == 0 && length(seg) >= 5 ) 
            
            % Do SNHT if this segment is not yet evaluated ................
            if ~ismember(seg_tim([1 end]),tested,'rows')
                
                % Add its info to the list of already evaluated segments 
                tested   = [tested; seg_tim([1 end])];

                % Calculate SNHT of this segment
                [TS_max,TS_id] = max(calculate_TS(seg));

                % Calculate the threshold of SNHT
                NN       = nnz(~isnan(seg));
                thshd    = PHA_func_find_SNHT_ts_auto(NN,auto,Para);

                if any(ismember([2 9], do_debug)) % ~~~~~~~~~~~~~~~~~~~~~~~
                    % Out put TS info for debugging purposes
                    temp = yrs(ct_st) + TS_id;
                    yrmo = timstp2yrmon(Para.Fixed_para_yr_st, 1, temp-1);
                    disp(num2str([TS_max temp yrmo thshd],...
                        ['SNHT stats : %6.2f in time step %4.0f year',...
                        ' %4.0f for threshold %6.2f']));
                end
                % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

                if do_split == 1  % do split :: concatenate new breaks ....

                    if TS_max > thshd || first_itr == 1
                        yrs   = [yrs (yrs(ct_st) + TS_id)];
                        n_chg = n_chg + 1;
                    end

                else % do merge :: remove breakpoints if not significant ..
                    if TS_max < thshd
                        l_rm  = [l_rm ct_st+1];
                        n_chg = n_chg + 1;
                    end
                end

            else % Skip segments that are already evaluated for speed .....
                if any(ismember([2 9], do_debug)) % ~~~~~~~~~~~~~~~~~~~~~~~
                    disp('Already calculated, skip'); 
                end
                % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            end

        elseif do_split == 0 % Always merge short intervals ---------------
            if any(ismember([2 9], do_debug)) % ~~~~~~~~~~~~~~~~~~~~~~~~~~~
                disp('Merge the middle point of interval'); 
            end
            % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            l_rm  = [l_rm ct_st+1];
            n_chg = n_chg + 1;
        end
    end
    
    % Re-sort newly added or remove breakpoints after each loop >>>>>>>>>>>
    if do_split == 1
        yrs = sort(yrs); 
    else
        yrs(l_rm)  = []; 
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function TS = calculate_TS(input)

    % 1. Normalize time series --------------------------------------------
    N      = numel(input);
    in_anm = input - nanmean(input,2);
    n_ntnan= nnz(~isnan(in_anm)); 
    std    = sqrt(nansum(in_anm.^2) ./ (n_ntnan-2));
    in_std = in_anm / std;

    if any(abs(in_std) > 5)        % Remove outliers
        in_std(abs(in_std) > 5) = nan;
        in_anm = in_std - nanmean(in_std,2);
        n_ntnan= nnz(~isnan(in_anm)); 
        std    = sqrt(nansum(in_anm.^2) ./ (n_ntnan-2));
        in_std = in_anm / std;
    end

    D      = repmat(in_std,N-1,1);

    % 2. Breakinto two segments -------------------------------------------
    L = tril(ones(N));
    L = L(1:end-1,:);

    D1 = D;  D1(L == 0) = nan;
    D2 = D;  D2(L == 1) = nan;

    % 3. Calculate the statistics -----------------------------------------
    Z1 = nanmean(D1,2);
    Z2 = nanmean(D2,2);
    N1 = sum(~isnan(D1),2);
    N2 = sum(~isnan(D2),2);

    TS = (N1 .* (Z1.^2) + N2 .* (Z2.^2));
    TS(1) = 0;                   % The first one is not used in NOAA's code
end