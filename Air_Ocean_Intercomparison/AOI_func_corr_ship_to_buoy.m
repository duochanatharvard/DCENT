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

    if size(DM2,1) == 72
        window = 1;
    else
        window = 3;
    end
    for ct1 = 1:size(DM2,1)
        for ct2 = 1:size(DM2,2)
            l1 = ct1 + [-window:window];
            l2 = ct2 + [-window:window];
            l1(l1<=0) = l1(l1<=0) + size(DM2,1);
            l1(l1>size(DM2,1)) = l1(l1>size(DM2,1)) - size(DM2,1);
            l2(l2<=0) = [];
            l2(l2>size(DM2,2)) = [];
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
