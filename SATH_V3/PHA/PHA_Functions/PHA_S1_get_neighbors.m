% =========================================================================
% [D_tg, D_nb_final, Dif_T] = PHA_S1_get_neighbors(D,sta_list,Para)
% 
% Find neighboring stations of a target following Menne et al. (2009).
% 
% -------------------------------------------------------------------------
% [Input]
% D        :: Data structure
% sta_list :: a list of stations to be processed
% Para     :: Parameter structure
%
% -------------------------------------------------------------------------
% [Output]
% NET_pair :: Network for pair-wise bp detection
% NET_att  :: Network for BP attribution
% NET_adj  :: Network for BP adjustment estimation
%
% -------------------------------------------------------------------------
% By Duo Chan
% Last Modified: Otc. 8, 2023 in Southampton
% =========================================================================

function [NET_pair, NET_att, NET_adj] = PHA_S1_get_neighbors(D,sta_list,Para)

    PHA_func_debug_flag;

    % Calculate the initial pair-wise network >>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    % if 0
    disp('Calculate our own network')
    NET_pair    = nan(0,2);
    NET2        = nan(Para.Ns,Para.NEIGH_FINAL);
    for ct_sta  = sta_list
        net     = PHA_S1_get_neighbors_single(D,ct_sta,Para);
        l_rm    = net(:,2) == net(:,1) | ...
                  ismember(net(:,[2 1]),NET_pair,'rows');
        NET_pair        = [NET_pair; net(~l_rm,:)];
        NET2(ct_sta,1:size(net,1))  = net(:,2);
        clear('D_tg','D_nb','Dif_T')
    end
    NET_pair    = sortrows(NET_pair,1); 
    % else
    %     disp('Use NOAA network')
    %     [NET_pair, NET2] = PHA_debug_get_NOAA_network;
    % end

    % expend NETWORK by adding things back, and truncate the number of >>>>
    % comparisons to be within 1.5 x NEIGH_FINAL
    NET_adj         = NET2;
    expend_length   = round(Para.NEIGH_FINAL * 0.5);
    NET_adj(:,end+(1:expend_length)) = nan;
    for ct_sta      = sta_list
        l1  = NET_pair(:,1) == ct_sta;
        l2  = NET_pair(:,2) == ct_sta;
        lst = sort([NET_pair(l1,2); NET_pair(l2,1)]);
        lst(ismember(lst,NET2(ct_sta,:))) = [];
        if numel(lst) > expend_length
            lst = lst(1:expend_length);
        end
        NET_adj(ct_sta,Para.NEIGH_FINAL+(1:numel(lst))) = lst;
    end

    if reproduce_NOAA == 1 % Convert NET_adj -> a list of NET_att >>>>>>>>>
        NET_att = zeros(0,2);
        for ct_sta = sta_list
            temp = NET_adj(ct_sta,2:end);
            temp(isnan(temp)) = [];
            NET_att = [NET_att; [repmat(ct_sta,numel(temp),1)  temp']];
        end
    else % Our method, do not use NET_att to constrain BP attribution -----
        NET_att = [];
    end
end

% #########################################################################
% The following function does analysis for a single station 
% #########################################################################
function net = PHA_S1_get_neighbors_single(D,ct_sta,Para)

    PHA_func_debug_flag;

    % Pickout the nearest NEIGH_CLOSE stations >>>>>>>>>>>>>>>>>>>>>>>>>>>>
    Para.NEIGH_CLOSE = min(size(D.T,1), Para.NEIGH_CLOSE);
    Para.NEIGH_FINAL = min(Para.NEIGH_CLOSE,Para.NEIGH_FINAL);

    dis       = distance(D.Lat,D.Lon+normrnd(0,0.00001,size(D.Lat)),...
                                              D.Lat(ct_sta),D.Lon(ct_sta));
    dis_sort  = sort(dis);
    l         = dis <= dis_sort(Para.NEIGH_CLOSE);

    clear('D_tg','D_nb')
    D_tg      = CDC_subset2(D,ct_sta,1);
    D_nb      = CDC_subset2(D,l,1);

    % Prepare data for evaluation >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    Tn        = D_nb.T(:,:);
    Tg        = repmat(D_tg.T(:)', size(Tn,1), 1);

    % Calculate anomalies using common coverage >>>>>>>>>>>>>>>>>>>>>>>>>>>
    Tg_anm    = CDC_demean(Tg,2,12);
    Tn_anm    = CDC_demean(Tn,2,12);
    Tg_anm    = Tg_anm + Tn_anm * 0;
    Tn_anm    = Tn_anm + Tg_anm * 0;

    % If two stations has too few over lap, ignore them >>>>>>>>>>>>>>>>>>>
    N_common  = nansum(~isnan(Tn + Tg),2);
    l_invld_R = N_common < Para.NUM4COV;
    
    % Get rid of stations that does not have R higher than CORR_LIM >>>>>>>
    if strcmp(Para.NEIGH_CORR,'1 diff')
        D_nb.R          = CDC_corr(diff(Tn_anm,1,2), diff(Tg_anm,1,2), 2);
        D_nb.R(l_invld_R) = -1;
        [R_sort,l_sort] = sort(D_nb.R,'descend');
        l_sort(R_sort < Para.CORR_LIM) = [];

    elseif strcmp(Para.NEIGH_CORR,'near') % -------------------------------
        D_nb.R          = distance(D_nb.Lat,D_nb.Lon,D_tg.Lat,D_tg.Lon);
        D_nb.R(l_invld_R) = 9999;
        [R_sort,l_sort]      = sort(D_nb.R,'ascend');
        l_sort(R_sort > 999) = [];

    elseif strcmp(Para.NEIGH_CORR,'corr') % -------------------------------
        D_nb.R          = CDC_corr(Tn_anm, Tg_anm, 2);
        D_nb.R(l_invld_R) = -1;
        [R_sort,l_sort] = sort(D_nb.R,'descend');
        l_sort(R_sort < Para.CORR_LIM) = [];
    end
    
    % Rearrange stations by correlation >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    D_nb.Tn_anm    = Tn_anm;
    D_nb.Tg_anm    = Tg_anm;
    D_nb_sort_by_R = CDC_subset2(D_nb,l_sort,1);
    NEIGH_INTER    = numel(l_sort);
    
    % Generate output stations >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    if NEIGH_INTER > Para.NEIGH_FINAL

        % Decide whether to add a station into the list of neighbors ------
        clear('l_val')
        temp = D_nb_sort_by_R.Tn_anm + D_nb_sort_by_R.Tg_anm;
        l_val  = ~isnan(reshape(temp, NEIGH_INTER, Para.Nt));

        clear('l_use','l_cant')
        l_use    = [true(Para.NEIGH_FINAL,1); ...
                          false(NEIGH_INTER - Para.NEIGH_FINAL,1)];
        n_sta    = nansum(l_val(l_use,:),1);
        l_sparse = n_sta < Para.MIN_STNS;

        for add_target = (Para.NEIGH_FINAL+1):1:NEIGH_INTER
            if any(l_sparse & l_val(add_target,:) == 1)   
                % if it provides data in the data sparse period -----------
                use_list = find(l_use)'; 
                for rm_target = use_list(end:-1:1)
                    use_list_rm = use_list;
                    use_list_rm(use_list_rm == rm_target) = [];
                    n_sta_add    = nansum(l_val([use_list_rm add_target],:),1);
                    l_add_new    = any((n_sta_add - n_sta) > 0 & l_sparse);
                    l_not_rm     = ~any((n_sta_add - n_sta) < 0 & l_sparse);
                    if l_add_new && l_not_rm
                        l_use(rm_target)  = 0;
                        l_use(add_target) = 1;
                        n_sta             = nansum(l_val(l_use,:),1);
                        l_sparse          = n_sta < Para.MIN_STNS;
                        break
                    end
                end
            end
        end
        D_nb_final = CDC_subset2(D_nb_sort_by_R,l_use,1);
    else
        D_nb_final = D_nb_sort_by_R;
    end

    % Output local network >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    net   = [repmat(D_tg.UID,numel(D_nb_final.UID),1) D_nb_final.UID];
end