clear;
dir_CRUTEM5         = [CDC_other_temp_dir,'CRUTEM5/'];
Ns                  = ncread([dir_CRUTEM5,'CRUTEM.5.0.2.0.station_counts.nc'],'tas_nobs');
err_LSAT_sampling   = ncread([dir_CRUTEM5,'CRUTEM.5.0.2.0.measurement_sampling.nc'],'tas_unc');

a = err_LSAT_sampling(:,:,1:2088).^2 .* Ns(:,:,1:2088);
a = round(a,3);
sampling_base = squeeze(quantile(reshape(a,72,36,12,174),0.5,4));
sampling_base = sampling_base([37:end 1:36],:,:);

% Find the mask for grid box ever sampled, accounting for island stations
for ct1 = 1:5
    for ct2 = 1:5
        sampling_base_1X1(ct1:5:360,ct2:5:180,:) = sampling_base; 
    end
end
l_mask = ~isnan(sampling_base_1X1);

% To 1 degree resolution
P.threshold = 1;
for ct_mon = 1:12
    temp1 = CDC_interp_high_reso(2.5:5:357.5,-87.5:5:87.5,sampling_base(:,:,ct_mon),0.25:0.5:360,-89.75:0.5:90,'Land','linear');
    temp2 = CDC_interp_high_reso(2.5:5:357.5,-87.5:5:87.5,sampling_base(:,:,ct_mon),0.25:0.5:360,-89.75:0.5:90,'Ocean','linear');
    temp1(isnan(temp1)) = temp2(isnan(temp1));
    sampling_base_1X1_origin(:,:,ct_mon) = CDC_average_grid(0.25:0.5:360,-89.75:0.5:90,temp1,0.5:1:359.5,-89.5:1:89.5,P);
end

temp = CDC_interp_high_reso(2.5:5:357.5,-87.5:5:87.5,sampling_base(:,:,ct_mon),0.25:0.5:360,-89.75:0.5:90,'Land','linear');
temp = CDC_average_grid(0.25:0.5:360,-89.75:0.5:90,temp,0.5:1:359.5,-89.5:1:89.5,P);
l = ~isnan(temp);
l = repmat(l,1,1,12);
sampling_base_1X1_origin(~l_mask & ~l) = nan;

% Add buffers along coasts, this step is not necessary for land stations, 
% as land stations do not move but it should not affect the final results.
sampling_base_1X1 = sampling_base_1X1_origin;
for ct_mon = 1:12

    % Find neighboring values ---------------------------------------------
    for ct = 1:3
        sampling_base_1X1(:,:,ct_mon) = get_value_from_neighbours(sampling_base_1X1(:,:,ct_mon));
    end

    % Smoothing -----------------------------------------------------------
    for ct = 1:5
        sampling_base_1X1(:,:,ct_mon) = CDC_smooth2(sampling_base_1X1(:,:,ct_mon),5,1);
    end
end

% Replace -----------------------------------------------------------------
a = sampling_base_1X1_origin;
a(isnan(a)) = sampling_base_1X1(isnan(a));
sampling_base_1X1 = a;
sampling_base_5X5 = sampling_base;

save('Sampling_error_base_from_CRUTEM5.mat','sampling_base_5X5','sampling_base_1X1','-v7.3')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = get_value_from_neighbours(in)

    clear('Neighbor')
    for ct1 = 1:size(in,1)
        for ct2 = 1:size(in,2)
            ii = [ct1-1:ct1+1];
            jj = [ct2-1:ct2+1];
            ii(ii<1) = ii(ii<1) + size(in,1);
            ii(ii>size(in,1)) = ii(ii>size(in,1)) - size(in,1);
            jj(jj<1) = [];
            jj(jj>size(in,2)) = [];
            temp = in(ii,jj,:,:);
            if ct2 == 1
                temp(2,1,:,:) = nan;              
            else
                temp(2,2,:,:) = nan;
            end
            temp = nanmean(reshape(temp,size(temp,1)*size(temp,2),size(temp,3),size(temp,4)),1);
            Neighbor(ct1,ct2,:,:) = temp;
        end
    end
    out = in;
    out(isnan(in)) = Neighbor(isnan(in));
end