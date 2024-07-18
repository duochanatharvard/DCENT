% ICOADS_NC_Step_02_WM(yr, mon, id, redo)
%
%  The following function computes the winsorized mean of SST on one degree
%  and pentad (5-day) resolution grids. Here, the winsorized mean cuts off
%  at 25% and 75% quantile of samples in individual grids.
%
% Last update: 2024-04-10

function ICOADS_NC_Step_02_WM(yr, mon, id, redo)

    if ~exist('redo','var'), redo = 1; end

    if ~exist('id','var')
        varname = 'SST';
    elseif id == 1
        varname = 'SST';
    else
        varname = 'NMAT';
    end

    % recommend to use nansum that returns nan rather than 0 when inputs are all nan
    % addpath('/n/home10/dchan/Matlab_Tool_Box/')

    % Set direcotry of files  ---------------------------------------------
    dir_save  = ICOADS_NC_OI('WM');
    cmon = '00';  cmon(end-size(num2str(mon),2)+1:end) = num2str(mon);
    if strcmp(varname,'SST')
        file_save = [dir_save,'ICOADS_R3.0.0_',num2str(yr),'-',cmon,'_WM_',varname,'.mat'];
    else
        file_save = [dir_save,'ICOADS_R3.0.0_',num2str(yr),'-',cmon,'_WM_',varname,'.mat'];
    end

    if ~isfile(file_save) || redo == 1
        % Target output file does not exist or redo the analysis
        % Compute winsorized mean   -------------------------------------------
        if strcmp(varname,'SST')
    
            C0_YR      = ICOADS_NC_function_read(yr,mon,'YR');
            C0_DY      = ICOADS_NC_function_read(yr,mon,'DY');
            C0_LON     = ICOADS_NC_function_read(yr,mon,'lon');
            C0_LAT     = ICOADS_NC_function_read(yr,mon,'lat');
            C0_SST     = ICOADS_NC_function_read(yr,mon,'SST');
            C0_OI_CLIM = ICOADS_NC_function_read(yr,mon,'OI_CLIM');
            QC_NON_SST = ICOADS_NC_function_read(yr,mon,'QC_NON_SST');
            C1_SF      = ICOADS_NC_function_read(yr,mon,'SF');
            C1_SNC     = ICOADS_NC_function_read(yr,mon,'SNC');
            C1_ZNC     = ICOADS_NC_function_read(yr,mon,'ZNC');
    
            C0_QC_ME_1 = QC_NON_SST == 1 & ((C0_SST > (C0_OI_CLIM-10)) & (C0_SST < (C0_OI_CLIM+10)));
            C0_QC_ME_1(C0_SST > 37 | C0_SST < -5) = 0;
            C0_QC_ME_1(C1_SNC > 5) = 0;
            C0_QC_ME_1(C1_ZNC > 5 & C0_YR > 1859) = 0;
    
            clear('in_var','in_lon','in_lat','in_dy');
            in_var = C0_SST(C0_QC_ME_1) - C0_OI_CLIM(C0_QC_ME_1);
            in_lon = C0_LON(C0_QC_ME_1);
            in_lat = C0_LAT(C0_QC_ME_1);
            in_day = C0_DY(C0_QC_ME_1);
    
        elseif strcmp(varname,'NMAT')
    
            C0_YR       = ICOADS_NC_function_read(yr,mon,'YR');
            C0_DY       = ICOADS_NC_function_read(yr,mon,'DY');
            C0_LON      = ICOADS_NC_function_read(yr,mon,'lon');
            C0_LAT      = ICOADS_NC_function_read(yr,mon,'lat');
            C0_AT       = ICOADS_NC_function_read(yr,mon,'AT');
            C0_ERA_CLIM = ICOADS_NC_function_read(yr,mon,'ERA_CLIM');
            QC_NON_AT   = ICOADS_NC_function_read(yr,mon,'QC_NON_AT');
            C1_AF       = ICOADS_NC_function_read(yr,mon,'AF');
            C1_ANC      =  ICOADS_NC_function_read(yr,mon,'ANC');
            C1_ZNC      = ICOADS_NC_function_read(yr,mon,'ZNC');
            C1_ND       = ICOADS_NC_function_read(yr,mon,'ND');
            C1_DCK      = ICOADS_NC_function_read(yr,mon,'DCK');
            C1_PT       = ICOADS_NC_function_read(yr,mon,'PT');
    
            C0_QC_ME_1 = QC_NON_AT == 1 & ((C0_AT > (C0_ERA_CLIM-10)) & (C0_AT < (C0_ERA_CLIM+10)));
            C0_QC_ME_1(C1_ANC > 5) = 0;
            C0_QC_ME_1(C1_ZNC > 5 & C0_YR > 1859) = 0;
            [C0_QC_ME_1,C0_AT] = ICOADS_NC_function_get_NMAT(yr,mon,...
                            C0_LON,C0_LAT,C0_AT,C0_QC_ME_1,C1_DCK,C1_PT,C1_ND);
    
            clear('in_var','in_lon','in_lat','in_dy');
            in_var = C0_AT(C0_QC_ME_1) - C0_ERA_CLIM(C0_QC_ME_1);
            in_lon = C0_LON(C0_QC_ME_1);
            in_lat = C0_LAT(C0_QC_ME_1);
            in_day = C0_DY(C0_QC_ME_1);
        end
    
        if (isempty(in_var) == 0)
            clear('var_grd')
            [var_grd,~] = re_function_general_pnt2grd_3d(in_lon,in_lat,in_day,in_var,[],1,1,5,2,'pentad');
            % [var_grd,~] = re_function_general_pnt2grd_3d(in_lon,in_lat,in_day,in_var,[],5,5,5,2,'pentad');
            [WM,ST,NUM] = ICOADS_NC_function_WM(var_grd);
        else
            WM  = NaN(360,180,6);
            ST  = NaN(360,180,6);
            NUM = NaN(360,180,6);
        end
    
        clear('in_var','in_lon','in_lat','in_dy');
        save([file_save],'WM','ST','NUM','-v7.3');
    
        disp([file_save ,' is finished!']);
        disp([' ']);
    else
        disp('Target File exist, skip...');
    end
end
