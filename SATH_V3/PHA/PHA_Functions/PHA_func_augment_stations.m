function [T_out,Lon_out,Lat_out,I] = PHA_func_augment_stations(T,SEG,Lon,Lat)

    mm              = max(SEG,[],2);
    mm(isnan(mm))   = 1;
    N               = cumsum([0; mm]);

    T_out           = nan(N(end),size(T,2));
    Lon_out         = nan(N(end),1);
    Lat_out         = nan(N(end),1);
    I               = nan(N(end),1);
    for ct = 1:size(T,1)

        if rem(ct,5000) == 0, disp(ct); end

        l           = (N(ct)+1):N(ct+1);

        % ------------------------------------------
        T_in        = T(ct,:);
        seg         = SEG(ct,:);
        T_aug       = nan(numel(l),size(T_in,2));
        n_seg       = max(seg);
        if ~isnan(n_seg)
            for ct1 = 1:max(seg)
                T_aug(ct1,seg == ct1) = T_in(seg == ct1);
            end
        end

        % ------------------------------------------

        T_out(l,:)  = T_aug;
        Lon_out(l)  = Lon(ct);
        Lat_out(l)  = Lat(ct);
        I(l)        = ct;
    end
end
