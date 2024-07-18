function SST_raw = AOI_func_read_raw_SST
    % Load ship and buoy SSTs
    Para_AOI.excld_smll_bns = 1;
    SST_buoy = AOI_read_data('SST_buoy', [], Para_AOI);
    N_buoy   = AOI_read_data('N_buoy',   [], Para_AOI);
    SST_corr = AOI_read_data('SST_ship_raw', [], Para_AOI);
    N_ship   = AOI_read_data('N_ship',   [], Para_AOI);

    % Combine ship SST with Buoy SSTs
    N_buoy2                 = N_buoy;
    N_buoy2(N_buoy2 > 2000) = 2000;
    SST_raw = AOI_func_combine_two_fields(SST_corr,SST_buoy,N_ship,N_buoy2*6.8);
end
