% P_out = ICOADS_read(P)
% 
% var: a string or a cell list of strings
%       The function will omit 'CX_' when reading data
% ref: 'SST' or 'NMAT' or 'None'(shortcut '-')  -->  default: 'SST'
% 
% The function does the following adjustments to variables:
% 1. SST method 7 & 9 -> -1
% 2. Generic ID -> '         '
% 
% The function also provides the following options
% 1. Subset outputs according to UIDs     (P.select_UID = list_of_UIDs)
% 2. Load clim of Diurnal SSTs from buoys (P.buoy_diurnal = 1)
% 
% Last updata: 2021-06-24
% 
% Useage need to further subset data, e.g., only using bucket measurements:
% 
% P.var = {'C0_SST','C0_LON','C0_LAT','C0_YR','SI_Std'}; 
% P.yr = 1930; P.mon = 1; P.ref = 'SST'; P.select_UID = [];
% Data = ICOADS_read(P);
% l_use = Data.SI_Std == 0;
% [Data_use,var_list] = ICOADS_subset(Data,l_use);
% 
% 
% In addition to standard ICOADS outputs, below are a list of variables 
% That are also frequently used by the LME analysis
% 
% UTC:           Universial Time (hours since 0001-01-01 00:00)
% YR/MO/DY:      Year/Month/Day
% LCL:           Local time
% LCL_int:       Local time rounded to the nearest integer
% UID:           Universial ID aved as a double number rather than a string
% CTY_CRT:       Corrected country information
% OI_CLIM:       SST climatology
% SI_Std:        SST method without inference
% SI_K12:        SST method inferred following Kennedy et al. (2012b)
% ERA_CLIM:      Air temperature climatology
% NMAT:          Nighttime marine air tempearutres corrected for WWII
% QC_FINAL_SST:  QC of SST after using flags and buddy check
% QC_FINAL_NMAT: QC of NMAT after using flags and buddy check and Kent13
% ID_Kent:       ID of tracked ships from Carrela17

function P_out = ICOADS_read(P)

    % Parse input ---------------------------------------------------------
    yr = P.yr;
    mon = P.mon;
    if isfield(P,'var') 
        var = P.var;  
    else
        var = {'C0_LON','C0_LAT','C0_UTC','SI_Std','C1_DCK','C0_CTY_CRT',...
               'C1_PT','C0_SST','C0_OI_CLIM','C98_UID'};  
    end
    if isfield(P,'buoy_diurnal')
        if P.buoy_diurnal == 1 && ~isfield(P,'LCL_int')
            var{end+1} = 'LCL_int';  flag_lcl = 0;
        else
            flag_lcl = 1;
        end
    end
    if isfield(P,'ref'), ref = P.ref;  else, ref = 'SST'; end
    if strcmp(ref,'-'),        ref = 'None';   end
    if isfield(P,'select_UID'), select_UID = P.select_UID;  else, select_UID = []; end
    
    var_out  = var;  % name of variables in outputs
    var_look = var;  % name of variables when loading files (look up)

    % Longitude and Latitude are stored in lower case in NC files ---------
    if ~iscell(var_look)
        if ismember(var_look,{'LON','LAT'}),  var_look = lower(var_look);  end
        if ismember(var_look,{'C0_LON'}),     var_look = 'lon';  end
        if ismember(var_look,{'C0_LAT'}),     var_look = 'lat';  end
    else
        for ct_var = 1:numel(var_look)
            if ismember(var_look{ct_var},{'LON','LAT'})
                var_look{ct_var} = lower(var_look{ct_var});  
            end
            if ismember(var_look{ct_var},{'C0_LON'})     
                var_look{ct_var} = 'lon';  
            end
            if ismember(var_look{ct_var},{'C0_LAT'})     
                var_look{ct_var} = 'lat';  
            end
        end
    end
    
    % Read data from target files -----------------------------------------
    clear('P_out')
    if ~iscell(var)
        eval(['P_out.',var_out,' = ICOADS_NC_function_read(yr,mon,''',var_look,''');']);
    else
        for ct_var = 1:numel(var)
            var_out_temp = var_out{ct_var};
            var_look_temp = var_look{ct_var};
            eval(['P_out.',var_out_temp,...
                ' = ICOADS_NC_function_read(yr,mon,''',var_look_temp,''');']);
        end
    end
    
    % Read quality control flags ------------------------------------------
    if strcmp(ref,'SST')
        l_use = ICOADS_NC_function_read(yr,mon,'QC_FINAL_SST') == 1;
    elseif strcmp(ref,'NMAT')
        l_use = ICOADS_NC_function_read(yr,mon,'QC_FINAL_NMAT') == 1;
    elseif strcmp(ref,'None')
        l_use = true(size(out));
    end
    
    % Subset data for outputs ---------------------------------------------
    [P_out,~] = ICOADS_subset(P_out,l_use);
    var_list = fieldnames(P_out);

    % If measurement method is read, assign 7 and 9 to be unknown ---------
    if isfield(P_out,'SI_Std')
        P_out.SI_Std(P_out.SI_Std == 7 | P_out.SI_Std == 9) = -1;
    end
    if isfield(P_out,'SI_K12')
        P_out.SI_K12(P_out.SI_K12 == 7 | P_out.SI_K12 == 9) = -1;
    end
    
    % remove generic IDs that are not useful for any analyses -------------
    if any(ismember(var_list,{'C0_ID','ID'}))
        
        bad_ID_list = ['0120     ';'SHIP     ';'PLAT     '; 'RIGG     '; 
                       'MASKST   ';'1        ';'58       '; '7        ';
                       'MASKSTID '];
        try
            temp = P_out.C0_ID;
            l = ismember(temp,bad_ID_list,'rows');
            P_out.C0_ID(l,:) = 32;
        catch
            temp = P_out.ID;
            l = ismember(temp,bad_ID_list,'rows');
            P_out.ID(l,:) = 32;
        end
    end
    
    % If UID for subsetting specific data is assigned ---------------------
    if ~isempty(select_UID)
        var_list = fieldnames(P_out);
        [~,pst] = ismember(select_UID,P_out.C98_UID);

        for ct_var = 1:numel(var_list)
            eval(['P_out.',var_list{ct_var},' = P_out.',var_list{ct_var},'(pst,:);']);
        end
    end

    % If we are to find the clim of dirunal cycle from buoy ---------------
    if isfield(P,'buoy_diurnal')
        if P.buoy_diurnal == 1
            
            dir_da = ICOADS_NC_OI('Mis');
            load([dir_da,'Diurnal_Amplitude_buoy_SST_1990_2014_climatology.mat'],'Diurnal_clim_buoy_1990_2014');
            load([dir_da,'Diurnal_Shape_buoy_SST.mat'],'Diurnal_Shape');
            
            DA_mgntd  = LME_function_grd2pnt(P_out.C0_LON,P_out.C0_LAT,...
                ones(size(P_out.C0_LON))*P.mon,Diurnal_clim_buoy_1990_2014,5,5,1);
            Y = fix((P_out.C0_LAT+90)/5)+1;  Y(Y>36)=36;
            P_out.LCL_int(isnan(P_out.LCL_int)) = 1;
            
            DASHP_id = sub2ind(size(Diurnal_Shape), ...
                       P_out.LCL_int, Y, ones(size(P_out.C0_LON))*P.mon);
            DA_shape = Diurnal_Shape(DASHP_id);
            
            P_out.Buoy_Diurnal = DA_shape .* DA_mgntd;
            P_out.Buoy_Diurnal(isnan(P_out.Buoy_Diurnal)) = 0;
            
            if flag_lcl == 0
                P_out = rmfield(P_out,'LCL_int');
            end   
        end
    end
end
    
    