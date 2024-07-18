function var_clim = LME_lme_var_clim(x1,x2,y1,y2,t1,t2,mt,P)

    % ************
    % Read Data **
    % ************
    disp('Loading decorrelation rate ...')
    dir_load = LME_OI('Mis');
    if strcmp(P.varname,'SST')
        file_de = [dir_load,'OI_SST_inter_annual_decorrelation_20180316.mat'];
    else
        file_de = [dir_load,'ERA_interim_inter_annual_decorrelation_20180318.mat'];
    end
    load(file_de,'GR_lon','GR_lat','GR_tim','VAR_lon')

    GR_lon = double(GR_lon);
    GR_lat = double(GR_lat);
    GR_tim = double(GR_tim) * 1.5;
    VAR_lon = double(VAR_lon);
    clear('GR_lon_2','GR_lat_2','GR_tim_2','VAR_lon_2')

    % ******************
    % Regrid onto 2x2 **
    % ******************
    disp('Regridding decorrelation rate ...')
    for i = 1:180
        for j = 1:90
            temp = GR_lon(i*8-7:i*8,j*8-7:j*8,:);
            GR_lon_2(i,j,:) = nanmean(nanmean(temp,1),2);
            temp = GR_lat(i*8-7:i*8,j*8-7:j*8,:);
            GR_lat_2(i,j,:) = nanmean(nanmean(temp,1),2);
            temp = GR_tim(i*8-7:i*8,j*8-7:j*8,:);
            GR_tim_2(i,j,:) = nanmean(nanmean(temp,1),2);
            temp = VAR_lon(i*8-7:i*8,j*8-7:j*8,:);
            VAR_lon_2(i,j,:) = nanmean(nanmean(temp,1),2);
        end
    end

    % **********************************
    % Compute the position statistics **
    % **********************************
    disp('Computing position statistics ...')
    mx = LME_function_mean_period([x1; x2],360);
    my = nanmean([y1; y2],1);
    dx = abs(rem(x1 - x2 + 540,360)-180);
    dy = abs(y1 - y2);
    dt = abs(t1 - t2) / 24;

    % *******************
    % Get the variance **
    % *******************
    disp('Getting variance ...')
    clear('var_1','var_2','var_2_2','var_1_2')
    var_1 = LME_function_grd2pnt(x1,y1,mt,VAR_lon,0.25,0.25,1);
    var_1_2 = LME_function_grd2pnt(x1,y1,mt,VAR_lon_2,2,2,1);
    var_1(isnan(var_1)) = var_1_2(isnan(var_1));

    var_2 = LME_function_grd2pnt(x2,y2,mt,VAR_lon,0.25,0.25,1);
    var_2_2 = LME_function_grd2pnt(x2,y2,mt,VAR_lon_2,2,2,1);
    var_2(isnan(var_2)) = var_2_2(isnan(var_2));

    % *****************************
    % Get the decorrelation rate **
    % *****************************
    disp('Getting decorreltation rate ...')
    gr_lon = LME_function_grd2pnt(mx,my,mt,GR_lon,0.25,0.25,1);
    gr_lon_2 = LME_function_grd2pnt(mx,my,mt,GR_lon_2,2,2,1);
    gr_lon(isnan(gr_lon)) = gr_lon_2(isnan(gr_lon));

    gr_lat = LME_function_grd2pnt(mx,my,mt,GR_lat,0.25,0.25,1);
    gr_lat_2 = LME_function_grd2pnt(mx,my,mt,GR_lat_2,2,2,1);
    gr_lat(isnan(gr_lat)) = gr_lat_2(isnan(gr_lat));

    gr_tim = LME_function_grd2pnt(mx,my,mt,GR_tim,0.25,0.25,1);
    gr_tim_2 = LME_function_grd2pnt(mx,my,mt,GR_tim_2,2,2,1);
    gr_tim(isnan(gr_tim)) = gr_tim_2(isnan(gr_tim));

    % **************************************
    % Compute the covariance and variance **
    % **************************************
    disp('Computing climatic variance ...')
    Cor = exp(-dx.*gr_lon -dy.*gr_lat -dt.*gr_tim);
    var_clim = var_1 + var_2 - 2 * sqrt(var_1) .* sqrt(var_2) .* Cor;

end
