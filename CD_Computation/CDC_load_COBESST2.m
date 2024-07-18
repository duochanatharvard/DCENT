% [COBESST2,lon,lat,yr] = CDC_load_COBESST2(en)
% if en exist :: use regridded data

function [COBESST2,lon,lat,yr] = CDC_load_COBESST2(en)

    dir    = [CDC_other_temp_dir,'CobeSST2/'];
    
    if ~exist('en','var')
        
        file   = [dir,'sst.mon.mean.nc'];
        COBESST2 = ncread(file,'sst');
        lon    = ncread(file,'lon');
        lat    = ncread(file,'lat');
        COBESST2(COBESST2>1000) = nan;
        
        COBESST2 = COBESST2(:,end:-1:1,:);
        lat    = lat(end:-1:1);
        if rem(size(COBESST2,3),12) == 0
            Nt  = size(COBESST2,3);
        else
            Nt  = ceil(size(COBESST2,3)/12)*12;
            COBESST2(:,:,(end+1):Nt) = nan;
        end
        COBESST2 = reshape(COBESST2(:,:,1:Nt),size(COBESST2,1),size(COBESST2,2),12,Nt/12);
        yr     = [1:Nt/12]+1849;
        
    else
        lon  = 2.5:5:360;
        lat  = -87.5:5:90;
        file = [dir,'COBESST_5x5_regridded.mat'];
        if ~isfile(file)
            [sst,lon_high,lat_high,yr] = CDC_load_COBESST2;
            P.threshold = 1;
            sst = CDC_average_grid(lon_high',lat_high',sst(:,:,:),lon,lat,P);
            sst = reshape(sst,size(sst,1),size(sst,2),12,size(sst,3)/12);
            save(file,'sst','yr','-v7.3');
        else
            load(file);
        end
        COBESST2 = sst - nanmean(sst(:,:,:,[1982:2014]-1849),4);
    end

    [yr_start,yr_end] = CDC_common_time_interval;
    [COBESST2, yr] = CDC_trim_years(COBESST2, yr, yr_start, yr_end);
end