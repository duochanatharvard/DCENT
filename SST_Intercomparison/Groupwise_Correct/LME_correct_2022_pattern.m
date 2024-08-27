% This version tries to calculate things by decade to save the amount of
% time reading files
function LME_correct_2022_pattern(P)

    % *********************************************************************
    % Assign default parameters
    % *********************************************************************
    if ~isfield(P,'connect_Kobe'),    P.connect_Kobe = 0;    end
    if ~isfield(P,'do_add_JP'),       P.do_add_JP = 0;       end
    if ~isfield(P,'do_rmdup'),        P.do_rmdup = 0;        end

    % *********************************************************************
    % Set Parameters for gridding
    % *********************************************************************
    reso_x  = P.reso_x;
    reso_y  = P.reso_y;
    % yr_list = [1850:1854] + (P.en - 1) * 5;
    yr_list = P.en + 1849;
    N_yr    = numel(yr_list);
    
    % *********************************************************************
    % Read the LME outputs & Assigning effects to be corrected
    % *********************************************************************
    lme      = load(LME_output_files('LME_output_pattern_full',P),'out','out_rnd');
    N_member = size(lme.out_rnd.bias_fixed_rnd,2);

    disp(['Get pattern of biases ...'])
    if reso_x == 5
        load(LME_input_files('Pattern',P),'Bucket_bias_pattern')
    else
        load(LME_input_files('Pattern_1x1',P),'Bucket_bias_pattern')
    end
    Bucket_bias_pattern(isnan(Bucket_bias_pattern)) = 0;

    % *********************************************************************
    % Initialize the correction
    % *********************************************************************
    clear('SST_corr','SST_corr_rnd','SST_ship','NUM_ship','SST_buoy','NUM_buoy')
    
    SST_ship = nan(360/reso_x,180/reso_y,12,N_yr);
    NUM_ship = zeros(360/reso_x,180/reso_y,12,N_yr);
    SST_buoy = nan(360/reso_x,180/reso_y,12,N_yr);
    NUM_buoy = zeros(360/reso_x,180/reso_y,12,N_yr);

    SST_corr.grp_fix_ones = zeros(360/reso_x,180/reso_y,12,N_yr);
    SST_corr.grp_fix_ptrn = zeros(360/reso_x,180/reso_y,12,N_yr);
    SST_corr.grp_dcd_ones = zeros(360/reso_x,180/reso_y,12,N_yr);
    SST_corr.grp_dcd_ptrn = zeros(360/reso_x,180/reso_y,12,N_yr);

    SST_corr_rnd.grp_fix_ones_rnd = zeros(360/reso_x,180/reso_y,12,N_yr,N_member);
    SST_corr_rnd.grp_fix_ptrn_rnd = zeros(360/reso_x,180/reso_y,12,N_yr,N_member);
    SST_corr_rnd.grp_dcd_ones_rnd = zeros(360/reso_x,180/reso_y,12,N_yr,N_member);
    SST_corr_rnd.grp_dcd_ptrn_rnd = zeros(360/reso_x,180/reso_y,12,N_yr,N_member);

    % *********************************************************************
    % Start the correction
    % *********************************************************************
    for yr = yr_list
        for mon = 1:12

            disp(['En :',num2str(P.en),' Starting Year ',...
                                      num2str(yr),'  Month ',num2str(mon)])
                                  
            clear('DATA','DATA_all','DATA_buoy')

            try
                % *********************************************************
                % Read in files
                % *********************************************************
                disp('Reading data ...')
                % Read ship SSTs used in the LME analysis
                PP = P; PP.yr = yr; PP.mon = mon; PP.buoy_diurnal = 0; PP.mute_read = 1;
                clear('DATA'); DATA = ICOADS_read_ship(PP); clear('PP')

                do_this_month = 1;
                
            catch
                disp(['Year ',num2str(yr),' Month ',num2str(mon),' does not exist!'])
                do_this_month = 0;
            end
                
            % If file exist, process this month ---------------------------
            if do_this_month == 1
                
                DATA = LME_function_adjust_WWII(DATA);
                if strcmp(P.case_name,'nation_deck_method')
                    DATA.SI_Std(ismember(DATA.SI_Std,[7 9])) = -1;
                    DATA.SI_Std(ismember(DATA.SI_Std,[4]))   = 3;
                end
                kind = [DATA.DCK DATA.SI_Std];
                DATA.bck_pattern = LME_function_grd2pnt(DATA.C0_LON,DATA.C0_LAT,...
                                        [],Bucket_bias_pattern(:,:,mon),reso_x,reso_y,1);

                % Read all SSTs needed to generate gridded data -----------
                % To write a script reading those data
                PP = P; PP.yr = yr; PP.mon = mon; PP.buoy_diurnal = 0; PP.mute_read = 1;
                clear('DATA_all');  DATA_all = ICOADS_read(PP); clear('PP')
                DATA_all = LME_function_adjust_WWII(DATA_all);
                if isfield(P,'correct_buoy_clim')
                    DATA_all.offset_pnt  = LME_function_get_buoy_clim_offset(P,DATA_all);
                    DATA_all.C0_OI_CLIM  = DATA_all.C0_OI_CLIM + DATA_all.offset_pnt;
                end

                DATA_buoy = ICOADS_subset(DATA_all,DATA_all.SI_Std==-2 | DATA_all.SI_Std==-3);
                clear('DATA_all')

                % *********************************************************
                % Applying Common and Groupwise Correction
                % *********************************************************
                disp(['Find Correction ...'])
                clear('CORR')

                % groupwise bias corrections - fixed effect ---------------
                [l,pst] = ismember(kind,lme.out.unique_grp,'rows'); 

                CORR.grp_fix_ones      = corr2pnts(pst,l,lme.out.bias_fixed);
                CORR.grp_fix_ptrn      = corr2pnts(pst,l,lme.out.bias_fixed_pattern,DATA.bck_pattern);
                CORR.grp_fix_ones_rnd  = corr2pnts(pst,l,lme.out_rnd.bias_fixed_rnd);
                CORR.grp_fix_ptrn_rnd  = corr2pnts(pst,l,lme.out_rnd.bias_fixed_pattern_rnd,DATA.bck_pattern);
                
                if isfield(lme.out,'bias_decade')
                    did                    = LME_lme_effect_decadal(DATA.C0_YR(1),P);
                    CORR.grp_dcd_ones      = corr2pnts(pst,l,lme.out.bias_decade(did,:)');
                    CORR.grp_dcd_ptrn      = corr2pnts(pst,l,lme.out.bias_decade_pattern(did,:)',DATA.bck_pattern);
                    CORR.grp_dcd_ones_rnd  = corr2pnts(pst,l,squeeze(lme.out_rnd.bias_decade_rnd(did,:,:)));
                    CORR.grp_dcd_ptrn_rnd  = corr2pnts(pst,l,squeeze(lme.out_rnd.bias_decade_pattern_rnd(did,:,:)),DATA.bck_pattern);
                end
                
                % *********************************************************
                % Gridding data
                % *********************************************************
                disp(['Gridding data ...'])
                clear('lon','lat')
                yr_id = yr-yr_list(1)+1;
                lon = DATA.C0_LON;
                lat = DATA.C0_LAT;

                % gridding corrections ------------------------------------
                SST_corr.grp_fix_ones(:,:,mon,yr_id) = CDC_pnt2grd...
                           (lon,lat,[],CORR.grp_fix_ones,reso_x,reso_y,[]);
                       
                SST_corr.grp_fix_ptrn(:,:,mon,yr_id) = CDC_pnt2grd...
                           (lon,lat,[],CORR.grp_fix_ptrn,reso_x,reso_y,[]);

                SST_corr.grp_dcd_ones(:,:,mon,yr_id) = CDC_pnt2grd...
                           (lon,lat,[],CORR.grp_dcd_ones,reso_x,reso_y,[]);
                       
                SST_corr.grp_dcd_ptrn(:,:,mon,yr_id) = CDC_pnt2grd...
                           (lon,lat,[],CORR.grp_dcd_ptrn,reso_x,reso_y,[]);

                SST_corr_rnd.grp_fix_ones_rnd(:,:,mon,yr_id,:) = CDC_pnt2grd...
                       (lon,lat,[],CORR.grp_fix_ones_rnd,reso_x,reso_y,[]);
                
                SST_corr_rnd.grp_fix_ptrn_rnd(:,:,mon,yr_id,:) = CDC_pnt2grd...
                       (lon,lat,[],CORR.grp_fix_ptrn_rnd,reso_x,reso_y,[]);

                SST_corr_rnd.grp_dcd_ones_rnd(:,:,mon,yr_id,:) = CDC_pnt2grd...
                       (lon,lat,[],CORR.grp_dcd_ones_rnd,reso_x,reso_y,[]);
                       
                SST_corr_rnd.grp_dcd_ptrn_rnd(:,:,mon,yr_id,:) = CDC_pnt2grd...
                       (lon,lat,[],CORR.grp_dcd_ptrn_rnd,reso_x,reso_y,[]);
                
                % Grid raw data -------------------------------------------
                [SST_ship(:,:,mon,yr_id), NUM_ship(:,:,mon,yr_id)] = CDC_pnt2grd...
                    (lon,lat,[],DATA.C0_SST - DATA.C0_OI_CLIM,reso_x,reso_y,[]);

                if ~isempty(DATA_buoy.C0_LON)
                    clear('lon_buoy','lat_buoy')
                    lon_buoy = DATA_buoy.C0_LON;
                    lat_buoy = DATA_buoy.C0_LAT;
                    [SST_buoy(:,:,mon,yr_id), NUM_buoy(:,:,mon,yr_id)] = CDC_pnt2grd...
                        (lon_buoy,lat_buoy,[],DATA_buoy.C0_SST - DATA_buoy.C0_OI_CLIM,reso_x,reso_y,[]);
                end

                clear('WM','NUM')
            else
                SST_ship(:,:,mon,yr_id) = nan;
                SST_buoy(:,:,mon,yr_id) = nan;
            end

        end
    end

    % Save data -----------------------------------------------------------
    PP = P; PP.subset_yr_list = yr_list;
    file_save = LME_output_files('Corr_2022_clean',PP);
    save(file_save,'SST_corr','SST_corr_rnd','SST_ship','NUM_ship','SST_buoy','NUM_buoy','-v7.3');
    
end

function out = corr2pnts(pst,l,lme_bias,pattern)

    pst(pst == 0)   = 1;
    
    out             = - lme_bias(pst,:);
    out(l==0,:)     = 0;  
    out(isnan(out)) = 0;
    if exist('pattern','var')
        out = out .* pattern;
    end
    
end