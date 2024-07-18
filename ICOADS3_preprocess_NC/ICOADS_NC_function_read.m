function out = ICOADS_NC_function_read(yr,mon,var)

    dir1  = ICOADS_NC_OI('nc_files');
    dir2  = ICOADS_NC_OI('pre_QC');
    dir3  = ICOADS_NC_OI('QCed');
    dir4  = ICOADS_NC_OI('Kent_save');


    cmon = '00';  cmon(end-size(num2str(mon),2)+1:end) = num2str(mon);
    ICOADS_version = ICOADS_NC_version(yr);
    
    file1 = [dir1,'ICOADS_R',ICOADS_version,'_',...
                                               num2str(yr),'-',cmon,'.nc'];
    file2 = [dir2,'ICOADS_R',ICOADS_version,'_',...
                                         num2str(yr),'-',cmon,'_preQC.nc'];
    file3 = [dir3,'ICOADS_R',ICOADS_version,'_',...
                                          num2str(yr),'-',cmon,'_QCed.nc'];
    file4 = [dir4,'ICOADS_R',ICOADS_version,'_',...
                                   num2str(yr),'-',cmon,'_Tracks_Kent.nc'];
                                     
    if any(ismember(var,'_')) && ...
            (var(1) == 'C' && var(2) >= '0' && var(2) <= '9')
        var = var(find(var == '_',1)+1:end);
    end
                                     
    % read data from files
    try 
        out = ncread(file4,var);
    catch
        try
            out = ncread(file3,var);
        catch
            try
                out = ncread(file2,var);
            catch
                out = ncread(file1,var);
            end
        end
    end
    
    out = double(out);
    
    if strcmp(var,'DY')
        out(out == 0) = nan;
    end
    
end
    
    