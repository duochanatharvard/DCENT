function C0_NB = ICOADS_NC_function_get_all_neighbors(file_load_wm,varname,C0_LON,C0_LAT,C0_DY,reso_s,reso_t)

    clear('WM_temp','NUM_temp')
    WM_temp  = NaN(360/reso_s,180/reso_s,90/reso_t);
    NUM_temp = NaN(360/reso_s,180/reso_s,90/reso_t);
    for i=1:size(file_load_wm,1)
        ff = [file_load_wm(i,1:end-4),'_',varname,file_load_wm(i,end-3:end)];
        disp(ff)
        fid=fopen(ff,'r');
        if(fid>0)
           clear('WM','NUM')
           fclose(fid);
           load(ff,'WM','NUM');
           WM_temp(1:360/reso_s,1:180/reso_s,(i-1)*(30/reso_t)+1:i*(30/reso_t))=WM;
           NUM_temp(1:360/reso_s,1:180/reso_s,(i-1)*(30/reso_t)+1:i*(30/reso_t))=NUM;
        end
    end
    clear('NUM','WM')
    WM_temp(NUM_temp == 1) = NaN;

    % Find Neighbours =====================================================
    clear('nei_0','nei_1','nei_2','nei_3')
    % Read Neighbours at this grid box ------------------------------------
    nei_0 = re_function_general_grd2pnt(C0_LON,C0_LAT,C0_DY,WM_temp(:,:,7:12),reso_s,reso_s,reso_t);
    % N_nei_0 = re_function_general_grd2pnt(C0_LON,C0_LAT,C0_DY,NUM_temp(:,:,7:12),reso_s,reso_s,reso_t);
    % nei_0(N_nei_0 == 1) = NaN;
    % Span out level 1 ----------------------------------------------------
    nei_1 = ICOADS_NC_function_get_neighbour(1,C0_LON,C0_LAT,C0_DY,WM_temp,reso_s,reso_t); nei_1 = nei_1(:);
    % Span out level 2 ----------------------------------------------------
    nei_2 = ICOADS_NC_function_get_neighbour(2,C0_LON,C0_LAT,C0_DY,WM_temp,reso_s,reso_t); nei_2 = nei_2(:);
    % Span out level 3 ----------------------------------------------------
    nei_3 = ICOADS_NC_function_get_neighbour(3,C0_LON,C0_LAT,C0_DY,WM_temp,reso_s,reso_t); nei_3 = nei_3(:);

    nei_1(~isnan(nei_0)) = NaN;
    nei_2(~isnan(nei_0) | ~isnan(nei_1)) = NaN;
    nei_3(~isnan(nei_0) | ~isnan(nei_1) | ~isnan(nei_2)) = NaN;
    C0_NB = nanmean([nei_0 nei_1 nei_2 nei_3],2);
    clear('nei_0','nei_1','nei_2','nei_3')

end