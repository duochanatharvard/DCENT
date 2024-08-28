% out = AOI_read_data(input, num, Para_AOI)
    
function out = AOI_read_data(input, num, Para_AOI)

    reso = Para_AOI.reso_x;
    app  = [num2str(reso),'X',num2str(reso)];

    if strcmp(input,'LME_SST')
        
        % Load LME corrected SST
        SST_en_id = num;

        file_SST  = [AOI_IO('LME_SST'),'SST_',app,'_en_',num2str(SST_en_id),...
               '_nation_deck_method_do_season_0_pattern_excld_smll_bns_',...
               num2str(Para_AOI.excld_smll_bns),'.mat'];
        load(file_SST,'SST_ship');
        out       = SST_ship;
        
    elseif strcmp(input,'SST_ship_raw')
        file_SST  = [AOI_IO('LME_SST'),'SST_',app,'_en_-1_nation_deck_method_',...
            'do_season_0_pattern_excld_smll_bns_',num2str(Para_AOI.excld_smll_bns),'.mat'];
        load(file_SST,'SST_ship');
        out       = SST_ship;

    elseif strcmp(input,'SST_buoy')
        file_SST  = [AOI_IO('LME_SST'),'SST_',app,'_en_-1_nation_deck_method_',...
            'do_season_0_pattern_excld_smll_bns_',num2str(Para_AOI.excld_smll_bns),'.mat'];
        load(file_SST,'SST_buoy');
        out       = SST_buoy;

    elseif strcmp(input,'N_ship')
        file_SST  = [AOI_IO('LME_SST'),'SST_',app,'_en_-1_nation_deck_method_',...
            'do_season_0_pattern_excld_smll_bns_',num2str(Para_AOI.excld_smll_bns),'.mat'];
        load(file_SST,'NUM_ship');
        out       = NUM_ship;

    elseif strcmp(input,'N_buoy')
        file_SST  = [AOI_IO('LME_SST'),'SST_',app,'_en_-1_nation_deck_method_',...
            'do_season_0_pattern_excld_smll_bns_',num2str(Para_AOI.excld_smll_bns),'.mat'];
        load(file_SST,'NUM_buoy');
        out       = NUM_buoy;

    elseif strcmp(input,'SST_infer')
        file_SST  = [AOI_IO('data_download',Para_SATH),'Inferred_SST_gridded_20220519.mat'];
        load(file_SST,'SST_infer_grid');
        out       = SST_infer_grid;
        
    end
end
