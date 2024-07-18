function nei = ICOADS_NC_function_get_neighbour ...
                        (sp,C0_LON,C0_LAT,C0_DY,WM_temp,reso_s,reso_t)

    ct = 0;
    clear('nei_temp')
    for i = [-sp:sp]
        for j = [-sp:sp]
            for k = [-sp:sp]
                if(sum(abs([i,j,k])) == sp)
                    ct = ct+1;
                    nei_temp(ct,:) = re_function_general_grd2pnt...
                        (C0_LON+i*reso_s,C0_LAT+j*reso_s,C0_DY,WM_temp(:,:,[7:12]+k),reso_s,reso_s,reso_t);
                end
            end
        end
    end
    nei = nanmean(nei_temp,1);
    
end