 function AOI_Step_02_get_scaling(num,Para_AOI)

    SATH_GHCN_post_setup;        
    file_load   = [AOI_IO('data',P),'AOI_paired_coastal_SAT_SST_anomalies_',P.PHA_version,'_R_',num2str(Para_AOI.do_round),'.mat'];
    Data        = load(file_load,'raw_SST_anm','raw_SAT_anm','lon','lat');
    
    % Re-calculate the anomaly only during fitting parameters
    Data.raw_SST_anm = Data.raw_SST_anm - nanmean(Data.raw_SST_anm(:,:,[1982:2014]-1849),3);
    
    % *********************************************************************
    % Compute output arguments
    % *********************************************************************
    if Para_AOI.do_season == 0
        Parameters = nan(36,18,3);
    else
        Parameters = nan(36,18,9);
    end
    for ct_x = 1:36
        for ct_y = 1:18
            
            disp([ct_x ct_y])
            Data_grid = AOI_func_prepare_grid_data(Data,ct_x,ct_y,Para_AOI);
            
            if ~isempty(Data_grid)
                x_fit     = AOI_toolbox(Data_grid,[],Para_AOI,'o');
                Data_grid = AOI_toolbox(Data_grid,x_fit,Para_AOI,'p');

                if Para_AOI.do_season == 0
                    Parameters(ct_x,ct_y,1:3) = x_fit;
                elseif P.do_season == 1
                    Parameters(ct_x,ct_y,1:9) = x_fit;
                end
                
                Save_data{ct_x,ct_y} = Data_grid;
            else
                Save_data{ct_x,ct_y} = [];
            end
            
        end
    end
    
    % *********************************************************************
    % Save scaling factors
    % *********************************************************************
    file_save = [AOI_IO('data',P),'AOI_Model_para_',P.PHA_version,'_R_',num2str(Para_AOI.do_round),'.mat'];
    save(file_save,'Parameters','Save_data','-v7.3');
end
