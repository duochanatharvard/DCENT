function SST_corr_taper = AOI_func_correct_SST_1X1(MLR_b_taper, SST_obs)

    % Load the pattern of bucket models -----------------------------------
    solar_shading = 0.5;
    file_pattern  = [...
        'spatial_pattern_1x1_bucket_bias_solar_exposure_',num2str(1-solar_shading),'.mat'];
    load(file_pattern,'Bucket_bias_pattern');

    % Generate corrections ------------------------------------------------
    pattern_masked   = repmat(Bucket_bias_pattern,1,1,1,size(SST_obs,4));
    pattern_masked(isnan(SST_obs)) = nan;
    bias_taper_reshp = reshape(MLR_b_taper,1,1,1,size(SST_obs,4),size(MLR_b_taper,2));
    Corr_taper       = - (pattern_masked .* bias_taper_reshp(:,:,:,:,1) + bias_taper_reshp(:,:,:,:,2));
    SST_corr_taper   = SST_obs + Corr_taper;    

end
