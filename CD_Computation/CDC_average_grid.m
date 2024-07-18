% field_out = CDC_average_grid(lon_high,lat_high,field_in,lon_target,lat_target,P)
function field_out = CDC_average_grid(lon_high,lat_high,field_in,lon_target,lat_target,P)

    % Averaging from a fine regular grid to a coarse regular grid
    if size(lon_high,1) ~= 1, lon_high = lon_high'; end
    if size(lat_high,1) ~= 1, lat_high = lat_high'; end
    
    temp = field_in(:,:,1);
    if any(isnan(temp(:)))
        field_type = 'Miss';
    else
        field_type = 'Full';
    end
    
    if min(size(lon_high)) > 1
        lon_high = lon_high(:,1);
        lat_high = lat_high(1,:);
    end
    
    if ~exist('P','var')
        P.threshold = 0.5;
    end
    
    reso_lon = abs(mode(diff(lon_target,[],2)));
    reso_lat = abs(mode(diff(lat_target,[],2)));
    
    if strcmp(field_type,'Full')
        
        field_inter = nan(numel(lon_target),numel(lat_high),size(field_in,3));
        field_out   = nan(numel(lon_target),numel(lat_target),size(field_in,3));
        
        for ct_lon = 1:numel(lon_target)
            
            l_lon = lon_high >= (ct_lon-1) * reso_lon & ...
                lon_high < (ct_lon) * reso_lon;
            
            field_inter(ct_lon,:,:) = nanmean(field_in(l_lon,:,:),1);
        end

        for ct_lat = 1:numel(lat_target)
            
            l_lat = lat_high >= (ct_lat-1) * reso_lat - 90 & ...
                lat_high < (ct_lat) * reso_lat - 90;

            temp     = field_inter(:,l_lat,:);
            lat_temp = repmat(lat_high(l_lat),size(field_inter,1),1,size(field_inter,3));
            weigh    = cos(lat_temp*pi/180);
            
            field_out(:,ct_lat,:) = nansum(temp .* weigh,2) ./ nansum(weigh,2);
        end
        
    elseif strcmp(field_type,'Miss')
        
        mask_invalid = all(isnan(field_in),3);
        field_out = nan(numel(lon_target),numel(lat_target),size(field_in,3));
        
        for ct_lon = 1:numel(lon_target)
            for ct_lat = 1:numel(lat_target)
                
                l_lon = lon_high >= (ct_lon-1) * reso_lon & ...
                    lon_high < (ct_lon) * reso_lon;
                
                l_lat = lat_high >= (ct_lat-1) * reso_lat - 90 & ...
                    lat_high < (ct_lat) * reso_lat - 90;
                
                invalid_temp  = mask_invalid(l_lon,l_lat,:);
                
                if nnz(invalid_temp(:))/numel(invalid_temp(:)) < P.threshold
                    
                    temp      = field_in(l_lon,l_lat,:);
                    lat_temp  = repmat(lat_high(l_lat),size(temp,1),1,size(field_in,3));
                    weigh     = cos(lat_temp*pi/180);
                    l         = repmat(invalid_temp,1,1,size(field_in,3));
                    weigh(l == 1) = 0;
                    
                    field_out(ct_lon,ct_lat,:) = nansum(nansum(temp .* weigh,1),2) ./ nansum(nansum(weigh,1),2);
                end
            end
        end
    end
end

