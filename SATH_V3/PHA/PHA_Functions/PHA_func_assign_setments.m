function SEG = PHA_func_assign_setments(T_comb,N_nb,N_nb_thsld,N_nan)

    if ~exist('N_nan','var'), N_nan = 240; end

    SEG         = nan(size(T_comb));
    seg_n       = ones(size(T_comb,1),1);
    flag        = false(size(T_comb,1),1);
    ct_nan      = seg_n;
    for i = 2:size(SEG,2)
        l           = isnan(T_comb(:,i));
        ct_nan(l)   = ct_nan(l) + 1;
        l           = ~isnan(T_comb(:,i)) & ct_nan >= N_nan & flag == true;
        seg_n(l)    = seg_n(l) + 1;
        l           = ~isnan(T_comb(:,i));
        SEG(l,i)    = seg_n(l);
        ct_nan(l)   = 0;
        flag(l)     = true;
    end
    clear('ct_nan','seg_n','flag','i','l')
    
    % Combine segments if both are have sufficient neighbors
    % which is considered homogeneous after groupwise homogenization ----------
    N_seg           = max(SEG,[],2);
    for ct_sta      = 1:size(SEG,1)
        if N_seg(ct_sta) > 1
            for ct_seg = (N_seg(ct_sta)-1):-1:1
                l1  = SEG(ct_sta,:) == ct_seg;
                l2  = SEG(ct_sta,:) == (ct_seg + 1);
                if  nanmean(N_nb(ct_sta,l1)) >= N_nb_thsld && ...
                    nanmean(N_nb(ct_sta,l2)) >= N_nb_thsld
                    % if both are nb-rich segments combine them
                    SEG(ct_sta,l2) = ct_seg;
                end
            end
        end
    end
    clear('ct_sta','l1','l2')
end
