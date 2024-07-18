% =========================================================================
% BP_pair = PHA_func_BIC_KTH(input,yrs,PW_rmv,NET,ct_pair,Para)
% 
% Confirm the type of breakpoints and record breakpoint statistics
%
% -------------------------------------------------------------------------
% [Input]
% input   :: time series of data to be analyzed [1xn]
% yrs     :: a list of the ending timing of segments of input
% NET     :: network of pairs (for providing UID of stations, which is then
%            used for assigning UID for individual breakpoints [nx2]
% ct_pair :: counter for the pairs analyzed (also for providing UID of bp)
% Para    :: Parameter structure
% 
% -------------------------------------------------------------------------
% [Output]
% BP_pair :: Confirmed breakpoints in pair-wise detection [nx9]
% 
% [Format of output data]
% 1. UID1   2. UID2   3.TID   4.TYPE   5.BP_MAG  6.Z-score
% 7-8.RMV Data  9. Assigned BP?  10. IBP UID
%
% -------------------------------------------------------------------------
% By Duo Chan
% Last Modified: Otc. 8, 2023 in Southampton
% =========================================================================

function  [BP_pair, BP_info] = PHA_func_BIC_KTH(input, yrs, PW_rmv, NET,...
                                             ct_pair, Para, Tg_anm, Tn_anm)

    UID1 = NET(ct_pair,1);
    UID2 = NET(ct_pair,2);

    PHA_func_debug_flag;

    input0 = input;          % keep a record of incoming data for later use

    % Mask out removed points (short segments in SNHT) >>>>>>>>>>>>>>>>>>>>
    for ct = 1:size(PW_rmv,1)
        input(:,PW_rmv(ct,3):PW_rmv(ct,4)) = nan;
    end

    % Perform BIC to SNHT detected breakpoints >>>>>>>>>>>>>>>>>>>>>>>>>>>>
    BP_info   = nan(6,0);
    for ct_bp = 1:(numel(yrs)-2)

        % get the current segment and the next one
        clear('seg','tid','last_good','l1','l2')
        seg_tim     = (yrs(ct_bp)+1):yrs(ct_bp+2);
        seg         = input(seg_tim);

        % find the location of bp in the subset segment
        last_good   = yrs(ct_bp+1) - yrs(ct_bp);
        
        % test using BIC 
        bic_info = PHA_func_minbic(seg,last_good,2,Para);
        if any(ismember([2 9], do_debug))
            disp(num2str([yrs(ct_bp+1); bic_info]',...
                '%6.0f %6.0f %10.5f %6.2f %6.2f %6.2f'))
        end

        % if it is a breakpoint, add it to the list 
        if bic_info(1) >= 3
            BP_info = [BP_info [yrs(ct_bp+1); bic_info]];
        end
        % 1.TID   2.TYPE   3.BP_MAG  4.STD    5.ZSCORE    6.BIC SCORE  
        % For the output, it is only the first 3 columns that are useful
        % so, it will be subset at the end
    end
    
    % >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    % Once initially checked datapoints, the code now goes through each of 
    % them to either combine nearby breaks having the same sign or remove 
    % those having different signs.
    % From here, the NOAA algorithm does not remove short breaks,
    %                                    and we simply follow their choice.
    input         = input0;

    % Calculate the bp timing excluding nan values
    n_non_nan     = cumsum(~isnan(input));
    BP_info(7,:)  = n_non_nan(BP_info(1,:));

    % Keep track of removed data associated with individual bps
    BP_info(8:9,:) = 0;

    % Loop over individual breakpoints. combine or remove them
    BP_keep       = combine_BIC_BP(BP_info, input, yrs, Para, Tg_anm, Tn_anm);

    % >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    % For missing data, if a breakpoint is detected just on the boundaries
    % of segments of missing data, then it is likely that each time step of 
    % the missing segment is the true bp timing, so all of them need to be
    % assigned.  
    % [1] Note that, data removed because of uncertain BP magnitudes are 
    % also assigned.
    % [2] Note also that for Matlab's max function, it only returns the
    % first index, that is when missing value exist, detected BPs are only
    % and always at the beginning of the segment with missing data.
    N_bp          = size(BP_keep,2);
    BP_keep(10,:) = 0;   % Indicator of infill
    BP_keep(11,:) = get_IBP_UID(UID1,UID2,1:N_bp); % UID of Initial BPs

    % Expand and fill nan values in between >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    BP_infill     = BP_keep;
    for ct  = 1:N_bp
        tim = BP_keep(1,ct);

        % Duplicate nan values --------------------------------------------
        if isnan(input(tim+1))

            % find the last point of the missing segment
            tid = tim+1;
            while isnan(input(tid))
                tid = tid + 1;
            end
            tid             = tid - 1;
            bp_infill       = repmat(BP_keep(:,ct),1,tid-tim);
            bp_infill(1,:)  = (tim+1):tid;
            bp_infill(10,:) = 1;
            BP_infill       = [BP_infill bp_infill];
        end

        % Duplicate uncertain period --------------------------------------
        if BP_keep(8,ct) > 0
            bp_infill       = repmat(BP_keep(:,ct),1,BP_keep(9,ct)-BP_keep(8,ct)+1);
            bp_infill(1,:)  = BP_keep(8,ct):BP_keep(9,ct);
            bp_infill(10,:) = 1;
            BP_infill       = [BP_infill bp_infill];
        end
    end
    % 1.TID   2.TYPE   3.BP_MAG   4.STD    5.ZSCORE     6.BIC SCORE  
    % 7.TID Exld NaN   8-9.RMV Data  10. Assigned BP?   11. IBP UID

    % >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    % STD, and BIC SCORE are not needed in further steps, 
    % instead UID of stations needs to be added, cleaning up data for
    % output of this function
    temp     = repmat([UID1 UID2]',1,size(BP_infill,2));
    % output both magnitude and z-score
    BP_pair  = [temp; BP_infill([1 2 3 5 8 9 10 11],:)]';  

    % Not sure why NOAA keeps BP whose magnitude is zero in their output
    % But these points should not be used in further steps and are removed
    BP_pair  = BP_pair(BP_pair(:,5)~=0,:);

    BP_pair  = unique(BP_pair,'rows');

    % [Format of the output data]
    % 1. UID1   2. UID2   3.TID   4.TYPE   5.BP_MAG  6.Z-score
    % 7-8.RMV Data  9. Assigned BP?  10. IBP UID
end

% *************************************************************************
function IBP_UID = get_IBP_UID(UID1,UID2,X)
   IBP_UID = UID1*10000000 + UID2*100 + X;
end

% *************************************************************************
function BP_keep = combine_BIC_BP(BP_info, input, yrs, Para, Tg_anm, Tn_anm)

    PHA_func_debug_flag;

    BP_keep         = BP_info;

    if ~isempty(BP_info)

        % Start from the first breakpoint >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        ct_c        = 1;
        ct_last     = 0;
        while ct_c <= numel(BP_info(1,:))

            epoch   = Para.ADJ_MINLEN;

            if any(ismember([2 9], do_debug)) % ~~~~~~~~~~~~~~~~~~~~~~~~~~~
                disp('==========================='); 
                disp(BP_info(1,ct_c));
            end
            % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

            % Find consecutive chains of BPs that are within --------------
            % ADJ_MINLEN months to one another
            do_search   = true;
            n_last_old  = 0;
            while do_search
                tim     = BP_info(7,ct_c);
                % find breakpoints in the coming epoch
                l       = BP_info(7,:) > tim & BP_info(7,:) <= (tim+epoch);
                n_last  = find(l,1,'last');
                % if there are any extending the epoch and search again 
                % this if using the enlongated epoch find other bps, 
                % repeat until no further breakpoints are found
                if nnz(l) > 0 && n_last > n_last_old
                    epoch      = Para.ADJ_MINLEN + ...
                                 BP_info(7,n_last) - BP_info(7,ct_c);
                    n_last_old = n_last;
                else
                    do_search  = false;
                end
            end

            % nearby breakpoints needs to test which one to keep ----------
            ct_p    = ct_c + nnz(l);             % the last bp in the group

            if ct_last > 0
                ct_st = BP_info(1,ct_last)+1;       % ct_c ~= 1 
            else
                ct_st = yrs(1)+1;                   % ct_c == 1 
            end
            
            % find the next bp after the current group of bps -------------
            if ct_p ~= numel(BP_info(1,:)) 
                ct_ed = BP_info(1,ct_p + 1);        % ct_p ~= end
            else
                ct_ed = yrs(end);                   % ct_p == end
            end

            if any(ismember([2 9], do_debug)) % ~~~~~~~~~~~~~~~~~~~~~~~~~~~
                disp(num2str([ct_st ct_ed])); 
            end
            % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

            % subset data and perform further analysis --------------------
            clear('seg','bp_info_sub','bps')
            seg         = input(ct_st:ct_ed);
            seg_t       = Tg_anm(ct_st:ct_ed);
            seg_n       = Tn_anm(ct_st:ct_ed);
            bp_info_sub = [BP_info(:,ct_c) BP_info(:,l)];
            bps_in_seg  = bp_info_sub(1,:) - ct_st + 1;

            if any(ismember([2 9], do_debug)) && do_debug_more_detail 
                figure(99); clf; hold on;
                plot(seg,'.-'); 
                plot(bps_in_seg,zeros(1,numel(bps_in_seg)),...
                               'x','markersize',20,'linewi',2)
            end

            % -------------------------------------------------------------
            if numel(bps_in_seg) == 1

                % If only one breakpoint re-evaluate anyway
                % Why you need to re-evaluate? because NOAA does not mask
                % out any data in this round, which was not done in the
                % initial estimate of bp magnitudes
                bic_info = update_BP(seg,bps_in_seg,Para,seg_t,seg_n);
                [BP_keep, id_keep]  = combine_BP...
                               (BP_keep,bic_info,bps_in_seg,ct_c,Para);

                % The combine BP function keeps the one with the lowest BIC
                % and remove all other BPs to be NaN.

            else % ........................................................

                % then evaluate the magnitude of individual breakpoints
                bic_info    = update_BP(seg,bps_in_seg,Para,seg_t,seg_n);

                s           = sign(bic_info(2,:));

                if ~(any(s == -1) && any(s == 1)) % .......................
                    if any(ismember([2 9], do_debug)), disp('same sign'); end
                    % If of the same sign, combine them
                    [BP_keep, id_keep] = combine_BP...
                                   (BP_keep,bic_info,bps_in_seg,ct_c,Para);

                else % ....................................................
                    % otherwise, we keep the earlierst break, reevaluate 
                    % its amplitude after masking data in between those 
                    % breaks.  We also record the time interval of data to
                    % be removed.
                    if any(ismember([2 9], do_debug)), disp('different sign'); end
                    [BP_keep, data_rmv, id_keep] = remove_BP...
                            (BP_keep,seg,bps_in_seg,ct_c,Para,seg_t,seg_n);
                    % remove data 
                    input(data_rmv(1):data_rmv(2)) = nan;
                end
            end

            if any(ismember([2 9], do_debug)), disp(num2str(BP_keep)); end
            ct_last = ct_c + id_keep - 1;           
            ct_c    = ct_p + 1;       % jump to the next bp after the group
        end

        % After going through all the breakpoints,
        % thinning the matrix by removing NaN columns
        BP_keep(:,all(isnan(BP_keep),1)) = [];
    end
end

% *************************************************************************
function bic_info = update_BP(seg,bps_in_seg,Para,seg_t,seg_n)

    PHA_func_debug_flag;

    clear('bic_info')
    for ct_bp = 1:numel(bps_in_seg)
        bic_info(:,ct_bp) = PHA_func_minbic(seg,bps_in_seg(ct_bp),0,Para);
    end

    if reproduce_NOAA == 1 || reproduce_NOAA == 0
        std_min = min([std(seg_t,"omitnan"), std(seg_n,"omitnan")]);
        bic_info(4,:) = abs(bic_info(2,:)) / std_min;
    else
        bic_info(4,:) = abs(bic_info(4,:));
    end

    if any(ismember([2 9], do_debug)), disp(num2str(bic_info','%10.5f')); end
    % 1.TYPE   2.BP_MAG   3.STD   4.ZSCORE   5.BIC SCORE
end

% *************************************************************************
function [BP_keep, id_keep] = combine_BP(BP_keep,bic_info,bps_in_seg,ct_c,Para)

    PHA_func_debug_flag;

    l_keep        = false(1,numel(bps_in_seg));
    thold         = 3;
    if any(bic_info(1,:) >= thold)

        % If the least breakpoint type is greater than "thold"
        % keep the one with the least BIC score

        l_qua     = bic_info(1,:) >= thold;
        min_bic   = min(bic_info(end,l_qua));
        I         = find(min_bic == bic_info(end,:) & l_qua);
        l_keep(I) = true;

        BP_keep(2:6,find(l_keep) + ct_c - 1)  = bic_info(:,I);
        id_keep   = find(l_keep);

    else

        id_keep   = 1;  % only to keep track of the current breakpoint
    end 
    
    % After combining breakpoints, remove all other breakpoints
    % When nothing is combined, all breakpoints are removed
    BP_keep(:,find(~l_keep) + ct_c - 1)     = nan;
end

% *************************************************************************
function [BP_keep, data_rmv, id_keep] = remove_BP(BP_keep,seg,bps_in_seg,...
                                                   ct_c,Para,seg_t,seg_n)

    PHA_func_debug_flag;

    N_bp        = numel(bps_in_seg);
    l_keep      = [true false(1,N_bp-1)];

    % Keep a record of which segment of data are removed
    % note that BP_keep contains the absolute timing 
    data_rmv    = [BP_keep(1,ct_c)+1  BP_keep(1,ct_c+N_bp-1)];

    % mask out data to be removed and re-evaluate BIC for the first segment
    % note that segment does not have an absolute timing
    seg((bps_in_seg(1)+1):bps_in_seg(end))   = nan;
    seg_t((bps_in_seg(1)+1):bps_in_seg(end)) = nan;
    seg_n((bps_in_seg(1)+1):bps_in_seg(end)) = nan;
    bic_info    = PHA_func_minbic(seg,bps_in_seg(1),0,Para);

    if reproduce_NOAA == 1 || reproduce_NOAA == 0
        std_min = min([std(seg_t,"omitnan"), std(seg_n,"omitnan")]);
        bic_info(4,:) = abs(bic_info(2,:)) / std_min;
    else
        bic_info(4,:) = abs(bic_info(4,:));
    end

    % if bp_type is greater than 3, then keep this breakpoint
    BP_keep(2:6,ct_c)  = bic_info;
    BP_keep(8:9,ct_c)  = data_rmv;
    
    % After keeping the earlierst breakpoints, remove all other breakpoints
    BP_keep(:,find(~l_keep) + ct_c - 1) = nan;

    % This is to avoid the pair from being removed in later steps
    BP_keep(3,find(l_keep) + ct_c - 1) = BP_keep(3,find(l_keep) + ct_c - 1) + ...
                                          normrnd(0,0.00001,1,nnz(l_keep));

    id_keep   = 1;           % only to keep track of the current breakpoint
end