% [BINNED,W_X] = LME_lme_bin_2021_pattern(P)
% Stemmed from LME_lme_bin_2021
%
% P.type
% P.subset_year
% P.key = 5000;           % threshold of pairs the group to be included
% P.varname = 'SST';      % not necessary but for running early script
% P.method  = 'Ship';     % not necessary but for running early script
% P.yr_start    = 1850;   % Assign years, when all yearly effect is the same
% P.yr_interval = 5;      % This function is turned off
% P.save_sum & P.save_sum_binned

function [BINNED,W_X] = LME_lme_bin_2021_pattern(P)

    % *********************************************************************
    % Load Data
    % *********************************************************************
    try
        if P.do_combined_analysis == 1
            file_load  = LME_output_files('SST_Pairs_sum_dedup',P);
        else
            file_load  = LME_output_files('SST_Pairs_sum',P);
        end
        load(file_load,'P1','P2');
    catch
        disp('problems occurs when reading the target file')
        return
    end

    % *********************************************************************
    % Get information at pair level
    % *********************************************************************
    if strcmp(P.case_name,'nation_deck_method')
        P1.SI_Std(ismember(P1.SI_Std,[7 9])) = -1;
        P2.SI_Std(ismember(P2.SI_Std,[7 9])) = -1;
        P1.SI_Std(ismember(P1.SI_Std,[4])) = 3;
        P2.SI_Std(ismember(P2.SI_Std,[4])) = 3;
    end

    if strcmp(P.case_name,'nation_deck_method')
        P1.grp = [P1.DCK P1.SI_Std];
        P2.grp = [P2.DCK P2.SI_Std];
    elseif strcmp(P.case_name,'kent_id')
        P1.grp = [P1.ID_Kent];
        P2.grp = [P2.ID_Kent];
    end
    
    % Exchange pairs such that grp1 is always smaller than grp2
    [grp_uni,~,grp_id] = unique([P1.grp; P2.grp],'rows');
    l1                 = grp_id(1:size(P1.grp,1));
    l2                 = grp_id((size(P1.grp,1)+1):end);
    l_exchg            = l1 > l2;
    P1_temp            = ICOADS_combine(CDC_subset2(P1,~l_exchg,1),CDC_subset2(P2,l_exchg,1));
    P2_temp            = ICOADS_combine(CDC_subset2(P2,~l_exchg,1),CDC_subset2(P1,l_exchg,1));
    P1                 = P1_temp;
	P2                 = P2_temp;
	clear('P1_temp','P2_temp')

    clear('P_sum')
    if strcmp(P.case_name,'nation_deck_method')
        P_sum.grp1 = [P1.DCK P1.SI_Std];
        P_sum.grp2 = [P2.DCK P2.SI_Std];
    elseif strcmp(P.case_name,'kent_id')
        P_sum.grp1 = [P1.ID_Kent];
        P_sum.grp2 = [P2.ID_Kent];
    end
    P_sum.mx = LME_function_mean_period([P1.C0_LON'; P2.C0_LON'],360)';
    P_sum.my = nanmean([P1.C0_LAT P2.C0_LAT],2);
    P_sum.data_cmp = (P1.C0_SST - P1.C0_OI_CLIM - P1.Buoy_Diurnal) - ...
                     (P2.C0_SST - P2.C0_OI_CLIM - P2.Buoy_Diurnal);

    % Get corrections in SST climatology from drifting buoy ---------------
    if isfield(P,'correct_buoy_clim')
        P1.offset_pnt  = LME_function_get_buoy_clim_offset(P,P1);
        P2.offset_pnt  = LME_function_get_buoy_clim_offset(P,P2);
        P_sum.data_cmp = P_sum.data_cmp - (P1.offset_pnt - P2.offset_pnt);
    end

    % *********************************************************************
    % Load Pattern of SST biases
    % *********************************************************************
    disp(['Get pattern of biases ...'])
    file_pattern = LME_input_files('Pattern',P);
    load(file_pattern,'Bucket_bias_pattern')

    mon_temp = P1.C0_MO;
    % mon_temp(P_sum.my < 0) = mon_temp(P_sum.my < 0) + 6;
    % mon_temp(mon_temp > 12) = mon_temp(mon_temp > 12) - 12;

    P_sum.bucket_pattern = LME_function_grd2pnt...
                    (P_sum.mx,P_sum.my,mon_temp,Bucket_bias_pattern,5,5,1);
    clear('mon_temp')

    % *********************************************************************
    % Remove pairs that have the same groupings
    % *********************************************************************
    disp('Remove duplicate pairs and small groups ...')
    clear('l_rp','l_sm','l_rm')
    l_rp = all(P_sum.grp1 == P_sum.grp2,2);

    % remove small groups -------------------------------------------------
    [~,~,L] = unique([P_sum.grp1; P_sum.grp2],'rows');
    l_sm = ismember(L,find(hist(L,1:1:max(L)) <= P.key));
    l_sm = any([l_sm(1:numel(l_sm)/2)  l_sm(numel(l_sm)/2+1:end)],2);
    clear('L')

    l_rm = l_rp | l_sm | isnan(P_sum.bucket_pattern);

    % Remove points that does not belong to a certain month ---------------
    % if isfield(P,'mon_list')
    %     if numel(P.mon_list) ~= 12
    %         mon_temp = P1.C0_MO;
    %         % mon_temp(P_sum.my < 0) = mon_temp(P_sum.my < 0) + 6;
    %         % mon_temp(mon_temp > 12) = mon_temp(mon_temp > 12) - 12;
    %         l_rm = l_rm | ~ismember(mon_temp,P.mon_list);
    %         clear('mon_temp')
    %     end
    % end

    % Remove points that does not belong to a certain period of years -----
    if isfield(P,'subset_year')
        l_rm = l_rm | ~ismember(P1.C0_YR,P.subset_year);
    end

    % Subset Data ---------------------------------------------------------
    P1    = ICOADS_subset(P1,   ~l_rm);
    P2    = ICOADS_subset(P2,   ~l_rm);
    P_sum = ICOADS_subset(P_sum,~l_rm);

    clear('l_rp','l_sm','l_rm')
    disp('Remove duplicate pairs and small groups completes!')
    disp(' ')

    % *********************************************************************
    % Assign error structure for pairs
    % *********************************************************************
    % Compute the climatic variance of SST --------------------------------
    disp(['Compute the climatic variance ...'])
    P_sum.var_clim = LME_lme_var_clim(P1.C0_LON',P2.C0_LON',...
                  P1.C0_LAT',P2.C0_LAT',P1.C0_UTC',P2.C0_UTC',P1.C0_MO',P)';
    P_sum.var_clim(isnan(P_sum.var_clim)) = 10;                 % P.varname

    % Get observational error and power of error decay --------------------
    disp(['Compute the observational variance ...'])
    [var_rnd,var_ship,pow] = LME_lme_var_obs_cd(P);
    P_sum.w        = ones(size(P1.C0_LON,1),1);
    P_sum.var_rnd  = P_sum.w * var_rnd;
    P_sum.var_ship = P_sum.w * var_ship;
    disp('Assign error structure completes!')
    disp(' ')

    % *********************************************************************
    % Assign Effects to pairs of SSTs
    % *********************************************************************
    disp('Assign effects ...')
    % Assign regional effects ---------------------------------------------
    P_sum.group_region_lon = discretize(P_sum.mx,[0:30:360]);
    P_sum.group_region_lat = discretize(P_sum.my,[-90:15:90]);

    % Assign seasonal effect (this function is turned off after V2020) ----
    P_sum.group_season = P1.C0_MO;

    % Assign decadal effect (P.yr_start / P.yr_interval) ------------------
    P_sum.group_decade = LME_lme_effect_decadal(P1.C0_YR,P);
    if all(P_sum.group_decade == 1), P_sum.group_decade(:) = 0; end
    disp('Assign effects completes!');    disp(' ')

    % *********************************************************************
    % Generate BINs
    % *********************************************************************
    [kind_bin_uni,~,group_nation] = unique([P_sum.grp1 P_sum.grp2],'rows');

    [kind_binned_uni,~,~] = unique([P_sum.group_decade, group_nation,...
                      P_sum.group_region_lon, P_sum.group_region_lat,...
                                              P_sum.group_season],'rows');

    disp(['A total of ',num2str(size(kind_bin_uni,1)),...
                                     ' combinations of groups']); disp(' ')

    disp(['A total of ',num2str(size(kind_binned_uni,1)),...
                              ' combinations of groups + region + decade'])

    % *********************************************************************
    % Compute the weights in the constrain
    % *********************************************************************
    [Group_uni,~,J_group] = unique([P_sum.grp1;  P_sum.grp2],'rows');
    W_X = hist(J_group,1:1:max(J_group));
    W_X = W_X./nansum(W_X);
    clear('P1','P2');

    % *********************************************************************
    % Bin the pairs in a fast manner
    % *********************************************************************
    disp('Start Binning ...')

    N_group_combination   = size(kind_bin_uni,1);
    N_total               = size(kind_binned_uni,1);
    BINNED.Bin_y          = nan(N_total,1);
    BINNED.Bin_w          = nan(N_total,1);
    BINNED.Bin_n          = nan(N_total,1);
    BINNED.Bin_var_clim   = nan(N_total,1);
    BINNED.Bin_var_rnd    = nan(N_total,1);
    BINNED.Bin_var_ship   = nan(N_total,1);
    BINNED.Bin_region_lon = nan(N_total,1);
    BINNED.Bin_region_lat = nan(N_total,1);
    BINNED.Bin_decade     = nan(N_total,1);
    BINNED.Bin_season     = nan(N_total,1);
    BINNED.Bin_pattern    = nan(N_total,1);
    BINNED.Bin_kind       = nan(N_total,size(kind_bin_uni,2));
    BINNED.Group_uni      = Group_uni;
    
    if isfield(P,'bin_sub_id')
        list_ct_nat = [1:2500] + (P.bin_sub_id - 1) * 2500;
        list_ct_nat(list_ct_nat > N_group_combination) = [];
    else
        list_ct_nat = 1:N_group_combination;
    end
    
    % ---------------------------------------------------------------------
    % Binning starts
    % ---------------------------------------------------------------------
    ct = 0;
    % nation level --------------------------------------------------------
    for ct_nat = list_ct_nat
        if rem(ct_nat,100) == 0
            disp(['Starting the ',num2str(ct_nat),'th Pairs'])
        end
        clear('l'); l = group_nation == ct_nat;
        clear('P_sum_nat'); P_sum_nat = ICOADS_subset(P_sum,l);

        % decade level ----------------------------------------------------
        clear('decade_uni','J_decade')
        [decade_uni,~,J_decade] = unique(P_sum_nat.group_decade);

        for ct_dcd = 1:max(J_decade)
            clear('l'); l = J_decade == ct_dcd;
            clear('P_sum_dcd'); P_sum_dcd = ICOADS_subset(P_sum_nat,l);

            % region-lon level --------------------------------------------
            clear('region_lon_uni','J_region_lon')
            [region_lon_uni,~,J_region_lon] = unique(P_sum_dcd.group_region_lon);

            for ct_reg_lon = 1:max(J_region_lon)
                clear('l');  l = J_region_lon == ct_reg_lon;
                clear('P_sum_reg_lon'); P_sum_reg_lon = ICOADS_subset(P_sum_dcd,l);

                % region-lat level ----------------------------------------
                clear('region_lat_uni','J_region_lat')
                [region_lat_uni,~,J_region_lat] = unique(P_sum_reg_lon.group_region_lat);

                for ct_reg_lat = 1:max(J_region_lat)
                    clear('l');  l = J_region_lat == ct_reg_lat;
                    clear('P_sum_reg_lat'); P_sum_reg_lat = ICOADS_subset(P_sum_reg_lon,l);

                    % season level ----------------------------------------
                    clear('season_uni','J_season')
                    [season_uni,~,J_season] = unique(P_sum_reg_lat.group_season);

                    for ct_sea = 1:max(J_season)
                        clear('l');  l = J_season == ct_sea;
                        clear('P_sum_sea'); P_sum_sea = ICOADS_subset(P_sum_reg_lat,l);

                        % Compute the binned average **********************
                        ct = ct + 1;
                        clear('w','n');
                        w = P_sum_sea.w ./ nansum(P_sum_sea.w);
                        n = numel(P_sum_sea.w);
                        BINNED.Bin_y(ct) = nansum(P_sum_sea.data_cmp .* w);
                        BINNED.Bin_pattern(ct) = nansum(P_sum_sea.bucket_pattern .* w);
                        BINNED.Bin_n(ct) = n;

                        clear('var_clim_bin','var_rnd_bin','var_ship_bin')
                        var_clim_bin = nanmean(P_sum_sea.var_clim)  ./ n;
                        var_rnd_bin  = 2*nanmean(P_sum_sea.var_rnd) ./ n;
                        var_ship_bin = 2*nanmean(P_sum_sea.var_ship)./(n.^pow);
                        BINNED.Bin_w(ct) = 1 ./ ...
                            (var_clim_bin + var_rnd_bin + var_ship_bin);

                        BINNED.Bin_var_clim(ct) = var_clim_bin;
                        BINNED.Bin_var_rnd(ct)  = var_rnd_bin;
                        BINNED.Bin_var_ship(ct) = var_ship_bin;
                        BINNED.Bin_region_lon(ct) = region_lon_uni(ct_reg_lon);
                        BINNED.Bin_region_lat(ct) = region_lat_uni(ct_reg_lat);
                        BINNED.Bin_decade(ct) = decade_uni(ct_dcd);
                        BINNED.Bin_season(ct) = season_uni(ct_sea);
                        BINNED.Bin_kind(ct,:) = kind_bin_uni(ct_nat,:);

                        clear('w','n','P_sum_sea');
                        clear('var_clim_bin','var_rnd_bin','var_ship_bin')
                    end
                    clear('temp_season_uni','J_season','P_sum_reg_lat')
                end
                clear('temp_region_lat_uni','J_region_lat','P_sum_reg_lon')
            end
            clear('temp_region_lon_uni','J_region_lon','P_sum_dcd')
        end
        clear('temp_decade_uni','J_decade','P_sum_nat')
    end
    clear('ct','ct_dcd','ct_nat','ct_reg','ct_sea')
    clear('group_nation','kind_bin_uni','kind_binned_uni')
    disp('Binning completes!')
    disp(' ')

    % *********************************************************************
    % Save data
    % *********************************************************************
    if isfield(P,'bin_sub_id')
        l_sub  = ~isnan(BINNED.Bin_y);
        if nnz(l_sub) > 0
            BINNED = CDC_subset2(BINNED,l_sub,1); 
            if P.do_combined_analysis == 1
                file_save  = LME_output_files('SST_Pairs_binned_pattern_dedup_sub',P);
            else
                file_save  = LME_output_files('SST_Pairs_binned_pattern_sub',P);
            end
            save(file_save,'BINNED','W_X','-v7.3');
        end
    else
        if P.do_combined_analysis == 1
            file_save  = LME_output_files('SST_Pairs_binned_pattern_dedup',P);
        else
            file_save  = LME_output_files('SST_Pairs_binned_pattern',P);
        end
        save(file_save,'BINNED','W_X','-v7.3');
    end
end
