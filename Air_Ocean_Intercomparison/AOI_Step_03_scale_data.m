function AOI_Step_03_scale_data(num,Para_AOI)

    SATH_GHCN_post_setup; 

    file_load   = [AOI_IO('data',P),'AOI_paired_coastal_SAT_SST_anomalies_',P.PHA_version,'_R_',num2str(Para_AOI.do_round),'.mat'];
    load(file_load,'raw_SST_anm','raw_SAT_anm','lon','lat','stations','Tier');
    
    file_load = [AOI_IO('data',P),'AOI_Model_para_',P.PHA_version,'_R_',num2str(Para_AOI.do_round),'.mat']; 
    load(file_load,'Parameters');
    
    % *********************************************************************
    % Loop over stations and rescale the data
    % *********************************************************************
    SST_infer = nan(size(raw_SAT_anm));
    
    for ct = 1:size(raw_SAT_anm,1)
        
        if rem(ct,200) == 0, disp(num2str(ct)); end
        
        % Evaluate the BD98d model ----------------------------------------
        SAT = squeeze(raw_SAT_anm(ct,:,:));
        
        if nnz(~isnan(SAT)) > 120

            % Interpolate data to run the fitted AOI model ----------------
            Data  = AOI_func_pre_process_data_scale(SAT,Para_AOI);
            
            % Get fitted parameters
            ct_x  = discretize(lon(ct),0:10:360);
            ct_y  = discretize(lat(ct),-90:10:90);
            x_fit = squeeze(Parameters(ct_x,ct_y,:));
            
            % Use the model to predict
            Data  = AOI_toolbox(Data,x_fit,Para_AOI,'p');
            Data.T_o_m(isnan(Data.SAT)) = nan;
            
            % Put things into a common file according to years
            SST_infer(ct,:,Data.yrs - Para_AOI.yr_sub_st+1) = ...
                               reshape(Data.T_o_m,12,numel(Data.yrs));
        end
    end

    % Calculate SAT anomalies ---------------------------------------------
    [SST_infer_anm,~] = AOI_func_connect_stations(SST_infer,lon,lat,Para_AOI);
    
    file_save = [AOI_IO('data',P),'AOI_Coastal_SAT_inferred_SST_',P.PHA_version,'_R_',num2str(Para_AOI.do_round),'.mat'];
    save(file_save,'SST_infer','SST_infer_anm','raw_SST_anm','raw_SAT_anm','-v7.3');

    file_save = [AOI_IO('data',P),'AOI_SAT_and_inferred_SST_',P.PHA_version,'_R_',num2str(Para_AOI.do_round),'.mat'];
    save(file_save,'SST_infer_anm','raw_SAT_anm','lon','lat','stations','-v7.3');

    % Grid inferred SSTs --------------------------------------------------
    reso_x         = Para_AOI.reso_x; 
    reso_y         = Para_AOI.reso_y; 
    SST_infer_grid = nan(360/reso_x,180/reso_y,12,size(SST_infer_anm,3));
    SST_infer_N    = nan(360/reso_x,180/reso_y,12,size(SST_infer_anm,3));
    for ct_yr = 1:size(SST_infer_anm,3)
        if rem(ct_yr,20) == 0,  disp(ct_yr);  end
        for ct_mon = 1:12
            temp = SST_infer_anm(:,ct_mon,ct_yr);
            l    = ~isnan(temp);
            if nnz(l) > 0
                [SST_infer_grid(:,:,ct_mon,ct_yr),SST_infer_N(:,:,ct_mon,ct_yr)] ...
                    = CDC_pnt2grd(lon(l),lat(l),[],temp(l),reso_x,reso_y,[]);
            end
        end
    end
    
    file_save = [AOI_IO('data',P),'AOI_Inferred_SST_gridded_',P.PHA_version,'_R_',num2str(Para_AOI.do_round),'.mat'];
    save(file_save,'SST_infer_grid','SST_infer_N','-v7.3');

    % Correct SSTs --------------------------------------------------------
    if Para_AOI.do_round == 1
        off = 0;
    else
        off = 100;
    end
    SST_obs = AOI_read_data('LME_SST', num + off, Para_AOI);
    [SST_corr, MLR_b, Stats_common, SST_corr_taper, MLR_b_taper] = AOI_func_correct_SST...
               (SST_infer_grid, SST_infer_N, SST_obs, num + off, Para_AOI);

    file_save = [AOI_IO('data',P),'AOI_Corrected_SST_gridded_5X5_',P.PHA_version,'_R_',num2str(Para_AOI.do_round),'.mat'];
    save(file_save,'SST_corr','MLR_b','SST_corr_taper','MLR_b_taper','-v7.3');  

    clear('SST_infer_grid','SST_infer_N','SST_corr','SST_corr_taper')

    % Generate corrections for 1x1 degree resolution data
    Para_AOI.reso_x = 1;
    Para_AOI.reso_y = 1;
    SST_obs         = AOI_read_data('LME_SST', num + off, Para_AOI);
    SST_corr_taper  = AOI_func_correct_SST_1X1(MLR_b_taper, SST_obs);

    file_save = [AOI_IO('data',P),'AOI_Corrected_SST_gridded_1X1_',P.PHA_version,'_R_',num2str(Para_AOI.do_round),'.mat'];
    save(file_save,'SST_corr_taper','MLR_b_taper','-v7.3');

end
