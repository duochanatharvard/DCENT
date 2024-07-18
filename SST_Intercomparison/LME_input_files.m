% file = LME_input_files(input,P)
% Specify which input files are used:
% LME_input_files:
% >> SAT     :: Land Station Temperatures
% >> Pattern :: Bias_pattern
% >> ASerror :: Air-Sea Variance


function file = LME_input_files(input,P)

    % =====================================================================
    if strcmp(input,'SAT')
        file     = [LME_OI('Mis'),'Station_monthly_T_anomalies_20210831_do_season_',num2str(P.do_season),'.mat'];
        
    % =====================================================================
    elseif strcmp(input,'Pattern')
        if ~isfield(P,'pattern_sens')
            file = [LME_OI('Mis'),'spatial_pattern_bucket_bias.mat'];
        else
            switch P.pattern_sens
                case 1
                    file = [LME_OI('Mis'),'spatial_pattern_bucket_bias_solar_exposure_0.5.mat'];
                case 2
                    file = [LME_OI('Mis'),'spatial_pattern_bucket_bias_solar_exposure_0.mat'];
                case 3
                    file = [LME_OI('Mis'),'spatial_pattern_bucket_bias_solar_exposure_1.mat'];
                case 4
                    file = [LME_OI('Mis'),'spatial_pattern_bucket_bias_solar_exposure_0.5_RH_adjusted.mat'];
            end
        end
    % =====================================================================
    elseif strcmp(input,'ASerror')
        file = [LME_OI('Mis'),'CMIP6_coastal_air_sea_diff_interannual_variance_do_season_',num2str(P.do_season),'.mat'];
       
    % ===================================================================== 
    end
end