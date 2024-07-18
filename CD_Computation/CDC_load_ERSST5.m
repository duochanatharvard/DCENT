% [ERSST5,lon,lat,yr] = CDC_load_ERSST5(en)
% When en is missing, read 2x2 data
% When en is zero, read 5x5 data
% When en >=1 and <= 1000, read 5x5 ensemble member

function [ERSST5,lon,lat,yr] = CDC_load_ERSST5(en)

    % ERSST5
    dir    = [CDC_other_temp_dir,'ERSST5/'];
    
    if ~exist('en','var')

        file = [dir,'sst.mnmean.nc'];

        ERSST5 = ncread(file,'sst');
        lon    = ncread(file,'lon');
        lat    = ncread(file,'lat');
        ERSST5(ERSST5<-100) = nan;
        ERSST5 = ERSST5(:,end:-1:1,:);
        lat    = lat(end:-1:1);
        if rem(size(ERSST5,3),12) == 0
            Nt  = size(ERSST5,3);
        else
            Nt  = ceil(size(ERSST5,3)/12)*12;
            ERSST5(:,:,(end+1):Nt) = nan;
        end
        ERSST5 = reshape(ERSST5(:,:,1:Nt),size(ERSST5,1),size(ERSST5,2),12,Nt/12);
        yr     = [1:Nt/12]+1853;
        
    else
        lon = 2.5:5:360;
        lat = -87.5:5:90;
        
        if en == 0
            
            file = [dir,'ERSST5_5x5_regridded.mat'];
            
            if ~isfile(file)
                
                [sst,lon_high,lat_high,yr] = CDC_load_ERSST5;
                P.threshold = 1;
                sst = CDC_average_grid(lon_high',lat_high',sst(:,:,:),lon,lat,P);
                sst = reshape(sst,size(sst,1),size(sst,2),12,size(sst,3)/12);
                save(file,'sst','yr','-v7.3');
            else    
                load(file);
            end
            ERSST5 = sst - nanmean(sst(:,:,:,[1982:2014]-1853),4);

        else
            file = [dir,'ERSST5_EN_processed/ERSST5_regrid_5X5_1854_2017_ensemble_',num2str(en),'.mat'];
            load(file);
            ERSST_regrid = reshape(ERSST_regrid,72,36,12,164);
            ERSST5 = ERSST_regrid - nanmean(ERSST_regrid(:,:,:,[1982:2014]-1853),4);
            yr  = 1854:2017;
            
        end
    end

    [yr_start,yr_end] = CDC_common_time_interval;
    [ERSST5, yr] = CDC_trim_years(ERSST5, yr, yr_start, yr_end);
end