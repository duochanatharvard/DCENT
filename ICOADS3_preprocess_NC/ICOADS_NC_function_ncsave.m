function ICOADS_NC_function_ncsave(file_save,var_name,data,type)

    N_meas = size(data,1);
    
    if ~exist('type','var'),   type = 'double';    end
    if isempty(type),          type = 'double';    end
    if ismember(type,{'single','double'}), FillValue = -9999; end
    if strcmp(type,'int16'), FillValue = -99; end
    
    if size(data,2) == 1
        nccreate(file_save,var_name,'Dimensions', {'obs',N_meas},...
             'Datatype',type,'FillValue',FillValue,'Format','netcdf4');
    else
        nccreate(file_save,var_name,'Dimensions', {'obs',N_meas,[var_name,'_len'],size(data,2)},...
             'Datatype',type,'FillValue','disable','Format','netcdf4');
    end
    ncwrite(file_save,var_name,data);

end