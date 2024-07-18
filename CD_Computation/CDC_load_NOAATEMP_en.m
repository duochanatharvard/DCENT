% [NOAATEMP, yr] = CDC_load_NOAATEMP_en(en)

function [NOAATEMP, lon, lat, yr] = CDC_load_NOAATEMP_en(en)

    dir         = [CDC_other_temp_dir,'NOAAGT_ensemble/'];
    file_path   = [dir,'temp.ano.merg5.dat.',sprintf('%04d',en)];

    data        = load_data(file_path);
    
    if rem(size(data,3),12) == 0
        Nt      = size(data,3);
    else
        Nt      = ceil(size(data,3)/12)*12;
        data(:,:,(end+1):Nt) = nan;
    end
    
    data        = reshape(data(:,:,1:Nt),size(data,1),size(data,2),12,Nt/12);
    yr          = [1:Nt/12]+1849;
    
    [yr_start,yr_end] = CDC_common_time_interval;
    [NOAATEMP, yr]    = CDC_trim_years(data, yr, yr_start, yr_end);

    lon         = 2.5:5:87.5;
    lat         = -87.5:5:87.5;

end

function data = load_data(file_path)
    fid         = fopen(file_path, 'rb', 'ieee-be');
    rows        = 72;
    cols        = 36;
    num_records = 2008;
    data        = fread(fid, (rows*cols+2) * num_records, 'real*4');
    fclose(fid);
    
    data        = reshape(data, rows*cols+2, num_records);
    data        = data(2:end-1,:);
    data        = reshape(data, rows, cols, num_records);
end


