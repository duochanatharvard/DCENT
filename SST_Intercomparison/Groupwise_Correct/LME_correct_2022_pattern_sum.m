function LME_correct_2022_pattern_sum(P)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if P.en == -1 % Raw Ship and buoy temperatures
        
        SST_ship = nan(360/P.reso_x,180/P.reso_y,12,numel(P.yr_list));
        NUM_ship = zeros(360/P.reso_x,180/P.reso_y,12,numel(P.yr_list));
        SST_buoy = nan(360/P.reso_x,180/P.reso_y,12,numel(P.yr_list));
        NUM_buoy = zeros(360/P.reso_x,180/P.reso_y,12,numel(P.yr_list));
        for yr = P.yr_list

            if rem(yr,10) == 0, disp(num2str(yr)); end
            
            yr_id     = yr - P.yr_list(1) + 1;
            PP        = P; PP.subset_yr_list = yr;
            file_load = LME_output_files('Corr_2022_clean',PP);

            data = load(file_load,'SST_ship','NUM_ship','SST_buoy','NUM_buoy');
            SST_ship(:,:,:,yr_id) = data.SST_ship;
            NUM_ship(:,:,:,yr_id) = data.NUM_ship;
            SST_buoy(:,:,:,yr_id) = data.SST_buoy;
            NUM_buoy(:,:,:,yr_id) = data.NUM_buoy;
        end
        
        file_save = LME_output_files('Corr_2022_sum',P);
        save(file_save,'SST_ship','NUM_ship','SST_buoy','NUM_buoy','-v7.3');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif P.en == 0  % Central corrected temperatures 

        SST_ship = nan(360/P.reso_x,180/P.reso_y,12,numel(P.yr_list));
        SST_ship_fix_ones = nan(360/P.reso_x,180/P.reso_y,12,numel(P.yr_list));
        SST_ship_dcd_ones = nan(360/P.reso_x,180/P.reso_y,12,numel(P.yr_list));
        SST_ship_fix_ptrn = nan(360/P.reso_x,180/P.reso_y,12,numel(P.yr_list));
        SST_ship_dcd_ptrn = nan(360/P.reso_x,180/P.reso_y,12,numel(P.yr_list));
        for yr = P.yr_list
            
            if rem(yr,10) == 0, disp(num2str(yr)); end

            yr_id     = yr - P.yr_list(1) + 1;
            PP        = P; PP.subset_yr_list = yr;
            file_load = LME_output_files('Corr_2022_clean',PP);

            data = load(file_load,'SST_ship','SST_corr');
            corr = data.SST_corr.grp_dcd_ones + ...
                   data.SST_corr.grp_dcd_ptrn + ...
                   data.SST_corr.grp_fix_ones + ...
                   data.SST_corr.grp_fix_ptrn;
            SST_ship(:,:,:,yr_id) = data.SST_ship + corr;

            corr = data.SST_corr.grp_fix_ones;
            SST_ship_fix_ones(:,:,:,yr_id) = data.SST_ship + corr;
            
            corr = data.SST_corr.grp_dcd_ones;
            SST_ship_dcd_ones(:,:,:,yr_id) = data.SST_ship + corr;

            corr = data.SST_corr.grp_fix_ptrn;
            SST_ship_fix_ptrn(:,:,:,yr_id) = data.SST_ship + corr;
            
            corr = data.SST_corr.grp_dcd_ptrn;
            SST_ship_dcd_ptrn(:,:,:,yr_id) = data.SST_ship + corr;
            
        end

        file_save = LME_output_files('Corr_2022_sum',P);
        save(file_save,'SST_ship','SST_ship_fix_ones','SST_ship_dcd_ones',...
            'SST_ship_fix_ptrn','SST_ship_dcd_ptrn','-v7.3');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif P.en > 0  % Randomized corrected temperatures

        SST_ship = nan(360/P.reso_x,180/P.reso_y,12,numel(P.yr_list));
        for yr = P.yr_list

            if rem(yr,10) == 0, disp(num2str(yr)); end
            
            yr_id     = yr - P.yr_list(1) + 1;
            PP        = P; PP.subset_yr_list = yr;
            file_load = LME_output_files('Corr_2022_clean',PP);

            data = load(file_load,'SST_ship',['SST_corr_rnd',num2str(P.en)]);

            data.SST_corr_rnd = data.(['SST_corr_rnd_', num2str(P.en)]);

            corr = data.SST_corr_rnd.grp_dcd_ones_rnd(:,:,:,:,P.en) + ...
                   data.SST_corr_rnd.grp_dcd_ptrn_rnd(:,:,:,:,P.en) + ...
                   data.SST_corr_rnd.grp_fix_ones_rnd(:,:,:,:,P.en) + ...
                   data.SST_corr_rnd.grp_fix_ptrn_rnd(:,:,:,:,P.en);
            SST_ship(:,:,:,yr_id) = data.SST_ship + corr;

        end

        file_save = LME_output_files('Corr_2022_sum',P);
        save(file_save,'SST_ship','-v7.3');
    end
end
