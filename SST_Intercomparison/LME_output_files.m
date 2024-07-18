function file = LME_output_files(input,P)

    % SST-SST pairs =======================================================
    if strcmp(input,'SST_Pairs_all')
        file = [LME_OI('all_pairs'),'IMMA1_R',ICOADS_NC_version(P.yr),'_',...
        num2str(P.yr),'-',CDF_num2str(P.mon,2),'_All_ship_pairs_',P.case_name,'.mat'];

    elseif strcmp(input,'SST_Pairs_sub')
        file = [LME_OI('screen_pairs'),'IMMA1_R',ICOADS_NC_version(P.yr),'_',...
        num2str(P.yr),'-',CDF_num2str(P.mon,2),'_Ship_pairs_',P.case_name,'.mat'];
    
    elseif strcmp(input,'SST_Pairs_sum')
        file = [LME_OI('bin_pairs'),'SUM_ship_ship_pairs_',P.case_name,'_',...
                 num2str(P.subset_yr_list(1)),'_',num2str(P.subset_yr_list(end)),'.mat'];
        
    % SST-Station pairs ===================================================
    elseif strcmp(input,'SAT_Pairs_sub')
        dir_save = [LME_OI('home'),'Step_L01_Pairs/'];
        file = [dir_save,'ICOADS_R',ICOADS_NC_version(P.yr),'_',...
            num2str(P.yr),'-',CDF_num2str(P.mon,2),'_pairs_SST_land_do_season_',num2str(P.do_season),'.mat'];
        
    elseif strcmp(input,'SAT_Pairs_sum')   
        dir_save = [LME_OI('home'),'Step_L02_SUM_Pairs/'];
        file = [dir_save,'SUM_ship_land_pairs_',P.case_name,'_',...
                 num2str(P.subset_yr_list(1)),'_',num2str(P.subset_yr_list(end)),'_do_season_',num2str(P.do_season),'.mat'];

    % Pairs seperated for combined analysis ===============================

    elseif strcmp(input,'SST_Pairs_sum_dedup')
        file = [LME_OI('bin_pairs'),'SUM_ship_ship_pairs_',P.case_name,'_',...
                 num2str(P.subset_yr_list(1)),'_',num2str(P.subset_yr_list(end)),'_do_season_',num2str(P.do_season),'_for_combined_analysis.mat'];

    elseif strcmp(input,'SAT_Pairs_sum_dedup')   
        dir_save = [LME_OI('home'),'Step_L02_SUM_Pairs/'];
        file = [dir_save,'SUM_ship_land_pairs_',P.case_name,'_',...
                 num2str(P.subset_yr_list(1)),'_',num2str(P.subset_yr_list(end)),'_do_season_',num2str(P.do_season),'_for_combined_analysis.mat'];

    % Binned Pairs ========================================================
    
    elseif strcmp(input,'SST_Pairs_binned_pattern')
        file = [LME_OI('bin_pairs'),'Binned_ship_ship_pairs_',P.case_name,'_',...
                 num2str(P.subset_yr_list(1)),'_',num2str(P.subset_yr_list(end)),'_do_season_',num2str(P.do_season),'_pattern.mat'];

    elseif strcmp(input,'SST_Pairs_binned_pattern_sub')
        file = [LME_OI('bin_pairs'),'Binned_ship_ship_pairs_',P.case_name,'_',...
                 num2str(P.subset_yr_list(1)),'_',num2str(P.subset_yr_list(end)),'_do_season_',num2str(P.do_season),'_pattern_en_',num2str(P.bin_sub_id),'.mat'];

    elseif strcmp(input,'SAT_Pairs_binned_pattern')
        dir_save = [LME_OI('home'),'Step_L03_Binned_Pairs/'];
        file = [dir_save,'Binned_ship_land_pairs_',P.case_name,'_',...
                 num2str(P.subset_yr_list(1)),'_',num2str(P.subset_yr_list(end)),'_do_season_',num2str(P.do_season),'_pattern.mat'];
            
    elseif strcmp(input,'SST_Pairs_binned_pattern_dedup')
        file = [LME_OI('bin_pairs'),'Binned_ship_ship_pairs_',P.case_name,'_',...
                 num2str(P.subset_yr_list(1)),'_',num2str(P.subset_yr_list(end)),'_do_season_',num2str(P.do_season),'_pattern_combined_analysis.mat'];

        elseif strcmp(input,'SST_Pairs_binned_pattern_dedup_sub')
        file = [LME_OI('bin_pairs'),'Binned_ship_ship_pairs_',P.case_name,'_',...
                 num2str(P.subset_yr_list(1)),'_',num2str(P.subset_yr_list(end)),'_do_season_',num2str(P.do_season),'_pattern_combined_analysis_en_',num2str(P.bin_sub_id),'.mat'];
             
    elseif strcmp(input,'SAT_Pairs_binned_pattern_dedup')
        dir_save = [LME_OI('home'),'Step_L03_Binned_Pairs/'];
        file = [dir_save,'Binned_ship_land_pairs_',P.case_name,'_',...
                 num2str(P.subset_yr_list(1)),'_',num2str(P.subset_yr_list(end)),'_do_season_',num2str(P.do_season),'_pattern_combined_analysis.mat'];

    % LME output ==========================================================
    elseif strcmp(input,'LME_output_pattern_core')
        dir_save  = LME_OI('LME_output');
        file = [dir_save,'LME_',P.case_name,'_',...
                 num2str(P.subset_yr_list(1)),'_',num2str(P.subset_yr_list(end)),'_do_season_',num2str(P.do_season),'_pattern_excld_smll_bns_',num2str(P.excld_smll_bns),'_core.mat'];

    elseif strcmp(input,'LME_output_pattern_full')
        dir_save  = LME_OI('LME_output'); 
        file = [dir_save,'LME_',P.case_name,'_',...
                 num2str(P.subset_yr_list(1)),'_',num2str(P.subset_yr_list(end)),'_do_season_',num2str(P.do_season),'_pattern_excld_smll_bns_',num2str(P.excld_smll_bns),'_full.mat'];
    
    elseif strcmp(input,'LME_output_pattern_combined_core')
        dir_save  = LME_OI('LME_output');
        file = [dir_save,'LME_',P.case_name,'_',...
                 num2str(P.subset_yr_list(1)),'_',num2str(P.subset_yr_list(end)),'_do_season_',num2str(P.do_season),'_pattern_combined_analysis_excld_smll_bns_',num2str(P.excld_smll_bns),'_core.mat'];

    elseif strcmp(input,'LME_output_pattern_combined_full')
        dir_save  = LME_OI('LME_output');
        file = [dir_save,'LME_',P.case_name,'_',...
                 num2str(P.subset_yr_list(1)),'_',num2str(P.subset_yr_list(end)),'_do_season_',num2str(P.do_season),'_pattern_combined_analysis_excld_smll_bns_',num2str(P.excld_smll_bns),'_full.mat'];

    % Correction output ===================================================

    elseif strcmp(input,'Corr_2022_clean')
        dir_save  = LME_OI('idv_corr');
        file = [dir_save,'Raw_and_Correction_',P.case_name,'_',...
                 num2str(P.subset_yr_list(1)),'_',num2str(P.subset_yr_list(end)),'_do_season_',num2str(P.do_season),'_pattern_excld_smll_bns_',num2str(P.excld_smll_bns),'.mat'];

    elseif strcmp(input,'Corr_2022_sum')
        dir_save  = LME_OI('rnd_corr');
        file = [dir_save,'SST_en_',num2str(P.en),'_',P.case_name,'_do_season_',num2str(P.do_season),'_pattern_excld_smll_bns_',num2str(P.excld_smll_bns),'.mat'];

    elseif strcmp(input,'Corr_full_sst_only')
        dir_save  = LME_OI('idv_corr');
        file = [dir_save,'Corr_full_',P.case_name,'_',...
                 num2str(P.subset_yr_list(1)),'_',num2str(P.subset_yr_list(end)),'_do_season_',num2str(P.do_season),'_pattern_excld_smll_bns_',num2str(P.excld_smll_bns),'.mat'];

    elseif strcmp(input,'Corr_idv_sst_only')
        dir_save  = LME_OI('idv_corr');
        file = [dir_save,'Corr_inv_en_',num2str(P.en),'_',P.case_name,'_',...
                 num2str(P.subset_yr_list(1)),'_',num2str(P.subset_yr_list(end)),'_do_season_',num2str(P.do_season),'_pattern_excld_smll_bns_',num2str(P.excld_smll_bns),'.mat'];

    elseif strcmp(input,'Corr_rnd_sst_only')
        dir_save  = LME_OI('rnd_corr');
        file = [dir_save,'Corr_rnd_en_',num2str(P.en),'_',P.case_name,'_',...
                 num2str(P.subset_yr_list(1)),'_',num2str(P.subset_yr_list(end)),'_do_season_',num2str(P.do_season),'_pattern_excld_smll_bns_',num2str(P.excld_smll_bns),'.mat'];

    elseif strcmp(input,'Post_1_sst_only')
        dir_save  = [LME_OI('home'),'Step_XX_Download/'];
        file = [dir_save,'Statistics_raw_corr_',P.case_name,'_',...
                 num2str(P.subset_yr_list(1)),'_',num2str(P.subset_yr_list(end)),'_do_season_',num2str(P.do_season),'_pattern_excld_smll_bns_',num2str(P.excld_smll_bns),'.mat'];

    elseif strcmp(input,'Corr_full')
        dir_save  = [LME_OI('home'),'Step_L05_Idv_Corr/'];
        file = [dir_save,'Corr_full_',P.case_name,'_',...
                 num2str(P.subset_yr_list(1)),'_',num2str(P.subset_yr_list(end)),'_do_season_',num2str(P.do_season),'_pattern_combined_analysis_excld_smll_bns_',num2str(P.excld_smll_bns),'_core.mat'];

    elseif strcmp(input,'Corr_idv')
        dir_save  = [LME_OI('home'),'Step_L05_Idv_Corr/'];
        file = [dir_save,'Corr_inv_en_',num2str(P.en),'_',P.case_name,'_',...
                 num2str(P.subset_yr_list(1)),'_',num2str(P.subset_yr_list(end)),'_do_season_',num2str(P.do_season),'_pattern_combined_analysis_excld_smll_bns_',num2str(P.excld_smll_bns),'_full.mat'];

    elseif strcmp(input,'Corr_rnd')
        dir_save  = [LME_OI('home'),'Step_L06_Rnd_Corr/'];
        file = [dir_save,'Corr_rnd_en_',num2str(P.en),'_',P.case_name,'_',...
                 num2str(P.subset_yr_list(1)),'_',num2str(P.subset_yr_list(end)),'_do_season_',num2str(P.do_season),'_pattern_combined_analysis_excld_smll_bns_',num2str(P.excld_smll_bns),'_full.mat'];

    elseif strcmp(input,'Post_1')
        dir_save  = [LME_OI('home'),'Step_LXX_Download/'];
        file = [dir_save,'Statistics_raw_corr_',P.case_name,'_',...
                 num2str(P.subset_yr_list(1)),'_',num2str(P.subset_yr_list(end)),'_do_season_',num2str(P.do_season),'_pattern_combined_analysis_excld_smll_bns_',num2str(P.excld_smll_bns),'.mat'];
   
    end

end
