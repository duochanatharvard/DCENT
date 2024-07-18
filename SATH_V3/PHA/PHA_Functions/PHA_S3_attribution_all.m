% =========================================================================
% BP_att = PHA_S3_attribution_all(BP_pair, Para, NET_att)
% 
% Attribute pair-wise breakpoints to individual stations using a counting
% down method. This code follows the Fortran algorithm in WM12 and does a 
% global search for all time steps.
% 
% -------------------------------------------------------------------------
% [Input]
% BP_pair   :: A list of confirmed pair-wise breakpoints [nx10]
% tm_trgt   :: the time step to focus on
% Para      :: Parameter structure
% NET_att   :: optional, putting a limit on the length of the network
% 
% [Format of input data]
% 1. UID1   2. UID2   3.TID   4.TYPE   5.BP_MAG  6.Z-score
% 7-8.RMV Data  9. Assigned BP?  10. IBP UID  11. auto-correlation
% 
% -------------------------------------------------------------------------
% [Output]
% BP_att  :: A list of breakpoints attributed to stations [nx10]
%
% [Format of output data]
% 1.UID  2.TID  3.YR  4.MO  5. TYPE  6.MADJ  7.Z-score  8. auto  9.#NB
%
% -------------------------------------------------------------------------
% By Duo Chan
% Last Modified: Otc. 8, 2023 in Southampton
% =========================================================================

function BP_att = PHA_S3_attribution_all(BP_pair, Para, NET_att)

    PHA_func_debug_flag;

    if isempty(NET_att) 
        do_Net_ext = 0;  % Use all possible pairs
    else
        do_Net_ext = 1;  % Truncate the number of loop back pairs       
    end

    % Get rid of all pairs that are not greater than 3 >>>>>>>>>>>>>>>>>>>>
    BP_pair = BP_pair(BP_pair(:,4) >= 3,:);
    
    % if 0
    %     BP_all  = BP_pair;
    % else
    % To speed up computation, subset BP list by time steps >>>>>>>>>>>>>>>
    for ct_tim = 1:Para.Nt
        BP_all{ct_tim} = BP_pair(BP_pair(:,3) == ct_tim,:);
    end
    % end

    % >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    % Get a matrix of neighbour info from NET
    Ns = Para.Ns;
    Nt = Para.Nt;
    if do_Net_ext == 1
        Count    = BP2Count_NET_ext(BP_pair, Ns, Nt, NET_att);
    else
        Count    = BP2Count(BP_pair, Ns, Nt);
    end
    Count_all    = Count;

    if any(ismember([3 9], do_debug)) && do_debug_more_detail > 0 % ~~~~~~~
        figure(99); 
        subplot(3,5,ct_bp+1); cla; hold on;
        CDF_pcolor(Count);
    end
    % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    % Doing the counting down approach >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    ct_bp    = 0;
    BP_att = nan(0,9);
    while max(Count(:)) > 1

        ct_bp       = ct_bp + 1;

        m           = max(Count(:));
        [x,y]       = find(Count == m);

        if numel(x) > 1
            [~,I]   = min(x);
            x       = x(I);
            y       = y(I);
        end

        if any(ismember([3 9], do_debug)) % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            disp(num2str([y, timstp2yrmon(Para.Fixed_para_yr_st,1,y-1) x m]))
        end
        % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

        % 1. UID1   2. UID2   3.TID   4.TYPE   5.BP_MAG  6.Z-score
        % 7-8.RMV Data  9. Assigned BP?  10. IBP UID  11. auto-correlation

        % Calculate the statistics of that BP -----------------------------
        BP_att(ct_bp,:) = [x y 0 0 0 0 0 0 Count_all(x,y)];
        l_bp_ctb        = BP_all{y}(:,1)==x | BP_all{y}(:,2)==x;
        BP_sub          = BP_all{y}(l_bp_ctb,:);

        clear('uid1','uid2','bptyp','madj','data_rmv','infill_st','auto')
        uid1            = BP_sub(:,1);
        uid2            = BP_sub(:,2);
        bptyp           = BP_sub(:,4);
        madj            = BP_sub(:,5);
        zscr            = BP_sub(:,6);
        auto            = BP_sub(:,11);
        
        l1              = uid1 == x;
        l2              = uid2 == x;

        % Put everything according to target minus neighbor ...............
        clear('madj_temp','zscr_temp','bptyp_temp')
        clear('data_rmv_temp','auto_temp')
        bptyp_temp          = [bptyp(l1);      bptyp(l2)];
        madj_temp           = [madj(l1);       -madj(l2)];
        zscr_temp           = [zscr(l1);       zscr(l2)];
        auto_temp           = [auto(l1);       auto(l2)];

        % Mean magnitude and z-score ......................................
        BP_att(ct_bp,6)    = mean(madj_temp,"omitnan");
        BP_att(ct_bp,7)    = mean(zscr_temp,"omitnan");
        BP_att(ct_bp,8)    = mean(auto_temp,"omitnan");

        % Mean magnitude ..................................................
        type_uni    = unique(bptyp_temp);
        if numel(type_uni) > 1 || numel(bptyp_temp) < 5
            BP_att(ct_bp,5) = 3;
        else
            BP_att(ct_bp,5) = type_uni;
        end

        % Find all BPs in the list at different times ---------------------
        l_bp_ctb    = (BP_pair(:,1)==x | BP_pair(:,2)==x) & BP_pair(:,3) == y;
        UID_list    = BP_pair(l_bp_ctb,10);
        l_bp_rm     = ismember(BP_pair(:,10),UID_list);

        % Calculate how that is going to change the count matrix
        if do_Net_ext == 1
            C_chg     = BP2Count_NET_ext(BP_pair(l_bp_rm,:), Ns, Nt, NET_att);
        else
            C_chg     = BP2Count(BP_pair(l_bp_rm,:), Ns, Nt);
        end

        % Remove count from count matrix and BPs from the total list
        Count     = Count - C_chg;
        BP_pair(l_bp_rm,:) = [];

        if any(ismember([3 9], do_debug)) && do_debug_more_detail > 0 % ~~~
            figure(99); 
            subplot(3,5,ct_bp+1); cla; hold on;
            CDF_pcolor(Count);
        end
        % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    end

    [mon,yr]        = ind2sub([12,500],BP_att(:,2));
    yr_st           = Para.Fixed_para_yr_st;
    BP_att(:,3:4)  = [yr+yr_st-1 mon];
    % 1.UID  2.TID  3.YR  4.MO  5. TYPE  6.MADJ  7.Z-score  8. auto  9.#NB

    BP_att = sortrows(BP_att,2);
    BP_att = sortrows(BP_att,1);
end

% *************************************************************************
function C       = BP2Count_NET_ext(BP_pair, Ns, Nt, NET_att)

    % only counting BP_pairs within a list of extended network
    l1           = ismember(BP_pair(:,[1 2]),NET_att,'rows');
    l2           = ismember(BP_pair(:,[2 1]),NET_att,'rows');

    sub_1_sta    = BP_pair(l1,1);
    sub_1_tim    = BP_pair(l1,3); 

    ind1c        = sub2ind([Ns, Nt], sub_1_sta, sub_1_tim);
    [uni1,~,J1]  = unique(ind1c);
    C1           = accumarray(J1, 1);

    sub_2_sta    = BP_pair(l2,2);
    sub_2_tim    = BP_pair(l2,3);

    ind2c        = sub2ind([Ns, Nt], sub_2_sta, sub_2_tim);
    [uni2,~,J2]  = unique(ind2c);
    C2           = accumarray(J2, 1);

    C            = zeros(Ns,Nt);
    C(uni1)      = C(uni1) + C1;
    C(uni2)      = C(uni2) + C2;
end

function C       = BP2Count(BP_pair, Ns, Nt)

    sub_1_sta    = BP_pair(:,1);
    sub_1_tim    = BP_pair(:,3); 

    ind1c        = sub2ind([Ns, Nt], sub_1_sta, sub_1_tim);
    [uni1,~,J1]  = unique(ind1c);
    C1           = accumarray(J1, 1);

    sub_2_sta    = BP_pair(:,2);
    sub_2_tim    = BP_pair(:,3);

    ind2c        = sub2ind([Ns, Nt], sub_2_sta, sub_2_tim);
    [uni2,~,J2]  = unique(ind2c);
    C2           = accumarray(J2, 1);

    C            = zeros(Ns,Nt);
    C(uni1)      = C(uni1) + C1;
    C(uni2)      = C(uni2) + C2;
end