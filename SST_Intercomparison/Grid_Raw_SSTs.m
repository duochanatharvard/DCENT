% sbatch --account=huybers_lab  -J DA_amplitude  -t 10080 -p huce_intel,huce_cascade -n 1  --mem-per-cpu=20000  --array=1-171  -o logs/err --wrap='matlab -nosplash -nodesktop -nodisplay -r "LME_setup;  num=$SLURM_ARRAY_TASK_ID;  Grid_Raw_SSTs; quit;">>logs/log_Raw_$SLURM_ARRAY_TASK_ID'
% num = 1;

ct_yr  = 1849+num;
reso_x = 5;
reso_y = 5;

dir = '/n/home10/dchan/holy_peter/LME_intercomparison_2021/Step_00_raw_gridded/';
load([dir,'group_information.mat'],'groups')

SST_bucket          = nan(72,36,12);
N_bucket            = zeros(72,36,12);
SST_bucket_infer    = nan(72,36,12);
N_bucket_infer      = zeros(72,36,12);
SST_ERI             = nan(72,36,12);
N_ERI               = zeros(72,36,12);
SST_buoy            = nan(72,36,12);
SST_buoy_full       = nan(72,36,12);
SST_OI_clim         = nan(72,36,12);
N_buoy              = zeros(72,36,12);
SST_group           = nan(72,36,12,size(groups,1));
N_group             = zeros(72,36,12,size(groups,1));

for ct_mon = 1:12

    disp([ct_yr ct_mon])
    P.yr            = ct_yr;
    P.mon           = ct_mon;
    P.var           = {'C0_YR','C0_MO','C0_LCL_int','C0_UTC','C0_LAT','C0_LON','SI_Std',...
                       'C0_SST','C0_W','C0_D','C0_CTY_CRT','C1_DCK','C1_PT','C0_OI_CLIM'};
    P.ref           = 'SST';
    P.do_connect    = 1;
    P.connect_Kobe  = 1;
    P.buoy_diurnal  = 1;

    clear('data','data_ship','data_buoy')
    data_ship       = ICOADS_read_ship(P);
    data            = ICOADS_read(P);
    data_buoy       = ICOADS_subset(data,data.SI_Std == -2);
    clear('data')

    % grid bucket SSTs (exclude RU from deck 732) -------------------------
    clear('data_bucket','SST_in')
    l_use           = data_ship.SI_Std == 0 & ~(data_ship.C1_DCK == 732 & ismember(data_ship.C0_CTY_CRT,'RU','rows'));
    if nnz(l_use) > 0
        data_bucket     = ICOADS_subset(data_ship,l_use);
        SST_in          = data_bucket.C0_SST - data_bucket.C0_OI_CLIM;
        [SST_bucket(:,:,ct_mon),~,N_bucket(:,:,ct_mon)] = ...
              LME_function_gridding(data_bucket.C0_LON',data_bucket.C0_LAT',...
                                    [],SST_in',[],reso_x,reso_y,[],2,[],[],[]);
    end

    clear('data_bucket','SST_in')
    l_use           = data_ship.SI_Std == 0 & ~(data_ship.C1_DCK == 732 & ismember(data_ship.C0_CTY_CRT,'RU','rows'));
    l_infer         = data_ship.C0_YR<=1940 & data_ship.SI_Std == -1;
    if nnz(l_use | l_infer) > 0
        data_bucket     = ICOADS_subset(data_ship,l_use | l_infer);
        SST_in          = data_bucket.C0_SST - data_bucket.C0_OI_CLIM;
        [SST_bucket_infer(:,:,ct_mon),~,N_bucket_infer(:,:,ct_mon)] = ...
              LME_function_gridding(data_bucket.C0_LON',data_bucket.C0_LAT',...
                                    [],SST_in',[],reso_x,reso_y,[],2,[],[],[]);
    end

    % grid ERI SSTs (include US ships after 1941) -------------------------
    clear('data_ERI','SST_in')
    l_use           = data_ship.SI_Std == 1 | (data_ship.C0_YR >= 1941 & ismember(data_ship.C0_CTY_CRT,'US','rows'));
    if nnz(l_use) > 0
        data_ERI        = ICOADS_subset(data_ship,l_use);
        SST_in          = data_ERI.C0_SST - data_ERI.C0_OI_CLIM;
        [SST_ERI(:,:,ct_mon),~,N_ERI(:,:,ct_mon)] = ...
              LME_function_gridding(data_ERI.C0_LON',data_ERI.C0_LAT',...
                                    [],SST_in',[],reso_x,reso_y,[],2,[],[],[]);
    end
    
    % grid Buoy SSTs ------------------------------------------------------
    clear('SST_in')
    if ~isempty(data_buoy.C0_YR)
        SST_in          = data_buoy.C0_SST - data_buoy.C0_OI_CLIM;
        [SST_buoy(:,:,ct_mon),~,N_buoy(:,:,ct_mon)] = ...
              LME_function_gridding(data_buoy.C0_LON',data_buoy.C0_LAT',...
                                    [],SST_in',[],reso_x,reso_y,[],2,[],[],[]);

        SST_in          = data_buoy.C0_SST;
        [SST_buoy_full(:,:,ct_mon),~,~] = ...
              LME_function_gridding(data_buoy.C0_LON',data_buoy.C0_LAT',...
                                    [],SST_in',[],reso_x,reso_y,[],2,[],[],[]);

        SST_in          = data_buoy.C0_OI_CLIM;
        [SST_OI_clim(:,:,ct_mon),~,~] = ...
              LME_function_gridding(data_buoy.C0_LON',data_buoy.C0_LAT',...
                                    [],SST_in',[],reso_x,reso_y,[],2,[],[],[]);
    end
    
    % grid individual groups ----------------------------------------------
    grp = [data_ship.DCK data_ship.SI_Std];
    grp_uni = unique(grp,'rows');
    for ct_grp = 1:size(groups,1)
        disp(ct_grp)
        if ismember(groups(ct_grp,:),grp_uni,'rows')
            clear('data_grp')
            l_use    = ismember(grp,groups(ct_grp,:),'rows');
            data_grp = ICOADS_subset(data_ship,l_use);
            SST_in          = data_grp.C0_SST - data_grp.C0_OI_CLIM;
            [SST_group(:,:,ct_mon,ct_grp),~,N_group(:,:,ct_mon,ct_grp)] = ...
                  LME_function_gridding(data_grp.C0_LON',data_grp.C0_LAT',...
                                        [],SST_in',[],reso_x,reso_y,[],2,[],[],[]);
        end
    end
end

dir_save  = dir;
file_save = [dir_save,'Raw_SSTs_',num2str(ct_yr),'.mat'];
save(file_save,'SST_bucket','N_bucket','SST_bucket_infer','N_bucket_infer',...
    'SST_ERI','N_ERI','SST_buoy','N_buoy','SST_group','N_group','SST_buoy_full','SST_OI_clim','-v7.3');
