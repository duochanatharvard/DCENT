function [SST_ship_ref_buoy,SST_buoy_ref_ship] = ...
              AOI_func_corr_ship_to_buoy(SST_ship,SST_buoy,N_ship,N_buoy)

    W0  = (N_ship .* N_buoy) ./ (6*N_buoy + N_ship);
    D0  = SST_ship - SST_buoy;
    DM  = nansum(W0.*D0,4) ./ nansum(W0,4);
    W1  = nansum(W0,4);
    for ct = 1:12
        l = ct + [-1:1];
        l(l<=0) = l(l<=0) + 12;
        l(l>12) = l(l>12) - 12;
        W = W1(:,:,l);
        D = DM(:,:,l);
        DM2(:,:,ct) = nansum(W.*D,3)./nansum(W,3);
        W2(:,:,ct)  = nansum(W,3);
    end

    for ct1 = 1:72
        for ct2 = 1:36
            l1 = ct1 + [-1:1];
            l2 = ct2 + [-1:1];
            l1(l1<=0) = l1(l1<=0) + 72;
            l1(l1>72) = l1(l1>72) - 72;
            l2(l2<=0) = [];
            l2(l2>35) = [];
            D = DM2(l1,l2,:);
            W = W2(l1,l2,:);
            DM3(ct1,ct2,:) = nansum(nansum(W.*D,1),2) ./ nansum(nansum(W,1),2);
        end
    end
    DM3(isnan(DM3)) = 0;
    % DM3(isnan(DM2)) = nan;

    SST_ship_ref_buoy = SST_ship - DM3;
    SST_buoy_ref_ship = SST_buoy + DM3;
end
