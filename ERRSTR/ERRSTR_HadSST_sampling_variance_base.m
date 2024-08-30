clear;
dir_HadSST4         = [CDC_other_temp_dir,'HadSST4/'];
Ns                  = ncread([dir_HadSST4,...
    'HadSST.4.0.1.0_number_of_superobservations.nc'],'numsuperobs');
err_SST_sampling    = ncread([dir_HadSST4,...
    'HadSST.4.0.1.0_sampling_uncertainty.nc'],'tos_unc');

a = err_SST_sampling(:,:,1:2090).^2 .* Ns(:,:,1:2090);
a = round(a,3);

sampling_base = nan(72,36);
for ctx = 1:72
    for cty = 1:36
        temp              = squeeze(a(ctx,cty,:));
        temp(isnan(temp)) = [];
        if ~isempty(temp)
            l_same(ctx,cty)   = numel(unique(temp)) == 1;
            sampling_base(ctx,cty) = unique(nanmean(temp));
        end
    end
end

sampling_base(sampling_base > 30) = 30;
sampling_base = sampling_base([37:end 1:36],:);

P.threshold = 1;
temp = CDC_interp_high_reso(2.5:5:357.5,-87.5:5:87.5,sampling_base,0.25:0.5:360,-89.75:0.5:90,'Ocean','linear');
sampling_base_1X1_origin = CDC_average_grid(0.25:0.5:360,-89.75:0.5:90,temp,0.5:1:359.5,-89.5:1:89.5,P);

% Find neighboring values -------------------------------------------------
sampling_base_1X1 = sampling_base_1X1_origin;
for ct = 1:3
    sampling_base_1X1 = get_value_from_neighbours(sampling_base_1X1);
end

% Smoothing ---------------------------------------------------------------
for ct = 1:5
    sampling_base_1X1 = CDC_smooth2(sampling_base_1X1,5,1);
end

% Replace -----------------------------------------------------------------
a = sampling_base_1X1_origin;
a(isnan(a)) = sampling_base_1X1(isnan(a));
sampling_base_1X1 = a;
sampling_base_5X5 = sampling_base;

save('Sampling_error_base_from_HadSST4.mat','sampling_base_5X5','sampling_base_1X1','-v7.3')

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