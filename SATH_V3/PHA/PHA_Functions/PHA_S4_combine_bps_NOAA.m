% =========================================================================
% BP_comb = PHA_S4_combine_bps_NOAA(BP_att, D, sta_list, Para)
% 
% Combine nearby breakpoints that are attributed to individual stations
% 
% -------------------------------------------------------------------------
% [Input]
% BP_att  :: A list of attributed breakpoints [nx10]
% sta_id  :: target station to be examined
% Para    :: Parameter structure
%
% [Format of input data]
% 1.UID  2.TID  3.YR  4.MO  5. TYPE  6.MADJ  7.Z-score  8. auto  9.#NB
% -------------------------------------------------------------------------
% [Output]
% BP_comb :: A list of combined breakpoints
% D       :: Data sttructure with uncertain periods removed
% 
% [Format of output data]
% 1.UID  2.TID  3.YR  4.MO  5. TYPE  6.MADJ  7.Z-score  8. auto  9.#NB
%
% -------------------------------------------------------------------------
% By Duo Chan
% Last Modified: Otc. 8, 2023 in Southampton
% =========================================================================

function BP_comb = PHA_S4_combine_bps_NOAA(BP_att, D, sta_list, Para)

    BP_comb     = nan(0,9);
    for sta_id  = sta_list
        bp_comb = PHA_S4_combine_bps_single(BP_att,D,sta_id,Para);
        if ~isempty(bp_comb), BP_comb  = [BP_comb; bp_comb];  end
    end

end

% #########################################################################
% The following function does analysis for a single station
% #########################################################################
function bp_comb = PHA_S4_combine_bps_single(BP_att, D, sta_id, Para)
    
    PHA_func_debug_flag;

    % 1.UID  2.TID  3.YR  4.MO  5. TYPE  6.MADJ  7.Z-score  8. auto  9.#NB
    l = BP_att(:,1) == sta_id;

    if nnz(l) > 0 % Analysis starts >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

        N_bp            = nnz(l);
        bp_att          = BP_att(l,:);

        % time step without nan
        time_non_nan    = cumsum(~isnan(D.T(sta_id,:)));
        bp_att(:,10)    = time_non_nan(bp_att(:,2));        % time w.o. nan
    
        % Find the length of c.i.
        ci              = PHA_find_SNHT_ci(bp_att(:,7),Para);
        
        % Combine until all points are investigated >>>>>>>>>>>>>>>>>>>>>>>
        l_checked       = false(size(ci));
        occupied        = [];
        while nnz(l_checked) < N_bp

            temp  = bp_att(:,9);    % bp number
            temp(l_checked) = 0;

            % Find the index of the current unchecked BP that has most
            % neighbors
            [~,I] = max(temp);

            epoch = bp_att(I,10) + (-ci(I):ci(I));          % time w.o. nan

            l_ocp = ismember(epoch, occupied);

            if any(l_ocp)

                % This breakpoint is already ocupied, needs to be combined
                % if there are more than one bps, find the closest point
                target   = epoch(l_ocp);
                if numel(target) > 1
                    dis     = abs(target - bp_att(I,10));   % time w.o. nan
                    target  = target(find(dis == min(dis),1,'first'));
                end
                
                % Find the index of the target bp
                J           = find(bp_att(:,10) == target); % time w.o. nan

                % Combine BP I into BP J >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                % For the type of breakpoint, if anyone is 3, use 3, 
                % if they do not agree, also use 3 ------------------------
                type_uni            = unique(bp_att([I; J],5));
                if numel(type_uni) > 1
                    bp_att(J,5)     = 3;
                else
                    bp_att(J,5)     = type_uni;
                end
                % For magnitude, z-score and auto-correlation -> average --
                bp_att(J,6:8)     = (bp_att(J,6:8).* bp_att(J,9) + ...
                                     bp_att(I,6:8).* bp_att(I,9)) ./ ...    
                                    (bp_att(J,9) + bp_att(I,9));
                % For the number of neighbors, simply add things up -------
                bp_att(J,9)         = bp_att(J,9) + bp_att(I,9);
                bp_att(I,:)         = nan;

            else
                % This breakpoint is an independent point >>>>>>>>>>>>>>>>>
                occupied = sort([occupied; bp_att(I,10)]);  % time w.o. nan
            end

            % if any(ismember(do_debug,[4 9])) % ~~~~~~~~~~~~~~~~~~~~~~~~~~
            %     PHA_print_output(bp_att, 'combine_debug', 'Cleaned up', Para);
            %     disp(occupied)
            % end
            % % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

            l_checked(I) = true;
        end
        bp_comb  = bp_att(~isnan(bp_att(:,1)),1:9);
    else
        bp_comb  = zeros(0,9);
    end
end

% *************************************************************************
function ci = PHA_find_SNHT_ci(bp_mag,Para)

    switch Para.AMPLOC_PCT
        case 0.05
            ci_list = [29 12 7 5 3 2 1];
        case 0.075
            ci_list = [36 18 12 8 6 5 5];
        case 0.1
            ci_list = [59 23 12 8 6 5 5];
    end

    z_list      = [0 0.4, 0.6, 0.8, 1.0, 1.5, 3.0, 5.0];

    ci = repmat(ci_list(1),size(bp_mag));
    for ct_mag  = 2:numel(z_list)
        l       = abs(bp_mag) >= z_list(ct_mag-1) & ...
                  abs(bp_mag) < z_list(ct_mag);
        ci(l)   = ci_list(ct_mag-1);
    end
    l           = abs(bp_mag) >= z_list(end);
    ci(l)       = ci_list(end);
end