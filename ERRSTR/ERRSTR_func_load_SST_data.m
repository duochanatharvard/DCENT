function [DATA_ship, DATA_moored, DATA_drifter] = DCENT_ERR_STR_func_load_SST_data(yr,mon)

    % Determine which data are needed
    P.ref = 'SST';
    if yr <= 2009
        P.var = {'ID_Kent','C0_LON','C0_LAT','C0_UTC','SI_Std','C0_ID','C0_II',...
                 'C1_PT','C98_UID','QC_FINAL_SST','C1_ND','C0_CTY_CRT','C1_DCK'};
    else
        P.var = {'C0_LON','C0_LAT','C0_UTC','SI_Std','C0_ID','C0_II',...
                 'C1_PT','C98_UID','QC_FINAL_SST','C1_ND','C0_CTY_CRT','C1_DCK'};
    end

    % Load in ship measurements
    PP = P; PP.yr = yr; PP.mon = mon; PP.buoy_diurnal = 0; PP.mute_read = 1;
    clear('DATA_ship'); DATA_ship = ICOADS_read_ship(PP); clear('PP')
    if yr <= 2009
        l  = ismember(DATA_ship.ID_Kent(:,1:2),'NA','rows');
        DATA_ship.ID_Kent(l,:) = 32;
        DATA_ship.C0_ID = [DATA_ship.C0_II  DATA_ship.ID_Kent];  
    else
        DATA_ship.C0_ID = [DATA_ship.C0_II DATA_ship.C0_ID];
    end

    % Load in buoy measurements
    PP = P; PP.yr = yr; PP.mon = mon; PP.buoy_diurnal = 0; PP.mute_read = 1;
    clear('DATA_all');  DATA_all = ICOADS_read(PP); clear('PP')
    DATA_buoy     = ICOADS_subset(DATA_all,DATA_all.SI_Std==-2 | DATA_all.SI_Std==-3);

    % Split Moored versus Drifters
    l             = ismember(DATA_buoy.C1_PT, [6 9 13 14 15 16]);
    DATA_moored   = ICOADS_subset(DATA_buoy, l);
    DATA_drifter  = ICOADS_subset(DATA_buoy, ~l);

    DATA_moored.C0_ID  = [DATA_moored.C0_II  DATA_moored.C0_ID];
    DATA_drifter.C0_ID = [DATA_drifter.C0_II DATA_drifter.C0_ID];

end