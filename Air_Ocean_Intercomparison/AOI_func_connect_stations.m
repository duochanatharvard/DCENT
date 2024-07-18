function [T_anm,Tier] = AOI_func_connect_stations(T,lon,lat,Para_AOI)

    N_sta = size(T,1);
    yr_st = Para_AOI.yr_sub_st;
    key   = Para_AOI.distance;

    % *********************************************************************
    % Tier 1: stations having enough data to evaluate climatology
    % *********************************************************************
    disp(['Pairing Round ',num2str(1)])
    clim_period  = [1982:2014];

    Tier      = zeros(N_sta,1);
    T_anm     = nan(size(T));
    for ct_station = 1:N_sta

        clear('T_temp_1982')
        T_temp_1982 = squeeze(T(ct_station,:,clim_period - yr_st + 1));  

        % =================================================================
        % If sufficient data are available for compute a climatology
        % =================================================================
        if nansum(nansum(~isnan(T_temp_1982),1) > 6) > 15

            Tier(ct_station) = 1;

            % -------------------------------------------------------------
            % Directly compute the mean
            % -------------------------------------------------------------
            T_clim = nanmean(T_temp_1982,2);
            
            clear('T_temp','T_temp_anm')
            T_temp      = squeeze(T(ct_station,:,:));  
            T_temp_anm  = T_temp - T_clim;
            T_anm(ct_station,:,:) = T_temp_anm;
        end
        clear('T_temp','T_temp_1982','T_temp_anm','T_tmp_anm')
    end

    % *********************************************************************
    % Tier 2-X: stations that do not have enough data to evaluate climatology
    % But has neighboring Tier 1 stations with at least 60-month overlap
    % *********************************************************************
    nb_exist         = zeros(size(T,1),1);
    do_gradual_match = 1;

    for ct_round = 2:25

        disp(['Pairing Round ',num2str(ct_round)])

        yr_st_round = 1990 - ct_round * 10;
        if yr_st_round<yr_st, yr_st_round = yr_st; end

        for ct_station = 1:N_sta


            if Tier(ct_station) == 0

                % =========================================================
                % check data of this station covers the period after yr_st
                % =========================================================
                clear('T_temp','T_temp_1970','id_nb','l_yr')
                l_yr         = [yr_st_round:2020] - yr_st + 1;
                T_temp_round = squeeze(T(ct_station,:,l_yr));   
                T_temp       = squeeze(T(ct_station,:,:));   

                if nnz(~isnan(T_temp_round(:))) > 120
                    % -----------------------------------------------------
                    % Find neighbours 
                    % -----------------------------------------------------
                    clear('dist')
                    dist = distance(lat(ct_station),lon(ct_station),lat,lon);
                    dist(ct_station)              = nan;
                    dist(abs(dist)> (key./111))   = nan;
                    id_nb = find(~isnan(dist) & ismember(Tier,[1:ct_round-1]));

                    if nnz(id_nb) ~= 0

                        nb_exist(ct_station) = 1;

                        % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        % Check if at least 5 years of matches 
                        % between the target station and its neighbours
                        % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        clear('T_temp_nb_anm','N_temp_nb','T_temp_nb_anm_f','N_temp_nb_f')
                        T_temp_nb_anm_f = squeeze(nanmean(T_anm(id_nb,:,:),1));
                        N_temp_nb_f     = squeeze(nansum(~isnan(T_anm(id_nb,:,:)),1));
                        T_temp_nb_anm   = squeeze(nanmean(T_anm(id_nb,:,l_yr),1));
                        N_temp_nb       = squeeze(nansum(~isnan(T_anm(id_nb,:,l_yr)),1));

                        if ct_round <= 13
                            th = 120; 
                        else
                            th = 120 - (ct_round-13)*20; 
                        end
                        th(th<0) = 0;

                        if do_gradual_match == 1
                            l_do = nnz(~isnan(T_temp_round(:) + T_temp_nb_anm(:))) > th;
                        else
                            l_do = nnz(~isnan(T_temp(:) + T_temp_nb_anm_f(:))) > th;
                        end

                        if l_do

                            Tier(ct_station) = ct_round;

                            % If you have a high quality neighbour, ------- 
                            % just match temperature anomalies to 
                            % be consistent with neighbours                
                            clear('T_temp_anm','d','w','dd')
                            T_temp_anm  = T_temp - nanmean(T_temp,2);
                            if do_gradual_match == 1
                                d       = T_temp_anm(:,l_yr) - T_temp_nb_anm;
                                w       = 1./(1+1./N_temp_nb);
                            else
                                d       = T_temp_anm - T_temp_nb_anm_f;
                                w       = 1./(1+1./N_temp_nb_f);
                            end
                            w(isnan(d)) = 0;
                            dd          = nansum(d.*w,2) ./ nansum(w,2);
                            T_temp_anm  = T_temp_anm - dd;
                            T_anm(ct_station,:,:) = T_temp_anm;
                        end
                    end
                end
            end
            clear('T_temp','T_temp_1970','T_temp_anm','T_tmp_anm',...
                  'T_temp_nb','T_temp_nb_anm','N_temp_nb');
        end
    end
end